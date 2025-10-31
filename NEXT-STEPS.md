# Next Steps - Getting Device 2 Working

## ✅ Current Status

**Device 1 (User 1000):**
- ✅ Linphone is configured
- ✅ Shows "missed call" when you dial 1000 (calling yourself)
- ✅ This means Linphone is working!

**Device 2 (User 1001):**
- ❌ Not working yet
- Need to configure

## 🎯 Goal

Get Device 2 registered so you can call between Device 1 and Device 2.

## 📱 Configure Device 2 (Step-by-Step)

### On Your Second iOS Device:

1. **Install Linphone** (if not already installed)
   - Open App Store
   - Search "Linphone"
   - Install

2. **Open Linphone**

3. **Add SIP Account**
   - Tap **"Use SIP Account"**
   - Or go to Settings → Accounts → **"+"**

4. **Enter These EXACT Credentials:**

```
┌─────────────────────────────────────┐
│ Username:     1001                  │
│ Password:     user1001pass          │
│ Domain:       10.225.5.12:5060      │
│ Display Name: Device 2 (optional)   │
│ Transport:    UDP                   │
└─────────────────────────────────────┘
```

⚠️ **IMPORTANT:**
- Password is `user1001pass` (NOT `1001pass`)
- Domain MUST include `:5060` at the end
- Transport MUST be UDP (not TCP)

5. **Tap "Login" or "Save"**

6. **Wait 5-10 seconds**

7. **Look for Green Dot** ✅
   - Green = Connected and ready!
   - Red = Failed (check credentials)
   - Orange = Trying to connect

## 🧪 Test the Connection

### Once Device 2 Shows Green Dot:

**From Device 1 (1000):**
- Open Linphone
- Dial: `1001`
- Press call button
- Device 2 should ring! 📞

**From Device 2 (1001):**
- Open Linphone  
- Dial: `1000`
- Press call button
- Device 1 should ring! 📞

## 🔍 Verify Registration on Server

After configuring Device 2, check if it registered:

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep 1001
```

**Should show:**
```
Endpoint:  1001    Available   0 of 1
```

If it shows "Unavailable", Device 2 is not registered yet.

## 📊 Check Both Devices

```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep -E "1000|1001"
```

**When both working:**
```
Endpoint:  1000    Available   0 of 1
Endpoint:  1001    Available   0 of 1
```

## 🎬 Demo Call Flow

```
Device 1 (1000)          Asterisk Server          Device 2 (1001)
     │                         │                         │
     │  1. Dial 1001          │                         │
     ├────────────────────────>│                         │
     │                         │  2. Route to 1001      │
     │                         ├────────────────────────>│
     │                         │                         │ 3. Ring! 📞
     │                         │  4. Answer             │
     │                         │<────────────────────────┤
     │  5. Connected!         │                         │
     │<═══════════════════════════════════════════════>│
     │         Audio Stream (RTP)                       │
```

## ❓ Common Issues

### Issue: Device 2 Won't Register

**Check:**
1. Both devices on same WiFi? ✓
2. Correct password? `user1001pass` ✓
3. Domain includes `:5060`? ✓
4. Transport is UDP? ✓

**Try:**
- Delete account and re-add
- Restart Linphone app
- Restart iOS device

### Issue: Registers but Can't Call

**Check:**
1. Green dot on both devices? ✓
2. Dialing correct extension? (1000 or 1001) ✓
3. Not dialing your own number? ✓

**Try:**
- Enable ICE in Linphone settings
- Add STUN server: `stun.l.google.com`

### Issue: Call Connects but No Audio

**Check:**
1. Microphone permissions granted? ✓
2. Volume turned up? ✓
3. Not muted? ✓

**Try:**
- Enable ICE in Linphone advanced settings
- Add STUN server
- Check both devices have good WiFi signal

## 🎉 Success Criteria

You'll know it's working when:

1. ✅ Device 1 shows green dot
2. ✅ Device 2 shows green dot
3. ✅ Can dial 1001 from Device 1
4. ✅ Device 2 rings
5. ✅ Can answer and hear each other
6. ✅ Can dial 1000 from Device 2
7. ✅ Device 1 rings
8. ✅ Can answer and hear each other

## 📝 Quick Reference

| What | Device 1 | Device 2 |
|------|----------|----------|
| Username | 1000 | 1001 |
| Password | user1000pass | user1001pass |
| Domain | 10.225.5.12:5060 | 10.225.5.12:5060 |
| Dial to call other | 1001 | 1000 |

## 🆘 Need Help?

If Device 2 still won't work:

1. **Take screenshots:**
   - Linphone account settings on Device 2
   - Any error messages

2. **Get server logs:**
   ```bash
   podman logs asterisk-server > debug.log
   ```

3. **Check what's registered:**
   ```bash
   podman exec asterisk-server asterisk -rx "pjsip show contacts"
   ```

4. **Watch live registration attempts:**
   ```bash
   podman logs -f asterisk-server
   ```
   Then try to register Device 2 and watch for errors.

## 🚀 After Both Devices Work

Once you have both devices working:

1. **Test call quality:**
   - Make a call
   - Talk for a minute
   - Check for delays or echo

2. **Test multiple calls:**
   - Call back and forth several times
   - Verify consistent behavior

3. **Add Device 3 (optional):**
   - Use credentials for user 1002
   - Test 3-way scenarios

4. **Ready for chatbots:**
   - Once telephony works, you can implement Tasks 3-5
   - This will enable extensions 2000 and 3000

## 💡 Pro Tips

1. **Keep Linphone open** - iOS may kill background apps
2. **Good WiFi signal** - Both devices need strong connection
3. **Same network** - Must be on same WiFi
4. **Check battery** - Low battery can affect performance
5. **Restart helps** - When in doubt, restart the app

---

**Remember:** You're calling yourself when you dial 1000 from Device 1. That's why you see "missed call" - it's normal! You need Device 2 configured to make actual calls between devices.
