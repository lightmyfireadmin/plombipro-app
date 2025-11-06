# Cloudflare Pages Deployment Guide for PlombiPro

## Problem

Your Flutter app cannot be built directly on Cloudflare Pages because:
- Cloudflare Pages doesn't have Flutter SDK pre-installed
- Installing Flutter in the build environment is complex and time-consuming
- The error you saw: `/bin/sh: 1: flutter: not found`

## Solution: Deploy Pre-Built Flutter Web App

Follow these steps to deploy your Flutter web app to Cloudflare Pages:

---

## Step 1: Build Flutter Web App Locally

On your local machine (where Flutter is installed), run:

```bash
# Make sure you're in the project directory
cd /path/to/plombipro-app

# Clean previous builds
flutter clean

# Build for web (release mode)
flutter build web --release

# This creates the build output in: build/web/
```

**Important**: The `build/web/` directory will contain your compiled Flutter web app.

---

## Step 2: Cloudflare Pages Configuration

### Option A: Deploy via Cloudflare Dashboard (Recommended)

1. **Go to Cloudflare Pages Dashboard**
   - Visit: https://dash.cloudflare.com/
   - Navigate to: Workers & Pages → Create application → Pages → Connect to Git

2. **Connect Your Repository**
   - Repository: `lightmyfireadmin/plombipro-app`
   - Branch: `main` (or create a dedicated deployment branch like `production`)

3. **Configure Build Settings**
   ```
   Framework preset: None
   Build command: (leave empty or use: flutter build web --release)
   Build output directory: build/web
   Root directory: (leave empty)
   Environment variables: (see below)
   ```

4. **Important Build Settings**

   **If building on Cloudflare** (requires Flutter installation - complex):
   - Build command: `flutter build web --release`
   - This will FAIL unless you add Flutter installation steps

   **If using pre-built files** (recommended):
   - Build command: Leave EMPTY or use: `echo "Using pre-built files"`
   - Make sure to commit your `build/web/` directory to git
   - Root directory: `build/web`

### Option B: Deploy via Wrangler CLI

```bash
# Install Wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy from build directory
cd build/web
wrangler pages deploy . --project-name=plombipro-app
```

---

## Step 3: Environment Variables

Add these environment variables in Cloudflare Pages dashboard:

**Settings → Environment Variables**

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

⚠️ **Note**: Flutter web apps bundle environment variables at build time, not runtime. You need to:
1. Set these in your local `.env` file BEFORE building
2. Or use Cloudflare's environment variables if you build on their platform

---

## Step 4: Git Strategy for Deployment

### Strategy A: Commit Build Files (Easiest)

1. **Remove build/ from .gitignore temporarily**

   Edit `.gitignore` and comment out or remove:
   ```
   # build/
   ```

2. **Commit the build**
   ```bash
   git add build/web
   git commit -m "Add pre-built Flutter web app for Cloudflare Pages"
   git push origin main
   ```

3. **Configure Cloudflare Pages**
   - Root directory: `build/web`
   - Build command: (empty)
   - Output directory: `.` (current directory)

### Strategy B: Separate Branch for Production (Recommended)

1. **Create a production branch**
   ```bash
   git checkout -b production
   ```

2. **Build and commit**
   ```bash
   flutter build web --release
   git add -f build/web
   git commit -m "Production build for Cloudflare Pages"
   git push -u origin production
   ```

3. **Configure Cloudflare Pages**
   - Branch: `production`
   - Root directory: `build/web`
   - Build command: (empty)

### Strategy C: Use GitHub Actions (Advanced)

Create `.github/workflows/deploy-cloudflare.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Build Flutter Web
        run: flutter build web --release

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: plombipro-app
          directory: build/web
```

---

## Recommended Solution

**For your immediate needs**, use **Strategy B** (Separate Branch):

```bash
# 1. Build locally
flutter build web --release

# 2. Create production branch
git checkout -b cloudflare-production
git add -f build/web
git commit -m "Add pre-built Flutter web app for Cloudflare deployment"
git push -u origin cloudflare-production

# 3. Configure Cloudflare Pages:
#    - Repository: lightmyfireadmin/plombipro-app
#    - Branch: cloudflare-production
#    - Root directory: build/web
#    - Build command: (empty)
#    - Output directory: .
```

---

## Troubleshooting

### Issue: "Flutter not found" error
**Solution**: Don't build on Cloudflare. Use pre-built files instead (see Strategy B above).

### Issue: "No wrangler.toml file found"
**Solution**: The `wrangler.toml` file has been created for you. It's configured for pre-built deployments.

### Issue: App loads but shows blank page
**Possible causes**:
1. Base href issue - rebuild with: `flutter build web --release --base-href "/"`
2. Missing environment variables - check if your app needs them at build time
3. CORS issues with Supabase - check your Supabase CORS settings

### Issue: Want to deploy only the walkthrough.html
**Solution**: If you only want to deploy the static HTML documentation:
```bash
# Create a new branch with just the static file
git checkout -b static-docs
mkdir public
cp walkthrough.html public/index.html
git add public
git commit -m "Static documentation for Cloudflare"
git push -u origin static-docs

# Configure Cloudflare:
# - Branch: static-docs
# - Root directory: public
# - Build command: (empty)
```

---

## Summary

✅ **Repository**: `lightmyfireadmin/plombipro-app`

✅ **Recommended Branch**: Create new branch `cloudflare-production` with pre-built files

✅ **Cloudflare Settings**:
- Root directory: `build/web`
- Build command: (empty)
- Output directory: `.`

✅ **Files Created**:
- `wrangler.toml` - Cloudflare Pages configuration
- This guide - `CLOUDFLARE_PAGES_SETUP.md`

---

## Next Steps

1. **On your local machine**: Run `flutter build web --release`
2. **Follow Strategy B** above to create the production branch
3. **Configure Cloudflare Pages** with the settings above
4. **Deploy and test**

Need help? Check the Cloudflare Pages documentation: https://developers.cloudflare.com/pages/
