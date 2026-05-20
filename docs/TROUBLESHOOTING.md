# Troubleshooting

I've hit most of these problems myself. Here's what actually worked.

## Can't Register Your Phone

This is the #1 issue. Check these in order:

### 1. Firewall (Almost Always This)

Fedora blocks everything by default. Run this:

```bash
sudo firewall-cmd --add-port=5060/udp --permanent
sudo firewall-cmd --add-port=10000-10100/udp --permanent
sudo firewall-cmd --reload
```

I forget this step like 50% of the time when testing on a fresh machine.

### 2. Asterisk Actually Running?

```bash
docker ps | grep asterisk
```

If it's not there, start it:
```bash
./scripts/start-asterisk-only.sh
```

If it starts then immediately exits, check the logs:
```bash
docker logs asterisk-server
```

Common startup failures:
- Port 5060 already in use by something else
- Config file syntax error (I edit these by hand, easy to mess up)
- SELinux blocking the container (Fedora thing, use `:Z` on volumes)

### 3. Wrong IP Address

You can't use `localhost` or `127.0.0.1` from your phone. Use your actual LAN IP:

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

Should look like `192.168.1.42` or `10.0.0.15`.

### 4. Wrong Password

The test passwords are:
- User 1000: `user1000pass`
- User 1001: `user1001pass`
- User 1002: `user1002pass`

Yes they're terrible. This is a dev setup.

## No Audio During Calls

### Check RTP Ports

```bash
sudo firewall-cmd --list-ports
```

Should include `5060/udp` and `10000-10100/udp`. If not, see firewall commands above.

### Check Codecs

Asterisk and the client need to agree on a codec. I use Opus, ulaw, and alaw.

```bash
docker logs asterisk-server | grep codec
```

If you see "no compatible codecs", something's wrong with the config.

### Enable ICE/STUN in Linphone

This fixed one-way audio for me:
- Settings → Network → Enable ICE
- STUN server: `stun.l.google.com:19302`

## Asterisk Won't Start at All

Nuclear option - blow it away and rebuild:

```bash
docker stop asterisk-server
docker rm asterisk-server
docker rmi asterisk-server:latest
./scripts/start-asterisk-only.sh
```

Takes like 2 minutes. If this doesn't work, check the build logs - might be a network issue downloading Asterisk packages.

## Two Phones, One Won't Register

Make sure both phones are on the **same WiFi network** as the server. I spent an embarrassing amount of time debugging this before realizing one phone was on 5GHz and the other on the guest network.

Also double-check:
- Username is just the number (1000, 1001, etc)
- Password includes the full thing: `user1000pass` not just `1000pass`
- Domain has `:5060` at the end
- Transport is UDP, not TCP or TLS

## Debugging Asterisk

The Asterisk CLI is actually pretty useful:

```bash
# Jump into the running Asterisk
 docker exec -it asterisk-server asterisk -r

# Inside Asterisk:
 asterisk*CLI> core set verbose 5
 asterisk*CLI> pjsip set logger on

# Now watch the SIP messages flow
```

This will show you exactly what the phone is sending and why Asterisk is rejecting it.

## Still Stuck?

1. Get the logs: `docker logs asterisk-server > debug.log`
2. Check what's registered: `docker exec asterisk-server asterisk -rx "pjsip show contacts"`
3. Open an issue on GitHub with the logs

Honestly, 90% of the time it's the firewall.
