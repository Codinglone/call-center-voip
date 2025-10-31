# Testing with Laptop (No Phone Needed!)

## 🖥️ SIP Softphones for Linux

You can use SIP softphones on your Fedora laptop to test the system without needing iOS devices.

## 🎯 Recommended: Linphone Desktop

Linphone has a desktop version that works great on Linux!

### Install Linphone Desktop

```bash
# On Fedora
sudo dnf install linphone

# Or use Flatpak
flatpak install flathub org.linphone.Linphone
```

### Configure Linphone Desktop

1. **Open Linphone**
   ```bash
   linphone
   # or if using Flatpak:
   flatpak run org.linphone.Linphone
   ```

2. **Add SIP Account**
   - Click **"Use SIP Account"** or go to Settings → Accounts
   - Click **"+"** to add account

3. **Enter Credentials**
   ```
   Username: 1000
   Password: user1000pass
   SIP Server: 127.0.0.1:5060
   Transport: UDP
   ```

4. **Click "Add" or "Login"**

5. **Look for green status** = Connected!

## 🎯 Alternative: Zoiper

Zoiper is another popular SIP client.

### Install Zoiper

```bash
# Download from: https://www.zoiper.com/en/voip-softphone/download/current
# Or use the free version
wget https://www.zoiper.com/downloads/zoiper5/Zoiper5_5.6.3_x86_64.tar.gz
tar -xzf Zoiper5_5.6.3_x86_64.tar.gz
cd Zoiper5
./zoiper5
```

### Configure Zoiper

1. **Open Zoiper**
2. **Settings → Accounts → Add Account**
3. **Select "SIP"**
4. **Enter:**
   ```
   Account name: User 1000
   Domain: 127.0.0.1:5060
   Username: 1000
   Password: user1000pass
   ```
5. **Save**

## 🎯 Simplest: Command Line with PJSUA

PJSUA is a command-line SIP client - perfect for quick testing!

### Install PJSUA

```bash
sudo dnf install pjproject pjsua
```

### Test with PJSUA

**Terminal 1 (User 1000):**
```bash
pjsua --id sip:1000@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --realm "*" \
      --username 1000 \
      --password user1000pass \
      --auto-answer 200
```

**Terminal 2 (User 1001):**
```bash
pjsua --id sip:1001@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --realm "*" \
      --username 1001 \
      --password user1001pass
```

**Make a call from Terminal 2:**
```
m
sip:1000@127.0.0.1
```

## 🧪 Testing Scenarios

### Scenario 1: Two Terminal Windows

Open two terminals on your laptop and run PJSUA in each with different users.

**Terminal 1:**
```bash
pjsua --id sip:1000@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1000 \
      --password user1000pass
```

**Terminal 2:**
```bash
pjsua --id sip:1001@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1001 \
      --password user1001pass
```

Then from Terminal 2, press `m` and dial `sip:1000@127.0.0.1`

### Scenario 2: Linphone + Terminal

- Run Linphone GUI with user 1000
- Run PJSUA in terminal with user 1001
- Call between them!

### Scenario 3: Laptop + Phone

- Linphone Desktop on laptop (user 1000)
- Linphone iOS on phone (user 1001)
- Call between them!

## 📝 Quick Test Script

Save this as `test-call.sh`:

```bash
#!/bin/bash

echo "Starting SIP test clients..."
echo ""
echo "Terminal 1: User 1000 (will auto-answer)"
echo "Terminal 2: User 1001 (you can make calls)"
echo ""
echo "From Terminal 2, press 'm' then enter: sip:1000@127.0.0.1"
echo ""

# Check if pjsua is installed
if ! command -v pjsua &> /dev/null; then
    echo "Error: pjsua not installed"
    echo "Install with: sudo dnf install pjsua"
    exit 1
fi

# Check if Asterisk is running
if ! podman ps | grep -q asterisk-server; then
    echo "Error: Asterisk is not running"
    echo "Start with: ./start-asterisk-only.sh"
    exit 1
fi

echo "Ready to test!"
echo ""
echo "Run these commands in separate terminals:"
echo ""
echo "Terminal 1:"
echo "pjsua --id sip:1000@127.0.0.1 --registrar sip:127.0.0.1:5060 --username 1000 --password user1000pass --auto-answer 200"
echo ""
echo "Terminal 2:"
echo "pjsua --id sip:1001@127.0.0.1 --registrar sip:127.0.0.1:5060 --username 1001 --password user1001pass"
```

## 🔍 Verify Registration

After starting your SIP clients, check if they registered:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints"
```

Should show:
```
Endpoint:  1000    Available   0 of 1
Endpoint:  1001    Available   0 of 1
```

## 🎮 PJSUA Commands

Once PJSUA is running, you can use these commands:

```
m  - Make a call
a  - Answer incoming call
h  - Hangup call
q  - Quit
+  - Increase volume
-  - Decrease volume
```

## 🎯 Complete Test Example

### Step 1: Start Asterisk
```bash
./start-asterisk-only.sh
```

### Step 2: Open Terminal 1 (User 1000)
```bash
pjsua --id sip:1000@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1000 \
      --password user1000pass \
      --auto-answer 200 \
      --null-audio
```

### Step 3: Open Terminal 2 (User 1001)
```bash
pjsua --id sip:1001@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1001 \
      --password user1001pass \
      --null-audio
```

### Step 4: Make a Call from Terminal 2
```
>>> m
(You will be asked for destination)
>>> sip:1000@127.0.0.1
```

### Step 5: Watch the Call Connect!
- Terminal 1 will auto-answer
- You'll see call status in both terminals
- Press `h` to hangup

## 🎤 Testing with Audio

Remove `--null-audio` flag to test with real audio:

```bash
pjsua --id sip:1000@127.0.0.1 \
      --registrar sip:127.0.0.1:5060 \
      --username 1000 \
      --password user1000pass
```

Make sure your laptop has:
- ✅ Microphone working
- ✅ Speakers/headphones connected
- ✅ Audio not muted

## 🐛 Troubleshooting

### PJSUA Not Found
```bash
sudo dnf install pjproject pjsua
```

### Can't Register
Check Asterisk is running:
```bash
podman ps | grep asterisk
```

### No Audio
1. Check audio devices:
   ```bash
   aplay -l  # List playback devices
   arecord -l  # List recording devices
   ```

2. Test audio:
   ```bash
   speaker-test -t wav -c 2
   ```

3. Use `--null-audio` flag to test without audio first

### Registration Fails
Check credentials:
- Username: `1000` or `1001`
- Password: `user1000pass` or `user1001pass`
- Server: `127.0.0.1:5060`

## 📊 Monitoring

### Watch Asterisk Logs
```bash
podman logs -f asterisk-server
```

### Check Active Calls
```bash
podman exec asterisk-server asterisk -rx "core show channels"
```

### Check Registrations
```bash
podman exec asterisk-server asterisk -rx "pjsip show contacts"
```

## 🎉 Success Criteria

You'll know it's working when:

1. ✅ Both PJSUA clients show "Registration successful"
2. ✅ Can make call from one to the other
3. ✅ Call connects (shows "CONFIRMED")
4. ✅ Can hear audio (if not using --null-audio)
5. ✅ Can hangup cleanly

## 💡 Pro Tips

1. **Use --null-audio** for initial testing (no audio hardware needed)
2. **Use --auto-answer** on one client for easier testing
3. **Open 3+ terminals** to test multiple users
4. **Use Linphone GUI** if you prefer graphical interface
5. **Mix and match** - laptop + phone works great!

## 🚀 Next Steps

Once laptop testing works:
1. ✅ You've verified Asterisk is working correctly
2. ✅ You've verified SIP registration works
3. ✅ You've verified call routing works
4. ✅ Ready to test with iOS devices
5. ✅ Ready to implement chatbot services (Tasks 3-5)

---

**This is actually the BEST way to test!** No need for multiple phones - just use your laptop! 🎉
