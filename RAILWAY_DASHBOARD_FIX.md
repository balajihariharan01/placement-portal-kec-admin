# CRITICAL: Railway Dashboard Settings to Check

## 🎯 The Issue

Railway is trying to load config from this URL:
```
https://placement-portal-kec-backend-production.up.railway.app/api/webhooks/railway
```

This is **WRONG** - that's a webhook endpoint, not a config file!

---

## ✅ IMMEDIATE ACTION REQUIRED

### Step 1: Push the Code Fix

```bash
cd c:\college\full
git add .
git commit -m "Fix Railway config URL - add railway.toml"
git push origin main
```

### Step 2: Fix Railway Dashboard Settings

**WHERE TO GO**:

1. **Open Railway Dashboard**: https://railway.app/dashboard
2. **Select your Project**
3. **Click on Backend Service** (the Go API service)
4. **Click "Settings"** (gear icon at top right)

**WHAT TO LOOK FOR** (scroll through ALL settings):

```
┌─────────────────────────────────────────────┐
│ Service Settings                            │
├─────────────────────────────────────────────┤
│                                             │
│ ⚠️ LOOK FOR ANY OF THESE:                  │
│                                             │
│ • Configuration Source                      │
│ • Config URL                                │
│ • Config File URL                           │
│ • Remote Configuration                      │
│ • Service Configuration                     │
│                                             │
│ IF YOU SEE A URL LIKE:                      │
│ ".../api/webhooks/railway"                  │
│                                             │
│ ❌ DELETE IT!                               │
│ ⬜ Leave field EMPTY                        │
│                                             │
└─────────────────────────────────────────────┘
```

### Step 3: Save and Redeploy

1. Click **"Save"** or **"Update"** button
2. Go to **"Deployments"** tab
3. Click **"View Details"** on latest deployment
4. Click **"Redeploy"** button

---

## 🔍 Common Railway Settings Sections

Look through these sections in Backend Service Settings:

### ① General Settings
- **Service Name**: `placement-portal-kec-backend` (or similar)
- **Description**: (optional)

### ② Source Settings
- **Repository**: Should point to your GitHub repo ✅
- **Branch**: `main` ✅
- **Root Directory**: `/backend` or empty ✅
- ⚠️ **Config File**: Should be EMPTY ❌ (DELETE if filled)

### ③ Build Settings
- **Builder**: `NIXPACKS` ✅
- **Build Command**: Auto-detected from `railway.toml` ✅
- **Install Command**: Auto-detected ✅

### ④ Deploy Settings
- **Start Command**: Auto-detected from `railway.toml` ✅
- **Health Check Path**: `/api/health` ✅
- **Restart Policy**: `ON_FAILURE` ✅

### ⑤ Advanced Settings
- ⚠️ **Configuration URL**: Should NOT EXIST or be EMPTY ❌
- ⚠️ **External Config**: Should be DISABLED ❌

---

## 🔴 What NOT to Delete

**KEEP THESE** (don't delete):
- ✅ Environment Variables (all of them!)
- ✅ Repository connection
- ✅ Branch name
- ✅ Root directory setting

**DELETE THESE** (if found):
- ❌ Any URL in "Config" fields
- ❌ "Configuration Source" if it points to a URL
- ❌ Any webhook URL in settings

---

## 🎯 Files You Just Created

These files tell Railway to **NOT load config from URLs**:

1. **`backend/railway.toml`** ← Main fix
   ```toml
   [config]
   loadFromUrl = false
   ```

2. **`frontend/railway.toml`** ← Preventive fix
   ```toml
   [config]
   loadFromUrl = false
   ```

---

## ✅ After You Fix It

Railway will:
1. ✓ Read `railway.toml` from your repository
2. ✓ See `loadFromUrl = false`
3. ✓ **STOP** trying to fetch config from webhook URL
4. ✓ Build and deploy successfully

---

## 🔧 Alternative: Delete in Railway CLI

If you have Railway CLI installed:

```bash
# Login
railway login

# Link to your project
railway link

# Check current config
railway config

# If you see a config URL, remove it:
railway config set <key> ""  # Replace <key> with the actual config key name
```

---

## 🆘 Can't Find the Setting?

### Option 1: Recreate Service

If you can't find where the config URL is set:

1. **Backup**: Copy all environment variables
2. **Delete**: Delete the backend service in Railway
3. **Create**: Create new service from GitHub
4. **Configure**: Set root directory, env vars
5. **Deploy**: Push to deploy

### Option 2: Railway Support

1. Join Railway Discord: https://discord.gg/railway
2. Ask in #help channel:
   ```
   My service is trying to load config from:
   https://...up.railway.app/api/webhooks/railway
   
   I've set loadFromUrl=false in railway.toml
   but error persists. How do I clear the
   service-level config URL setting?
   ```

---

## 📊 Quick Checklist

- [ ] Code pushed with `railway.toml` files
- [ ] Checked Backend Service Settings in Railway Dashboard
- [ ] Cleared any "Config URL" or similar fields
- [ ] Saved changes in Railway
- [ ] Redeployed service
- [ ] Checked deployment logs (no config URL error)
- [ ] Tested `/api/health` endpoint

---

## ✅ Success Indicators

You'll know it's fixed when:

1. **Build logs show**:
   ```
   ✓ Using railway.toml configuration
   ✓ Config loaded from repository
   ```

2. **NO errors about**:
   ```
   ❌ config file ... does not exist
   ```

3. **Health check works**:
   ```bash
   curl https://.../api/health
   # Returns: {"status":"success"}
   ```

---

**NEXT STEP**: 

1. ✅ Push the code (with railway.toml)
2. ➡️ GO TO RAILWAY DASHBOARD NOW
3. ➡️ CHECK SERVICE SETTINGS
4. ➡️ CLEAR ANY CONFIG URL FIELDS
5. ➡️ REDEPLOY

Do this NOW before Railway tries to deploy again!
