# Implementation Plan

- [x] 1. Set up project structure and base infrastructure
  - Create directory structure for asterisk, orchestrator, chatbots (english/kinyarwanda), and shared utilities
  - Create Docker Compose configuration file with service definitions for asterisk, orchestrator, english-bot, kinyarwanda-bot, and redis
  - Set up environment variable templates and configuration management
  - Create README with setup instructions and architecture overview
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 2. Configure Asterisk server for basic telephony
  - [x] 2.1 Create Asterisk configuration files
    - Write pjsip.conf with user endpoint templates and orchestrator endpoint
    - Write extensions.conf with dial plan for user-to-user calls (extensions 1000-1999)
    - Write rtp.conf with codec preferences (opus, ulaw, alaw) and port ranges
    - Configure logging in logger.conf for call events
    - _Requirements: 4.1, 4.2, 4.3, 4.5_
  
  - [x] 2.2 Implement dial plan routing for chatbot extensions
    - Add extension 2000 for English chatbot routing in extensions.conf
    - Add extension 3000 for Kinyarwanda chatbot routing in extensions.conf
    - Configure audio bridging to orchestrator service
    - Add error handling contexts for invalid extensions
    - _Requirements: 4.2, 7.3_
  
  - [x] 2.3 Create Asterisk Docker container setup
    - Write Dockerfile for Asterisk with required modules
    - Configure volume mounts for configuration and sound files
    - Set up network ports for SIP and RTP
    - Add health check script for container monitoring
    - _Requirements: 6.1, 6.4_

- [ ] 3. Build Chatbot Orchestrator service
  - [ ] 3.1 Create orchestrator project structure and dependencies
    - Initialize Python project with FastAPI, asyncio, redis-py, and pydantic
    - Create data models for CallSession, ConversationTurn, ChatbotRequest, ChatbotResponse
    - Set up configuration management for service URLs and Redis connection
    - _Requirements: 5.1, 5.5_
  
  - [ ] 3.2 Implement session management
    - Write session creation endpoint (POST /session/start)
    - Implement session state storage in Redis with TTL
    - Create session retrieval and update functions
    - Implement session cleanup endpoint (DELETE /session/{id})
    - Add session timeout handling (5 minutes inactivity)
    - _Requirements: 5.5, 7.2_
  
  - [ ] 3.3 Implement audio routing and format conversion
    - Create audio format conversion utilities (Asterisk codecs to 16-bit PCM)
    - Write audio chunk buffering logic
    - Implement bidirectional audio streaming between Asterisk and chatbots
    - Add audio endpoint (POST /session/audio)
    - _Requirements: 5.2, 5.4_
  
  - [ ] 3.4 Implement chatbot service integration
    - Create HTTP client for English chatbot service
    - Create HTTP client for Kinyarwanda chatbot service
    - Implement routing logic based on called extension
    - Add circuit breaker pattern for chatbot service failures
    - Implement fallback error responses when chatbots are unavailable
    - _Requirements: 5.2, 5.3, 7.1_
  
  - [ ] 3.5 Add WebSocket interface for Asterisk
    - Implement WebSocket endpoint for call sessions
    - Handle WebSocket connection lifecycle
    - Process incoming audio frames from Asterisk
    - Send chatbot audio responses back through WebSocket
    - _Requirements: 5.1_
  
  - [ ]* 3.6 Add monitoring and health check endpoints
    - Create health check endpoint (GET /health)
    - Add Prometheus metrics for call volume, latency, and errors
    - Implement logging for all session events
    - _Requirements: 6.3_

- [ ] 4. Build English Voice Chatbot service
  - [ ] 4.1 Create English chatbot project structure
    - Initialize Python project with dependencies (openai, langchain, fastapi)
    - Create configuration for API keys and model selection
    - Set up data models for chat requests and responses
    - _Requirements: 2.1_
  
  - [ ] 4.2 Implement Speech-to-Text pipeline
    - Integrate OpenAI Whisper API for English STT
    - Implement Voice Activity Detection (VAD) for speech pause detection
    - Create audio buffering logic until complete utterance
    - Add confidence scoring for transcriptions
    - _Requirements: 2.2_
  
  - [ ] 4.3 Implement LLM conversation processing
    - Set up OpenAI GPT-4 or Claude API client
    - Create conversation context management with history
    - Implement prompt engineering for voice assistant behavior
    - Add response generation with 3-second timeout
    - _Requirements: 2.5_
  
  - [ ] 4.4 Implement Text-to-Speech pipeline
    - Integrate OpenAI TTS or Google TTS API
    - Configure voice selection for natural English speech
    - Implement audio format conversion to required output format
    - Add audio streaming for responses
    - _Requirements: 2.3_
  
  - [ ] 4.5 Create REST API endpoint
    - Implement POST /chat/english endpoint
    - Add request validation and error handling
    - Integrate STT, LLM, and TTS pipeline
    - Return response with text and audio
    - Add health check endpoint
    - _Requirements: 2.1, 2.5_
  
  - [ ]* 4.6 Add error handling and fallbacks
    - Implement retry logic for API failures
    - Add fallback responses for low-confidence STT
    - Handle LLM timeout with default response
    - Log all errors with session context
    - _Requirements: 7.1, 7.2_

- [ ] 5. Build Kinyarwanda Voice Chatbot service
  - [ ] 5.1 Create Kinyarwanda chatbot project structure
    - Initialize Python project with ML dependencies
    - Set up model loading utilities for custom Kinyarwanda models
    - Create configuration for model paths and parameters
    - Set up data models for chat requests and responses
    - _Requirements: 3.1_
  
  - [ ] 5.2 Implement Kinyarwanda Speech-to-Text
    - Integrate or load custom Kinyarwanda STT model
    - Implement Voice Activity Detection for speech pause detection
    - Create audio preprocessing for Kinyarwanda phonetics
    - Add confidence scoring and handle low-confidence cases
    - _Requirements: 3.2_
  
  - [ ] 5.3 Implement Kinyarwanda language model
    - Load fine-tuned Kinyarwanda LLM (based on Digital Umuganda resources)
    - Create conversation context management
    - Implement Kinyarwanda-specific prompt templates
    - Handle tone and morphology in language understanding
    - Add support for code-switching detection
    - _Requirements: 3.4, 3.5_
  
  - [ ] 5.4 Implement Kinyarwanda text normalization
    - Integrate Kinyarwanda TTS text normalizer
    - Handle tone marks and diacritics
    - Normalize numbers, dates, and special characters for pronunciation
    - Process morphological variations
    - _Requirements: 3.3, 3.4_
  
  - [ ] 5.5 Implement Kinyarwanda Text-to-Speech
    - Load custom Kinyarwanda TTS model
    - Apply text normalization before TTS
    - Generate natural-sounding Kinyarwanda speech
    - Implement audio format conversion
    - _Requirements: 3.3_
  
  - [ ] 5.6 Create REST API endpoint
    - Implement POST /chat/kinyarwanda endpoint
    - Add request validation and error handling
    - Integrate STT, LLM, normalization, and TTS pipeline
    - Return response with text, normalized text, and audio
    - Add health check endpoint
    - _Requirements: 3.1, 3.5_
  
  - [ ]* 5.7 Add error handling and fallbacks
    - Implement fallback for low-confidence STT
    - Add simpler response generation for complex queries
    - Handle model loading failures gracefully
    - Log all errors with session context
    - _Requirements: 7.1, 7.2_

- [ ] 6. Integrate Asterisk with Chatbot Orchestrator
  - [ ] 6.1 Configure Asterisk AGI or ARI interface
    - Set up Asterisk ARI (Asterisk REST Interface) configuration
    - Create ARI application for chatbot call handling
    - Configure Stasis dialplan application in extensions.conf
    - _Requirements: 5.1_
  
  - [ ] 6.2 Implement Asterisk-to-Orchestrator bridge
    - Create Python script using ARI client library
    - Handle incoming calls to chatbot extensions (2000, 3000)
    - Establish WebSocket connection to orchestrator
    - Stream audio from Asterisk channel to orchestrator
    - Play audio responses from orchestrator back to caller
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [ ] 6.3 Add call event handling
    - Handle call answer, hangup, and error events
    - Notify orchestrator of call lifecycle events
    - Clean up resources on call termination
    - _Requirements: 4.4, 7.4_

- [ ] 7. Implement user-to-user calling
  - Create user registration script or interface
  - Configure user SIP endpoints in pjsip.conf (extensions 1000-1999)
  - Test direct user-to-user call routing
  - Add call logging to CDR
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.3, 4.4_

- [ ] 8. Add system monitoring and logging
  - [ ] 8.1 Set up centralized logging
    - Configure log aggregation for all services
    - Add structured logging with session IDs
    - Create log rotation policies
    - _Requirements: 4.4, 7.4_
  
  - [ ]* 8.2 Implement metrics collection
    - Add Prometheus exporters to all services
    - Create Grafana dashboards for call metrics
    - Set up alerts for service failures
    - Monitor audio quality metrics
    - _Requirements: 6.3_

- [ ] 9. Create deployment and testing infrastructure
  - [ ] 9.1 Finalize Docker Compose configuration
    - Add all service dependencies and networking
    - Configure volume mounts for persistence
    - Set up environment variable injection
    - Add service restart policies
    - _Requirements: 6.1, 6.4_
  
  - [ ] 9.2 Create deployment documentation
    - Write installation guide for all dependencies
    - Document configuration options for each service
    - Create troubleshooting guide
    - Add architecture diagrams
    - _Requirements: 6.2_
  
  - [ ]* 9.3 Create integration test suite
    - Write automated tests for user-to-user calls
    - Create test scripts for English chatbot interaction
    - Create test scripts for Kinyarwanda chatbot interaction
    - Add concurrent call testing
    - Test failover scenarios
    - _Requirements: 6.5_
  
  - [ ] 9.4 Create startup and health check scripts
    - Write startup script to launch all services
    - Create health check script to verify all services are running
    - Add service dependency checking
    - Implement graceful shutdown script
    - _Requirements: 6.3, 6.5_

- [ ] 10. Implement error handling and recovery
  - Add error message audio files to Asterisk sounds directory
  - Implement service unavailable handling in orchestrator
  - Add automatic service restart on failure in Docker Compose
  - Create circuit breaker implementation for chatbot services
  - Test and validate all error scenarios
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 4.5_
