# Quick Start Guide

This guide will help you run the Voice Communication System locally and connect iOS clients.

## Prerequisites

- Docker and Docker Compose installed
- iOS device with Linphone app installed
- Both your computer and iOS device on the same network

## Step 1: Start the System

```bash
# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

Wait for all services to start (about 30-60 seconds). Check status:

```bash
docker-compose ps
```

All services should show as "healthy" or "running".

## Step 2: Find Your Server IP Address

You need your computer's local IP address for the SIP clients to connect.

**On Linux:**
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

**On macOS:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Look for an IP like `192.168.1.x` or `10.0.0.x`

## Step 3: Configure Linphone on iOS

### Add SIP Account

1. Open Linphone app
2. Tap **"Use SIP Account"** or go to Settings → Accounts → Add
3. Enter the following:

**Basic Settings:**
- **Username**: `1000`
- **Password**: `user1000pass`
- **Domain**: `YOUR_IP:5060` (e.g., `192.168.1.100:5060`)
- **Transport**: UDP

**Advanced Settings (tap "Advanced"):**
- **Outbound Proxy**: Leave empty
- **Enable ICE**: Yes
- **Enable STUN**: Yes (optional, use `stun.l.google.com`)

4. Tap **"Login"** or **"Save"**

### Verify Registration

- You should see a green dot or "Connected" status
- If it fails, check the server IP and firewall settings

## Step 4: Test Calling

### Test User-to-User Calls

If you have two iOS devices:

1. Configure first device with user `1000`
2. Configure second device with user `1001` (password: `user1001pass`)
3. From device 1, dial `1001`
4. Device 2 should ring!

### Test Chatbot Extensions

From any registered device:

- Dial **2000** for English Voice Chatbot
- Dial **3000** for Kinyarwanda Voice Chatbot

**Note:** The chatbot services need to be fully implemented for these to work. Currently, they'll connect but may not respond until the orchestrator and chatbot services are complete.

## Step 5: Monitor and Debug

### View Asterisk Logs
```bash
docker logs -f asterisk-server
```

### Check Registered Endpoints
```bash
docker exec asterisk-server asterisk -rx "pjsip show endpoints"
```

You should see your registered users:

```
Endpoint:  1000/1000                                             Not in use    0 of inf
```

### View Active Calls
```bash
docker exec asterisk-server asterisk -rx "core show channels"
```

### Access Asterisk CLI
```bash
docker exec -it asterisk-server asterisk -r
```

Type `help` for available commands, `exit` to quit.

## Troubleshooting

### Can't Register from iOS

**Check 1: Server is running**
```bash
docker-compose ps
```

**Check 2: Port 5060 is accessible**
```bash
# On your server
sudo netstat -ulnp | grep 5060
```

**Check 3: Firewall**
```bash
# On Linux, allow SIP and RTP ports
sudo ufw allow 5060/udp
sudo ufw allow 10000:10100/udp
```

**Check 4: Verify IP address**
- Make sure you're using the correct local IP
- Both devices must be on the same network
- Don't use `localhost` or `127.0.0.1` from iOS

### No Audio in Calls

**Check 1: RTP ports are open**
```bash
sudo ufw allow 10000:10100/udp
```

**Check 2: Codec mismatch**
- Ensure Opus, ulaw, or alaw is enabled in Linphone
- Check Asterisk logs for codec negotiation

**Check 3: NAT/Firewall issues**
- Enable ICE in Linphone settings
- Enable STUN server: `stun.l.google.com`

### Calls Connect but Drop Immediately

Check Asterisk logs:
```bash
docker logs asterisk-server | grep ERROR
```

Common causes:
- Codec negotiation failure
- RTP timeout (check RTP ports)
- Network connectivity issues

## Adding More Users

Edit `asterisk/config/pjsip.conf` and add:

```ini
[1003](user-template)
auth=1003
aors=1003

[1003](user-auth-template)
password=user1003pass
username=1003

[1003](user-aor-template)
```

Then restart Asterisk:
```bash
docker-compose restart asterisk
```

## Stopping the System

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## Network Configuration for Remote Access

If you want to access from outside your local network:

1. **Port Forward** on your router:
   - 5060/UDP → Your server IP
   - 10000-10100/UDP → Your server IP

2. **Update pjsip.conf** with your public IP:
   ```ini
   [transport-udp]
   type=transport
   protocol=udp
   bind=0.0.0.0:5060
   external_media_address=YOUR_PUBLIC_IP
   external_signaling_address=YOUR_PUBLIC_IP
   ```

3. **Use Dynamic DNS** if your public IP changes (e.g., DuckDNS, No-IP)

## Security Notes

⚠️ **For Production Use:**

1. Change default passwords in `pjsip.conf`
2. Use strong passwords (not `user1000pass`)
3. Enable TLS/SRTP for encrypted calls
4. Implement fail2ban for brute force protection
5. Use firewall rules to limit access
6. Consider VPN for remote access instead of port forwarding

## Next Steps

- Implement the orchestrator service (Task 3)
- Set up chatbot services (Tasks 4-5)
- Test end-to-end chatbot calls
- Add more users as needed
- Configure production security settings
