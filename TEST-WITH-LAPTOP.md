# Test with Laptop - No Phone Needed! 🖥️

## Quick Start (3 Steps)

### Step 1: Install Test Client

```bash
./install-test-client.sh
```

This installs PJSUA, a command-line SIP client.

### Step 2: Open Two Terminals

**Terminal 1:**
```bash
./test-user1000.sh
```

Wait until you see "Registration successful"

**Terminal 2:**
```bash
./test-user1001.sh
```

Wait until you see "Registration successful"

### Step 3: Make a Call

In **Terminal 2**, type:
```
m
```

Then enter:
```
sip:1000@127.0.0.1
```

**Terminal 1 will auto-answer!** 🎉

You'll see call status in both terminals.

Press `h` to hangup.

## What You'll See

### Terminal 1 (User 1000) - Auto-answers
```
🎤 Starting SIP Client as User 1000

This client will AUTO-ANSWER incoming calls
Press Ctrl+C to quit

Waiting for calls from user 1001...

>>> Registration successful
>>> Incoming call from 1001
>>> Call CONFIRMED
>>> Call duration: 00:00:05
```

### Terminal 2 (User 1001) - Makes calls
```
🎤 Starting SIP Client as User 1001

Commands:
  m - Make a call
  h - Hangup
  q - Quit

To call user 1000, press 'm' then enter: sip:1000@127.0.0.1

>>> Registration successful
>>> m
(Destination URI) sip:1000@127.0.0.1
>>> Calling...
>>> Call CONFIRMED
>>> Call duration: 00:00:05
```

## Verify on Server

While both clients are running, check registration:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints"
```

Should show:
```
Endpoint:  1000    Available   0 of 1
Endpoint:  1001    Available   0 of 1
```

Check active call:
```bash
podman exec asterisk-server asterisk -rx "core show channels"
```

## Commands in PJSUA

```
m  - Make a call
a  - Answer incoming call (not needed with auto-answer)
h  - Hangup current call
q  - Quit PJSUA
+  - Increase volume
-  - Decrease volume
```

## Testing Scenarios

### Scenario 1: Basic Call Test (No Audio)
- Uses `--null-audio` flag
- No microphone/speakers needed
- Just tests SIP signaling and call setup
- **Perfect for initial testing!**

### Scenario 2: With Real Audio
Edit the scripts and remove `--null-audio` flag:

```bash
# In test-user1000.sh and test-user1001.sh
# Remove this line:
--null-audio \
```

Then you can actually talk through your laptop's microphone!

### Scenario 3: Three Users
Open a third terminal:

```bash
pjsua --id sip:1002@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1002 \
      --password user1002pass \
      --null-audio
```

Now you can test calls between 1000, 1001, and 1002!

## Troubleshooting

### "pjsua: command not found"
Run the installer:
```bash
./install-test-client.sh
```

### "Registration failed"
Check Asterisk is running:
```bash
podman ps | grep asterisk
```

If not running:
```bash
./start-asterisk-only.sh
```

### "Can't make call"
1. Make sure both clients show "Registration successful"
2. Check you're entering: `sip:1000@127.0.0.1` (not just `1000`)
3. Verify Asterisk logs: `podman logs asterisk-server | tail -20`

### No Audio (when not using --null-audio)
1. Check microphone: `arecord -l`
2. Check speakers: `aplay -l`
3. Test audio: `speaker-test -t wav -c 2`
4. Use `--null-audio` for testing without audio

## Advantages of Laptop Testing

✅ **No phone needed** - Test everything on one machine  
✅ **Easy debugging** - See logs in real-time  
✅ **Fast iteration** - Quick to restart and test  
✅ **Multiple users** - Open many terminals  
✅ **No network issues** - Everything is localhost  

## After Laptop Testing Works

Once you've verified calls work on laptop:

1. ✅ **System is working correctly**
2. ✅ **SIP registration works**
3. ✅ **Call routing works**
4. ✅ **Ready to test with iOS devices**
5. ✅ **Ready to implement chatbots**

## Mix Laptop + Phone

You can also test:
- Laptop (user 1000) ↔ iPhone (user 1001)
- Laptop (user 1000) ↔ Laptop GUI (user 1001)
- Any combination!

Just use:
- `127.0.0.1` for laptop clients
- `10.225.5.12` for phone clients

## GUI Alternative

If you prefer a graphical interface:

```bash
# Install Linphone Desktop
sudo dnf install linphone

# Run it
linphone
```

Then configure with same credentials:
- Username: 1000
- Password: user1000pass
- Server: 127.0.0.1:5060

## Quick Reference

| Terminal | User | Password | Auto-Answer | Command to Call |
|----------|------|----------|-------------|-----------------|
| Terminal 1 | 1000 | user1000pass | Yes | - |
| Terminal 2 | 1001 | user1001pass | No | `m` then `sip:1000@127.0.0.1` |

## Success! 🎉

When you see:
```
>>> Registration successful
>>> Call CONFIRMED
```

**Your VoIP system is working perfectly!**

You can now:
- Test with iOS devices
- Implement chatbot services
- Add more users
- Deploy to production

---

**This is the easiest way to test!** No phones, no network issues, just pure SIP testing on localhost! 🚀
