#!/bin/bash
#================================ TEST USER 1001 ================================
# Starts PJSUA as user 1001
# Run this in a second terminal after starting test-user1000.sh
#================================================================================

echo "🎤 Starting SIP Client as User 1001"
echo ""
echo "Commands:"
echo "  m - Make a call"
echo "  h - Hangup"
echo "  q - Quit"
echo ""
echo "To call user 1000, press 'm' then enter: sip:1000@127.0.0.1"
echo ""

pjsua --id sip:1001@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --realm "*" \
      --username 1001 \
      --password user1001pass \
      --null-audio \
      --log-level 3 \
      --local-port 5062
