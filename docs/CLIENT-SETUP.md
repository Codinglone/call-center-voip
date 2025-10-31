# iOS Client Setup Guide

## Overview

This guide explains how to connect iOS devices to your Asterisk server using Linphone.

## Architecture

```
┌─────────────────┐
│   iOS Device    │
│   (Linphone)    │
│   User: 1000    │
└────────┬────────┘
         │ SIP (5060/UDP)
         │ RTP (10000-10100/UDP)
         │
         ▼
┌─────────────────────────────────────┐
│     Your Computer (Docker Host)     │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Asterisk Container         │  │
│  │   - SIP Server (5060)        │  │
│  │   - RTP Media (10000-10100)  │  │
│  │   - ARI Interface (8088)     │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │   Orchestrator Container     │  │
│  │   - Chatbot Routing          │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │   Chatbot Containers         │  │
│  │   - English Bot (2000)       │  │
│  │   - Kinyarwanda Bot (3000)   │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Linphone - Open Source SIP Client

### Why Linphone?

- ✅ Open source (GPL v3)
- ✅ Available on iOS App Store
- ✅ Supports modern codecs (Opus, ulaw, alaw)
- ✅ Good NAT traversal (ICE, STUN)
- ✅ Active development
- ✅ Free to use

### Source Code

- iOS App: https://github.com/BelledonneCommunications/linphone-iphone
- SDK: https://github.com/BelledonneCommunications/linphone-sdk
- Core: https://github.com/BelledonneCommunications/liblinphone

## Step-by-Step Setup

### 1. Install Linphone

Download from the App Store:
- Search for "Linphone"
- Install the app (free)
- Open the app

### 2. Configure SIP Account

#### Option A: Using the Wizard

1. Tap **"Use SIP Account"**
2. Select **"Use SIP account"** (not "Create account")
3. Fill in the form:
   - **Username**: `1000`
   - **Password**: `user1000pass`
   - **Domain**: `192.168.1.100:5060` (replace with your server IP)
   - **Display name**: Your name (optional)
4. Tap **"Login"**

#### Option B: Manual Configuration

1. Go to **Settings** → **Accounts**
2. Tap **"+"** to add account
3. Select **"Use SIP account"**
4. Enter details:

**Basic:**
```
Username: 1000
Password: user1000pass
Domain: YOUR_SERVER_IP:5060
Display Name: Test User 1
```

**Advanced:**
```
Transport: UDP
Outbound Proxy: (leave empty)
Enable ICE: ON
STUN Server: stun.l.google.com (optional)
```

5. Tap **"Save"**

### 3. Verify Connection

Look for:
- Green dot next to account name
- Status: "Connected" or "Registered"

If you see "Connection failed" or red dot:
- Check server IP address
- Verify server is running: `docker-compose ps`
- Check firewall settings

### 4. Configure Audio Settings

Go to **Settings** → **Audio**:

**Codecs (in order of preference):**
1. ✅ Opus (best quality, lowest bandwidth)
2. ✅ PCMU (ulaw) - standard
3. ✅ PCMA (alaw) - standard
4. ❌ Disable others for simplicity

**Other Settings:**
- Echo Cancellation: ON
- Adaptive Rate Control: ON
- DTMF: RFC 4733

### 5. Test Calling

#### Test 1: Echo Test (if configured)
- Dial `600` (if echo test is set up)
- You should hear yourself

#### Test 2: Call Another User
- Set up second device with user `1001`
- From first device, dial `1001`
- Second device should ring

#### Test 3: Call Chatbot
- Dial `2000` for English chatbot
- Dial `3000` for Kinyarwanda chatbot

## Network Requirements

### Same Network (Local)

Both your computer and iOS device must be on the same WiFi network.

**Find your server IP:**
```bash
# Linux
ip addr show | grep "inet " | grep -v 127.0.0.1

# macOS
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Use the IP that starts with:
- `192.168.x.x` (most common)
- `10.0.x.x`
- `172.16.x.x` to `172.31.x.x`

### Remote Access (Internet)

To access from outside your network:

1. **Port forward on your router:**
   - 5060/UDP → Your server's local IP
   - 10000-10100/UDP → Your server's local IP

2. **Update Asterisk config** (`asterisk/config/pjsip.conf`):
   ```ini
   [transport-udp]
   external_media_address=YOUR_PUBLIC_IP
   external_signaling_address=YOUR_PUBLIC_IP
   ```

3. **Use your public IP** in Linphone domain field

4. **Security:** Consider using a VPN instead of exposing ports

## Troubleshooting

### Can't Register

**Symptom:** Red dot, "Connection failed"

**Solutions:**
1. Verify server is running:
   ```bash
   # Podman
   podman ps
   
   # Docker
   docker-compose ps
   ```

2. Check Asterisk logs:
   ```bash
   # Podman
   podman logs asterisk-server | grep NOTICE
   
   # Docker
   docker logs asterisk-server | grep NOTICE
   ```

3. Verify IP address is correct
4. Check both devices are on same network
5. Try disabling iOS VPN if active

### Registers but Can't Call

**Symptom:** Calls fail immediately

**Solutions:**
1. Check Asterisk endpoints:
   ```bash
   docker exec asterisk-server asterisk -rx "pjsip show endpoints"
   ```

2. Verify extension exists (1000-1999 for users)
3. Check Asterisk logs during call attempt

### No Audio in Calls

**Symptom:** Call connects but no audio

**Solutions:**
1. Check RTP ports are open (10000-10100/UDP)
2. Enable ICE in Linphone settings
3. Add STUN server: `stun.l.google.com`
4. Check codec compatibility:
   ```bash
   docker exec asterisk-server asterisk -rx "core show channels"
   ```

5. Verify firewall allows RTP:
   ```bash
   sudo ufw allow 10000:10100/udp
   ```

### One-Way Audio

**Symptom:** Can hear them, they can't hear you (or vice versa)

**Solutions:**
1. NAT/firewall issue - enable ICE and STUN
2. Check microphone permissions on iOS
3. Verify symmetric RTP is enabled (it is by default)

### Poor Audio Quality

**Solutions:**
1. Ensure Opus codec is enabled and preferred
2. Check network bandwidth
3. Reduce background apps on iOS
4. Check for packet loss:
   ```bash
   docker exec asterisk-server asterisk -rx "rtp show stats"
   ```

## Multiple Devices

You can connect multiple iOS devices:

**Device 1:**
- Username: 1000
- Password: user1000pass

**Device 2:**
- Username: 1001
- Password: user1001pass

**Device 3:**
- Username: 1002
- Password: user1002pass

Each device gets a unique extension number.

## Alternative iOS SIP Clients

If you want to try other open-source options:

1. **Linphone** (recommended) - Most feature-complete
2. **Telephone** - Simpler, macOS focused
3. **Zoiper** - Has free tier (not fully open source)

## Security Best Practices

For production use:

1. **Change default passwords** in `pjsip.conf`
2. **Use strong passwords** (not `user1000pass`)
3. **Enable TLS** for encrypted signaling
4. **Enable SRTP** for encrypted audio
5. **Use VPN** for remote access
6. **Implement fail2ban** for brute force protection
7. **Limit registration attempts**

## Next Steps

Once you have Linphone working:

1. Test user-to-user calls between devices
2. Implement the orchestrator service (Task 3)
3. Test chatbot extensions (2000, 3000)
4. Add more users as needed
5. Configure production security

## Getting Help

If you're stuck:

1. Check `QUICKSTART.md` for basic setup
2. Review Asterisk logs: `docker logs asterisk-server`
3. Check Linphone logs in the app (Settings → Advanced → Logs)
4. Verify network connectivity with ping
5. Test with a different SIP client to isolate issues

## Useful Commands

```bash
# Check if user is registered
docker exec asterisk-server asterisk -rx "pjsip show endpoints"

# View registration details
docker exec asterisk-server asterisk -rx "pjsip show registrations"

# Monitor calls in real-time
docker exec asterisk-server asterisk -rx "core show channels"

# View detailed call logs
docker logs asterisk-server | grep "User to User Call"

# Restart Asterisk if needed
docker-compose restart asterisk
```
