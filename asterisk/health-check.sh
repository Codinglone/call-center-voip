#!/bin/bash
#================================ ASTERISK HEALTH CHECK ================================
# Health check script for Asterisk container
# Verifies that Asterisk is running and responsive
#=======================================================================================

# Check if Asterisk process is running
if ! pgrep -x asterisk > /dev/null; then
    echo "ERROR: Asterisk process not running"
    exit 1
fi

# Check if Asterisk CLI is responsive
if ! asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "ERROR: Asterisk CLI not responsive"
    exit 1
fi

# Check if PJSIP is loaded and running
if ! asterisk -rx "pjsip show endpoints" > /dev/null 2>&1; then
    echo "ERROR: PJSIP module not loaded"
    exit 1
fi

# Check if ARI is available
if ! curl -s -f http://localhost:8088/ari/api-docs/resources.json > /dev/null 2>&1; then
    echo "WARNING: ARI interface not responding (may not be critical)"
fi

echo "Asterisk health check passed"
exit 0
