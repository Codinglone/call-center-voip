# Quick Start

Get the Voice Communication System running in minutes.

## Prerequisites

- Docker 20.10+ or Podman 3.0+
- 4GB RAM available
- Ports 5060, 8000-8002, 10000-10100 free

## Docker (Quick)

```bash
docker-compose up --build
```

## Podman (Fedora/RHEL)

```bash
./scripts/start-podman.sh
```

## Verify

```bash
docker-compose ps  # or podman ps
```

All services should show as "healthy" or "running".

## Connect a Client

### iOS (Linphone)

1. Install Linphone from App Store
2. Add SIP account:
   - Username: `1000`
   - Password: `user1000pass`
   - Domain: `YOUR_IP:5060`
   - Transport: UDP

### Laptop (No Phone Needed)

```bash
./scripts/install-test-client.sh
./scripts/test-user1000.sh  # Terminal 1
./scripts/test-user1001.sh  # Terminal 2
```

In Terminal 2, type `m` then `sip:1000@127.0.0.1` to call.

## Next Steps

- [Architecture Overview](../ARCHITECTURE.md)
- [Client Setup Guide](CLIENT-SETUP.md)
- [Call Flow](CALL-FLOW.md)
