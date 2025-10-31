#!/bin/bash

# Voice Communication System - Health Check Script

echo "=========================================="
echo "Voice Communication System - Health Check"
echo "=========================================="
echo ""

# Function to check service health
check_service() {
    local name=$1
    local url=$2
    
    if curl -f -s "$url" > /dev/null 2>&1; then
        echo "✅ $name: Healthy"
        return 0
    else
        echo "❌ $name: Unhealthy or not responding"
        return 1
    fi
}

# Check Docker containers
echo "Docker Containers:"
echo "------------------"
docker-compose ps
echo ""

# Check service health endpoints
echo "Service Health:"
echo "---------------"
check_service "Orchestrator     " "http://localhost:8000/health"
check_service "English Chatbot  " "http://localhost:8001/health"
check_service "Kinyarwanda Bot  " "http://localhost:8002/health"
echo ""

# Check Redis
echo "Redis:"
echo "------"
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis: Connected"
else
    echo "❌ Redis: Not responding"
fi
echo ""

# Check Asterisk
echo "Asterisk:"
echo "---------"
if docker-compose exec -T asterisk asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "✅ Asterisk: Running"
else
    echo "❌ Asterisk: Not responding"
fi
echo ""

echo "=========================================="
echo "For detailed logs, run:"
echo "  docker-compose logs -f [service-name]"
echo "=========================================="
