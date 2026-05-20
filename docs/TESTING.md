# Testing Guide

## Test with Laptop (No Phone Needed)

Install PJSUA, a command-line SIP client, to test without physical phones.

### Setup

```bash
./scripts/install-test-client.sh
```

### Run Test

**Terminal 1:**
```bash
./scripts/test-user1000.sh
```

**Terminal 2:**
```bash
./scripts/test-user1001.sh
```

Wait for "Registration successful" in both.

### Make a Call

In Terminal 2, type:
- `m` (make call)
- Enter: `sip:1000@127.0.0.1`

### Commands During Call

| Key | Action |
|-----|--------|
| `h` | Hang up |
| `a` | Answer |
| `m` | Make call |
| `q` | Quit |

## Test with iOS Devices

See [Client Setup Guide](CLIENT-SETUP.md) for Linphone configuration.

## Verify Registration

```bash
docker exec asterisk-server asterisk -rx "pjsip show endpoints"
```

Expected output:
```
Endpoint:  1000    Available   0 of 1
Endpoint:  1001    Available   0 of 1
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't register | Check firewall: `sudo firewall-cmd --add-port=5060/udp --permanent` |
| No audio | Open RTP ports: `sudo firewall-cmd --add-port=10000-10100/udp --permanent` |
| Call fails | Check Asterisk logs: `docker logs asterisk-server` |
