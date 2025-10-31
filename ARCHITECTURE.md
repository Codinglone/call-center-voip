# Voice Communication System - Architecture Overview

## System Components

### 1. Asterisk Server
- **Purpose**: Core telephony platform
- **Technology**: Asterisk 20
- **Responsibilities**:
  - SIP registration and authentication
  - Call routing and management
  - RTP audio stream handling
  - User-to-user call bridging
  - Call detail record (CDR) logging

### 2. Chatbot Orchestrator
- **Purpose**: Bridge between Asterisk and chatbot services
- **Technology**: Python, FastAPI, Redis
- **Responsibilities**:
  - Session management and state persistence
  - Audio format conversion
  - Routing to language-specific chatbots
  - Bidirectional audio streaming
  - Circuit breaker for service failures

### 3. English Voice Chatbot
- **Purpose**: AI-powered English conversation
- **Technology**: Python, OpenAI APIs, LangChain
- **Pipeline**:
  1. Speech-to-Text (Whisper)
  2. Language Model (GPT-4)
  3. Text-to-Speech (OpenAI TTS)

### 4. Kinyarwanda Voice Chatbot
- **Purpose**: AI-powered Kinyarwanda conversation
- **Technology**: Python, Custom ML models
- **Pipeline**:
  1. Speech-to-Text (Custom Kinyarwanda model)
  2. Language Model (Fine-tuned Kinyarwanda LLM)
  3. Text Normalization (Kinyarwanda-specific)
  4. Text-to-Speech (Custom Kinyarwanda TTS)

### 5. Redis
- **Purpose**: Session state and caching
- **Technology**: Redis 7
- **Usage**:
  - Call session storage
  - Conversation history
  - Temporary audio buffers

## Data Flow

### User-to-User Call
```
User A → Asterisk → User B
```

### Chatbot Interaction
```
User → Asterisk → Orchestrator → Chatbot Service
                                  ↓
                                  STT → LLM → TTS
                                  ↓
User ← Asterisk ← Orchestrator ← Audio Response
```

## Network Architecture

All services communicate over a Docker bridge network (`voice-network`):
- Subnet: 172.20.0.0/16
- Internal DNS resolution
- Isolated from host network except exposed ports

## Extension Mapping

| Extension Range | Purpose |
|----------------|---------|
| 1000-1999 | User extensions |
| 2000 | English chatbot |
| 3000 | Kinyarwanda chatbot |

## Audio Formats

- **Asterisk Codecs**: opus, ulaw, alaw (prioritized in order)
- **Internal Processing**: 16-bit PCM, 16kHz
- **RTP Ports**: 10000-10100

## Service Dependencies

```
orchestrator → redis
orchestrator → english-bot
orchestrator → kinyarwanda-bot
asterisk → orchestrator
```

## Scalability Considerations

- Orchestrator can be horizontally scaled with load balancer
- Redis can be clustered for high availability
- Chatbot services can run multiple instances
- Asterisk can be clustered using Kamailio or similar

## Security Layers

1. **Network**: Docker network isolation
2. **Authentication**: SIP authentication for users
3. **Encryption**: TLS/SRTP support (configurable)
4. **API**: JWT tokens between services
5. **Rate Limiting**: On chatbot endpoints

## Monitoring Points

- Service health endpoints (`/health`)
- Prometheus metrics (`/metrics`)
- Asterisk CDR logs
- Application logs (structured JSON)
- Redis connection status

## Failure Modes and Recovery

| Failure | Impact | Recovery |
|---------|--------|----------|
| Asterisk down | All calls fail | Auto-restart (30s) |
| Orchestrator down | Chatbot calls fail | Auto-restart, user calls continue |
| Chatbot down | That language unavailable | Circuit breaker, error message |
| Redis down | New sessions fail | In-memory fallback |

## Performance Targets

- User-to-user latency: <200ms
- Chatbot response time: <3s
- Concurrent calls: 10+
- Audio quality: MOS >4.0
- Session timeout: 5 minutes

## Future Enhancements

- WebRTC support for browser-based clients
- Multi-language detection and switching
- Call recording and transcription
- Analytics dashboard
- Load balancing and clustering
- Kubernetes deployment
