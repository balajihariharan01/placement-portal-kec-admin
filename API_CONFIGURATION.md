# API Configuration Guide

## Overview
This document describes the API configuration for the KEC Placement Portal application.

## Environment Configuration

### Frontend (Next.js)

The frontend uses environment variables to configure the API connection:

**Production** (`.env.production`):
```env
NEXT_PUBLIC_API_URL=https://placement-backend-production-aa69.up.railway.app/api
NEXT_PUBLIC_APP_ENV=production
NEXT_PUBLIC_APP_NAME=KEC Placement Portal
```

**Development** (`.env.development`):
```env
NEXT_PUBLIC_API_URL=http://localhost:8080/api
NEXT_PUBLIC_APP_ENV=development
NEXT_PUBLIC_APP_NAME=KEC Placement Portal
```

### Backend (Go/Fiber)

**Production** (`backend/.env.prod`):
```env
PORT=8080
APP_ENV=production
DB_URL=<your-railway-postgres-url>
JWT_SECRET=<your-secret-key>
CORS_ALLOWED_ORIGINS=https://placement-portal-kec-admin-production.up.railway.app
CLOUDINARY_URL=<your-cloudinary-url>
SMTP_EMAIL=<your-email>
SMTP_PASSWORD=<your-app-password>
```

**Development** (`backend/.env.dev`):
```env
PORT=8080
APP_ENV=development
DB_URL=postgresql://postgres:postgres@localhost:5432/placement_portal?sslmode=disable
JWT_SECRET=dev-secret-key
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

## Security Features

### 1. CORS Configuration
- Production: Only allows requests from specific Railway frontend domain
- Development: Allows localhost origins
- Configured via `CORS_ALLOWED_ORIGINS` environment variable

### 2. HTTPS Enforcement
- Production automatically converts HTTP to HTTPS
- Certificate validation enabled for production

### 3. Authentication
- JWT-based authentication
- Tokens stored in localStorage
- Automatic token injection via axios interceptors
- Auto-redirect to login on 401/403 errors

### 4. Request Features
- **Timeout**: 30 seconds default
- **Retry Logic**: Up to 3 retries for server errors (5xx)
- **Exponential Backoff**: Delays between retries increase exponentially
- **Request Tracking**: X-Request-Time header added to all requests

### 5. Error Handling
- 401/403: Auto-logout and redirect to login
- 404: Resource not found message
- 422: Validation error display
- 429: Rate limiting message
- 5xx: Automatic retry with user notification
- Network errors: Connection check prompt
- Timeout errors: Dedicated timeout message

## API Client Usage

### Basic Usage
```typescript
import api from '@/lib/api';
import { API_ROUTES } from '@/constants/config';

// GET request
const response = await api.get(API_ROUTES.ADMIN_DRIVES);

// POST request
const response = await api.post(API_ROUTES.ADMIN_AUTH.LOGIN, { email, password });

// PUT request
const response = await api.put(`${API_ROUTES.ADMIN_DRIVES}/${id}`, data);

// DELETE request
const response = await api.delete(`${API_ROUTES.ADMIN_DRIVES}/${id}`);
```

### Health Check
```typescript
import { checkAPIHealth } from '@/lib/api';

const isHealthy = await checkAPIHealth();
if (!isHealthy) {
  console.error('API is not responding');
}
```

### Custom Timeout
```typescript
// Override default timeout for specific requests
const response = await api.get('/some-endpoint', { timeout: 60000 }); // 60 seconds
```

## Deployment Checklist

### Frontend (Railway)
1. ✅ Set environment variables in Railway dashboard:
   - `NEXT_PUBLIC_API_URL=https://placement-backend-production-aa69.up.railway.app/api`
   - `NEXT_PUBLIC_APP_ENV=production`
2. ✅ Deploy from main branch
3. ✅ Verify build completes successfully
4. ✅ Test frontend can reach backend

### Backend (Railway)
1. ✅ Set environment variables in Railway dashboard:
   - `PORT=8080`
   - `APP_ENV=production`
   - `DB_URL=<railway-postgres-connection-string>`
   - `JWT_SECRET=<secure-random-string>`
   - `CORS_ALLOWED_ORIGINS=https://placement-portal-kec-admin-production.up.railway.app`
   - `CLOUDINARY_URL=<cloudinary-connection-string>`
   - `SMTP_EMAIL=<email>`
   - `SMTP_PASSWORD=<app-password>`
2. ✅ Deploy from main branch
3. ✅ Verify Go build completes
4. ✅ Check logs for successful startup
5. ✅ Test `/api/health` endpoint

## Testing

### Health Check
```bash
# Backend health
curl https://placement-backend-production-aa69.up.railway.app/api/health

# Expected response:
# {"status":"success"}
```

### CORS Check
```bash
# Test CORS from allowed origin
curl -H "Origin: https://placement-portal-kec-admin-production.up.railway.app" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Authorization" \
     -X OPTIONS \
     https://placement-backend-production-aa69.up.railway.app/api/v1/drives
```

## Scaling Considerations

1. **Connection Pooling**: Database connections are pooled automatically
2. **Stateless Design**: JWT tokens allow horizontal scaling
3. **CDN Ready**: Static assets can be served via CDN
4. **Rate Limiting**: Implement rate limiting at load balancer level
5. **Monitoring**: Add application performance monitoring (APM)
6. **Caching**: Consider Redis for session/data caching

## Troubleshooting

### CORS Errors
- Verify `CORS_ALLOWED_ORIGINS` includes your frontend domain
- Check for trailing slashes in origins
- Ensure protocol (http/https) matches

### 401 Errors
- Check JWT token is valid
- Verify JWT_SECRET matches between deployments
- Check token expiration

### Timeout Errors
- Increase timeout for slow endpoints
- Check database query performance
- Verify network connectivity

### Connection Refused
- Verify backend is running
- Check PORT configuration
- Ensure Railway service is deployed
