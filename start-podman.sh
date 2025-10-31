#!/bin/bash
#================================ PODMAN START SCRIPT ================================
# Quick start script for Voice Communication System using Podman
# Builds and starts all services, then displays connection info
#====================================================================================

set -e

echo "🚀 Starting Voice Communication System with Podman..."
echo ""

# Check if podman-compose is available
if command -v podman-compose &> /dev/null; then
    COMPOSE_CMD="podman-compose"
    COMPOSE_FILE="podman-compose.yml"
    echo "✓ Using podman-compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    COMPOSE_FILE="podman-compose.yml"
    echo "✓ Using docker-compose with Podman backend"
else
    echo "⚠️  Neither podman-compose nor docker-compose found"
    echo "Installing podman-compose..."
    pip3 install --user podman-compose
    COMPOSE_CMD="podman-compose"
    COMPOSE_FILE="podman-compose.yml"
fi

echo ""

# Build and start services
echo "📦 Building containers with Podman..."
$COMPOSE_CMD -f $COMPOSE_FILE build

echo ""
echo "🔄 Starting services..."
$COMPOSE_CMD -f $COMPOSE_FILE up -d

echo ""
echo "⏳ Waiting for services to be healthy (30 seconds)..."
sleep 30

echo ""
echo "✅ Services started! Checking status..."
$COMPOSE_CMD -f $COMPOSE_FILE ps

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
echo "Chatbot extensions: 2000 (English), 3000 (Kinyarwanda)"
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
echo "Stop system:"
echo "  $COMPOSE_CMD -f $COMPOSE_FILE down"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 For detailed instructions, see QUICKSTART.md"
echo ""
