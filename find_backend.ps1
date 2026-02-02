# Quick Script to Find Your Railway Backend Domain
# This will test common Railway URL patterns and find which one is your backend

Write-Host "Finding Your Railway Backend Domain..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Based on your frontend: placement-portal-kec-admin-production.up.railway.app
# Testing common backend URL patterns

$patterns = @(
    "https://placement-portal-kec-backend-production.up.railway.app",
    "https://placement-portal-kec-admin-backend-production.up.railway.app",
    "https://placement-api-production.up.railway.app",
    "https://kec-placement-backend-production.up.railway.app",
    "https://backend-placement-portal-kec-production.up.railway.app"
)

$found = $false

foreach ($url in $patterns) {
    Write-Host "Testing: $url" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri "$url/api/health" -Method GET -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "FOUND! This is your backend!" -ForegroundColor Green
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "YOUR EXACT WEBHOOK URL" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Backend Domain:" -ForegroundColor Cyan
            Write-Host "  $url" -ForegroundColor White
            Write-Host ""
            Write-Host "Railway Webhook URL:" -ForegroundColor Cyan
            Write-Host "  $url/api/webhooks/railway" -ForegroundColor Green
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            
            # Test the webhook endpoint
            Write-Host "Testing webhook endpoint..." -ForegroundColor Yellow
            $webhookUrl = "$url/api/webhooks/railway"
            $testPayload = @{
                type = "deployment.success"
                projectId = "test-project"
                timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
                data = @{
                    deploymentId = "test-123"
                    status = "success"
                }
            } | ConvertTo-Json
            
            try {
                $webhookResponse = Invoke-WebRequest -Uri $webhookUrl -Method POST -Body $testPayload -ContentType "application/json" -UseBasicParsing
                if ($webhookResponse.StatusCode -eq 200) {
                    Write-Host "Webhook endpoint is working! Response:" -ForegroundColor Green
                    Write-Host $webhookResponse.Content -ForegroundColor White
                }
            } catch {
                Write-Host "Webhook test failed. Make sure latest code is deployed." -ForegroundColor Yellow
            }
            
            $found = $true
            break
        }
    } catch {
        Write-Host "Not this one" -ForegroundColor Red
    }
    
    Write-Host ""
}

if (-not $found) {
    Write-Host ""
    Write-Host "Could not automatically find your backend domain." -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual Steps:" -ForegroundColor Yellow
    Write-Host "1. Go to Railway Dashboard: https://railway.app" -ForegroundColor White
    Write-Host "2. Open your project: placement-portal-kec-admin" -ForegroundColor White
    Write-Host "3. Find your Backend/Go API service" -ForegroundColor White
    Write-Host "4. Click Settings -> Networking -> Copy Public Domain" -ForegroundColor White
    Write-Host "5. Your webhook URL will be: https://[YOUR-DOMAIN]/api/webhooks/railway" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
