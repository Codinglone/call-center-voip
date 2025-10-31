#!/bin/bash

# Voice Communication System - Startup Script

set -e

echo "=========================================="
echo "Voice Communication System - Starting"
echo "=========================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ Please edit .env with your configuration before continuing"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose not found"
    echo "Please install Docker Compose and try again"
    exit 1
fi

echo ""
echo "📦 Building services..."
docker-compose build

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
echo ""
echo "🔍 Checking service health..."

services=("orchestrator:8000" "english-bot:8001" "kinyarwanda-bot:8002")
all_healthy=true

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -f -s "http://localhost:${port}/health" > /dev/null 2>&1; then
        echo "✅ ${name} is healthy"
    else
        echo "⚠️  ${name} is not responding yet"
        all_healthy=false
    fi
done

echo ""
if [ "$all_healthy" = true ]; then
    echo "✅ All services are running!"
else
    echo "⚠️  Some services are still starting. Check logs with:"
    echo "   docker-compose logs -f"
fi

echo ""
echo "=========================================="
echo "Service URLs:"
echo "=========================================="
echo "Orchestrator:      http://localhost:8000"
echo "English Chatbot:   http://localhost:8001"
echo "Kinyarwanda Bot:   http://localhost:8002"
echo "Redis:             localhost:6379"
echo "Asterisk SIP:      localhost:5060"
echo ""
echo "Extension Mapping:"
echo "  1000-1999: User extensions"
echo "  2000:      English chatbot"
echo "  3000:      Kinyarwanda chatbot"
echo ""
echo "View logs: docker-compose logs -f"
echo "Stop services: docker-compose down"
echo "=========================================="
