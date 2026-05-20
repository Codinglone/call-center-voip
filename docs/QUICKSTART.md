# Quick Start

Here's how to get this thing running. It actually works, I've tested it.

## What You Need

- Docker or Podman (I use Podman on Fedora, but Docker works fine too)
- ~4GB RAM free
- These ports open: 5060, 8000-8002, 10000-10100

## Docker Way

```bash
docker-compose up --build
```

Wait like 30-60 seconds for everything to come up.

## Podman Way (What I Actually Use)

```bash
./scripts/start-podman.sh
```

This script handles all the SELinux stuff and port mapping that I kept forgetting.

## Check If It's Working

```bash
docker-compose ps  # or podman ps
```

You should see asterisk-server, redis-cache, and the other containers running. If asterisk keeps restarting, check the logs - probably a config issue.

## Connect Something

### Real Phones (iOS)

1. Install Linphone from the App Store (it's free)
2. Add a SIP account with these exact settings:
   - Username: `1000`
   - Password: `user1000pass` (yes, really, this is just for testing)
   - Domain: YOUR_COMPUTER_IP:5060 (not localhost, your actual IP like 192.168.1.x)
   - Transport: UDP

3. Hit save and wait for the green dot. If it's red, check the troubleshooting doc.

### Laptop (No Phone? No Problem)

I test everything on my laptop before touching phones. Here's how:

```bash
# Install PJSUA test client
./scripts/install-test-client.sh

# Terminal 1 - pretend to be user 1000
./scripts/test-user1000.sh

# Terminal 2 - pretend to be user 1001
./scripts/test-user1001.sh
```

Wait for "Registration successful" in both.

Then in Terminal 2:
- Type `m` (for make call)
- Enter: `sip:1000@127.0.0.1`
- It should ring in Terminal 1!

Call keys: `h` = hang up, `a` = answer, `q` = quit

## What Next?

- Read the [Architecture Overview](../ARCHITECTURE.md) if you're curious how this fits together
- [Client Setup Guide](CLIENT-SETUP.md) has screenshots for Linphone
- [Call Flow](CALL-FLOW.md) explains the SIP flow if you're into that stuff

Honestly the fastest way to verify it works is just running the laptop test above.
