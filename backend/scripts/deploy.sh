#!/bin/bash

# Mind Wars Backend Deployment Script
# This script deploys the Mind Wars backend infrastructure

set -e  # Exit on error

echo "🚀 Mind Wars Backend Deployment"
echo "================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "✓ .env file created. Please edit it with your configuration."
    echo ""
    read -p "Press Enter to continue after editing .env file..."
fi

echo "📦 Pulling Docker images..."
docker-compose pull

echo ""
echo "🏗️  Building services..."
docker-compose build

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are healthy
echo ""
echo "🔍 Checking service health..."

# Check API Server
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✓ API Server is healthy"
else
    echo "❌ API Server is not responding"
    docker-compose logs api-server
    exit 1
fi

# Check PostgreSQL
if docker-compose exec -T postgres pg_isready -U mindwars > /dev/null 2>&1; then
    echo "✓ PostgreSQL is healthy"
else
    echo "❌ PostgreSQL is not responding"
    exit 1
fi

# Check Redis
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✓ Redis is healthy"
else
    echo "❌ Redis is not responding"
    exit 1
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📊 Service URLs:"
echo "  - REST API:       http://localhost:3000"
echo "  - Multiplayer:    http://localhost:3001"
echo "  - PostgreSQL:     localhost:5432"
echo "  - Redis:          localhost:6379"
echo ""
echo "📝 Test users (password: password123):"
echo "  - alice@example.com"
echo "  - bob@example.com"
echo "  - charlie@example.com"
echo "  - diana@example.com"
echo ""
echo "📖 View logs:      docker-compose logs -f"
echo "🛑 Stop services:  docker-compose down"
echo ""
