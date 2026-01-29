# Railway Webhook Endpoint Test Script (PowerShell)
# This script tests all webhook endpoints to ensure they work correctly

param(
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "🧪 Testing Railway Webhook Endpoints" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$RailwayWebhookUrl = "$BaseUrl/api/webhooks/railway"
$GenericWebhookUrl = "$BaseUrl/api/webhooks/generic"
$HealthCheckUrl = "$BaseUrl/api/health"

Write-Host "📍 Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Test 1: POST to Railway Webhook (Expected: 200 OK)
Write-Host "✅ Test 1: POST to Railway Webhook" -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Gray
$body1 = @{
    type = "deployment.success"
    projectId = "test-project-123"
    timestamp = "2026-01-29T05:30:00Z"
    data = @{
        deploymentId = "dep-test-123"
        environmentId = "env-test-456"
        status = "success"
    }
} | ConvertTo-Json

try {
    $response1 = Invoke-WebRequest -Uri $RailwayWebhookUrl -Method POST -Body $body1 -ContentType "application/json" -UseBasicParsing
    Write-Host $response1.Content -ForegroundColor White
    Write-Host "📊 HTTP Status: $($response1.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "📊 HTTP Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}
Write-Host ""
Write-Host ""

# Test 2: GET to Railway Webhook (Expected: 405 Method Not Allowed)
Write-Host "❌ Test 2: GET to Railway Webhook (Should Fail with 405)" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------" -ForegroundColor Gray
try {
    $response2 = Invoke-WebRequest -Uri $RailwayWebhookUrl -Method GET -UseBasicParsing
    Write-Host $response2.Content -ForegroundColor White
    Write-Host "📊 HTTP Status: $($response2.StatusCode)" -ForegroundColor Cyan
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Expected error (405 Method Not Allowed)" -ForegroundColor Yellow
    Write-Host "📊 HTTP Status: $statusCode" -ForegroundColor Cyan
    
    # Read error response body
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host $errorBody -ForegroundColor White
}
Write-Host ""
Write-Host ""

# Test 3: Invalid JSON to Railway Webhook (Expected: 400 Bad Request)
Write-Host "❌ Test 3: Invalid JSON to Railway Webhook (Should Fail with 400)" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------------" -ForegroundColor Gray
$invalidBody = "invalid-json{"
try {
    $response3 = Invoke-WebRequest -Uri $RailwayWebhookUrl -Method POST -Body $invalidBody -ContentType "application/json" -UseBasicParsing
    Write-Host $response3.Content -ForegroundColor White
    Write-Host "📊 HTTP Status: $($response3.StatusCode)" -ForegroundColor Cyan
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Expected error (400 Bad Request)" -ForegroundColor Yellow
    Write-Host "📊 HTTP Status: $statusCode" -ForegroundColor Cyan
    
    # Read error response body
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host $errorBody -ForegroundColor White
}
Write-Host ""
Write-Host ""

# Test 4: POST to Generic Webhook (Expected: 200 OK)
Write-Host "✅ Test 4: POST to Generic Webhook" -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Gray
$body4 = @{
    event = "test.event"
    source = "test-script"
    data = @{
        message = "Testing generic webhook endpoint"
    }
} | ConvertTo-Json

try {
    $response4 = Invoke-WebRequest -Uri $GenericWebhookUrl -Method POST -Body $body4 -ContentType "application/json" -UseBasicParsing
    Write-Host $response4.Content -ForegroundColor White
    Write-Host "📊 HTTP Status: $($response4.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "📊 HTTP Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}
Write-Host ""
Write-Host ""

# Test 5: Health Check (Expected: 200 OK)
Write-Host "✅ Test 5: Health Check" -ForegroundColor Green
Write-Host "-----------------------" -ForegroundColor Gray
try {
    $response5 = Invoke-WebRequest -Uri $HealthCheckUrl -Method GET -UseBasicParsing
    Write-Host $response5.Content -ForegroundColor White
    Write-Host "📊 HTTP Status: $($response5.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "📊 HTTP Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}
Write-Host ""
Write-Host ""

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🎉 All tests completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "  ✅ Test 1: HTTP 200 (Success)" -ForegroundColor White
Write-Host "  ❌ Test 2: HTTP 405 (Method Not Allowed)" -ForegroundColor White
Write-Host "  ❌ Test 3: HTTP 400 (Bad Request)" -ForegroundColor White
Write-Host "  ✅ Test 4: HTTP 200 (Success)" -ForegroundColor White
Write-Host "  ✅ Test 5: HTTP 200 (Success)" -ForegroundColor White
Write-Host ""
Write-Host "Usage: .\test_webhooks.ps1 [-BaseUrl <URL>]" -ForegroundColor Cyan
Write-Host "Example: .\test_webhooks.ps1 -BaseUrl https://your-domain.railway.app" -ForegroundColor Cyan
