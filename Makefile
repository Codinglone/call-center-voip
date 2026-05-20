.PHONY: help install build up down restart logs health clean test lint format type-check check all

PYTHON := python3
VENV := .venv
PIP := $(VENV)/bin/pip
PYTEST := $(VENV)/bin/pytest
RUFF := $(VENV)/bin/ruff
MYPY := $(VENV)/bin/mypy

help:
	@echo "SipForge - Development Commands"
	@echo "========================================"
	@echo "make install    - Create venv and install dev deps"
	@echo "make build      - Build all Docker images"
	@echo "make up         - Start all services"
	@echo "make down       - Stop all services"
	@echo "make restart    - Restart all services"
	@echo "make logs       - View logs from all services"
	@echo "make health     - Check health of all services"
	@echo "make clean      - Remove all containers and volumes"
	@echo "make test       - Run test suite"
	@echo "make test-cov   - Run tests with coverage"
	@echo "make lint       - Run ruff linter"
	@echo "make format     - Auto-fix linting and format code"
	@echo "make type-check - Run mypy type checker"
	@echo "make check      - Run lint + type-check + test"

install:
	$(PYTHON) -m venv $(VENV)
	$(PIP) install -e ".[dev]"

build:
	@echo "Building Docker images..."
	docker-compose build

up:
	@echo "Starting services..."
	./scripts/start.sh

down:
	@echo "Stopping services..."
	docker-compose down

restart: down up

logs:
	docker-compose logs -f

health:
	@./scripts/health-check.sh

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	docker system prune -f
	@echo "Cleanup complete"

test:
	$(PYTEST) tests/ -v

test-cov:
	$(PYTEST) tests/ --cov=orchestrator --cov=chatbots --cov=shared --cov-report=html --cov-report=term

lint:
	$(RUFF) check orchestrator/ chatbots/ shared/ --ignore B008

format:
	$(RUFF) check orchestrator/ chatbots/ shared/ --ignore B008 --fix
	$(RUFF) format orchestrator/ chatbots/ shared/

type-check:
	$(MYPY) orchestrator/ chatbots/ shared/ --ignore-missing-imports

check: lint type-check test
	@echo "All checks passed!"
