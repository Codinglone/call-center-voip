"""SipForge English Voice Chatbot - FastAPI Service.

Pipeline: Audio (WAV) -> STT (Whisper tiny) -> LLM (Qwen2.5-0.5B) -> TTS (Piper)
"""

import io
import os
import wave
from typing import Optional

import numpy as np
import soundfile as sf
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.responses import JSONResponse, StreamingResponse
from faster_whisper import WhisperModel
from piper import PiperVoice
from transformers import AutoModelForCausalLM, AutoTokenizer

MODEL_DIR = os.getenv("MODEL_PATH", "/app/models")
WHISPER_DIR = os.path.join(MODEL_DIR, "whisper")
LLM_DIR = os.path.join(MODEL_DIR, "llm")
PIPER_DIR = os.path.join(MODEL_DIR, "piper")

app = FastAPI(title="SipForge English Chatbot", version="0.1.0")

# Lazy-loaded model handles
_whisper: Optional[WhisperModel] = None
_llm: Optional[AutoModelForCausalLM] = None
_tokenizer: Optional[AutoTokenizer] = None
_piper: Optional[PiperVoice] = None


def _ensure_dir(path: str) -> str:
    os.makedirs(path, exist_ok=True)
    return path


def get_whisper() -> WhisperModel:
    global _whisper
    if _whisper is None:
        _ensure_dir(WHISPER_DIR)
        _whisper = WhisperModel(
            "tiny",
            device="cpu",
            compute_type="int8",
            download_root=WHISPER_DIR,
        )
    return _whisper


def get_llm():
    global _llm, _tokenizer
    if _llm is None:
        _ensure_dir(LLM_DIR)
        model_name = "Qwen/Qwen2.5-0.5B-Instruct"
        _tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            cache_dir=LLM_DIR,
        )
        _llm = AutoModelForCausalLM.from_pretrained(
            model_name,
            cache_dir=LLM_DIR,
        )
    return _llm, _tokenizer


def get_piper() -> PiperVoice:
    global _piper
    if _piper is None:
        onnx_path = os.path.join(PIPER_DIR, "en_US-ryan-medium.onnx")
        if not os.path.exists(onnx_path):
            raise RuntimeError(
                f"Piper model not found at {onnx_path}. Run download_models.py first."
            )
        _piper = PiperVoice.load(onnx_path)
    return _piper


@app.get("/health")
def health():
    return {"status": "healthy", "service": "english-chatbot"}


@app.post("/process")
async def process_audio(audio: UploadFile = File(...)):
    """Full voice pipeline: upload WAV -> return synthesized response WAV.

    Expects a mono WAV file (any sample rate). Returns a mono 22.05 kHz WAV.
    """
    audio_bytes = await audio.read()

    # ---- STT ----
    data, sr = sf.read(io.BytesIO(audio_bytes), dtype="float32")
    if data.ndim > 1:
        data = data.mean(axis=1)

    # Resample to 16 kHz for Whisper if needed
    if sr != 16000:
        data = _resample(data, sr, 16000)

    whisper = get_whisper()
    segments, _ = whisper.transcribe(data, language="en", beam_size=5)
    user_text = " ".join([s.text for s in segments]).strip()

    if not user_text:
        return JSONResponse(
            {"error": "No speech detected", "stt_text": ""},
            status_code=400,
        )

    # ---- LLM ----
    model, tokenizer = get_llm()
    messages = [
        {"role": "system", "content": "You are a helpful call center assistant. Keep replies brief and friendly."},
        {"role": "user", "content": user_text},
    ]
    prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(
        **inputs,
        max_new_tokens=60,
        temperature=0.7,
        do_sample=True,
        top_p=0.95,
        pad_token_id=tokenizer.eos_token_id,
    )
    reply = tokenizer.decode(
        outputs[0][inputs.input_ids.shape[1] :], skip_special_tokens=True
    ).strip()

    # ---- TTS ----
    piper = get_piper()
    wav_buffer = io.BytesIO()
    with wave.open(wav_buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(piper.config.sample_rate)
        piper.synthesize(reply, wav_file)
    wav_buffer.seek(0)

    return StreamingResponse(
        wav_buffer,
        media_type="audio/wav",
        headers={"X-Stt-Text": user_text, "X-Llm-Reply": reply},
    )


@app.post("/chat/text")
async def chat_text(text: str = Form(...)):
    """Text-only endpoint for quick testing without audio."""
    model, tokenizer = get_llm()
    messages = [
        {"role": "system", "content": "You are a helpful call center assistant. Keep replies brief and friendly."},
        {"role": "user", "content": text},
    ]
    prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(
        **inputs,
        max_new_tokens=60,
        temperature=0.7,
        do_sample=True,
        top_p=0.95,
        pad_token_id=tokenizer.eos_token_id,
    )
    reply = tokenizer.decode(
        outputs[0][inputs.input_ids.shape[1] :], skip_special_tokens=True
    ).strip()
    return {"stt_text": text, "llm_reply": reply}


def _resample(data: np.ndarray, orig_sr: int, target_sr: int) -> np.ndarray:
    """Simple nearest-neighbour resample (good enough for demo)."""
    if orig_sr == target_sr:
        return data
    try:
        from scipy import signal
        return signal.resample(data, int(len(data) * target_sr / orig_sr))
    except ImportError:
        old_x = np.linspace(0, 1, len(data))
        new_x = np.linspace(0, 1, int(len(data) * target_sr / orig_sr))
        return np.interp(new_x, old_x, data)
