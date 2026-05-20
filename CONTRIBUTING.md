# Contributing to Call Center VoIP

Thank you for your interest in contributing to this project!

## Development Setup

### Prerequisites

- Python 3.11+
- Docker or Podman
- Make

### Setup

```bash
git clone https://github.com/Codinglone/call-center-voip.git
cd call-center-voip
make install
```

This will create a virtual environment and install development dependencies.

## Project Structure

```
call-center-voip/
├── asterisk/          # Asterisk telephony server configuration
├── orchestrator/      # Chatbot orchestrator service
├── chatbots/          # AI chatbot services
│   ├── english/
│   └── kinyarwanda/
├── shared/            # Shared utilities
├── docs/              # Documentation
├── scripts/           # Utility scripts
└── tests/             # Test suite
```

## Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run linting and tests: `make check`
5. Commit your changes
6. Push to your fork and open a Pull Request

## Code Style

- Python code follows PEP 8
- Use type hints where possible
- Run `make format` before committing

## Testing

```bash
# Run all tests
make test

# Run with coverage
make test-cov
```

## Commit Messages

Use clear, descriptive commit messages:

```
feat: add new endpoint for chatbot routing
fix: resolve SIP registration timeout
chore: update Docker base image
docs: add troubleshooting guide
```

## Questions?

Open an issue on GitHub or reach out to the maintainers.
