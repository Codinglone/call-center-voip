#!/bin/bash
#================================ STOP ASTERISK SCRIPT ================================
# Stops and removes the Asterisk container
#====================================================================================

echo "🛑 Stopping Asterisk Server..."
echo ""

if podman ps | grep -q asterisk-server; then
    echo "Stopping container..."
    podman stop asterisk-server
    
    echo "Removing container..."
    podman rm asterisk-server
    
    echo ""
    echo "✅ Asterisk server stopped and removed"
else
    echo "⚠️  Asterisk server is not running"
fi

echo ""
