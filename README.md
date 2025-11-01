# Voice Communication System

A distributed voice communication platform that integrates Asterisk telephony with AI-powered chatbots for English and Kinyarwanda languages.

## 🚀 Quick Links

- **[Quick Start Guide - Podman](QUICKSTART-PODMAN.md)** - Get up and running with Podman (Fedora/RHEL)
- **[Test with Laptop](TEST-WITH-LAPTOP.md)** - Test without phones using PJSUA
- **[iOS Client Setup](docs/CLIENT-SETUP.md)** - Connect Linphone to your server
- **[Current Status](CURRENT-STATUS.md)** - What's working and what's next
- **[Architecture Overview](ARCHITECTURE.md)** - System design and components

## ✅ Current Status (Task 2 Complete)

**Working:**
- ✅ Asterisk 20.9.3 server running in Podman
- ✅ SIP registration and authentication
- ✅ User-to-user calls (extensions 1000-1999)
- ✅ Dial plan routing configured
- ✅ RTP media streaming (Opus, ulaw, alaw codecs)
- ✅ Tested and validated with PJSUA clients

**Not Yet Implemented:**
- ⏳ Chatbot Orchestrator (Task 3)
- ⏳ English Chatbot Service (Task 4)
- ⏳ Kinyarwanda Chatbot Service (Task 5)
- ⏳ Extensions 2000 and 3000 (chatbot routing)

## Overview

This system enables three primary use cases:
1. **User-to-User Voice Calls**: Direct voice communication between registered users
2. **English Chatbot Interaction**: Voice conversations with an AI assistant in English
3. **Kinyarwanda Chatbot Interaction**: Voice conversations with an AI assistant in Kinyarwanda

## Architecture

```
┌─────────────┐
│ SIP Clients │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Asterisk Server │◄──────────────┐
└────────┬────────┘               │
         │                        │
         │ User-to-User Calls     │
         │                        │
         ▼                        │
┌──────────────────────┐          │
│ Chatbot Orchestrator │          │
└─────────┬────────────┘          │
          │                       │
    ┌─────┴─────┐                │
    ▼           ▼                │
┌─────────┐ ┌──────────────┐    │
│ English │ │ Kinyarwanda  │    │
│ Chatbot │ │   Chatbot    │    │
└─────────┘ └──────────────┘    │
                                 │
┌────────┐                       │
│ Redis  │◄──────────────────────┘
└────────┘
```

### Components

- **Asterisk Server**: Core telephony platform handling SIP registration and call routing
- **Chatbot Orchestrator**: Manages routing between Asterisk and chatbot services
- **English Voice Chatbot**: AI-powered conversational agent for English
- **Kinyarwanda Voice Chatbot**: AI-powered conversational agent for Kinyarwanda
- **Redis**: Session state management and caching

## Directory Structure

```
.
├── asterisk/
│   ├── config/          # Asterisk configuration files
│   └── sounds/          # Custom audio files
├── orchestrator/
│   └── src/             # Orchestrator service code
├── chatbots/
│   ├── english/
│   │   └── src/         # English chatbot code
│   └── kinyarwanda/
│       ├── src/         # Kinyarwanda chatbot code
│       └── models/      # Kinyarwanda language models
├── shared/
│   └── utils/           # Shared utilities
├── docker-compose.yml   # Service orchestration
├── .env.example         # Environment template
└── README.md
```

## Prerequisites

### Option A: Podman (Recommended for Fedora/RHEL)
- Podman 3.0+ (pre-installed on Fedora)
- podman-compose
- At least 4GB RAM available
- Ports 5060, 8000-8002, 10000-10100 available

### Option B: Docker
- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM available
- Ports 5060, 8000-8002, 10000-10100 available

## Quick Start

### 1. Start Asterisk Server

```bash
# Using Podman (Fedora/RHEL)
./start-asterisk-only.sh

# Or manually
podman build -t asterisk-server:latest ./asterisk
podman run -d --name asterisk-server \
  -p 5060:5060/udp \
  -p 10000-10100:10000-10100/udp \
  -p 8088:8088/tcp \
  -v ./asterisk/config:/etc/asterisk:Z \
  asterisk-server:latest
```

### 2. Test with Laptop (No Phone Needed!)

```bash
# Install test client
./install-test-client.sh

# Terminal 1: Start user 1000
./test-user1000.sh

# Terminal 2: Start user 1001
./test-user1001.sh

# In Terminal 2, type 'm' then 'sip:1000@127.0.0.1' to call
```

See **[TEST-WITH-LAPTOP.md](TEST-WITH-LAPTOP.md)** for detailed instructions.

### 3. Test with iOS Devices

**Configure Linphone:**
- Username: `1000` (or 1001, 1002)
- Password: `user1000pass`
- Domain: `YOUR_IP:5060`
- Transport: UDP

See **[docs/CLIENT-SETUP.md](docs/CLIENT-SETUP.md)** for detailed setup.

### 4. Verify Registration

```bash
# Check registered endpoints
podman exec asterisk-server asterisk -rx "pjsip show endpoints"

# View active calls
podman exec asterisk-server asterisk -rx "core show channels"

# Watch logs
podman logs -f asterisk-server
```

## Extension Mapping

- **1000-1999**: User extensions for direct calls
- **2000**: English chatbot
- **3000**: Kinyarwanda chatbot

## Configuration

### Asterisk Configuration

Configuration files are located in `asterisk/config/`:
- `pjsip.conf`: SIP endpoint definitions
- `extensions.conf`: Dial plan routing
- `rtp.conf`: RTP settings and codecs
- `logger.conf`: Logging configuration

### Environment Variables

Key environment variables (see `.env.example` for full list):

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for English chatbot | Required |
| `SESSION_TIMEOUT` | Session timeout in seconds | 300 |
| `LOG_LEVEL` | Logging level (DEBUG, INFO, WARNING, ERROR) | INFO |

## Development

### Building Individual Services

```bash
# Build orchestrator
docker-compose build orchestrator

# Build English chatbot
docker-compose build english-bot

# Build Kinyarwanda chatbot
docker-compose build kinyarwanda-bot
```

### Accessing Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f orchestrator
docker-compose logs -f asterisk
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Testing

### User-to-User Calls

1. Configure two SIP clients (e.g., Linphone, Zoiper)
2. Register with extensions 1000 and 1001
3. Call from one extension to the other

### English Chatbot

1. Configure SIP client
2. Register with any user extension (1000-1999)
3. Dial extension 2000
4. Speak in English when connected

### Kinyarwanda Chatbot

1. Configure SIP client
2. Register with any user extension (1000-1999)
3. Dial extension 3000
4. Speak in Kinyarwanda when connected

## Monitoring

### Health Checks

All services expose health check endpoints:
- Orchestrator: `http://localhost:8000/health`
- English Bot: `http://localhost:8001/health`
- Kinyarwanda Bot: `http://localhost:8002/health`

### Metrics

Prometheus metrics are available at:
- Orchestrator: `http://localhost:8000/metrics`
- English Bot: `http://localhost:8001/metrics`
- Kinyarwanda Bot: `http://localhost:8002/metrics`

## Troubleshooting

### Services Won't Start

```bash
# Check Docker status
docker ps -a

# Check logs for errors
docker-compose logs

# Verify ports are available
netstat -tuln | grep -E '5060|8000|8001|8002'
```

### Audio Quality Issues

- Verify RTP ports (10000-10100) are not blocked by firewall
- Check network latency between client and server
- Review codec configuration in `asterisk/config/rtp.conf`

### Chatbot Not Responding

```bash
# Check chatbot service health
curl http://localhost:8001/health
curl http://localhost:8002/health

# Verify API keys in .env
docker-compose config | grep API_KEY

# Check orchestrator logs
docker-compose logs orchestrator
```

### SIP Registration Fails

- Verify Asterisk is running: `docker-compose ps asterisk`
- Check Asterisk logs: `docker-compose logs asterisk`
- Verify SIP client configuration matches `pjsip.conf`

## Performance

### Expected Metrics

- User-to-user call latency: <200ms
- Chatbot response time: <3 seconds
- Concurrent calls supported: 10+
- Audio quality: MOS score >4.0

### Resource Requirements

- CPU: 2+ cores recommended
- RAM: 4GB minimum, 8GB recommended
- Network: 1Mbps per concurrent call
- Storage: 10GB for models and logs

## Security

- SIP authentication required for all registrations
- TLS/SRTP support for encrypted communications
- API authentication between internal services
- Rate limiting on chatbot endpoints
- Network segmentation via Docker networks


## Support

For issues and questions:
- Check the troubleshooting section above
- Review service logs: `docker-compose logs`
- Consult the design document in `.kiro/specs/asterisk-voice-communication/design.md`

