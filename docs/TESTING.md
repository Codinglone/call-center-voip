# Testing

I test everything on my laptop before deploying. Here's my workflow.

## The Laptop Test (No iPhones Needed)

This uses PJSUA, a command-line SIP client. It's ugly but it works.

### Install It

```bash
./scripts/install-test-client.sh
```

This downloads and builds PJSUA. Takes a minute.

### Run Two Users

**Terminal 1:**
```bash
./scripts/test-user1000.sh
```

You should see a bunch of SIP messages ending with something like "Registration successful".

**Terminal 2:**
```bash
./scripts/test-user1001.sh
```

Same thing.

### Make a Call

In Terminal 2 (user 1001):
1. Type `m` then hit Enter
2. Type `sip:1000@127.0.0.1` then hit Enter
3. Terminal 1 should start ringing!
4. In Terminal 1, type `a` to answer
5. You now have a voice call between two terminal windows. Wild.

Controls:
- `h` - hang up
- `a` - answer incoming call
- `m` - make call
- `q` - quit

### Troubleshooting the Test

If registration fails:
- Is Asterisk running? `docker ps | grep asterisk`
- Did you start the right script? `./scripts/test-user1000.sh` not `./test-user1000.sh` (moved those)
- Try `127.0.0.1` instead of `localhost` - PJSUA is picky

## Testing With Real iPhones

See [Client Setup Guide](CLIENT-SETUP.md) for Linphone screenshots. I spent way too long getting the settings right, wrote it all down.

### Verify Phones Actually Registered

```bash
docker exec asterisk-server asterisk -rx "pjsip show endpoints"
```

Should show:
```
Endpoint:  1000    Available   0 of 1
Endpoint:  1001    Available   0 of 1
```

If it says "Unavailable", the phone never actually registered. Usually means wrong password or firewall blocking 5060.

## Common Issues I've Hit

| Problem | What I Did |
|---------|-----------|
| Can't register | Opened firewall: `sudo firewall-cmd --add-port=5060/udp --permanent` |
| No audio at all | Opened RTP range: `sudo firewall-cmd --add-port=10000-10100/udp --permanent` |
| Call drops immediately | Checked logs: `docker logs asterisk-server`, usually a codec mismatch |
| Audio one-way only | Enabled ICE in Linphone settings |

The firewall thing gets me every time on a fresh Fedora install.
