# Security Configuration

## Overview

This document outlines the security measures implemented in the KEC Placement Portal.

## Authentication & Authorization

### JWT Configuration

- **Algorithm**: HS256 (HMAC with SHA-256)
- **Token Storage**: localStorage (Frontend)
- **Token Transmission**: Authorization header (Bearer scheme)
- **Token Expiration**: Configurable in backend

### Security Headers

All API requests include:
- `Authorization: Bearer <token>`
- `X-Request-Time: <ISO timestamp>`

## CORS (Cross-Origin Resource Sharing)

### Production Configuration

```go
AllowOrigins:     "https://placement-portal-kec-admin-production.up.railway.app"
AllowMethods:     "GET,POST,PUT,DELETE,OPTIONS"
AllowHeaders:     "Origin,Content-Type,Accept,Authorization"
AllowCredentials: true
MaxAge:           3600 // Cache preflight for 1 hour
```

### Development Configuration

```go
AllowOrigins: "http://localhost:3000,http://127.0.0.1:3000"
```

### Key Features

1. **Whitelist Only**: Only specified origins can access the API
2. **Credentials Support**: Allows cookies/auth headers
3. **Method Restriction**: Limited to required HTTP methods
4. **Preflight Caching**: Reduces OPTIONS requests

## HTTPS/TLS

### Production

- ✅ Railway provides automatic SSL/TLS certificates
- ✅ All connections forced to HTTPS
- ✅ Frontend auto-converts HTTP to HTTPS in production
- ✅ Certificate auto-renewal

### Implementation

Frontend automatically enforces HTTPS:
```typescript
if (process.env.NEXT_PUBLIC_APP_ENV === 'production' && url.startsWith('http://')) {
  console.warn('⚠️ Converting HTTP to HTTPS for production');
  return url.replace('http://', 'https://');
}
```

## Environment Variable Security

### What NOT to Commit

❌ `.env`  
❌ `.env.local`  
❌ `.env.production`  
❌ `.env.development`  
❌ Any file containing secrets  

### What to Commit

✅ `.env.example` (template without actual values)  
✅ Configuration structure documentation  

### Secret Management

1. **Development**: Use `.env.development` (gitignored)
2. **Production**: Set in Railway dashboard
3. **Rotation**: Change secrets periodically
4. **Access**: Limit who can view production secrets

## Request Security

### Timeout Configuration

```typescript
const API_TIMEOUT = 30000; // 30 seconds
```

Prevents:
- Hanging requests
- Resource exhaustion
- Denial of service

### Retry Logic

```typescript
const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // Exponential backoff
```

Features:
- Only retries on server errors (5xx)
- Exponential backoff prevents thundering herd
- Automatic failure after max retries

### Rate Limiting

Currently implemented at Railway level. Consider adding:
- Application-level rate limiting
- Per-user rate limits
- IP-based throttling

## Error Handling

### Secure Error Messages

Production errors never expose:
- Stack traces
- Internal paths
- Database structure
- System information

### Error Logging

- Client: Sanitized user-friendly messages
- Server: Detailed logs (not sent to client)
- Monitoring: Centralized error tracking

## Input Validation

### Frontend

- Type checking with TypeScript
- Form validation before submission
- Sanitization of user inputs

### Backend

- Request body validation
- SQL injection prevention (prepared statements)
- XSS protection
- CSRF tokens (if using cookies)

## Database Security

### Connection

```
postgresql://user:pass@host:port/db?sslmode=require&channel_binding=require
```

Features:
- ✅ SSL/TLS encrypted connections
- ✅ Channel binding for extra security
- ✅ Connection pooling limits
- ✅ Prepared statements

### Best Practices

1. Use Postgres roles and permissions
2. Separate read/write users
3. Regular backups
4. No direct database access from internet
5. Railway private networking

## Session Management

### Token Lifecycle

1. **Login**: Token generated and sent to client
2. **Storage**: Stored in localStorage
3. **Usage**: Sent with every request
4. **Expiry**: Auto-logout on 401/403
5. **Logout**: Token removed from localStorage

### Auto-Logout

```typescript
if (status === 401 || status === 403) {
  localStorage.removeItem('token');
  if (!window.location.pathname.includes('/login')) {
    window.location.href = '/login';
  }
}
```

## API Security

### Endpoint Protection

- ✅ Public endpoints: `/api/v1/auth/*`
- ✅ Protected endpoints: All others require JWT
- ✅ Role-based access: Admin vs Student routes
- ✅ Swagger UI: Available but documents auth requirements

### HTTP Methods

- `GET`: Read operations
- `POST`: Create operations
- `PUT`: Update operations
- `DELETE`: Delete operations
- `OPTIONS`: CORS preflight (auto-handled)

## File Upload Security

### Cloudinary Integration

```env
CLOUDINARY_URL=cloudinary://key:secret@cloud_name
```

Security measures:
1. File type validation
2. File size limits
3. Virus scanning (Cloudinary)
4. Signed URLs for downloads
5. No direct file system access

## Email Security

### SMTP Configuration

```env
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=app_specific_password
```

Best practices:
- Use app-specific passwords (not main password)
- Enable 2FA on email account
- Rate limit email sending
- Validate email addresses
- Prevent email injection

## Monitoring & Logging

### What to Log

✅ Authentication attempts  
✅ Authorization failures  
✅ API errors (5xx)  
✅ Unusual activity  
✅ Performance metrics  

### What NOT to Log

❌ Passwords  
❌ JWT tokens  
❌ Credit card numbers  
❌ Personal sensitive data  
❌ Full request bodies with secrets  

## Incident Response

### If Secrets Are Compromised

1. **Immediate**: Rotate compromised secrets
2. **Update**: Environment variables in Railway
3. **Redeploy**: All affected services
4. **Invalidate**: Old JWT tokens
5. **Notify**: Users if necessary
6. **Audit**: Review access logs

### Security Checklist

- [ ] All secrets in environment variables
- [ ] No secrets in git history
- [ ] CORS restricted to production domains
- [ ] HTTPS enforced
- [ ] JWT secret is strong (64+ chars)
- [ ] Database connection uses SSL
- [ ] Error messages don't leak info
- [ ] Rate limiting configured
- [ ] Input validation on all endpoints
- [ ] Regular dependency updates
- [ ] Monitoring/alerts configured
- [ ] Backup/recovery plan

## Compliance

### Data Protection

- Minimal data collection
- Secure data storage
- Encrypted data transmission
- User data access controls
- Data retention policies

### Privacy

- Clear privacy policy
- User consent for data usage
- Right to data deletion
- Secure password storage (hashed)

## Regular Maintenance

### Weekly

- [ ] Review error logs
- [ ] Check for failed login attempts
- [ ] Monitor API usage

### Monthly

- [ ] Update dependencies
- [ ] Review access logs
- [ ] Rotate secrets (recommended)
- [ ] Security audit

### Quarterly

- [ ] Penetration testing
- [ ] Code security review
- [ ] Update security documentation
- [ ] Review and update policies

## Resources

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Railway Security**: https://docs.railway.app/reference/security
- **Go Security**: https://golang.org/doc/security
- **Next.js Security**: https://nextjs.org/docs/advanced-features/security-headers

## Contact

For security issues, contact:
- Email: security@yourapp.com (setup recommended)
- Report via Railway support
- GitHub security advisories
