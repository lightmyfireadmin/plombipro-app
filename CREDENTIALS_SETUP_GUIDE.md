# PlombiFacto - Credentials & Platform Access Setup Guide

**Security First:** This guide explains how to securely provide credentials for development.

---

## 🔐 Required Platform Access

### 1. Supabase (Database & Storage)

**What I Need:**
- Project URL
- Anon/Public API Key (for client-side)
- Service Role Key (for server-side/Cloud Functions)
- Database connection string (optional, for migrations)

**How to Provide:**
1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Navigate to: **Settings → API**
4. Copy the following:
   - `Project URL`
   - `anon public` key
   - `service_role` key (⚠️ Keep secret!)

**Where to Put Them:**
Create a file: `lib/.env` (already in .gitignore)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**For Cloud Functions:**
These will be set as environment variables in Google Cloud.

---

### 2. Stripe (Payment Processing)

**What I Need:**
- Publishable Key (client-side)
- Secret Key (server-side)
- Webhook Signing Secret
- Test Mode vs Production Mode decision

**How to Provide:**
1. Go to: https://dashboard.stripe.com
2. Make sure you're in **Test Mode** (toggle top-right)
3. Navigate to: **Developers → API keys**
4. Copy:
   - `Publishable key` (starts with `pk_test_`)
   - `Secret key` (starts with `sk_test_`)
5. For webhook secret:
   - Go to **Developers → Webhooks**
   - Click on your webhook endpoint (or create one)
   - Copy `Signing secret` (starts with `whsec_`)

**Where to Put Them:**
Add to `lib/.env`:
```env
STRIPE_PUBLISHABLE_KEY=pk_test_51...
STRIPE_SECRET_KEY=sk_test_51...
STRIPE_WEBHOOK_SECRET=whsec_...
```

**Note:** We'll use Test Mode for development. You can switch to Production when ready.

---

### 3. Google Cloud Platform (Cloud Functions, Vision API)

**What I Need:**
- Project ID
- Service Account JSON key file
- Vision API enabled

**How to Provide:**

#### Step 1: Create/Use Existing GCP Project
1. Go to: https://console.cloud.google.com
2. Create a new project or select existing: `plombipro-app`
3. Note your `Project ID`

#### Step 2: Enable Required APIs
1. In GCP Console, go to **APIs & Services → Library**
2. Enable the following:
   - Cloud Functions API
   - Cloud Vision API
   - Cloud Scheduler API
   - Cloud Storage API

#### Step 3: Create Service Account
1. Go to: **IAM & Admin → Service Accounts**
2. Click **Create Service Account**
3. Name: `plombipro-cloud-functions`
4. Grant roles:
   - Cloud Functions Developer
   - Cloud Vision API User
   - Storage Object Admin
   - Pub/Sub Publisher (for schedulers)
5. Click **Done**
6. Click on the created service account
7. Go to **Keys → Add Key → Create New Key**
8. Choose **JSON**
9. Download the JSON file

**Where to Put It:**
Save the JSON file as: `cloud_functions/service-account-key.json`

⚠️ **IMPORTANT:** This file is in `.gitignore`. Never commit it!

**Add to `lib/.env`:**
```env
GCP_PROJECT_ID=plombipro-app-123456
```

---

### 4. SendGrid (Email Service)

**What I Need:**
- API Key
- Verified sender email address

**How to Provide:**
1. Go to: https://app.sendgrid.com
2. Create account (free tier: 100 emails/day)
3. Navigate to: **Settings → API Keys**
4. Click **Create API Key**
5. Name: `PlombiPro Production`
6. Choose **Full Access**
7. Copy the API key (starts with `SG.`)

**Verify Sender:**
1. Go to: **Settings → Sender Authentication**
2. Verify either:
   - Single Sender Verification (easier, for testing)
   - Domain Authentication (professional, for production)
3. Use your business email (e.g., `noreply@plombifacto.fr`)

**Where to Put It:**
Add to `lib/.env`:
```env
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@plombifacto.fr
SENDGRID_FROM_NAME=PlombiFacto
```

---

### 5. Firebase (Push Notifications, Analytics)

**What I Need:**
- Firebase project configuration
- google-services.json (Android)
- GoogleService-Info.plist (iOS)

**How to Provide:**
1. Go to: https://console.firebase.google.com
2. Select your project (or create one)
3. Add apps if not already done:

**For Android:**
1. Click **Add app → Android**
2. Package name: `com.plombipro.app` (check `android/app/build.gradle`)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

**For iOS:**
1. Click **Add app → iOS**
2. Bundle ID: `com.plombipro.app` (check `ios/Runner.xcodeproj`)
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

**For Web:**
1. Click **Add app → Web**
2. Copy the Firebase config
3. Update `lib/firebase_options.dart`

**Already configured?** Just verify the files exist in the paths above.

---

### 6. Point P & Cedeo (Web Scraping - Optional for now)

**What I Need:**
- Nothing initially! We'll start with public data.

**Note:** Web scraping is in Phase 2. We'll implement it carefully to respect:
- robots.txt
- Rate limiting
- Terms of Service

If you have official API access or partnerships, let me know!

---

## 📝 Complete .env File Template

Here's the complete template. Create this file and fill in your values:

**File:** `lib/.env`

```env
# ======================
# SUPABASE
# ======================
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx

# ======================
# STRIPE
# ======================
STRIPE_PUBLISHABLE_KEY=pk_test_51xxxxxxxxx
STRIPE_SECRET_KEY=sk_test_51xxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxx

# ======================
# GOOGLE CLOUD PLATFORM
# ======================
GCP_PROJECT_ID=plombipro-app-123456

# ======================
# SENDGRID (EMAIL)
# ======================
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@plombifacto.fr
SENDGRID_FROM_NAME=PlombiFacto

# ======================
# CHORUS PRO (Optional - Phase 2)
# ======================
CHORUS_PRO_LOGIN=your_login
CHORUS_PRO_PASSWORD=your_password
CHORUS_PRO_TECHNICAL_ID=your_tech_id

# ======================
# DEVELOPMENT
# ======================
ENVIRONMENT=development
DEBUG_MODE=true
```

---

## 🚀 How to Provide Credentials Securely

### Option 1: Share .env File Directly (Recommended)
1. Create the `lib/.env` file with all credentials
2. Share it via:
   - **Secure method:** Encrypted email (use ProtonMail or similar)
   - **Best method:** Password-protected ZIP file, share password separately
   - **For team:** Use a secret manager (AWS Secrets Manager, 1Password, etc.)

### Option 2: Paste Directly in Chat (Less Secure)
You can paste credentials directly here, but:
- ⚠️ Only do this in a private session
- ⚠️ Remember to rotate keys after project completion
- ⚠️ I'll use them only for this project

### Option 3: Environment Variables (For Production)
For production deployment:
- Set environment variables in Vercel/Netlify (for web)
- Set in Google Cloud Functions (for cloud functions)
- Use Flutter dotenv to load them

---

## 🔧 Cloud Functions Environment Setup

For each cloud function, we need to set environment variables:

```bash
# Navigate to cloud function
cd cloud_functions/ocr_processor

# Set environment variables
gcloud functions deploy ocr_processor \
  --set-env-vars SUPABASE_URL=https://xxx.supabase.co \
  --set-env-vars SUPABASE_KEY=eyJxxx \
  --set-env-vars GCP_PROJECT_ID=plombipro-123
```

I'll create a deployment script to automate this.

---

## ✅ Verification Checklist

After providing credentials, I'll verify:

- [ ] Supabase connection works (fetch profiles)
- [ ] Supabase Storage works (upload test file)
- [ ] Stripe test payment works
- [ ] SendGrid sends test email
- [ ] Google Vision API processes test image
- [ ] Cloud Functions deploy successfully
- [ ] Firebase notifications work

---

## 🔒 Security Best Practices

### What I'll Do:
1. ✅ Never commit credentials to Git
2. ✅ Use `.env` files (already in `.gitignore`)
3. ✅ Use environment variables for cloud functions
4. ✅ Rotate test keys before production
5. ✅ Use Stripe Test Mode during development
6. ✅ Implement Row Level Security (RLS) in Supabase

### What You Should Do:
1. 🔐 Use **Test/Development** keys during development
2. 🔐 Create separate **Production** keys when launching
3. 🔐 Enable 2FA on all platform accounts
4. 🔐 Review Supabase RLS policies before production
5. 🔐 Set up Stripe webhook signatures
6. 🔐 Monitor API usage for anomalies

---

## 📊 Platform Costs (Estimated)

### Free Tiers During Development:
- **Supabase:** Free tier (500 MB database, 1 GB storage)
- **Stripe:** Free (no monthly fee, just transaction fees)
- **SendGrid:** Free tier (100 emails/day)
- **Google Vision API:** $1.50 per 1,000 images (first 1,000 free/month)
- **Cloud Functions:** Free tier (2M invocations/month)
- **Firebase:** Free tier (10 GB storage, 10K notifications/month)

**Total for development:** ~$0-10/month

### Production Estimates:
- Supabase Pro: $25/month (for production features)
- SendGrid: $20/month (40K emails)
- Google Cloud: $50-100/month (depending on usage)
- Stripe: Pay per transaction (no monthly fee)

**Total estimated:** ~$100-150/month

---

## 🎯 What's Next?

Once you provide credentials, I'll:

1. **Immediate Setup (Day 1):**
   - Configure `.env` file
   - Test all connections
   - Deploy basic cloud functions
   - Run database migrations

2. **Phase 1 Implementation (Weeks 1-6):**
   - Fix critical bugs
   - Implement auto-numbering
   - Create 50+ templates
   - Enhance OCR
   - Implement Factur-X

3. **Regular Updates:**
   - Daily progress commits
   - Weekly summary reports
   - Deployed test versions for you to review

---

## 📞 Ready When You Are!

Share credentials using your preferred method from above. I recommend:

1. Create `lib/.env` file with all values
2. Share via encrypted email or password-protected ZIP
3. Also provide:
   - GCP Service Account JSON file
   - Firebase config files (if not already in repo)

**I'll notify you immediately** when:
- Credentials are configured ✅
- All connections verified ✅
- First feature is deployed ✅

Let's build this! 🚀

