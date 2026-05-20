# Call Flow Documentation

This document explains how calls flow through the SipForge.

## User-to-User Call Flow

```
┌─────────────┐                                    ┌─────────────┐
│   User A    │                                    │   User B    │
│ (Ext 1000)  │                                    │ (Ext 1001)  │
└──────┬──────┘                                    └──────▲──────┘
       │                                                  │
       │ 1. INVITE sip:1001@server                       │
       ├──────────────────────────────────────────┐      │
       │                                          │      │
       ▼                                          ▼      │
┌─────────────────────────────────────────────────────────────┐
│                    Asterisk Server                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 2. Lookup extension 1001 in [users] context         │  │
│  │ 3. Execute: Dial(PJSIP/1001,30)                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
       │                                                  │
       │ 4. 180 Ringing                                  │
       ◄────────────────────────────────────────────────┤
       │                                                  │
       │ 5. 200 OK (User B answers)                      │
       ◄────────────────────────────────────────────────┤
       │                                                  │
       │ 6. ACK                                          │
       ├─────────────────────────────────────────────────►
       │                                                  │
       │ 7. RTP Audio Stream (bidirectional)             │
       ◄────────────────────────────────────────────────►
       │                                                  │
       │ 8. BYE (call ends)                              │
       ├─────────────────────────────────────────────────►
       │                                                  │
```

### Steps Explained

1. **User A dials 1001**: SIP INVITE sent to Asterisk
2. **Asterisk looks up extension**: Finds 1001 in `extensions.conf` [users] context
3. **Dial command executes**: `Dial(PJSIP/1001,30)` rings User B for 30 seconds
4. **Ringing**: User B's phone rings, 180 Ringing sent back
5. **Answer**: User B answers, 200 OK sent
6. **ACK**: Call establishment confirmed
7. **Audio**: RTP streams flow directly between users (or through Asterisk if direct_media=no)
8. **Hangup**: Either party hangs up, BYE message sent

## Chatbot Call Flow (English - Extension 2000)

```
┌─────────────┐
│    User     │
│ (Ext 1000)  │
└──────┬──────┘
       │
       │ 1. INVITE sip:2000@server
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Asterisk Server                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 2. Lookup extension 2000 in [chatbots] context      │  │
│  │ 3. Answer()                                          │  │
│  │ 4. Playback(connecting-to-assistant)                │  │
│  │ 5. Stasis(chatbot-app,english,1000)                 │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 6. ARI WebSocket Connection
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Chatbot Orchestrator Service                   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 7. Receive channel event                            │  │
│  │ 8. Create session in Redis                          │  │
│  │ 9. Route to English chatbot service                 │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 10. HTTP/WebSocket to chatbot
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              English Chatbot Service                        │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 11. Receive audio stream                            │  │
│  │ 12. Speech-to-Text (Whisper)                        │  │
│  │ 13. Process with LLM (GPT-4)                        │  │
│  │ 14. Text-to-Speech (OpenAI TTS)                     │  │
│  │ 15. Send audio response                             │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 16. Audio response
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Chatbot Orchestrator Service                   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 17. Receive chatbot response                        │  │
│  │ 18. Stream audio to Asterisk via ARI                │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 19. RTP audio to user
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Asterisk Server                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 20. Play audio to user                              │  │
│  │ 21. Continue conversation loop                      │  │
│  │ 22. Hangup when user ends call                      │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 23. Audio playback
                         │
                         ▼
                    ┌─────────────┐
                    │    User     │
                    │ (Ext 1000)  │
                    └─────────────┘
```

### Steps Explained

1. **User dials 2000**: SIP INVITE for English chatbot
2. **Asterisk routes to chatbots context**: Matches extension 2000
3. **Call answered**: Asterisk answers immediately
4. **Greeting played**: "Connecting to assistant" audio file
5. **Stasis application**: Call handed to ARI application "chatbot-app" with parameters (english, caller_id)
6. **ARI connection**: Orchestrator receives channel control via WebSocket
7. **Channel event**: Orchestrator gets StasisStart event
8. **Session created**: New session stored in Redis with caller info
9. **Route to English bot**: Orchestrator forwards to English chatbot service
10. **Chatbot connection**: HTTP/WebSocket connection established
11. **Audio received**: User's speech audio stream
12. **STT processing**: Whisper converts speech to text
13. **LLM processing**: GPT-4 generates response
14. **TTS processing**: OpenAI TTS converts text to speech
15. **Response sent**: Audio response sent back to orchestrator
16. **Audio forwarded**: Orchestrator receives chatbot audio
17. **Response handling**: Orchestrator processes response
18. **Stream to Asterisk**: Audio streamed via ARI to Asterisk channel
19. **RTP to user**: Asterisk sends RTP audio to user
20. **Audio playback**: User hears chatbot response
21. **Conversation continues**: Loop repeats for multi-turn conversation
22. **Call ends**: User hangs up, Asterisk sends StasisEnd event
23. **Cleanup**: Session removed from Redis

## Kinyarwanda Chatbot Flow

The flow for extension 3000 (Kinyarwanda) is identical to the English flow, except:

- Step 5: `Stasis(chatbot-app,kinyarwanda,1000)`
- Step 9: Routes to Kinyarwanda chatbot service
- Steps 12-14: Uses Kinyarwanda-specific STT, LLM, and TTS models

## Error Handling Flows

### Invalid Extension

```
User dials 9999 (invalid)
    │
    ▼
Asterisk [users] context
    │
    ├─ No match for _1XXX
    ├─ No match for 2000
    ├─ No match for 3000
    │
    ▼
Match _X. (catch-all)
    │
    ▼
Goto(invalid,s,1)
    │
    ▼
[invalid] context
    │
    ├─ Answer()
    ├─ Playback(invalid-extension)
    ├─ Playback(please-try-again)
    └─ Hangup()
```

### User Unavailable

```
User A dials 1001
    │
    ▼
Asterisk executes Dial(PJSIP/1001,30)
    │
    ├─ User 1001 not registered
    │
    ▼
DIALSTATUS = CHANUNAVAIL
    │
    ▼
GotoIf unavail label
    │
    ├─ Playback(user-unavailable)
    └─ Hangup()
```

### User Busy

```
User A dials 1001
    │
    ▼
Asterisk executes Dial(PJSIP/1001,30)
    │
    ├─ User 1001 already on a call
    │
    ▼
DIALSTATUS = BUSY
    │
    ▼
GotoIf busy label
    │
    ├─ Playback(user-busy)
    └─ Hangup()
```

### Chatbot Service Down

```
User dials 2000
    │
    ▼
Stasis(chatbot-app,english,1000)
    │
    ├─ Orchestrator not responding
    │
    ▼
Stasis application fails
    │
    ▼
[chatbots] h extension (hangup handler)
    │
    ├─ NoOp(Call ended or error occurred)
    └─ Hangup()
```

## Audio Codec Negotiation

```
SIP Client                 Asterisk
    │                          │
    │ INVITE (SDP offer)       │
    │ Codecs: opus,ulaw,alaw   │
    ├─────────────────────────►│
    │                          │
    │                          │ Check allowed codecs
    │                          │ in pjsip.conf:
    │                          │ - opus ✓
    │                          │ - ulaw ✓
    │                          │ - alaw ✓
    │                          │
    │ 200 OK (SDP answer)      │
    │ Selected: opus           │
    ◄─────────────────────────┤
    │                          │
    │ ACK                      │
    ├─────────────────────────►│
    │                          │
    │ RTP with Opus codec      │
    ◄────────────────────────►│
```

## Session Management

### Session Lifecycle

```
Call Start
    │
    ▼
Create Session
    │
    ├─ Generate session_id
    ├─ Store in Redis
    │   ├─ caller_id
    │   ├─ language
    │   ├─ start_time
    │   └─ conversation_history
    │
    ▼
Active Conversation
    │
    ├─ Update conversation_history
    ├─ Refresh TTL (SESSION_TIMEOUT)
    │
    ▼
Call End
    │
    ├─ Mark session as ended
    ├─ Set TTL to 1 hour (for logs)
    │
    ▼
Session Cleanup
    │
    └─ Redis expires session after TTL
```

## Network Protocols

### SIP Signaling (Port 5060/UDP)

- INVITE: Initiate call
- 100 Trying: Processing request
- 180 Ringing: Destination ringing
- 200 OK: Call accepted
- ACK: Confirm call setup
- BYE: End call
- CANCEL: Cancel pending call

### RTP Media (Ports 10000-10100/UDP)

- Carries actual audio data
- Opus codec: 48kHz, variable bitrate
- ulaw/alaw: 8kHz, 64kbps
- RTCP: Quality monitoring

### ARI WebSocket (Port 8088/TCP)

- Channel events (StasisStart, StasisEnd)
- Channel control (answer, hangup, play)
- Bridge management
- Real-time audio streaming

## Performance Considerations

### Latency Budget

```
User speaks
    │
    ├─ Network latency: 10-50ms
    ▼
Asterisk receives
    │
    ├─ Processing: <5ms
    ▼
Orchestrator receives
    │
    ├─ Routing: <10ms
    ▼
Chatbot receives
    │
    ├─ STT: 500-1000ms
    ├─ LLM: 1000-2000ms
    ├─ TTS: 500-1000ms
    ▼
Response sent back
    │
    ├─ Network: 10-50ms
    ▼
User hears response

Total: ~2-4 seconds
```

### Concurrent Call Handling

- Each call uses 2 RTP ports (audio in/out)
- Port range 10000-10100 = 100 ports = 50 concurrent calls
- Can be increased by expanding RTP port range
- CPU/memory scales linearly with concurrent calls

## Monitoring Points

### Key Metrics to Track

1. **Call Setup Time**: INVITE to 200 OK
2. **Audio Quality**: MOS score, jitter, packet loss
3. **Chatbot Response Time**: User speech end to response start
4. **Session Duration**: Average call length
5. **Error Rate**: Failed calls / total calls
6. **Concurrent Calls**: Active calls at any time

### Log Locations

- Asterisk: `/var/log/asterisk/full`
- Orchestrator: stdout (Docker logs)
- Chatbots: stdout (Docker logs)
- Redis: stdout (Docker logs)

## Debugging Tips

### Enable Verbose Logging

```bash
# Asterisk CLI
docker exec -it asterisk-server asterisk -r
core set verbose 5
pjsip set logger on
```

### Trace SIP Messages

```bash
# In Asterisk CLI
pjsip set logger on

# Or in logger.conf
pjsip_log => notice,warning,error,debug
```

### Monitor RTP Streams

```bash
# In Asterisk CLI
rtp set debug on
```

### Watch Call Flow

```bash
# Follow Asterisk logs
docker logs -f asterisk-server | grep "User to User Call"

# Follow orchestrator logs
docker logs -f chatbot-orchestrator
```
