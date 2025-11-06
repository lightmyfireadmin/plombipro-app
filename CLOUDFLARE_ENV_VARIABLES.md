# Cloudflare Environment Variables Guide

## What Cloudflare is Used For

Based on your PlombiPro architecture:
- **Mobile App**: Distributed via App Store/Google Play (NO Cloudflare needed)
- **Backend**: Supabase (NO Cloudflare needed - has its own CDN)
- **Cloud Functions**: Google Cloud (NO Cloudflare needed)
- **Website**: This is where Cloudflare comes in

---

## Scenario 1: Marketing/Landing Page Only

If you have a **simple marketing website** (HTML/CSS/JS) that just shows:
- Product information
- Pricing
- Contact form
- Links to download the app

### Required Environment Variables: **MINIMAL**

```bash
# Cloudflare Pages Environment Variables

# For contact form (if you have one)
CONTACT_FORM_ENDPOINT=https://your-supabase-url.supabase.co/functions/v1/contact-form

# For analytics (optional)
GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX

# Public info only (these can be public)
APP_STORE_LINK=https://apps.apple.com/app/plombipro
GOOGLE_PLAY_LINK=https://play.google.com/store/apps/details?id=com.plombipro

# NO sensitive keys needed!
# NO SUPABASE_ANON_KEY needed (unless you're querying data)
# NO STRIPE keys needed (marketing site doesn't process payments)
```

**Why so minimal?**
- Static site doesn't connect to database
- No user authentication
- No sensitive data
- Just displays information

---

## Scenario 2: Flutter Web Build (Full App in Browser)

If you deployed the **PlombiPro Flutter app as a web app** using `flutter build web`:

### Required Environment Variables: **SAME AS MOBILE APP**

```bash
# Cloudflare Pages Environment Variables

# Supabase (REQUIRED)
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Stripe (REQUIRED for payments)
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx
# or for testing:
# STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx

# Optional: Cloud Functions URLs
INVOICE_GENERATOR_URL=https://europe-west1-your-project.cloudfunctions.net/invoice_generator
OCR_PROCESSOR_URL=https://europe-west1-your-project.cloudfunctions.net/ocr_processor
CHORUS_PRO_URL=https://europe-west1-your-project.cloudfunctions.net/chorus_pro_submitter

# Build environment
FLUTTER_WEB=true
```

**How to deploy Flutter Web to Cloudflare Pages:**
```bash
# Build the Flutter web app
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx

# The output will be in build/web/
# Upload this to Cloudflare Pages
```

---

## Scenario 3: Admin Dashboard (Separate Web App)

If you have a **separate admin/analytics dashboard** (React, Vue, etc.):

### Required Environment Variables: **DEPENDS ON FEATURES**

```bash
# Cloudflare Pages Environment Variables

# Supabase (REQUIRED)
VITE_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# OR if using service role for admin access (BE CAREFUL!)
# SUPABASE_SERVICE_ROLE_KEY=eyJ... # ONLY for server-side rendering!

# Analytics (if using external service)
VITE_GOOGLE_ANALYTICS=G-XXXXXXXXXX

# Stripe (if showing payment stats)
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx

# Other APIs
VITE_SENTRY_DSN=https://xxx@sentry.io/xxx # Error tracking
```

**Note:** Use framework-specific prefixes:
- Vite/Vue: `VITE_`
- Next.js: `NEXT_PUBLIC_`
- Create React App: `REACT_APP_`

---

## What You Should NOT Add to Cloudflare

### ❌ Never Add These (Server-Side Only):

```bash
# NEVER add these to Cloudflare Pages (client-side)
SUPABASE_SERVICE_ROLE_KEY=xxx  # Can bypass RLS - DANGEROUS!
STRIPE_SECRET_KEY=sk_live_xxx  # Can charge cards!
GOOGLE_CLOUD_API_KEY=xxx       # Can access your GCP resources
CHORUS_PRO_CLIENT_SECRET=xxx   # Government API credentials
DATABASE_PASSWORD=xxx           # Direct database access

# These belong in:
# - Cloud Functions (Google Cloud Secret Manager)
# - Supabase Edge Functions (Supabase Vault)
# - Backend servers only
```

**Why?** Client-side code is visible to anyone. Never expose secrets!

---

## How to Set Environment Variables in Cloudflare Pages

### Via Dashboard:

1. Go to **Cloudflare Dashboard** → **Pages**
2. Select your project
3. Go to **Settings** → **Environment Variables**
4. Add variables for **Production** and **Preview** separately

### Via Wrangler CLI:

```bash
# Install Wrangler
npm install -g wrangler

# Login
wrangler login

# Set environment variables
wrangler pages project create plombipro-website

# Add secrets (for sensitive values)
wrangler pages secret put SUPABASE_ANON_KEY
# Paste the key when prompted

# Deploy
wrangler pages publish ./build
```

### Via `.env` file (for local development only):

```bash
# .env.local (DO NOT COMMIT TO GIT!)
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

Add to `.gitignore`:
```
.env
.env.local
.env.*.local
```

---

## Recommended Setup by Use Case

### 📄 Static Marketing Site
```bash
# Minimal - just for contact form
CONTACT_FORM_ENDPOINT=https://xxx.supabase.co/functions/v1/contact
```

### 🌐 Flutter Web App
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
```

### 📊 Admin Dashboard
```bash
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
VITE_GOOGLE_ANALYTICS=G-XXX
```

---

## Testing Environment Variables

Create a simple test page to verify they're loaded:

```html
<!-- test.html -->
<!DOCTYPE html>
<html>
<head>
  <title>Env Vars Test</title>
</head>
<body>
  <h1>Environment Variables Test</h1>
  <div id="output"></div>

  <script>
    // For Vite/Vue
    const envVars = {
      supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
      hasSupabaseKey: !!import.meta.env.VITE_SUPABASE_ANON_KEY,
      hasStripeKey: !!import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY
    };

    // For plain HTML sites
    // const envVars = {
    //   supabaseUrl: window.ENV?.SUPABASE_URL || 'NOT SET',
    //   // etc.
    // };

    document.getElementById('output').innerHTML = `
      <pre>${JSON.stringify(envVars, null, 2)}</pre>
    `;
  </script>
</body>
</html>
```

---

## Security Checklist for Cloudflare Pages

- ✅ Only use public/publishable keys (anon keys, publishable Stripe keys)
- ✅ Add `.env` files to `.gitignore`
- ✅ Use different keys for Production vs Preview environments
- ✅ Set CORS headers on your APIs to only allow your Cloudflare domain
- ✅ Enable Cloudflare Access if you want password protection
- ❌ Never commit API keys to Git
- ❌ Never use service role keys client-side
- ❌ Never expose secret keys

---

## Common Issues

### Issue: "Environment variable not defined"
**Solution:**
1. Check variable name matches exactly (case-sensitive)
2. Restart dev server after adding `.env` variables
3. In Cloudflare Pages, make sure you set it for the correct environment (Production/Preview)

### Issue: "Supabase connection fails"
**Solution:**
1. Verify `SUPABASE_URL` format: `https://xxx.supabase.co` (no trailing slash)
2. Check `SUPABASE_ANON_KEY` is the **anon public** key, not service role
3. Check CORS settings in Supabase Dashboard

### Issue: "Variables work locally but not in Cloudflare"
**Solution:**
1. Cloudflare Pages needs variables set in Dashboard, not just `.env`
2. Make sure you're using the correct prefix (`VITE_`, `NEXT_PUBLIC_`, etc.)
3. Redeploy after adding environment variables

---

## Next Steps

1. **Identify your use case** (marketing site, Flutter web, or admin dashboard)
2. **Set only the required variables** from the appropriate section above
3. **Test locally** with `.env` file
4. **Deploy to Cloudflare** and set environment variables in dashboard
5. **Verify** with the test page above

---

## Need Help?

If you tell me which type of website you have, I can provide:
- Exact environment variables needed
- Step-by-step Cloudflare Pages deployment guide
- Build commands and output directory settings
