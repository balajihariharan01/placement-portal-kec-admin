# Pre-Deployment Verification Checklist

Use this checklist before deploying to production to ensure everything is configured correctly.

---

## 🔧 Configuration Verification

### Frontend Configuration

- [ ] `.env.production` file exists
- [ ] `NEXT_PUBLIC_API_URL` is set to: `https://placement-backend-production-aa69.up.railway.app/api`
- [ ] `NEXT_PUBLIC_APP_ENV` is set to: `production`
- [ ] `.env` files are in `.gitignore`
- [ ] No hardcoded API URLs in code

**Verify:**
```bash
cat frontend/.env.production
```

### Backend Configuration

- [ ] `.env.prod` file exists
- [ ] `PORT` is set to: `8080`
- [ ] `APP_ENV` is set to: `production`
- [ ] `DB_URL` is set correctly (Railway PostgreSQL)
- [ ] `JWT_SECRET` is strong (64+ characters)
- [ ] `CORS_ALLOWED_ORIGINS` includes frontend URL exactly
- [ ] `CLOUDINARY_URL` is set
- [ ] `SMTP_EMAIL` and `SMTP_PASSWORD` are set
- [ ] `.env` files are in `.gitignore`

**Verify:**
```bash
cat backend/.env.prod
```

---

## 🔒 Security Verification

### CORS Settings

- [ ] Backend `CORS_ALLOWED_ORIGINS` matches frontend URL exactly
- [ ] No wildcard (`*`) in CORS origins
- [ ] Both HTTP and HTTPS versions considered
- [ ] Trailing slash handled correctly

### HTTPS

- [ ] Frontend enforces HTTPS in production
- [ ] Backend accepts HTTPS requests
- [ ] No mixed content warnings

### Authentication

- [ ] JWT_SECRET is unique and strong
- [ ] Token expiration is configured
- [ ] Auto-logout on 401/403 works
- [ ] Protected routes require authentication

### Environment Variables

- [ ] No secrets in git repository
- [ ] All `.env` files in `.gitignore`
- [ ] `.env.example` files don't contain real secrets
- [ ] Railway environment variables are set

---

## 🧪 Testing Checklist

### Backend Tests

**Health Check:**
```bash
curl https://placement-backend-production-aa69.up.railway.app/api/health
```
- [ ] Returns `{"status":"success"}`
- [ ] Response time < 1 second
- [ ] No CORS errors

**CORS Test:**
```bash
curl -H "Origin: https://placement-portal-kec-admin-production.up.railway.app" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS \
     https://placement-backend-production-aa69.up.railway.app/api/v1/drives
```
- [ ] Returns CORS headers
- [ ] No errors in response

### Frontend Tests

**From Browser Console:**
```javascript
testAPI.runAll()
```

- [ ] All connection tests pass
- [ ] CORS configuration verified
- [ ] Health check successful
- [ ] API URL is correct

### Authentication Flow

- [ ] Can login as admin
- [ ] Can login as student
- [ ] Token is stored in localStorage
- [ ] Token is sent in requests
- [ ] Protected routes are accessible after login
- [ ] Unauthorized access redirects to login

### End-to-End Tests

- [ ] Create a drive (admin)
- [ ] View drives (student)
- [ ] Upload student CSV (admin)
- [ ] Apply to drive (student)
- [ ] View applicants (admin)
- [ ] Update drive status (admin)

---

## 🚀 Railway Deployment

### Frontend Service

- [ ] Service created in Railway
- [ ] Connected to GitHub repository
- [ ] Root directory set (if monorepo)
- [ ] Environment variables configured
- [ ] Auto-deploy enabled
- [ ] Build completed successfully
- [ ] Service is running
- [ ] Public URL accessible

### Backend Service

- [ ] Service created in Railway
- [ ] Connected to GitHub repository
- [ ] Root directory set (if monorepo)
- [ ] Environment variables configured
- [ ] Auto-deploy enabled
- [ ] Build completed successfully
- [ ] Service is running on port 8080
- [ ] Public URL accessible

### Database Service

- [ ] PostgreSQL service provisioned
- [ ] Connection string obtained
- [ ] Schema migrated successfully
- [ ] Backups configured
- [ ] SSL connection working

---

## 📊 Monitoring & Logs

### Railway Logs

**Frontend:**
- [ ] No build errors
- [ ] No runtime errors
- [ ] No CORS errors
- [ ] API calls successful

**Backend:**
- [ ] Server starts successfully
- [ ] Database connection established
- [ ] No panic or fatal errors
- [ ] API requests being logged

### Browser Console

- [ ] No CORS errors
- [ ] No 404 errors for API calls
- [ ] No authentication errors
- [ ] API responses successful

---

## 📁 File Verification

### Created Files

- [ ] `frontend/.env.production`
- [ ] `frontend/.env.development`
- [ ] `frontend/.env.example`
- [ ] `frontend/src/utils/test-api-connection.ts`
- [ ] `backend/.env.prod` (updated)
- [ ] `backend/.env.dev`
- [ ] `API_CONFIGURATION.md`
- [ ] `RAILWAY_DEPLOYMENT.md`
- [ ] `SECURITY.md`
- [ ] `PRODUCTION_SETUP.md`
- [ ] `SETUP_SUMMARY.md`
- [ ] `ARCHITECTURE.md`
- [ ] `.gitignore` (updated)

### Updated Files

- [ ] `frontend/src/lib/api.ts` (enhanced)
- [ ] `frontend/src/constants/config.ts` (enhanced)
- [ ] `backend/cmd/api/main.go` (CORS config)
- [ ] `README.md` (updated)

---

## 🔄 Post-Deployment

### Immediate Checks (First 5 Minutes)

- [ ] Frontend loads without errors
- [ ] Backend health endpoint responds
- [ ] Can create an admin account
- [ ] Can login successfully
- [ ] Dashboard loads correctly
- [ ] Can fetch drives
- [ ] Can fetch students

### Within 1 Hour

- [ ] Test all major features
- [ ] Check Railway metrics (CPU, memory, network)
- [ ] Review logs for errors
- [ ] Test error scenarios
- [ ] Verify email sending works
- [ ] Test file uploads
- [ ] Check database connections

### Within 24 Hours

- [ ] Monitor for any crashes
- [ ] Review error logs
- [ ] Check response times
- [ ] Test with multiple users
- [ ] Verify auto-scaling (if enabled)
- [ ] Check database performance
- [ ] Review security logs

---

## 🐛 Common Issues & Solutions

### Issue: CORS Error in Browser

**Solution:**
1. Verify `CORS_ALLOWED_ORIGINS` in backend
2. Check for trailing slash mismatch
3. Ensure HTTPS protocol matches
4. Redeploy backend after changes

### Issue: 401 Unauthorized

**Solution:**
1. Clear localStorage in browser
2. Login again
3. Check JWT_SECRET matches
4. Verify token is being sent

### Issue: Cannot Connect to Backend

**Solution:**
1. Check backend is running in Railway
2. Verify `NEXT_PUBLIC_API_URL` is correct
3. Test health endpoint directly
4. Check Railway service status

### Issue: Database Connection Failed

**Solution:**
1. Verify `DB_URL` format
2. Check PostgreSQL service is running
3. Test connection with psql
4. Verify SSL mode is correct

---

## ✅ Final Verification

Before marking as production-ready:

- [ ] All environment variables configured
- [ ] All tests passing
- [ ] No errors in logs
- [ ] Documentation updated
- [ ] Team members can access
- [ ] Backup plan in place
- [ ] Rollback plan documented
- [ ] Monitoring enabled
- [ ] Contact information updated

---

## 📞 Emergency Contacts

### Railway Support
- Dashboard: https://railway.app/dashboard
- Discord: https://discord.gg/railway
- Status: https://status.railway.app

### Team Contacts
- Backend Lead: [Add contact]
- Frontend Lead: [Add contact]
- DevOps: [Add contact]

---

## 🎉 Deployment Complete!

Once all items are checked:

1. Mark deployment as successful in Railway
2. Update team on deployment status
3. Monitor for first 24 hours
4. Collect feedback from users
5. Plan for next iteration

---

**Deployment Date**: _________________

**Deployed By**: _________________

**Verification Completed**: ☐ Yes  ☐ No

**Status**: ☐ Production Ready  ☐ Needs Fixes

**Notes**:
_______________________________________________________
_______________________________________________________
_______________________________________________________
