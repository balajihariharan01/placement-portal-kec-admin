# KEC Placement Portal - Admin Dashboard

A production-ready placement portal system with secure frontend-backend integration, deployed on Railway.

[![Production](https://img.shields.io/badge/Production-Live-success)](https://placement-portal-kec-admin-production.up.railway.app)
[![Backend](https://img.shields.io/badge/Backend-API-blue)](https://placement-backend-production-aa69.up.railway.app/api)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🚀 Live Deployment

- **Frontend**: [placement-portal-kec-admin-production.up.railway.app](https://placement-portal-kec-admin-production.up.railway.app)
- **Backend**: [placement-backend-production-aa69.up.railway.app](https://placement-backend-production-aa69.up.railway.app/api)
- **Health**: [API Health Check](https://placement-backend-production-aa69.up.railway.app/api/health)

---

## 📁 Project Structure

```
placement-portal-kec-admin/
├── frontend/              # Next.js Admin Dashboard
│   ├── src/
│   │   ├── app/          # Next.js app directory
│   │   ├── components/   # React components
│   │   ├── services/     # API service layer
│   │   ├── lib/          # Utilities and API client
│   │   ├── constants/    # Configuration constants
│   │   └── types/        # TypeScript types
│   ├── public/           # Static assets
│   ├── .env.production   # Production environment
│   ├── .env.development  # Development environment
│   └── package.json
│
├── backend/              # Go/Fiber API Server
│   ├── cmd/api/         # Application entry point
│   ├── internal/
│   │   ├── handlers/    # HTTP handlers
│   │   ├── middleware/  # Auth, CORS, etc.
│   │   ├── routes/      # Route definitions
│   │   ├── database/    # Database connection
│   │   └── models/      # Data models
│   ├── .env.prod        # Production environment
│   ├── .env.dev         # Development environment
│   └── go.mod
│
├── student_app/         # Flutter Student Mobile App
│
├── ARCHITECTURE.md      # System architecture diagram
├── API_CONFIGURATION.md # API setup guide
├── RAILWAY_DEPLOYMENT.md # Deployment instructions
├── SECURITY.md          # Security measures
├── PRODUCTION_SETUP.md  # Quick reference
└── SETUP_SUMMARY.md     # Complete setup summary
```

---

## ✨ Features

### Admin Dashboard (Frontend)
- 📊 **Drive Management**: Create, update, and monitor placement drives
- 👥 **Student Management**: View, edit, and manage student profiles
- 📈 **Analytics Dashboard**: Real-time placement statistics
- 📁 **Bulk Operations**: CSV upload for student data
- 🔔 **Notifications**: Real-time updates via WebSocket
- 🎨 **Modern UI**: Built with shadcn/ui components

### Backend API
- 🔐 **JWT Authentication**: Secure token-based auth
- 🛡️ **Role-Based Access**: Admin and Student roles
- 📝 **RESTful API**: Clean API design
- 🗄️ **PostgreSQL**: Reliable database storage
- ☁️ **Cloud Storage**: Cloudinary integration for files
- 📧 **Email Service**: SMTP email notifications

### Security & Performance
- 🔒 **HTTPS Only**: Encrypted connections
- 🌐 **CORS Protection**: Whitelist-based access
- ⏱️ **Request Timeout**: 30-second timeout
- 🔄 **Auto Retry**: 3 retries with exponential backoff
- 🚨 **Error Handling**: Comprehensive error management
- 📊 **Health Monitoring**: Built-in health checks

---

## 🏗️ Tech Stack

### Frontend
- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **UI Library**: React 18
- **Styling**: Tailwind CSS + shadcn/ui
- **State Management**: React Context
- **HTTP Client**: Axios
- **Forms**: React Hook Form

### Backend
- **Language**: Go 1.21+
- **Framework**: Fiber v2
- **Database**: PostgreSQL (Railway)
- **Authentication**: JWT
- **File Storage**: Cloudinary
- **Email**: SMTP (Gmail)

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Go 1.21+
- PostgreSQL (local or Railway)

### Local Development

#### 1. Clone the repository
```bash
git clone <your-repo-url>
cd placement-portal-kec-admin
```

#### 2. Setup Frontend
```bash
cd frontend
cp .env.example .env.development
npm install
npm run dev
```

Frontend will run on `http://localhost:3000`

#### 3. Setup Backend
```bash
cd backend
cp .env.dev .env
go mod download
go run cmd/api/main.go
```

Backend will run on `http://localhost:8080`

#### 4. Test Connection
Open browser console on frontend and run:
```javascript
testAPI.runAll()
```

---

## 🌐 Production Deployment

### Railway Deployment

Complete deployment guide: [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)

**Quick Steps:**

1. **Backend Setup**
   - Create Railway service from GitHub
   - Set environment variables (see below)
   - Deploy automatically

2. **Frontend Setup**
   - Create Railway service from GitHub
   - Set environment variables (see below)
   - Deploy automatically

3. **Environment Variables**

   Frontend:
   ```env
   NEXT_PUBLIC_API_URL=https://placement-backend-production-aa69.up.railway.app/api
   NEXT_PUBLIC_APP_ENV=production
   ```

   Backend:
   ```env
   PORT=8080
   APP_ENV=production
   DB_URL=<railway-postgres-url>
   JWT_SECRET=<your-secret>
   CORS_ALLOWED_ORIGINS=https://placement-portal-kec-admin-production.up.railway.app
   CLOUDINARY_URL=<cloudinary-url>
   SMTP_EMAIL=<email>
   SMTP_PASSWORD=<app-password>
   ```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [SETUP_SUMMARY.md](SETUP_SUMMARY.md) | Complete setup summary |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture |
| [API_CONFIGURATION.md](API_CONFIGURATION.md) | API setup guide |
| [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) | Deployment guide |
| [SECURITY.md](SECURITY.md) | Security measures |
| [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md) | Quick reference |

---

## 🔒 Security Features

- ✅ HTTPS enforced in production
- ✅ CORS whitelist protection
- ✅ JWT token authentication
- ✅ Environment-based configuration
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ Rate limiting ready
- ✅ Secure password hashing
- ✅ SSL database connections
- ✅ Auto-logout on auth failure

---

## 🧪 Testing

### Backend Health Check
```bash
curl https://placement-backend-production-aa69.up.railway.app/api/health
```

Expected: `{"status":"success"}`

### Frontend Connection Test
Open browser console:
```javascript
// Run all tests
testAPI.runAll()

// Individual tests
testAPI.testConnection()
testAPI.testProtected()
testAPI.testAdmin()
```

---

## 📊 API Endpoints

### Public Endpoints
- `POST /api/v1/auth/login` - Student login
- `POST /api/v1/admin/auth/login` - Admin login
- `GET /api/health` - Health check

### Protected Endpoints (Admin)
- `GET /api/v1/admin/drives` - List all drives
- `POST /api/v1/admin/drives` - Create drive
- `PUT /api/v1/admin/drives/:id` - Update drive
- `DELETE /api/v1/admin/drives/:id` - Delete drive
- `GET /api/v1/admin/students` - List students
- `POST /api/v1/admin/students/bulk-upload` - Bulk upload

### Protected Endpoints (Student)
- `GET /api/v1/drives` - List available drives
- `POST /api/v1/drives/:id/apply` - Apply to drive
- `GET /api/v1/student/profile` - Get profile

Full API documentation: See Swagger at `/swagger`

---

## 🛠️ Development

### Scripts

Frontend:
```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Lint code
```

Backend:
```bash
go run cmd/api/main.go    # Start dev server
go build -o app cmd/api/main.go  # Build binary
go test ./...         # Run tests
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License.

---

## 👥 Team

- **Frontend**: Next.js + TypeScript
- **Backend**: Go + Fiber
- **Database**: PostgreSQL
- **Deployment**: Railway
- **Cloud Storage**: Cloudinary

---

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Check documentation files
- Review Railway logs
- Test with provided utilities

---

## 🎉 Acknowledgments

- Railway for hosting
- shadcn/ui for components
- Fiber for Go framework
- Next.js team

---

**Status**: 🟢 Production Ready

Last Updated: 2026-02-02

