#!/bin/bash
#================================ START SCRIPT ================================
# Quick start script for Voice Communication System
# Builds and starts all services, then displays connection info
#==============================================================================

set -e

echo "🚀 Starting Voice Communication System..."
echo ""

# Build and start services
echo "📦 Building Docker containers..."
docker-compose build

echo ""
echo "🔄 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy (30 seconds)..."
sleep 30

echo ""
echo "✅ Services started! Checking status..."
docker-compose ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 iOS CLIENT CONFIGURATION (Linphone)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your server IP addresses:"
if command -v ip &> /dev/null; then
    ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print "  • " $2}' | sed 's/\/.*$//'
elif command -v ifconfig &> /dev/null; then
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print "  • " $2}'
else
    echo "  (Run 'ip addr' or 'ifconfig' to find your IP)"
fi

echo ""
echo "Configure Linphone with:"
echo "  Username: 1000"
echo "  Password: user1000pass"
echo "  Domain:   YOUR_IP:5060  (e.g., 192.168.1.100:5060)"
echo "  Transport: UDP"
echo ""
echo "Available test users: 1000, 1001, 1002"
echo "Chatbot extensions: 2000 (English), 3000 (Kinyarwanda)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 USEFUL COMMANDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "View logs:"
echo "  docker logs -f asterisk-server"
echo ""
echo "Check registered endpoints:"
echo "  docker exec asterisk-server asterisk -rx 'pjsip show endpoints'"
echo ""
echo "View active calls:"
echo "  docker exec asterisk-server asterisk -rx 'core show channels'"
echo ""
echo "Access Asterisk CLI:"
echo "  docker exec -it asterisk-server asterisk -r"
echo ""
echo "Stop system:"
echo "  docker-compose down"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 For detailed instructions, see QUICKSTART.md"
echo ""
