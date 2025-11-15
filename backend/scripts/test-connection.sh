#!/bin/bash

# Mind Wars Backend Connection Test Script
# Tests all backend endpoints

set -e

API_URL="http://localhost:3000"
MULTIPLAYER_URL="http://localhost:3001"

echo "🧪 Mind Wars Backend Connection Tests"
echo "====================================="
echo ""

# Test 1: API Health Check
echo "1️⃣  Testing API Server health..."
response=$(curl -s -w "\n%{http_code}" "$API_URL/health")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$http_code" = "200" ]; then
    echo "   ✓ API Server is healthy"
    echo "   Response: $body"
else
    echo "   ❌ API Server health check failed (HTTP $http_code)"
    exit 1
fi

echo ""

# Test 2: Register a test user
echo "2️⃣  Testing user registration..."
register_response=$(curl -s -X POST "$API_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123",
    "displayName": "Test User"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$register_response" | tail -n1)
body=$(echo "$register_response" | head -n-1)

if [ "$http_code" = "201" ] || [ "$http_code" = "409" ]; then
    echo "   ✓ Registration endpoint working"
    if [ "$http_code" = "409" ]; then
        echo "   (User already exists - that's OK for testing)"
    fi
else
    echo "   ❌ Registration failed (HTTP $http_code)"
    echo "   Response: $body"
    exit 1
fi

echo ""

# Test 3: Login
echo "3️⃣  Testing user login..."
login_response=$(curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "password123"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$login_response" | tail -n1)
body=$(echo "$login_response" | head -n-1)

if [ "$http_code" = "200" ]; then
    echo "   ✓ Login successful"

    # Extract access token for subsequent tests
    ACCESS_TOKEN=$(echo "$body" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)

    if [ -n "$ACCESS_TOKEN" ]; then
        echo "   ✓ Access token received"
    else
        echo "   ⚠️  Warning: Could not extract access token"
    fi
else
    echo "   ❌ Login failed (HTTP $http_code)"
    echo "   Response: $body"
    exit 1
fi

echo ""

# Test 4: Get games list
echo "4️⃣  Testing games endpoint..."
games_response=$(curl -s -X GET "$API_URL/api/games" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -w "\n%{http_code}")

http_code=$(echo "$games_response" | tail -n1)

if [ "$http_code" = "200" ]; then
    echo "   ✓ Games list retrieved"
else
    echo "   ❌ Games endpoint failed (HTTP $http_code)"
    exit 1
fi

echo ""

# Test 5: Get leaderboard
echo "5️⃣  Testing leaderboard endpoint..."
leaderboard_response=$(curl -s -X GET "$API_URL/api/leaderboard/all-time" \
  -w "\n%{http_code}")

http_code=$(echo "$leaderboard_response" | tail -n1)

if [ "$http_code" = "200" ]; then
    echo "   ✓ Leaderboard retrieved"
else
    echo "   ❌ Leaderboard endpoint failed (HTTP $http_code)"
    exit 1
fi

echo ""

# Test 6: Database connection
echo "6️⃣  Testing database connection..."
if docker-compose exec -T postgres psql -U mindwars -d mindwars -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
    echo "   ✓ Database connection successful"
else
    echo "   ❌ Database connection failed"
    exit 1
fi

echo ""

# Test 7: Redis connection
echo "7️⃣  Testing Redis connection..."
if docker-compose exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "   ✓ Redis connection successful"
else
    echo "   ❌ Redis connection failed"
    exit 1
fi

echo ""
echo "✅ All connection tests passed!"
echo ""
echo "🎉 Backend is ready for mobile app connection!"
echo ""
echo "📱 Configure your Flutter app with:"
echo "   API URL: $API_URL/api"
echo "   Multiplayer URL: $MULTIPLAYER_URL"
echo ""
