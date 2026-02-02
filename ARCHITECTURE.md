# System Architecture - Frontend-Backend Connection

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          PRODUCTION ENVIRONMENT                          │
│                              (Railway Platform)                          │
└─────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────┐         ┌─────────────────────────────┐
│  Frontend Service (Next.js)    │         │  Backend Service (Go)       │
│  ─────────────────────────     │         │  ──────────────────────     │
│                                │         │                             │
│  Domain:                       │         │  Domain:                    │
│  placement-portal-kec-admin-   │◄───────►│  placement-backend-         │
│  production.up.railway.app     │  HTTPS  │  production-aa69.up.        │
│                                │         │  railway.app                │
│                                │         │                             │
│  Environment:                  │         │  Environment:               │
│  • NEXT_PUBLIC_API_URL ────────┼────────►│  • PORT=8080               │
│    (Backend URL)               │         │  • APP_ENV=production       │
│  • NEXT_PUBLIC_APP_ENV ────────┼────────►│  • JWT_SECRET              │
│    (production)                │         │  • CORS_ALLOWED_ORIGINS ◄──┼──┐
│                                │         │    (Frontend URL)           │  │
│                                │         │                             │  │
│  Components:                   │         │  Components:                │  │
│  • API Client (Axios)          │         │  • Fiber App                │  │
│    - Timeout: 30s              │         │  • CORS Middleware          │  │
│    - Retry: 3x                 │         │  • JWT Middleware           │  │
│    - Error Interceptor         │         │  • Route Handlers           │  │
│    - HTTPS Enforcer            │         │  • Database Connection      │  │
│                                │         │                             │  │
└────────────────────────────────┘         └──────────────┬──────────────┘  │
                                                          │                 │
                                                          │                 │
                                          ┌───────────────▼────────────┐    │
                                          │  PostgreSQL Database       │    │
                                          │  ─────────────────────     │    │
                                          │                            │    │
                                          │  Host: yamanote.proxy.     │    │
                                          │        rlwy.net            │    │
                                          │  Port: 12728               │    │
                                          │  SSL: Required             │    │
                                          │                            │    │
                                          └────────────────────────────┘    │
                                                                            │
┌───────────────────────────────────────────────────────────────────────────┘
│
│  CORS VALIDATION FLOW
│  ════════════════════
│
│  1. Browser sends request with Origin header
│  2. Backend checks Origin against CORS_ALLOWED_ORIGINS
│  3. If allowed, responds with CORS headers
│  4. Browser allows response
│
└───────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                         REQUEST/RESPONSE FLOW
═══════════════════════════════════════════════════════════════════════════

┌──────────┐                ┌──────────┐                ┌──────────┐
│  Browser │                │ Frontend │                │ Backend  │
└────┬─────┘                └────┬─────┘                └────┬─────┘
     │                           │                           │
     │  1. User Action           │                           │
     ├──────────────────────────►│                           │
     │                           │                           │
     │                           │  2. API Call              │
     │                           │     • Add Auth Token      │
     │                           │     • Add Tracking Header │
     │                           │     • Set Timeout (30s)   │
     │                           ├──────────────────────────►│
     │                           │                           │
     │                           │                           │  3. Validate
     │                           │                           │     • Check CORS
     │                           │                           │     • Verify JWT
     │                           │                           │     • Process Req
     │                           │                           │
     │                           │  4. Response              │
     │                           │◄──────────────────────────┤
     │                           │                           │
     │  5. Interceptor           │                           │
     │     • Check Status        │                           │
     │     • Handle Errors       │                           │
     │     • Retry if 5xx        │                           │
     │     • Update UI           │                           │
     │                           │                           │
     │  6. Display Result        │                           │
     │◄──────────────────────────┤                           │
     │                           │                           │


═══════════════════════════════════════════════════════════════════════════
                         ERROR HANDLING FLOW
═══════════════════════════════════════════════════════════════════════════

Error Type          Action                          User Experience
──────────────────────────────────────────────────────────────────────────
401/403             • Clear localStorage            • Toast: "Session expired"
Unauthorized        • Redirect to /login            • Auto-redirect to login
                    • Show error toast              

404                 • Show error toast              • Toast: "Resource not found"
Not Found           • No retry                      

422                 • Show validation message       • Toast: "Validation error: ..."
Validation          • No retry                      

429                 • Show rate limit message       • Toast: "Too many requests"
Rate Limit          • No retry                      

5xx                 • Retry up to 3 times           • First: Silent retry
Server Error        • Exponential backoff           • After 3: "Server error"
                    • Show toast after max          

Network             • Show connection error         • Toast: "Check connection"
Error               • No retry                      

Timeout             • Show timeout message          • Toast: "Request timeout"
(>30s)              • No retry                      


═══════════════════════════════════════════════════════════════════════════
                      SECURITY LAYERS
═══════════════════════════════════════════════════════════════════════════

Layer 1: HTTPS
├─ All traffic encrypted (TLS 1.2+)
├─ Automatic via Railway
└─ Frontend enforces HTTPS in production

Layer 2: CORS
├─ Whitelist-based origin checking
├─ Only allows specific domains
├─ Configured via environment variable
└─ Blocks unauthorized origins

Layer 3: Authentication
├─ JWT token-based
├─ Token stored in localStorage
├─ Auto-injected in request headers
├─ Auto-logout on 401/403
└─ Configurable expiration

Layer 4: Request Security
├─ Timeout prevents hanging (30s)
├─ Retry logic for reliability
├─ Request tracking headers
└─ Error message sanitization

Layer 5: Database
├─ SSL/TLS required
├─ Channel binding enabled
├─ Connection pooling
└─ No direct internet access


═══════════════════════════════════════════════════════════════════════════
                    ENVIRONMENT CONFIGURATION
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────┐
│         DEVELOPMENT                      │
├─────────────────────────────────────────┤
│                                          │
│  Frontend                                │
│  • API_URL: http://localhost:8080/api   │
│  • APP_ENV: development                  │
│                                          │
│  Backend                                 │
│  • PORT: 8080                            │
│  • CORS: localhost:3000, 127.0.0.1:3000 │
│  • DB: Local PostgreSQL                  │
│                                          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         PRODUCTION                       │
├─────────────────────────────────────────┤
│                                          │
│  Frontend                                │
│  • API_URL: https://backend.railway.app │
│  • APP_ENV: production                   │
│                                          │
│  Backend                                 │
│  • PORT: 8080                            │
│  • CORS: https://frontend.railway.app   │
│  • DB: Railway PostgreSQL                │
│                                          │
└─────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                       API ENDPOINT STRUCTURE
═══════════════════════════════════════════════════════════════════════════

/api
│
├── /health                          [GET]   Public - Health check
│
├── /v1
│   │
│   ├── /auth                         
│   │   ├── /login                    [POST]  Public - Student login
│   │   └── /logout                   [POST]  Public - Logout
│   │
│   ├── /admin
│   │   │
│   │   ├── /auth
│   │   │   ├── /login               [POST]  Public - Admin login
│   │   │   ├── /forgot-password     [POST]  Public - Password reset
│   │   │   ├── /reset-password      [POST]  Public - Password reset
│   │   │   └── /register            [POST]  Public - Register
│   │   │
│   │   ├── /drives                  [GET]   Protected (Admin) - List drives
│   │   │   ├── /                    [POST]  Protected (Admin) - Create drive
│   │   │   ├── /:id                 [PUT]   Protected (Admin) - Update drive
│   │   │   ├── /:id                 [DEL]   Protected (Admin) - Delete drive
│   │   │   └── /:id/applicants      [GET]   Protected (Admin) - Get applicants
│   │   │
│   │   └── /students                [GET]   Protected (Admin) - List students
│   │       ├── /                    [POST]  Protected (Admin) - Create student
│   │       ├── /:id                 [GET]   Protected (Admin) - Get student
│   │       ├── /:id                 [DEL]   Protected (Admin) - Delete student
│   │       └── /bulk-upload         [POST]  Protected (Admin) - Bulk upload
│   │
│   └── /drives                       [GET]   Protected - Student drives
│       └── /:id/apply                [POST]  Protected - Apply to drive
│
└── /webhooks
    ├── /whatsapp                     [ALL]   Public - WhatsApp webhook
    ├── /railway                      [POST]  Public - Railway webhook
    └── /generic                      [POST]  Public - Generic webhook


Legend:
  [GET]  - Read operation
  [POST] - Create operation
  [PUT]  - Update operation
  [DEL]  - Delete operation
  [ALL]  - All HTTP methods
  Public - No authentication required
  Protected - JWT token required
  Protected (Admin) - JWT token + admin role required
```
