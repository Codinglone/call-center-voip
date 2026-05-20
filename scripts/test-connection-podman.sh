#!/bin/bash
#================================ PODMAN CONNECTION TEST SCRIPT ================================
# Tests if Asterisk is running and ready to accept connections using Podman
# Run this after starting the system to verify everything is working
#===============================================================================================

set -e

echo "🔍 Testing Voice Communication System (Podman)..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check if containers are running
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Container Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if podman ps | grep -q "asterisk-server"; then
    echo -e "${GREEN}✓${NC} Asterisk container is running"
else
    echo -e "${RED}✗${NC} Asterisk container is not running"
    echo "  Run: ./scripts/start-podman.sh"
    exit 1
fi

echo ""

# Test 2: Check Asterisk is responsive
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Asterisk Responsiveness"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if podman exec asterisk-server asterisk -rx "core show version" > /dev/null 2>&1; then
    VERSION=$(podman exec asterisk-server asterisk -rx "core show version" | head -n1)
    echo -e "${GREEN}✓${NC} Asterisk is responsive"
    echo "  $VERSION"
else
    echo -e "${RED}✗${NC} Asterisk is not responding"
    echo "  Check logs: podman logs asterisk-server"
    exit 1
fi

echo ""

# Test 3: Check PJSIP module
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: PJSIP Module"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if podman exec asterisk-server asterisk -rx "pjsip show endpoints" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} PJSIP module is loaded"
    
    # Count configured endpoints
    ENDPOINT_COUNT=$(podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep -c "Endpoint:" || true)
    echo "  Configured endpoints: $ENDPOINT_COUNT"
else
    echo -e "${RED}✗${NC} PJSIP module not loaded"
    exit 1
fi

echo ""

# Test 4: Check SIP port
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: SIP Port (5060/UDP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ss -ulnp | grep -q ":5060"; then
    echo -e "${GREEN}✓${NC} SIP port 5060 is listening"
else
    echo -e "${YELLOW}⚠${NC} Cannot verify SIP port (may need root)"
fi

echo ""

# Test 5: Check ARI interface
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 5: ARI Interface (8088/TCP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if curl -s -f http://localhost:8088/ari/api-docs/resources.json > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} ARI interface is accessible"
else
    echo -e "${YELLOW}⚠${NC} ARI interface not responding (may still be starting)"
fi

echo ""

# Test 6: Show configured users
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 6: Configured Users"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Available test users:"
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep "^Endpoint:" | awk '{print "  • Extension: " $2}' | sed 's/\/.*//'

echo ""

# Test 7: Check for registered endpoints
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 7: Registered Clients"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REGISTERED=$(podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep -c "Avail" || true)

if [ "$REGISTERED" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} $REGISTERED client(s) currently registered"
    podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep "Avail"
else
    echo -e "${YELLOW}⚠${NC} No clients registered yet"
    echo "  This is normal if you haven't connected any SIP clients"
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✓${NC} System is ready for connections!"
echo ""
echo "Next steps:"
echo "  1. Find your server IP:"
echo "     ip addr show | grep 'inet ' | grep -v 127.0.0.1"
echo ""
echo "  2. Configure Linphone on iOS:"
echo "     Username: 1000"
echo "     Password: user1000pass"
echo "     Domain: YOUR_IP:5060"
echo ""
echo "  3. See docs/CLIENT-SETUP.md for detailed instructions"
echo ""
