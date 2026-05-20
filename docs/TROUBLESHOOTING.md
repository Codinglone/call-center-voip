# Troubleshooting

## Common Issues

### Can't Register from iOS

**Check firewall:**
```bash
sudo firewall-cmd --add-port=5060/udp --permanent
sudo firewall-cmd --add-port=10000-10100/udp --permanent
sudo firewall-cmd --reload
```

**Check Asterisk is running:**
```bash
docker ps | grep asterisk
```

**View Asterisk logs:**
```bash
docker logs asterisk-server | grep NOTICE
```

### No Audio in Calls

**Ensure RTP ports are open:**
```bash
sudo firewall-cmd --list-ports
```

**Check codec negotiation:**
```bash
docker logs asterisk-server | grep codec
```

**Enable ICE/STUN in Linphone:**
- Settings → Network → Enable ICE
- STUN server: `stun.l.google.com:19302`

### Asterisk Won't Start

**Check logs:**
```bash
docker logs asterisk-server
```

**Rebuild container:**
```bash
docker stop asterisk-server
docker rm asterisk-server
docker rmi asterisk-server:latest
./scripts/start.sh
```

### Device 2 Won't Register

1. Both devices on same WiFi?
2. Correct password? `user1001pass`
3. Domain includes `:5060`?
4. Transport is UDP?

**Try:**
- Delete account and re-add
- Restart Linphone app
- Restart device

### Call Connects but No Audio

1. Microphone permissions granted?
2. Volume turned up?
3. Not muted?

**Try:**
- Enable ICE in Linphone advanced settings
- Add STUN server
- Check both devices have good WiFi signal

## Debug Commands

```bash
# View all registered endpoints
docker exec asterisk-server asterisk -rx "pjsip show endpoints"

# View active channels
docker exec asterisk-server asterisk -rx "core show channels"

# Access Asterisk CLI
docker exec -it asterisk-server asterisk -r

# Enable verbose logging
core set verbose 5
pjsip set logger on

# View SIP debug
docker logs -f asterisk-server
```

## Getting Help

If issues persist:
1. Check [GitHub Issues](https://github.com/Codinglone/call-center-voip/issues)
2. Enable verbose logging and collect logs
3. Open a new issue with logs and steps to reproduce
