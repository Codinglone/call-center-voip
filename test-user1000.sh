#!/bin/bash
#================================ TEST USER 1000 ================================
# Starts PJSUA as user 1000 (will auto-answer calls)
# Run this in one terminal, then run test-user1001.sh in another
#================================================================================

echo "🎤 Starting SIP Client as User 1000"
echo ""
echo "This client will AUTO-ANSWER incoming calls"
echo "Press Ctrl+C to quit"
echo ""
echo "Waiting for calls from user 1001..."
echo ""

pjsua --id sip:1000@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --realm "*" \
      --username 1000 \
      --password user1000pass \
      --auto-answer 200 \
      --null-audio \
      --log-level 3 \
      --local-port 5061
