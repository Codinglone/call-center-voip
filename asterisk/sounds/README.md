# Asterisk Sound Files

This directory contains custom audio files for the Voice Communication System.

## Required Audio Files

The following audio files should be placed in this directory:

### User Messages
- `user-unavailable.wav` - Played when called user is not available
- `user-busy.wav` - Played when called user is busy

### Chatbot Messages
- `connecting-to-assistant.wav` - Played when connecting to a chatbot
- `service-unavailable.wav` - Played when chatbot service is down

### Error Messages
- `invalid-extension.wav` - Played when user dials invalid extension
- `please-try-again.wav` - Prompt to try again after error

## Audio Format Requirements

All audio files must be in the following format:
- Format: WAV (PCM)
- Sample Rate: 8000 Hz or 16000 Hz
- Channels: Mono (1 channel)
- Bit Depth: 16-bit

## Converting Audio Files

To convert audio files to the correct format, use:

```bash
sox input.wav -r 8000 -c 1 -b 16 output.wav
```

Or use ffmpeg:

```bash
ffmpeg -i input.mp3 -ar 8000 -ac 1 -sample_fmt s16 output.wav
```

## Default Asterisk Sounds

Asterisk includes default sound files in `/var/lib/asterisk/sounds/en/` which can be used as fallbacks.
