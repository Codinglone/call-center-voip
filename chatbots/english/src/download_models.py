#!/usr/bin/env python3
"""Download all models required by the English chatbot at build time.

Run this inside the Dockerfile so the container starts instantly.
"""

import os
import urllib.request

from faster_whisper import WhisperModel
from transformers import AutoModelForCausalLM, AutoTokenizer

MODEL_DIR = os.getenv("MODEL_PATH", "/app/models")
WHISPER_DIR = os.path.join(MODEL_DIR, "whisper")
LLM_DIR = os.path.join(MODEL_DIR, "llm")
PIPER_DIR = os.path.join(MODEL_DIR, "piper")


def download_whisper():
    print("[download] Whisper tiny via faster-whisper ...")
    os.makedirs(WHISPER_DIR, exist_ok=True)
    _ = WhisperModel("tiny", device="cpu", compute_type="int8", download_root=WHISPER_DIR)
    print("[download] Whisper OK")


def download_llm():
    print("[download] Qwen2.5-0.5B-Instruct via transformers ...")
    os.makedirs(LLM_DIR, exist_ok=True)
    model_name = "Qwen/Qwen2.5-0.5B-Instruct"
    tokenizer = AutoTokenizer.from_pretrained(
        model_name, cache_dir=LLM_DIR, trust_remote_code=True
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_name, cache_dir=LLM_DIR, trust_remote_code=True
    )
    print("[download] Qwen OK")


def download_piper_voice():
    print("[download] Piper TTS voice (en_US-ryan-medium) ...")
    os.makedirs(PIPER_DIR, exist_ok=True)
    base_url = (
        "https://huggingface.co/rhasspy/piper-voices/resolve/main/"
        "en/en_US/ryan/medium/"
    )
    files = [
        "en_US-ryan-medium.onnx",
        "en_US-ryan-medium.onnx.json",
    ]
    for fname in files:
        dest = os.path.join(PIPER_DIR, fname)
        if os.path.exists(dest):
            print(f"  {fname} already present")
            continue
        url = base_url + fname
        print(f"  fetching {fname} ...")
        urllib.request.urlretrieve(url, dest)
    print("[download] Piper OK")


if __name__ == "__main__":
    download_whisper()
    download_llm()
    download_piper_voice()
    print("\n[download] All models ready!")
