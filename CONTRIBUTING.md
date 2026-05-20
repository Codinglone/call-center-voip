# Contributing

Hey, thanks for even looking at this. I'm building this mostly solo but contributions are welcome.

## Getting Started

You need Python 3.11+, Docker or Podman, and Make.

```bash
git clone https://github.com/Codinglone/call-center-voip.git
cd call-center-voip
make install
```

That creates a virtual environment and installs dev dependencies.

## Project Layout

```
call-center-voip/
├── asterisk/          # Asterisk config and Dockerfile
├── orchestrator/      # Chatbot router (empty right now)
├── chatbots/          # English and Kinyarwanda bot code
│   ├── english/
│   └── kinyarwanda/
├── shared/            # Shared utils (also mostly empty)
├── docs/              # Docs
├── scripts/           # Shell scripts for testing
└── tests/             # Test suite
```

## Workflow

1. Fork it
2. Branch: `git checkout -b whatever-youre-working-on`
3. Make changes
4. Run `make check` (lint + type check + tests)
5. Commit and push
6. Open a PR

## Code Style

I use ruff for linting and formatting. Run `make format` before committing. Type hints are nice but not required everywhere yet — we're early stage.

## Testing

```bash
make test       # Run pytest
make test-cov   # With coverage report
```

Right now there's just scaffolding tests since the orchestrator and chatbots aren't implemented. Tests will grow as the project does.

## Commit Messages

I follow conventional commits out of habit:

```
feat: add chatbot routing endpoint
fix: handle SIP registration timeout
chore: update Asterisk base image
docs: add testing guide
```

## Questions?

Open an issue on GitHub.
