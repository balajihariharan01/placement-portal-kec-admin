# Railway Webhook Integration - Fix Documentation

## 🔴 Problem Identified

**Error:** `Response status: 405 Method Not Allowed`

**Root Cause:**
Railway webhooks were configured to send POST requests to `/login`, which is a **frontend route** that doesn't accept POST requests. Frontend routes are designed for browser navigation (GET requests) and do not have backend handlers for POST requests.

---

## ✅ Solution Implemented

Created a dedicated backend webhook endpoint that:
- ✅ Accepts **POST requests only**
- ✅ Validates and parses **JSON payloads**
- ✅ Returns **HTTP 200** on success
- ✅ Returns **HTTP 405** for non-POST methods
- ✅ Logs webhook events for monitoring
- ✅ Provides extensible event processing

---

## 🚀 Correct Railway Webhook URL

### Production (Railway Deployment)
```
https://your-domain.railway.app/api/webhooks/railway
```

**Example:**
- If your backend is deployed at: `https://placement-portal-kec.railway.app`
- Then your webhook URL is: `https://placement-portal-kec.railway.app/api/webhooks/railway`

### Local Development
```
http://localhost:8080/api/webhooks/railway
```

---

## 📋 Railway Webhook Configuration Steps

1. **Go to Railway Dashboard**
   - Navigate to your project
   - Click on **Settings** → **Webhooks**

2. **Add/Edit Webhook**
   - Click **"Add Webhook"** or edit existing webhook
   - Enter the webhook URL: `https://your-domain.railway.app/api/webhooks/railway`
   - Select events (recommended: `deployment.success`, `deployment.failed`, `deployment.started`)

3. **Save Configuration**
   - Click **"Save"**
   - Railway will send a test POST request to verify the endpoint

4. **Verify**
   - Check your application logs for: `Railway Webhook Received:`
   - You should see a 200 OK response in Railway's webhook logs

---

## 🔧 Additional Webhook Endpoints Available

### 1. Railway Webhook (Recommended for Railway events)
```
POST /api/webhooks/railway
```
**Use Case:** Deployment events, environment changes, alerts

### 2. WhatsApp Cloud API Webhook
```
GET/POST /api/webhooks/whatsapp
```
**Use Case:** WhatsApp bot integration (already implemented)

### 3. Generic Webhook (For any external service)
```
POST /api/webhooks/generic
```
**Use Case:** Any third-party service that sends POST webhooks (GitHub, Stripe, etc.)

---

## 🧪 Testing the Webhook

### Test with cURL
```bash
curl -X POST https://your-domain.railway.app/api/webhooks/railway \
  -H "Content-Type: application/json" \
  -d '{
    "type": "deployment.success",
    "projectId": "test-project",
    "timestamp": "2026-01-29T05:30:00Z",
    "data": {
      "deploymentId": "test-123",
      "status": "success"
    }
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Webhook received successfully",
  "type": "deployment.success",
  "timestamp": "2026-01-29T05:30:00Z"
}
```

### Test with Postman
1. Create a new POST request
2. URL: `https://your-domain.railway.app/api/webhooks/railway`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "type": "deployment.success",
  "projectId": "your-project-id",
  "timestamp": "2026-01-29T05:30:00Z",
  "data": {
    "deploymentId": "dep-123",
    "environmentId": "env-456",
    "status": "success"
  }
}
```
5. Send → Expect 200 OK response

---

## 📊 Webhook Event Types Supported

| Event Type | Description |
|-----------|-------------|
| `deployment.success` | Triggered when deployment completes successfully |
| `deployment.failed` | Triggered when deployment fails |
| `deployment.started` | Triggered when deployment starts |
| Custom events | Add your own event handling in the switch statement |

---

## 🔍 Monitoring Webhook Activity

### Check Application Logs
After deployment, monitor your Railway application logs:

```bash
# You should see entries like:
Railway Webhook Received:
{
  "type": "deployment.success",
  "projectId": "your-project-id",
  "timestamp": "2026-01-29T05:30:00Z",
  "data": {
    "deploymentId": "xxx",
    "status": "success"
  }
}
✅ Deployment successful for project: your-project-id
```

### Railway Webhook Logs
In Railway Dashboard → Settings → Webhooks:
- You'll see delivery history
- HTTP status codes (should be 200)
- Response times
- Retry attempts (if any)

---

## ⚠️ Important Notes

### 1. **Never Use Frontend Routes for Webhooks**
❌ **Wrong:** `https://your-domain.com/login`  
✅ **Correct:** `https://your-domain.com/api/webhooks/railway`

Frontend routes are designed for browser navigation, not API requests.

### 2. **Always Use Backend API Endpoints**
All webhooks must point to your **backend API** endpoints (paths starting with `/api/`)

### 3. **CORS is Not an Issue**
Since webhooks are server-to-server communication (Railway → Your Backend), CORS policies don't apply.

### 4. **Security Considerations**
For production, consider adding:
- Webhook signature verification
- Rate limiting
- IP whitelisting (Railway IPs)

Example with signature verification:
```go
func HandleRailwayWebhook(c *fiber.Ctx) error {
    // Verify webhook signature
    signature := c.Get("X-Railway-Signature")
    if !verifySignature(c.Body(), signature) {
        return c.Status(401).JSON(fiber.Map{
            "success": false,
            "error": "Invalid signature"
        })
    }
    // ... rest of handler
}
```

---

## ✅ Final Verification Checklist

### Before Deployment
- [x] Webhook endpoint accepts POST requests
- [x] Webhook endpoint parses JSON payloads
- [x] Webhook endpoint returns HTTP 200
- [x] Webhook endpoint returns HTTP 405 for non-POST methods
- [x] Logging is implemented for debugging

### After Deployment
- [ ] Update Railway webhook URL to: `https://your-domain.railway.app/api/webhooks/railway`
- [ ] Send test webhook from Railway dashboard
- [ ] Verify 200 OK response in Railway webhook logs
- [ ] Check application logs for webhook receipt confirmation
- [ ] Remove old `/login` webhook configuration (if exists)

### Testing
- [ ] Test with cURL or Postman
- [ ] Verify error handling (try GET request → expect 405)
- [ ] Verify invalid JSON handling (expect 400)
- [ ] Monitor logs for successful webhook processing

---

## 🎯 Summary

**What Changed:**
1. Created dedicated Railway webhook handler: `/api/webhooks/railway`
2. Implemented POST-only validation with proper error responses
3. Added JSON payload parsing and logging
4. Returns HTTP 200 on success as Railway expects

**What to Do Next:**
1. Deploy the updated backend to Railway
2. Update Railway webhook URL to point to `/api/webhooks/railway`
3. Test the webhook and verify logs

**Result:**
✅ Railway webhooks will now receive proper 200 OK responses  
✅ No more 405 Method Not Allowed errors  
✅ Frontend routes remain unchanged  
✅ All existing functionality preserved
