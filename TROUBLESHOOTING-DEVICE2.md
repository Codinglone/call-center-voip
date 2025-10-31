# Troubleshooting Second Device (User 1001)

## Quick Checklist

### ✅ Server Status
- Server is running: ✅
- Port 5060 is listening: ✅
- Firewall allows traffic: ✅
- Endpoint 1001 is configured: ✅

### 🔍 What to Check on Device 2

## Step 1: Verify Network Connection

**Both devices MUST be on the same WiFi network!**

On your second iOS device:
1. Go to **Settings** → **Wi-Fi**
2. Verify you're connected to the same network as your server
3. Note the network name

## Step 2: Double-Check Linphone Configuration

Open Linphone on the second device and verify **EXACTLY** these settings:

### Basic Settings
```
Username: 1001
Password: user1001pass
Domain: 10.225.5.12:5060
```

### Common Mistakes ❌
- ❌ Using `1001pass` instead of `user1001pass`
- ❌ Using just `10.225.5.12` without `:5060`
- ❌ Extra spaces in username or password
- ❌ Wrong IP address
- ❌ Transport set to TCP instead of UDP

### Correct Configuration ✅
```
┌─────────────────────────────────┐
│ Username: 1001                  │
│ Password: user1001pass          │
│ Domain: 10.225.5.12:5060        │
│ Display Name: Device 2          │
│ Transport: UDP                  │
└─────────────────────────────────┘
```

## Step 3: Advanced Settings

Tap **"Advanced"** in Linphone and set:

```
Outbound Proxy: [Leave Empty]
Enable ICE: ON
STUN Server: stun.l.google.com
Expire: 3600
```

## Step 4: Delete and Re-add Account

If it's still not working:

1. In Linphone, go to **Settings** → **Accounts**
2. Tap on the failing account
3. Tap **"Delete Account"**
4. Restart Linphone app
5. Add account again with correct credentials

## Step 5: Check Registration Status

### In Linphone
Look for:
- ✅ **Green dot** next to account = Connected
- ⚠️ **Orange dot** = Trying to connect
- ❌ **Red dot** = Failed

### On Server
Run this command to see if device registered:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep 1001
```

**Expected output when working:**
```
Endpoint:  1001    Available   0 of 1
```

**Current output (not registered):**
```
Endpoint:  1001    Unavailable   0 of 1
```

## Step 6: View Live Registration Attempts

Open a terminal and watch Asterisk logs in real-time:

```bash
podman logs -f asterisk-server
```

Then try to register on Device 2. You should see messages like:
- `REGISTER` requests
- Authentication attempts
- Success or failure messages

## Step 7: Test with Verbose Logging

Enable detailed logging:

```bash
podman exec -it asterisk-server asterisk -r
```

Then in the Asterisk CLI:
```
core set verbose 5
pjsip set logger on
```

Now try registering Device 2 again and watch the output.

Type `exit` to leave the CLI.

## Common Issues and Solutions

### Issue 1: "Connection Failed" or "Service Unavailable"

**Cause:** Can't reach the server

**Solutions:**
1. Verify IP address is correct: `10.225.5.12`
2. Check both devices on same WiFi
3. Try pinging server from Device 2 (if possible)
4. Restart Asterisk:
   ```bash
   podman restart asterisk-server
   ```

### Issue 2: "Authentication Failed" or "Forbidden"

**Cause:** Wrong username or password

**Solutions:**
1. Username must be exactly: `1001` (no spaces)
2. Password must be exactly: `user1001pass` (case-sensitive)
3. Delete account and re-add with correct credentials

### Issue 3: "Timeout" or Keeps Trying

**Cause:** Network/firewall issue

**Solutions:**
1. Check firewall on server (already verified as OK)
2. Check if iOS has VPN enabled (disable it)
3. Check if iOS has any network restrictions
4. Try restarting WiFi on iOS device

### Issue 4: Registers but Can't Call

**Cause:** RTP ports blocked

**Solutions:**
1. Verify RTP ports are open (already verified as OK)
2. Enable ICE in Linphone
3. Add STUN server: `stun.l.google.com`

## Alternative: Test with Different User

Try registering Device 2 with user **1002** instead:

```
Username: 1002
Password: user1002pass
Domain: 10.225.5.12:5060
Transport: UDP
```

If 1002 works but 1001 doesn't, there might be a configuration issue with endpoint 1001.

## Verify Asterisk Configuration

Let's check if endpoint 1001 is properly configured:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoint 1001"
```

Should show detailed configuration for user 1001.

## Check Authentication Settings

```bash
podman exec asterisk-server asterisk -rx "pjsip show auth 1001"
```

Should show:
```
Auth:  1001
    type: userpass
    username: 1001
    password: user1001pass
```

## Network Diagnostics

### From Your Computer (Server)
```bash
# Check if Asterisk is listening
ss -ulnp | grep 5060

# Check container is running
podman ps | grep asterisk

# Check container logs
podman logs asterisk-server | tail -50
```

### From iOS Device
Unfortunately, iOS doesn't have built-in network tools, but you can:
1. Try accessing a website to verify internet works
2. Check WiFi signal strength
3. Forget and rejoin the WiFi network

## Still Not Working?

### Collect Debug Information

1. **Get Asterisk logs:**
   ```bash
   podman logs asterisk-server > asterisk-debug.log
   ```

2. **Get endpoint status:**
   ```bash
   podman exec asterisk-server asterisk -rx "pjsip show endpoints" > endpoints.txt
   ```

3. **Get configuration:**
   ```bash
   cat asterisk/config/pjsip.conf | grep -A 10 "1001"
   ```

4. **Screenshot from Linphone:**
   - Take screenshot of account settings
   - Take screenshot of error message (if any)

### Try Simplest Test

1. **Stop Asterisk:**
   ```bash
   ./stop-asterisk.sh
   ```

2. **Start Asterisk:**
   ```bash
   ./start-asterisk-only.sh
   ```

3. **Wait 15 seconds**

4. **Try registering Device 2 again**

## Quick Test Script

Save this and run it:

```bash
#!/bin/bash
echo "=== Asterisk Status ==="
podman ps | grep asterisk

echo -e "\n=== Endpoints Status ==="
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep -E "1000|1001|1002"

echo -e "\n=== Recent Logs ==="
podman logs asterisk-server 2>&1 | tail -20

echo -e "\n=== Listening Ports ==="
ss -ulnp | grep 5060
```

## What Information to Provide

If you need more help, provide:
1. Exact error message from Linphone
2. Screenshot of Linphone account settings
3. Output of: `podman logs asterisk-server | tail -50`
4. iOS version
5. Linphone version
6. Are both devices on the same WiFi? (Yes/No)
7. Can Device 1 (user 1000) register successfully?

## Expected Behavior When Working

1. Open Linphone on Device 2
2. Account shows **green dot** within 5 seconds
3. Can dial Device 1 by entering `1000`
4. Device 1 rings
5. Answer on Device 1
6. Both devices can hear each other

## Next Steps

Once Device 2 is registered:
1. Test calling from Device 1 (1000) to Device 2 (1001)
2. Test calling from Device 2 (1001) to Device 1 (1000)
3. Test audio quality
4. Test with Device 3 (1002) if available
