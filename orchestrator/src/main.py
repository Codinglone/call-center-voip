"""SipForge Orchestrator - FastAPI Service.

Manages call routing between Asterisk ARI and chatbot services.
Implements a record -> process -> play loop for voice conversations.
"""

import asyncio
import json
import os
import uuid
from contextlib import asynccontextmanager
from pathlib import Path

import httpx
import redis.asyncio as redis
import websockets
from fastapi import FastAPI
from fastapi.responses import JSONResponse

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379")
ENGLISH_BOT_URL = os.getenv("ENGLISH_BOT_URL", "http://english-bot:8001")
KINYARWANDA_BOT_URL = os.getenv("KINYARWANDA_BOT_URL", "http://kinyarwanda-bot:8002")

ARI_HTTP_URL = os.getenv("ARI_URL", "http://asterisk:8088/ari")
ARI_WS_URL = ARI_HTTP_URL.replace("http://", "ws://").replace("https://", "wss://")
ARI_APP = os.getenv("ARI_APP", "chatbot-en")
ARI_USER = os.getenv("ARI_USER", "asterisk")
ARI_PASS = os.getenv("ARI_PASS", "changeme")
ARI_AUTH = (ARI_USER, ARI_PASS)

RECORDINGS_PATH = Path(os.getenv("RECORDINGS_PATH", "/shared/recordings"))
SOUNDS_PATH = Path(os.getenv("SOUNDS_PATH", "/shared/sounds"))

# Ensure directories exist
RECORDINGS_PATH.mkdir(parents=True, exist_ok=True)
SOUNDS_PATH.mkdir(parents=True, exist_ok=True)

redis_client: redis.Redis | None = None


# ---------------------------------------------------------------------------
# ARI Helpers
# ---------------------------------------------------------------------------
async def ari_post(path: str, json_data: dict | None = None) -> dict:
    """POST to Asterisk ARI HTTP API."""
    url = f"{ARI_HTTP_URL}{path}"
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(url, auth=ARI_AUTH, json=json_data)
        resp.raise_for_status()
        return resp.json() if resp.content else {}


async def ari_delete(path: str) -> None:
    """DELETE to Asterisk ARI HTTP API."""
    url = f"{ARI_HTTP_URL}{path}"
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.delete(url, auth=ARI_AUTH)
        if resp.status_code != 404:
            resp.raise_for_status()


# ---------------------------------------------------------------------------
# Call Session Manager
# ---------------------------------------------------------------------------
class CallSession:
    """Manages the conversation loop for a single ARI channel."""

    def __init__(self, channel_id: str):
        self.channel_id = channel_id
        self.recording_name = f"user_{channel_id}"
        self.bot_sound_name = f"bot_{channel_id}"
        self.active = True

    async def on_stasis_start(self) -> None:
        """Called when channel enters Stasis. Start the conversation loop."""
        print(f"[ari] Call started: {self.channel_id}")
        # Answer the channel
        await ari_post(f"/channels/{self.channel_id}/answer")
        await self._start_recording()

    async def on_recording_finished(self) -> None:
        """Called when user finishes speaking. Send to bot and play response."""
        if not self.active:
            return

        recording_wav = RECORDINGS_PATH / f"{self.recording_name}.wav"
        if not recording_wav.exists():
            print(f"[ari] Recording not found: {recording_wav}")
            await self._hangup()
            return

        try:
            # Send recording to English bot
            bot_wav = SOUNDS_PATH / f"{self.bot_sound_name}.wav"
            async with httpx.AsyncClient(timeout=60.0) as client:
                with open(recording_wav, "rb") as f:
                    resp = await client.post(
                        f"{ENGLISH_BOT_URL}/process",
                        files={"audio": ("user.wav", f, "audio/wav")},
                    )
                resp.raise_for_status()

                # Save bot response
                with open(bot_wav, "wb") as f:
                    f.write(await resp.aread())

                stt_text = resp.headers.get("x-stt-text", "")
                llm_reply = resp.headers.get("x-llm-reply", "")
                print(f"[ari] STT: {stt_text} | Bot: {llm_reply}")

            # Play bot response on channel
            await ari_post(
                f"/channels/{self.channel_id}/play",
                json_data={"media": f"sound:{self.bot_sound_name}"},
            )

        except Exception as e:
            print(f"[ari] Error processing call {self.channel_id}: {e}")
            await self._hangup()

    async def on_playback_finished(self) -> None:
        """Called when bot response finishes playing. Start recording again."""
        if self.active:
            await self._start_recording()

    async def on_channel_hangup(self) -> None:
        """Called when user hangs up."""
        print(f"[ari] Call ended: {self.channel_id}")
        self.active = False
        await self._cleanup()

    async def _start_recording(self) -> None:
        """Start recording user speech on the channel."""
        if not self.active:
            return
        try:
            # Delete old recording if exists
            old = RECORDINGS_PATH / f"{self.recording_name}.wav"
            if old.exists():
                old.unlink()

            await ari_post(
                f"/channels/{self.channel_id}/record",
                json_data={
                    "name": self.recording_name,
                    "format": "wav",
                    "maxDurationSeconds": 10,
                    "maxSilenceSeconds": 3,
                    "ifExists": "overwrite",
                    "beep": True,
                },
            )
            print(f"[ari] Recording started: {self.recording_name}")
        except Exception as e:
            print(f"[ari] Failed to start recording: {e}")
            await self._hangup()

    async def _hangup(self) -> None:
        """Hang up the channel."""
        try:
            await ari_post(f"/channels/{self.channel_id}/hangup")
        except Exception:
            pass
        self.active = False

    async def _cleanup(self) -> None:
        """Remove temporary audio files."""
        for path in [
            RECORDINGS_PATH / f"{self.recording_name}.wav",
            SOUNDS_PATH / f"{self.bot_sound_name}.wav",
        ]:
            try:
                if path.exists():
                    path.unlink()
            except Exception:
                pass


# Active call sessions keyed by channel ID
_active_sessions: dict[str, CallSession] = {}


# ---------------------------------------------------------------------------
# ARI WebSocket Listener
# ---------------------------------------------------------------------------
async def _heartbeat(stop_event: asyncio.Event):
    """Print periodic heartbeat to prove task is alive."""
    while not stop_event.is_set():
        try:
            await asyncio.wait_for(stop_event.wait(), timeout=10)
        except asyncio.TimeoutError:
            print("[ari] Heartbeat: websocket listener alive", flush=True)


async def ari_websocket_listener():
    """Connect to Asterisk ARI events WebSocket and handle call flow."""
    ws_uri = (
        f"{ARI_WS_URL}/events"
        f"?app={ARI_APP}"
        f"&api_key={ARI_USER}:{ARI_PASS}"
    )

    stop_event = asyncio.Event()
    heartbeat_task = asyncio.create_task(_heartbeat(stop_event))

    try:
        while True:
            try:
                print(f"[ari] Connecting to {ws_uri.replace(ARI_PASS, '***')}", flush=True)
                async with websockets.connect(ws_uri, ping_interval=20, ping_timeout=10) as ws:
                    print("[ari] WebSocket connected", flush=True)
                    async for message in ws:
                        try:
                            event = json.loads(message)
                            await _handle_ari_event(event)
                        except json.JSONDecodeError:
                            print(f"[ari] Invalid JSON: {message[:200]}", flush=True)
                        except Exception as e:
                            print(f"[ari] Event handler error: {e}", flush=True)
            except websockets.exceptions.ConnectionClosed:
                print("[ari] WebSocket closed, reconnecting in 5s...", flush=True)
            except Exception as e:
                print(f"[ari] WebSocket error: {e}, reconnecting in 5s...", flush=True)
            await asyncio.sleep(5)
    finally:
        stop_event.set()
        heartbeat_task.cancel()
        try:
            await heartbeat_task
        except asyncio.CancelledError:
            pass


async def _handle_ari_event(event: dict) -> None:
    """Dispatch ARI events to the appropriate session handler."""
    event_type = event.get("type")
    if not event_type:
        return
    print(f"[ari] Event: {event_type}", flush=True)

    # Extract channel ID from various event shapes
    channel_id = None
    if "channel" in event:
        channel_id = event["channel"].get("id")
    elif "channel_id" in event:
        channel_id = event["channel_id"]
    elif "recording" in event:
        target_uri = event["recording"].get("target_uri", "")
        if target_uri.startswith("channel:"):
            channel_id = target_uri.split(":", 1)[1]
    elif "playback" in event:
        target_uri = event["playback"].get("target_uri", "")
        if target_uri.startswith("channel:"):
            channel_id = target_uri.split(":", 1)[1]

    print(f"[ari]   channel_id={channel_id}", flush=True)

    if event_type == "StasisStart" and channel_id:
        # Ignore the ;2 (called) leg of Local channels — we only handle the caller leg
        channel_name = event.get("channel", {}).get("name", "")
        if "Local/" in channel_name and channel_name.endswith(";2"):
            print(f"[ari] Ignoring Local channel called leg: {channel_id}", flush=True)
            return
        # New call entering Stasis
        session = CallSession(channel_id)
        _active_sessions[channel_id] = session
        await session.on_stasis_start()

    elif event_type == "RecordingFinished" and channel_id:
        session = _active_sessions.get(channel_id)
        if session:
            await session.on_recording_finished()
        else:
            print(f"[ari] No session for recording channel {channel_id}", flush=True)

    elif event_type == "PlaybackFinished" and channel_id:
        session = _active_sessions.get(channel_id)
        if session:
            await session.on_playback_finished()

    elif event_type == "ChannelHangupRequest" and channel_id:
        session = _active_sessions.pop(channel_id, None)
        if session:
            await session.on_channel_hangup()

    elif event_type == "ChannelLeftBridge" and channel_id:
        session = _active_sessions.pop(channel_id, None)
        if session:
            await session.on_channel_hangup()


# ---------------------------------------------------------------------------
# FastAPI App
# ---------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    global redis_client

    # Connect Redis
    try:
        redis_client = redis.from_url(REDIS_URL, decode_responses=True)
        await redis_client.ping()
        print("[orchestrator] Redis connected")
    except Exception as e:
        print(f"[orchestrator] Redis connection failed: {e}")
        redis_client = None

    # Start ARI websocket listener in background
    ari_task = asyncio.create_task(ari_websocket_listener())

    yield

    # Shutdown
    ari_task.cancel()
    try:
        await ari_task
    except asyncio.CancelledError:
        pass
    if redis_client:
        await redis_client.close()
        print("[orchestrator] Redis disconnected")


app = FastAPI(title="SipForge Orchestrator", version="0.1.0", lifespan=lifespan)


@app.get("/health")
async def health():
    """Check orchestrator and downstream service health."""
    checks = {"orchestrator": "ok"}

    # Redis
    if redis_client:
        try:
            await redis_client.ping()
            checks["redis"] = "ok"
        except Exception as e:
            checks["redis"] = f"error: {e}"
    else:
        checks["redis"] = "not_configured"

    # English bot
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(f"{ENGLISH_BOT_URL}/health")
            checks["english-bot"] = "ok" if r.status_code == 200 else f"http_{r.status_code}"
    except Exception as e:
        checks["english-bot"] = f"error: {e}"

    # Kinyarwanda bot (optional, expected to fail until implemented)
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(f"{KINYARWANDA_BOT_URL}/health")
            checks["kinyarwanda-bot"] = "ok" if r.status_code == 200 else f"http_{r.status_code}"
    except Exception as e:
        checks["kinyarwanda-bot"] = "not_ready"

    status = 200 if checks["english-bot"] == "ok" else 503
    return JSONResponse({"status": checks}, status_code=status)


@app.post("/process_call")
async def process_call(call_data: dict):
    """Manual trigger endpoint for testing ARI call processing."""
    return {
        "status": "ari_websocket_active",
        "active_sessions": len(_active_sessions),
        "message": "Use SIP extension 2000 to reach the chatbot.",
    }
