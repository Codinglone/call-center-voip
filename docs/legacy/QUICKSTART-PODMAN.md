# Quick Start Guide (Podman)

This guide will help you run the Voice Communication System locally using **Podman** and connect iOS clients.

## Why Podman?

- ✅ Rootless containers (better security)
- ✅ Daemonless architecture
- ✅ Docker-compatible CLI
- ✅ Native on Fedora/RHEL
- ✅ No Docker daemon required

## Prerequisites

- Podman installed (already on your Fedora system)
- iOS device with Linphone app installed
- Both your computer and iOS device on the same network

## Step 1: Install podman-compose (if needed)

```bash
# Check if podman-compose is installed
which podman-compose

# If not installed, install it
pip3 install --user podman-compose

# Or use system package manager
sudo dnf install podman-compose
```

## Step 2: Start the System

### Option A: Using the Start Script (Recommended)

```bash
./scripts/start-podman.sh
```

This will automatically:
- Build all container images
- Start all services
- Display your IP address
- Show configuration details

### Option B: Manual Start

```bash
# Build containers
podman-compose -f podman-compose.yml build

# Start services in detached mode
podman-compose -f podman-compose.yml up -d

# Check status
podman-compose -f podman-compose.yml ps
```

## Step 3: Verify System is Running

```bash
# Run the test script
./scripts/test-connection-podman.sh

# Or manually check
podman ps
```

You should see containers running:
- `asterisk-server`
- `redis-cache`
- `chatbot-orchestrator`
- `english-chatbot`
- `kinyarwanda-chatbot`

## Step 4: Find Your Server IP Address

```bash
# Show all network interfaces
ip addr show | grep "inet " | grep -v 127.0.0.1

# Or use a simpler command
hostname -I
```

Look for an IP like `192.168.1.x` or `10.0.0.x`

## Step 5: Configure Linphone on iOS

### Install Linphone

1. Open App Store on your iOS device
2. Search for "Linphone"
3. Install the app (free)

### Configure SIP Account

1. Open Linphone
2. Tap **"Use SIP Account"**
3. Enter the following:

**Basic Settings:**
```
Username: 1000
Password: user1000pass
Domain: YOUR_IP:5060
```

Replace `YOUR_IP` with the IP address from Step 4.
Example: `192.168.1.100:5060`

**Advanced Settings:**
- Transport: UDP
- Enable ICE: Yes
- STUN Server: stun.l.google.com (optional)

4. Tap **"Login"** or **"Save"**

### Verify Registration

You should see:
- Green dot or "Connected" status in Linphone
- On your server, check:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints"
```

You should see user 1000 with status "Avail" or "Not in use"

## Step 6: Test Calling

### Test 1: User-to-User Call

If you have two iOS devices:

1. Configure first device with user `1000`
2. Configure second device with user `1001` (password: `user1001pass`)
3. From device 1, dial `1001`
4. Device 2 should ring!

### Test 2: Chatbot Extensions

From any registered device:

- Dial **2000** for English Voice Chatbot
- Dial **3000** for Kinyarwanda Voice Chatbot

**Note:** Chatbot services need to be fully implemented. Currently, they'll connect but may not respond until orchestrator and chatbot services are complete (Tasks 3-5).

## Useful Podman Commands

### View Logs

```bash
# All services
podman-compose -f podman-compose.yml logs -f

# Specific service
podman logs -f asterisk-server
podman logs -f chatbot-orchestrator
```

### Check Container Status

```bash
# Using podman-compose
podman-compose -f podman-compose.yml ps

# Using podman directly
podman ps
```

### Check Registered Endpoints

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints"
```

### View Active Calls

```bash
podman exec asterisk-server asterisk -rx "core show channels"
```

### Access Asterisk CLI

```bash
podman exec -it asterisk-server asterisk -r
```

Type `help` for available commands, `exit` to quit.

### Restart a Service

```bash
# Using podman-compose
podman-compose -f podman-compose.yml restart asterisk

# Using podman directly
podman restart asterisk-server
```

### Stop the System

```bash
# Stop all services
podman-compose -f podman-compose.yml down

# Stop and remove volumes (clean slate)
podman-compose -f podman-compose.yml down -v
```

## Troubleshooting

### Can't Register from iOS

**Check 1: Containers are running**
```bash
podman ps
```

**Check 2: Asterisk is responsive**
```bash
podman exec asterisk-server asterisk -rx "core show version"
```

**Check 3: Firewall (Fedora)**
```bash
# Check firewall status
sudo firewall-cmd --list-all

# Allow SIP and RTP ports
sudo firewall-cmd --add-port=5060/udp --permanent
sudo firewall-cmd --add-port=10000-10100/udp --permanent
sudo firewall-cmd --reload
```

**Check 4: SELinux (if issues persist)**
```bash
# Check SELinux status
getenforce

# Temporarily set to permissive for testing
sudo setenforce 0

# If this fixes it, you need proper SELinux policies
# Re-enable after testing:
sudo setenforce 1
```

**Check 5: Verify IP address**
- Make sure you're using the correct local IP
- Both devices must be on the same network
- Don't use `localhost` or `127.0.0.1` from iOS

### No Audio in Calls

**Check 1: RTP ports are open**
```bash
sudo firewall-cmd --add-port=10000-10100/udp --permanent
sudo firewall-cmd --reload
```

**Check 2: Codec mismatch**
- Ensure Opus, ulaw, or alaw is enabled in Linphone
- Check Asterisk logs for codec negotiation:
```bash
podman logs asterisk-server | grep codec
```

**Check 3: NAT/Firewall issues**
- Enable ICE in Linphone settings
- Enable STUN server: `stun.l.google.com`

### Calls Connect but Drop Immediately

```bash
# Check Asterisk logs for errors
podman logs asterisk-server | grep ERROR

# Check for permission issues
podman logs asterisk-server | grep -i permission
```

### Port Already in Use

```bash
# Find what's using port 5060
sudo ss -ulnp | grep 5060

# Stop conflicting service if needed
sudo systemctl stop <service-name>
```

### Volume Permission Issues

Podman uses different user namespaces. If you see permission errors:

```bash
# The :Z flag in volumes handles SELinux labeling
# Already configured in podman-compose.yml

# If issues persist, check volume ownership
podman volume inspect voice-network_asterisk-logs
```

## Podman-Specific Notes

### Rootless vs Rootful

By default, Podman runs rootless (as your user). This is more secure but has some limitations:

**Rootless (default):**
- More secure
- No sudo required
- Ports < 1024 require special handling
- Our setup uses ports > 1024, so no issues

**Rootful (if needed):**
```bash
# Run with sudo
sudo podman-compose -f podman-compose.yml up -d
```

### Networking

Podman creates a separate network namespace. The containers can communicate with each other using service names (e.g., `redis`, `asterisk`).

### Systemd Integration

You can run Podman containers as systemd services:

```bash
# Generate systemd unit files
podman generate systemd --new --files --name asterisk-server

# Move to systemd directory
sudo mv container-asterisk-server.service /etc/systemd/system/

# Enable and start
sudo systemctl enable container-asterisk-server
sudo systemctl start container-asterisk-server
```

## Performance Tips

### Resource Limits

You can limit container resources:

```bash
# Limit CPU and memory
podman run --cpus=2 --memory=2g asterisk-server
```

### Monitoring

```bash
# View resource usage
podman stats

# View specific container
podman stats asterisk-server
```

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
podman restart asterisk-server
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

3. **Firewall rules** (Fedora):
   ```bash
   sudo firewall-cmd --add-port=5060/udp --permanent
   sudo firewall-cmd --add-port=10000-10100/udp --permanent
   sudo firewall-cmd --reload
   ```

4. **Use Dynamic DNS** if your public IP changes

## Security Notes

⚠️ **For Production Use:**

1. Change default passwords in `pjsip.conf`
2. Use strong passwords (not `user1000pass`)
3. Enable TLS/SRTP for encrypted calls
4. Implement fail2ban for brute force protection
5. Use firewall rules to limit access
6. Consider VPN for remote access instead of port forwarding
7. Keep Podman and containers updated

## Next Steps

- Implement the orchestrator service (Task 3)
- Set up chatbot services (Tasks 4-5)
- Test end-to-end chatbot calls
- Add more users as needed
- Configure production security settings

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Linphone User Guide](https://www.linphone.org/technical-corner/linphone)
- [Asterisk Documentation](https://docs.asterisk.org/)
- [CLIENT-SETUP.md](docs/CLIENT-SETUP.md) - Detailed iOS setup
- [CALL-FLOW.md](docs/CALL-FLOW.md) - Technical call flow diagrams

## Getting Help

If you're stuck:

1. Check this guide's troubleshooting section
2. Review Asterisk logs: `podman logs asterisk-server`
3. Check Linphone logs in the app (Settings → Advanced → Logs)
4. Verify network connectivity with ping
5. Test with a different SIP client to isolate issues
6. Check Fedora firewall and SELinux settings
