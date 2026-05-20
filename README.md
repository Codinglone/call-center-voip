# Call Center VoIP

[![CI](https://github.com/Codinglone/call-center-voip/actions/workflows/ci.yml/badge.svg)](https://github.com/Codinglone/call-center-voip/actions)
[![License](https://img.shields.io/github/license/Codinglone/call-center-voip)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)

A distributed voice communication platform that integrates Asterisk telephony with AI-powered chatbots for English and Kinyarwanda languages.

## Overview

This system enables three primary use cases:

1. **User-to-User Voice Calls** — Direct voice communication between registered SIP users
2. **English Chatbot** — Voice conversations with an AI assistant in English
3. **Kinyarwanda Chatbot** — Voice conversations with an AI assistant in Kinyarwanda

## Architecture

```
SIP Clients (iOS/Laptop)
         │
         ▼
┌─────────────────┐
│  Asterisk 20    │◄── ARI
│  SIP Server     │    Interface
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
User Calls  Chatbot
(1000-1999) (2000/3000)
                │
                ▼
      ┌──────────────────┐
      │  Orchestrator    │
      │  (FastAPI)       │
      └────────┬─────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
 English Bot      Kinyarwanda Bot
(Whisper/GPT-4)  (Custom Models)
      │                 │
      └────────┬────────┘
               ▼
            Redis
```

### Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Asterisk Server | Asterisk 20 | SIP registration, call routing, RTP handling |
| Orchestrator | Python/FastAPI | Session management, audio routing |
| English Chatbot | OpenAI APIs | Whisper STT, GPT-4, OpenAI TTS |
| Kinyarwanda Chatbot | Custom ML | Local STT, LLM, TTS models |
| Redis | Redis 7 | Session state, conversation history |

## Quick Start

### Prerequisites

- Docker 20.10+ or Podman 3.0+
- 4GB RAM available
- Ports 5060, 8000-8002, 10000-10100 free

### Start the System

**Docker:**
```bash
docker-compose up --build
```

**Podman (Fedora/RHEL):**
```bash
./scripts/start-podman.sh
```

### Test Without Phones

```bash
./scripts/install-test-client.sh
./scripts/test-user1000.sh  # Terminal 1
./scripts/test-user1001.sh  # Terminal 2
```

In Terminal 2, type `m` then `sip:1000@127.0.0.1` to call.

### Connect iOS (Linphone)

- Username: `1000`
- Password: `user1000pass`
- Domain: `YOUR_IP:5060`
- Transport: UDP

See [docs/CLIENT-SETUP.md](docs/CLIENT-SETUP.md) for detailed setup.

## Documentation

| Document | Description |
|----------|-------------|
| [docs/QUICKSTART.md](docs/QUICKSTART.md) | Quick start guide |
| [docs/CLIENT-SETUP.md](docs/CLIENT-SETUP.md) | iOS/Linphone configuration |
| [docs/CALL-FLOW.md](docs/CALL-FLOW.md) | Technical call flow diagrams |
| [docs/TESTING.md](docs/TESTING.md) | Testing without phones |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues and fixes |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture overview |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Development setup and workflow |

## Project Status

| Feature | Status |
|---------|--------|
| Asterisk SIP server | ✅ Working |
| User-to-user calls | ✅ Working |
| RTP media streaming | ✅ Working |
| Orchestrator service | 🚧 Planned |
| English chatbot | 🚧 Planned |
| Kinyarwanda chatbot | 🚧 Planned |

## Development

```bash
# Setup
make install

# Run checks
make check

# Run tests
make test
```

## Security

⚠️ **Current setup is for development only.**

For production:
- Change default passwords in `pjsip.conf`
- Enable TLS/SRTP for encrypted calls
- Implement fail2ban for brute force protection
- See [.github/SECURITY.md](.github/SECURITY.md)

## License

[MIT](LICENSE)
