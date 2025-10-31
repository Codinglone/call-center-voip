# Asterisk Configuration

This directory contains the Asterisk telephony server configuration and Docker setup.

## Directory Structure

```
asterisk/
├── Dockerfile              # Asterisk container image
├── health-check.sh         # Container health check script
├── config/                 # Asterisk configuration files
│   ├── asterisk.conf       # Main Asterisk configuration
│   ├── pjsip.conf          # SIP endpoint definitions
│   ├── extensions.conf     # Dial plan routing logic
│   ├── rtp.conf            # RTP media configuration
│   ├── logger.conf         # Logging configuration
│   ├── modules.conf        # Module loading configuration
│   └── ari.conf            # ARI interface configuration
└── sounds/                 # Custom audio files
    └── README.md           # Audio file requirements
```

## Configuration Overview

### User Extensions (1000-1999)
- Direct user-to-user calling
- SIP authentication required
- Configured in `pjsip.conf`

### Chatbot Extensions
- **2000**: English Voice Chatbot
- **3000**: Kinyarwanda Voice Chatbot
- Routes through ARI to orchestrator service

### Supported Codecs
1. **Opus** (preferred) - High quality, low bandwidth
2. **ulaw** - Standard telephony codec
3. **alaw** - Alternative telephony codec

## Adding New Users

To add a new user endpoint, edit `config/pjsip.conf`:

```ini
[1003](user-template)
auth=1003
aors=1003

[1003](user-auth-template)
password=user1003pass
username=1003

[1003](user-aor-template)
```

## Testing Asterisk

### Check if Asterisk is running
```bash
docker exec asterisk-server asterisk -rx "core show version"
```

### View registered endpoints
```bash
docker exec asterisk-server asterisk -rx "pjsip show endpoints"
```

### View active calls
```bash
docker exec asterisk-server asterisk -rx "core show channels"
```

### View logs
```bash
docker logs asterisk-server
```

## Ports

- **5060/udp**: SIP signaling
- **10000-10100/udp**: RTP media streams
- **8088/tcp**: ARI interface for orchestrator

## Health Check

The container includes a health check script that verifies:
- Asterisk process is running
- CLI is responsive
- PJSIP module is loaded
- ARI interface is available

## Troubleshooting

### Asterisk won't start
Check logs: `docker logs asterisk-server`

### No audio in calls
- Verify RTP ports are open: 10000-10100/udp
- Check firewall settings
- Verify codec compatibility

### Can't register SIP client
- Check credentials in `pjsip.conf`
- Verify SIP port 5060/udp is accessible
- Check client configuration

### ARI not responding
- Verify port 8088 is exposed
- Check `ari.conf` credentials
- Ensure orchestrator can reach Asterisk container
