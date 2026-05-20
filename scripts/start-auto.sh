#!/bin/bash
#================================ AUTO-DETECT START SCRIPT ================================
# Automatically detects whether to use Podman or Docker and starts the system
#==========================================================================================

set -e

echo "🔍 Detecting container runtime..."
echo ""

# Check for Podman first (preferred on Fedora/RHEL)
if command -v podman &> /dev/null; then
    echo "✓ Podman detected - using Podman"
    echo ""
    
    # Check for podman-compose
    if ! command -v podman-compose &> /dev/null; then
        echo "⚠️  podman-compose not found. Installing..."
        pip3 install --user podman-compose
        echo ""
    fi
    
    exec ./scripts/start-podman.sh

# Fall back to Docker
elif command -v docker &> /dev/null; then
    echo "✓ Docker detected - using Docker"
    echo ""
    
    # Check for docker-compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ docker-compose not found. Please install it:"
        echo "   https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    exec ./scripts/start.sh

else
    echo "❌ Neither Podman nor Docker found!"
    echo ""
    echo "Please install one of the following:"
    echo ""
    echo "Podman (recommended for Fedora/RHEL):"
    echo "  sudo dnf install podman podman-compose"
    echo ""
    echo "Docker:"
    echo "  https://docs.docker.com/engine/install/"
    echo ""
    exit 1
fi
