#!/bin/bash
#================================ START ASTERISK ONLY ================================
# Starts only the Asterisk server for testing basic telephony
# Use this to test user-to-user calls before implementing chatbot services
#===================================================================================

set -e

echo "🚀 Starting Asterisk Server with Podman..."
echo ""

# Build Asterisk container
echo "📦 Building Asterisk container..."
podman build -t asterisk-server:latest ./asterisk

echo ""
echo "🔄 Starting Asterisk service..."
podman run -d \
  --name asterisk-server \
  -p 5060:5060/udp \
  -p 10000-10100:10000-10100/udp \
  -p 8088:8088/tcp \
  -v ./asterisk/config:/etc/asterisk:Z \
  -v ./asterisk/sounds:/var/lib/asterisk/sounds:Z \
  --restart unless-stopped \
  asterisk-server:latest

echo ""
echo "⏳ Waiting for Asterisk to start (10 seconds)..."
sleep 10

echo ""
echo "✅ Asterisk started! Checking status..."
podman ps | grep asterisk-server

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 iOS CLIENT CONFIGURATION (Linphone)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your server IP addresses:"
ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print "  • " $2}' | sed 's/\/.*$//'

echo ""
echo "Configure Linphone with:"
echo "  Username: 1000"
echo "  Password: user1000pass"
echo "  Domain:   YOUR_IP:5060  (e.g., 192.168.1.100:5060)"
echo "  Transport: UDP"
echo ""
echo "Available test users: 1000, 1001, 1002"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 USEFUL COMMANDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "View logs:"
echo "  podman logs -f asterisk-server"
echo ""
echo "Check registered endpoints:"
echo "  podman exec asterisk-server asterisk -rx 'pjsip show endpoints'"
echo ""
echo "View active calls:"
echo "  podman exec asterisk-server asterisk -rx 'core show channels'"
echo ""
echo "Access Asterisk CLI:"
echo "  podman exec -it asterisk-server asterisk -r"
echo ""
echo "Stop Asterisk:"
echo "  podman stop asterisk-server"
echo "  podman rm asterisk-server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 For detailed instructions, see QUICKSTART-PODMAN.md"
echo ""
echo "Note: Chatbot extensions (2000, 3000) won't work until orchestrator"
echo "      and chatbot services are implemented (Tasks 3-5)"
echo ""
