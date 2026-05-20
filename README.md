# SipForge

[![CI](https://github.com/Codinglone/SipForge/actions/workflows/ci.yml/badge.svg)](https://github.com/Codinglone/SipForge/actions)
[![License](https://img.shields.io/github/license/Codinglone/SipForge)](LICENSE)

SipForge connects Asterisk telephony with AI chatbots. Right now it handles regular voice calls between users, and eventually it'll route calls to English and Kinyarwanda chatbots too.

## What This Actually Does

I needed a way to have voice calls with AI assistants in Kinyarwanda. This is what I ended up building:

1. **Person-to-Person Calls** — Regular SIP phone calls between registered users (works now)
2. **English Chatbot** — Talk to an AI in English (works now)
3. **Kinyarwanda Chatbot** — Talk to an AI in Kinyarwanda (not built yet)

## How It Works

Your phone (or laptop) connects to an Asterisk server via SIP. Asterisk handles the call routing. Regular calls go straight through. Chatbot calls get routed through an orchestrator service that manages the AI pipeline.

```
Your Phone
    |
    v
Asterisk 20 (SIP server)
    |
    +---> Regular call (1000 -> 1001)
    |
    +---> Chatbot call (2000 / 3000)
            |
            v
    Orchestrator (Python/FastAPI + ARI websocket)
            |
    +-------+-------+
    |               |
English Bot     Kinyarwanda Bot
(Whisper +      (not started)
 Qwen2.5 +
 Piper)
    |
    v
  Redis (sessions)
```

Current state: Asterisk, orchestrator, and English chatbot are working end-to-end. Call extension 2000 to talk to the English bot.

## Try It Out

You need Docker or Podman, ~4GB RAM (for CPU inference), and these ports open: 5060, 8000-8002, 10000-10100.

### Start the Server

Docker:
```bash
docker-compose up --build
```

Podman (Fedora/RHEL):
```bash
./scripts/start-podman.sh
```

### Test the English Chatbot

The fastest way to test without a softphone:

```bash
# Start the stack
docker-compose up --build

# In another terminal, trigger a call via ARI
curl -s -X POST -u asterisk:changeme \
  -H "Content-Type: application/json" \
  -d '{"endpoint":"Local/2000@users","extension":"2000","context":"users","priority":1}' \
  http://127.0.0.1:8088/ari/channels
```

This creates a Local channel that enters the `Stasis(chatbot-en)` dialplan. The orchestrator will answer, record, send audio to the English bot, and play back the synthesized response. See [docs/TESTING.md](docs/TESTING.md) for more test scripts.

### Test Person-to-Person Calls Without a Phone

```bash
./scripts/install-test-client.sh
./scripts/test-user1000.sh   # Terminal 1
./scripts/test-user1001.sh   # Terminal 2
```

In Terminal 2, type `m` then `sip:1000@127.0.0.1` to make a call. Terminal 1 will ring. Type `a` to answer. You now have a voice call between two terminal windows.

### Connect a Real Phone

I use Linphone on iOS. Settings:
- Username: `1000`
- Password: `user1000pass`
- Domain: YOUR_LOCAL_IP:5060 (like `192.168.1.42:5060`)
- Transport: UDP

See [docs/CLIENT-SETUP.md](docs/CLIENT-SETUP.md) for the full walkthrough with screenshots.

## English Chatbot Pipeline

The English bot (`chatbots/english/`) runs a full voice pipeline inside a single FastAPI service:

1. **STT** — `faster-whisper` (tiny model, ~40MB)
2. **LLM** — `Qwen/Qwen2.5-0.5B-Instruct` (~1GB, runs on CPU)
3. **TTS** — `piper-tts` with `en_US-ryan-medium` (~60MB)

Models download automatically on first run (or via `download_models.py`). The orchestrator coordinates the loop: record user speech → send to bot → play response → repeat.

## Documentation

- [docs/QUICKSTART.md](docs/QUICKSTART.md) — Get it running fast
- [docs/CLIENT-SETUP.md](docs/CLIENT-SETUP.md) — Linphone configuration
- [docs/CALL-FLOW.md](docs/CALL-FLOW.md) — SIP call flow diagrams
- [docs/TESTING.md](docs/TESTING.md) — How I test without phones
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Things I broke and fixed
- [ARCHITECTURE.md](ARCHITECTURE.md) — Design decisions
- [CONTRIBUTING.md](CONTRIBUTING.md) — If you want to hack on this

## What's Working vs What's Not

| Thing | Status |
|-------|--------|
| Asterisk SIP server | Works |
| User-to-user voice calls | Works |
| RTP audio streaming | Works |
| iOS client setup | Tested |
| ARI websocket integration | Works |
| Orchestrator service | Works |
| English chatbot (Whisper + Qwen + Piper) | Works |
| Kinyarwanda chatbot | Not started |

## Dev Stuff

```bash
make install   # Set up venv
make check     # Lint + type check + test
make test      # Run tests
```

## Security Warning

This is a development setup. The passwords are hardcoded as `user1000pass`. Don't put this on the internet as-is. For a real deployment you'd want TLS/SRTP encryption, strong passwords, and fail2ban.

## License

MIT
