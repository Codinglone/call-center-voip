# Call Center VoIP

[![CI](https://github.com/Codinglone/call-center-voip/actions/workflows/ci.yml/badge.svg)](https://github.com/Codinglone/call-center-voip/actions)
[![License](https://img.shields.io/github/license/Codinglone/call-center-voip)](LICENSE)

A voice communication system I built that connects Asterisk telephony with AI chatbots. Right now it handles regular voice calls between users, and eventually it'll route calls to English and Kinyarwanda chatbots too.

## What This Actually Does

I needed a way to have voice calls with AI assistants in Kinyarwanda. This is what I ended up building:

1. **Person-to-Person Calls** — Regular SIP phone calls between registered users (works now)
2. **English Chatbot** — Talk to an AI in English (not built yet)
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
    Orchestrator (Python/FastAPI)
            |
    +-------+-------+
    |               |
English Bot     Kinyarwanda Bot
(Whisper +      (custom models)
 GPT-4)
    |
    v
  Redis (sessions)
```

Current state: Asterisk works great. The chatbot parts are planned.

## Try It Out

You need Docker or Podman, ~4GB RAM, and these ports open: 5060, 8000-8002, 10000-10100.

### Start the Server

Docker:
```bash
docker-compose up --build
```

Podman (Fedora/RHEL):
```bash
./scripts/start-podman.sh
```

### Test Without a Phone

This is how I test everything before touching real devices:

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
| Orchestrator service | Not started |
| English chatbot | Not started |
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
