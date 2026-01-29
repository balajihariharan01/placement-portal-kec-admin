#!/bin/bash

# Railway Webhook Endpoint Test Script
# This script tests all webhook endpoints to ensure they work correctly

echo "🧪 Testing Railway Webhook Endpoints"
echo "======================================"
echo ""

# Configuration
BASE_URL="${1:-http://localhost:8080}"
RAILWAY_WEBHOOK_URL="$BASE_URL/api/webhooks/railway"
GENERIC_WEBHOOK_URL="$BASE_URL/api/webhooks/generic"

echo "📍 Base URL: $BASE_URL"
echo ""

# Test 1: POST to Railway Webhook (Expected: 200 OK)
echo "✅ Test 1: POST to Railway Webhook"
echo "-----------------------------------"
curl -X POST "$RAILWAY_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "deployment.success",
    "projectId": "test-project-123",
    "timestamp": "2026-01-29T05:30:00Z",
    "data": {
      "deploymentId": "dep-test-123",
      "environmentId": "env-test-456",
      "status": "success"
    }
  }' \
  -w "\n📊 HTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Test 2: GET to Railway Webhook (Expected: 405 Method Not Allowed)
echo "❌ Test 2: GET to Railway Webhook (Should Fail with 405)"
echo "-----------------------------------------------------------"
curl -X GET "$RAILWAY_WEBHOOK_URL" \
  -w "\n📊 HTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Test 3: Invalid JSON to Railway Webhook (Expected: 400 Bad Request)
echo "❌ Test 3: Invalid JSON to Railway Webhook (Should Fail with 400)"
echo "------------------------------------------------------------------"
curl -X POST "$RAILWAY_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d 'invalid-json{' \
  -w "\n📊 HTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Test 4: POST to Generic Webhook (Expected: 200 OK)
echo "✅ Test 4: POST to Generic Webhook"
echo "-----------------------------------"
curl -X POST "$GENERIC_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "test.event",
    "source": "test-script",
    "data": {
      "message": "Testing generic webhook endpoint"
    }
  }' \
  -w "\n📊 HTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Test 5: Health Check (Expected: 200 OK)
echo "✅ Test 5: Health Check"
echo "-----------------------"
curl -X GET "$BASE_URL/api/health" \
  -w "\n📊 HTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

echo "======================================"
echo "🎉 All tests completed!"
echo ""
echo "Expected Results:"
echo "  ✅ Test 1: HTTP 200 (Success)"
echo "  ❌ Test 2: HTTP 405 (Method Not Allowed)"
echo "  ❌ Test 3: HTTP 400 (Bad Request)"
echo "  ✅ Test 4: HTTP 200 (Success)"
echo "  ✅ Test 5: HTTP 200 (Success)"
echo ""
echo "Usage: ./test_webhooks.sh [BASE_URL]"
echo "Example: ./test_webhooks.sh https://your-domain.railway.app"
