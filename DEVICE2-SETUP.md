# Device 2 Setup - Quick Guide

## 📱 What You Need

- Second iOS device (iPhone/iPad)
- Linphone app installed
- Both devices on same WiFi as server

## ⚡ Quick Setup (5 Minutes)

### Step 1: Open Linphone on Device 2

### Step 2: Tap "Use SIP Account"

### Step 3: Fill in These Details

```
┌──────────────────────────────────────────┐
│                                          │
│  Username:  1001                         │
│                                          │
│  Password:  user1001pass                 │
│                                          │
│  Domain:    10.225.5.12:5060             │
│                                          │
│  Transport: UDP                          │
│                                          │
└──────────────────────────────────────────┘
```

### Step 4: Tap "Login"

### Step 5: Wait for Green Dot ✅

## ✅ Test It Works

### From Device 1:
```
Open Linphone → Dial 1001 → Call
```
**Device 2 should ring!** 📞

### From Device 2:
```
Open Linphone → Dial 1000 → Call
```
**Device 1 should ring!** 📞

## 🎯 What Each Device Can Do

```
┌─────────────────┐         ┌─────────────────┐
│   Device 1      │         │   Device 2      │
│   User: 1000    │◄───────►│   User: 1001    │
│                 │  Calls  │                 │
│  Dial: 1001     │         │  Dial: 1000     │
│  to call →      │         │  to call →      │
└─────────────────┘         └─────────────────┘
```

## ⚠️ Common Mistakes

### ❌ Wrong Password
- NOT: `1001pass`
- NOT: `user1001`
- ✅ CORRECT: `user1001pass`

### ❌ Missing Port
- NOT: `10.225.5.12`
- ✅ CORRECT: `10.225.5.12:5060`

### ❌ Wrong Transport
- NOT: TCP
- ✅ CORRECT: UDP

### ❌ Calling Yourself
- Device 1 calling 1000 = missed call (yourself!)
- ✅ Device 1 calling 1001 = rings Device 2

## 🔍 How to Know It's Working

### On Device 2 (Linphone):
- ✅ Green dot next to account
- ✅ Status shows "Connected" or "Registered"

### On Server:
```bash
podman exec asterisk-server asterisk -rx "pjsip show endpoints" | grep 1001
```

**Should show:**
```
Endpoint:  1001    Available   0 of 1
```

## 🆘 Still Not Working?

### Try This:
1. **Delete the account** in Linphone
2. **Close Linphone** completely (swipe up)
3. **Reopen Linphone**
4. **Add account again** with correct details
5. **Wait 10 seconds**

### Check This:
- [ ] Both devices on same WiFi?
- [ ] Password is exactly `user1001pass`?
- [ ] Domain includes `:5060`?
- [ ] Transport is UDP?
- [ ] Server is running? (`podman ps | grep asterisk`)

### Get Help:
```bash
# Watch for registration attempts
podman logs -f asterisk-server

# Then try to register Device 2
# You should see log messages
```

## 📞 Making Your First Call

### From Device 1 to Device 2:

1. **Open Linphone on Device 1**
2. **Tap the dial pad**
3. **Enter: 1001**
4. **Tap the green call button** 📞
5. **Device 2 should ring!**
6. **Answer on Device 2**
7. **Say "Hello!"** 👋
8. **You should hear each other!** 🎉

### From Device 2 to Device 1:

1. **Open Linphone on Device 2**
2. **Tap the dial pad**
3. **Enter: 1000**
4. **Tap the green call button** 📞
5. **Device 1 should ring!**
6. **Answer on Device 1**
7. **Say "Hello back!"** 👋
8. **You should hear each other!** 🎉

## 🎉 Success!

Once both devices work, you have a working VoIP system!

**What you can do:**
- ✅ Make calls between devices
- ✅ Test audio quality
- ✅ Test in different rooms
- ✅ Add more devices (1002, 1003, etc.)

**What's next:**
- Implement orchestrator (Task 3)
- Add chatbot services (Tasks 4-5)
- Enable extensions 2000 and 3000

---

**Need more users?** Just ask and I can add more extensions!
