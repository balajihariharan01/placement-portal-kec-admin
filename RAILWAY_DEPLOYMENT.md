# Railway Deployment Guide

## Quick Start

This guide will help you deploy the KEC Placement Portal to Railway with proper frontend-backend integration.

## Prerequisites

- Railway account (https://railway.app)
- GitHub repository connected to Railway
- PostgreSQL database provisioned on Railway

## Deployment URLs

- **Frontend**: https://placement-portal-kec-admin-production.up.railway.app
- **Backend**: https://placement-backend-production-aa69.up.railway.app

## Step 1: Backend Deployment

### 1.1 Create Backend Service

1. Go to Railway dashboard
2. Create a new project or use existing
3. Click "New Service" → "GitHub Repo"
4. Select your repository
5. Set root directory to `/backend` (if monorepo)

### 1.2 Configure Environment Variables

Add the following environment variables in Railway dashboard:

```env
PORT=8080
APP_ENV=production
DB_URL=<your-railway-postgres-url>
JWT_SECRET=<generate-a-secure-random-string>
CORS_ALLOWED_ORIGINS=https://placement-portal-kec-admin-production.up.railway.app
CLOUDINARY_URL=cloudinary://your_key:your_secret@your_cloud
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

**Important Notes:**
- Get `DB_URL` from your Railway PostgreSQL service variables
- Generate a strong `JWT_SECRET` (64+ characters recommended)
- `CORS_ALLOWED_ORIGINS` must match your frontend domain exactly

### 1.3 Verify Backend Build

1. Railway will auto-detect Go and build
2. Check deployment logs for errors
3. Verify service is running on port 8080
4. Test health endpoint: `https://your-backend-url.up.railway.app/api/health`

Expected response:
```json
{"status":"success"}
```

## Step 2: Frontend Deployment

### 2.1 Create Frontend Service

1. In the same Railway project, click "New Service"
2. Select the same GitHub repository
3. Set root directory to `/frontend` (if monorepo)

### 2.2 Configure Environment Variables

Add these environment variables:

```env
NEXT_PUBLIC_API_URL=https://placement-backend-production-aa69.up.railway.app/api
NEXT_PUBLIC_APP_ENV=production
NEXT_PUBLIC_APP_NAME=KEC Placement Portal
```

**Important:** Ensure `NEXT_PUBLIC_API_URL` points to your backend service URL!

### 2.3 Verify Frontend Build

1. Railway will detect Next.js and build automatically
2. Check build logs
3. Ensure build completes without errors
4. Visit your frontend URL to verify deployment

## Step 3: Configure Networking

### 3.1 Generate Public URLs

1. Both services should have public URLs generated automatically
2. Copy the backend URL
3. Update frontend environment variable `NEXT_PUBLIC_API_URL` with backend URL
4. Copy frontend URL
5. Update backend environment variable `CORS_ALLOWED_ORIGINS` with frontend URL

### 3.2 Redeploy Services

After updating environment variables:
1. Redeploy backend service (to pick up new CORS settings)
2. Redeploy frontend service (to pick up new API URL)

## Step 4: Database Setup

### 4.1 Run Schema Migration

If you haven't already, run your database schema:

```bash
# From your local machine
psql -h yamanote.proxy.rlwy.net -U postgres -p 12728 -d railway -f "backend/project_schema.sql"
```

Or use Railway's CLI:
```bash
railway run psql $DATABASE_URL -f backend/project_schema.sql
```

### 4.2 Verify Database Connection

Check backend logs for successful database connection:
```
✅ Database connected successfully
```

## Step 5: Testing

### 5.1 Health Check

Test backend health:
```bash
curl https://placement-backend-production-aa69.up.railway.app/api/health
```

### 5.2 CORS Verification

From your browser console on the frontend:
```javascript
fetch('https://placement-backend-production-aa69.up.railway.app/api/health')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error)
```

Should return `{status: "success"}` without CORS errors.

### 5.3 Authentication Test

1. Visit your frontend
2. Navigate to login page
3. Attempt login with test credentials
4. Check browser network tab for successful API calls

## Step 6: Monitoring & Logs

### 6.1 View Logs

- Railway Dashboard → Select Service → Logs tab
- Monitor for errors, warnings, or performance issues

### 6.2 Metrics

- Check Railway metrics for CPU, memory, network usage
- Set up alerts for downtime or high resource usage

## Troubleshooting

### CORS Errors

**Symptom:** Browser console shows CORS policy errors

**Solutions:**
1. Verify `CORS_ALLOWED_ORIGINS` in backend matches frontend URL exactly
2. Check for trailing slashes (use both with and without)
3. Ensure protocol (https) matches
4. Redeploy backend after changing CORS settings

### 401/403 Errors

**Symptom:** All API calls return unauthorized errors

**Solutions:**
1. Verify JWT_SECRET is set correctly
2. Check token is being sent in Authorization header
3. Ensure token hasn't expired
4. Clear browser localStorage and login again

### Cannot Connect to Backend

**Symptom:** Network error or connection refused

**Solutions:**
1. Verify backend service is running in Railway
2. Check backend logs for startup errors
3. Ensure PORT is set to 8080
4. Verify DATABASE_URL is correct
5. Check Railway service health status

### Database Connection Failed

**Symptom:** Backend logs show database connection errors

**Solutions:**
1. Verify DB_URL format: `postgresql://user:pass@host:port/db?sslmode=require`
2. Check PostgreSQL service is running
3. Verify database credentials
4. Ensure SSL mode is set correctly

### Frontend Build Failures

**Symptom:** Frontend deployment fails during build

**Solutions:**
1. Check Node.js version compatibility
2. Verify all dependencies are in package.json
3. Clear Railway build cache and rebuild
4. Check for TypeScript errors in build logs

### Environment Variables Not Loading

**Symptom:** App uses default/wrong values

**Solutions:**
1. Verify variables are set in Railway dashboard
2. For frontend, ensure variables start with `NEXT_PUBLIC_`
3. Redeploy after adding/changing variables
4. Check Railway doesn't have duplicate services

## Production Checklist

Before going live, ensure:

- [ ] All environment variables are set correctly
- [ ] CORS origins match production domains
- [ ] JWT_SECRET is strong and unique
- [ ] Database schema is migrated
- [ ] Health endpoints return success
- [ ] HTTPS is enforced (Railway does this automatically)
- [ ] Error logging is working
- [ ] Authentication flow works end-to-end
- [ ] File uploads work (if applicable)
- [ ] Email sending works (if applicable)
- [ ] Frontend-backend communication is successful
- [ ] All sensitive data in .env files (not hardcoded)
- [ ] .env files are in .gitignore
- [ ] Database backups are configured
- [ ] Monitoring/alerts are set up

## Scaling Considerations

### Horizontal Scaling

Railway supports horizontal scaling:
1. Go to service settings
2. Increase replica count
3. Railway will load-balance automatically

### Database Scaling

For PostgreSQL:
1. Monitor connection pool usage
2. Consider upgrading Railway Postgres plan
3. Implement connection pooling (PgBouncer)

### Performance Optimization

1. Enable CDN for static assets
2. Implement Redis caching for frequent queries
3. Add database indexes for common queries
4. Enable compression for API responses
5. Use Railway's built-in caching

## Security Best Practices

1. ✅ Use environment variables for all secrets
2. ✅ Enable HTTPS only (Railway does this)
3. ✅ Restrict CORS to specific origins
4. ✅ Use strong JWT secrets (64+ characters)
5. ✅ Implement rate limiting
6. ✅ Sanitize all user inputs
7. ✅ Use prepared statements for SQL
8. ✅ Regular security audits
9. ✅ Keep dependencies updated
10. ✅ Monitor for suspicious activity

## Continuous Deployment

Railway automatically deploys on git push:

1. Push to main branch
2. Railway detects changes
3. Builds and deploys automatically
4. Zero-downtime deployment

To disable auto-deploy:
- Go to Service Settings → Deploy
- Disable "Auto Deploy"

## Support & Resources

- **Railway Docs**: https://docs.railway.app
- **Railway Discord**: https://discord.gg/railway
- **Status Page**: https://status.railway.app
- **API Docs**: Your backend `/swagger` endpoint

## Summary

Your application is now production-ready with:

✅ Secure HTTPS endpoints  
✅ Environment-based configuration  
✅ CORS whitelist protection  
✅ Centralized API service with retry logic  
✅ Request timeout and error handling  
✅ Auto-scaling support  
✅ Database connection pooling  
✅ Health monitoring endpoints  
✅ Production error logging  

**Frontend**: https://placement-portal-kec-admin-production.up.railway.app  
**Backend**: https://placement-backend-production-aa69.up.railway.app/api  
**Health**: https://placement-backend-production-aa69.up.railway.app/api/health
