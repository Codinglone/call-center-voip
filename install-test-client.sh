#!/bin/bash
#================================ INSTALL SIP TEST CLIENT ================================
# Installs PJSUA for testing SIP calls from your laptop
#========================================================================================

echo "🔧 Installing SIP test client (PJSUA)..."
echo ""

# Check if already installed
if command -v pjsua &> /dev/null; then
    echo "✅ PJSUA is already installed!"
    pjsua --version
    exit 0
fi

echo "Installing pjsua package..."
sudo dnf install -y pjsua

echo ""
if command -v pjsua &> /dev/null; then
    echo "✅ PJSUA installed successfully!"
    echo ""
    echo "Version:"
    pjsua --version
    echo ""
    echo "📖 See LAPTOP-TESTING.md for usage instructions"
else
    echo "❌ Installation failed"
    echo ""
    echo "Try manually:"
    echo "  sudo dnf install pjsua"
    exit 1
fi
