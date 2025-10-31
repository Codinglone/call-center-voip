.PHONY: help build up down restart logs health clean test

help:
	@echo "Voice Communication System - Make Commands"
	@echo "=========================================="
	@echo "make build      - Build all Docker images"
	@echo "make up         - Start all services"
	@echo "make down       - Stop all services"
	@echo "make restart    - Restart all services"
	@echo "make logs       - View logs from all services"
	@echo "make health     - Check health of all services"
	@echo "make clean      - Remove all containers and volumes"
	@echo "make test       - Run tests"
	@echo ""

build:
	@echo "Building services..."
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
	@echo "Cleanup complete"

test:
	@echo "Running tests..."
	@echo "Tests not yet implemented"
