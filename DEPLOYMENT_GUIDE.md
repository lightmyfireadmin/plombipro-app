# PlombiPro - Complete Deployment Guide 🚀

**Last Updated**: November 6, 2025

This guide covers how to push, build, and deploy your PlombiPro app for testing on computer and smartphone **without building directly on devices**.

---

## 📋 Table of Contents

1. [Quick Start - Choose Your Path](#-quick-start---choose-your-path)
2. [Prerequisites Setup](#-prerequisites-setup)
3. [Option 1: Automatic Deployment via GitHub Actions](#option-1-automatic-deployment-via-github-actions-recommended)
4. [Option 2: Manual Deployment](#option-2-manual-deployment)
5. [Testing on Devices](#-testing-on-devices)
6. [Deployment Platforms Summary](#-deployment-platforms-summary)
7. [Troubleshooting](#-troubleshooting)

---

## 🎯 Quick Start - Choose Your Path

### Path A: Fully Automated (Recommended) ⭐
- Push code to GitHub → Automatic build & deploy → Test on any device
- **Setup time**: 15 minutes
- **Best for**: Regular updates, team testing, production deployments

### Path B: Manual Deployment
- Build locally → Deploy manually → Test on any device
- **Setup time**: 5 minutes
- **Best for**: Quick tests, one-time deployments

---

## ⚙️ Prerequisites Setup

### Required Tools

```bash
# Check your installations
flutter --version    # Need: Flutter 3.19+
git --version        # Need: Git 2.x+
firebase --version   # Need: Firebase CLI (install below if missing)
```

### Install Firebase CLI (if not installed)

```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash

# Login to Firebase
firebase login

# Verify installation
firebase --version
```

### Verify Project Configuration

```bash
# Make sure you're in the project directory
cd /path/to/plombipro-app

# Install Flutter dependencies
flutter pub get

# Verify environment file exists
ls -la lib/.env  # Should exist (copy from lib/.env.example if missing)
```

---

## Option 1: Automatic Deployment via GitHub Actions (Recommended)

This option builds and deploys automatically whenever you push code to GitHub.

### Step 1: Configure GitHub Secrets (One-time setup)

1. **Go to your GitHub repository**:
   - https://github.com/lightmyfireadmin/plombipro-app

2. **Navigate to Settings → Secrets and variables → Actions**

3. **Add the following secrets**:

#### Required Secret: FIREBASE_TOKEN

```bash
# In your terminal, generate the token:
firebase login:ci

# Copy the token that appears
# Example: 1//0gABC123...xyz

# Add it to GitHub:
# Name: FIREBASE_TOKEN
# Value: <paste the token>
```

#### Optional Secrets (for iOS TestFlight deployment):

```bash
FIREBASE_SERVICE_ACCOUNT
# Get from: Firebase Console → Project Settings → Service Accounts
# Generate new private key → Copy entire JSON content

APPLE_ID
# Your Apple ID email (e.g., your-email@example.com)

APPLE_APP_SPECIFIC_PASSWORD
# Generate at: https://appleid.apple.com/account/manage
# Sign in → Security → App-Specific Passwords → Generate

MATCH_PASSWORD
# A password you create for encrypting iOS certificates
# Choose a strong password and save it securely

FASTLANE_SESSION
# Generate with: fastlane spaceauth -u your-email@example.com
# (Requires Fastlane installed: gem install fastlane)
```

### Step 2: Push Code to Trigger Deployment

```bash
# Make sure you're on the correct branch
git checkout main

# Add your changes
git add .

# Commit with a descriptive message
git commit -m "feat: Add new feature for testing"

# Push to GitHub (use the designated Claude branch)
git push -u origin claude/review-knowledge-base-011CUq7hymZLGEjDqtHQY19J
```

### Step 3: Monitor the Deployment

1. **Go to GitHub Actions**:
   - https://github.com/lightmyfireadmin/plombipro-app/actions

2. **Watch the workflow run**:
   - ✅ Run Tests
   - ✅ Build Android (APK + AAB)
   - ✅ Build iOS
   - ✅ Deploy to Firebase App Distribution
   - ✅ Deploy Web to Firebase Hosting

3. **Deployment completes in ~15-20 minutes**

### Step 4: Access Your Deployed App

**Web App (Available immediately)**:
```
Production: https://plombipro-devlpt.web.app
Preview:    https://plombipro-devlpt.firebaseapp.com
```

**Mobile Apps (Check your email)**:
- Android testers receive download link via email
- iOS testers receive TestFlight invitation

**Or visit Firebase Console**:
```
https://console.firebase.google.com/project/plombipro-devlpt/appdistribution
```

---

## Option 2: Manual Deployment

Build and deploy manually from your local machine.

### 2A: Deploy Web App

#### Step 1: Build Web App

```bash
# Clean previous builds
flutter clean

# Build for web (production)
flutter build web --release

# Output will be in: build/web/
```

#### Step 2A: Deploy to Firebase Hosting

```bash
# Make sure you're using the correct project
firebase use plombipro-devlpt

# Deploy to production
firebase deploy --only hosting

# You'll get a URL like:
# ✔  Deploy complete!
# Hosting URL: https://plombipro-devlpt.web.app
```

#### Step 2B: Deploy to Cloudflare Pages (Alternative)

```bash
# Install Wrangler CLI if not installed
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy from build directory
cd build/web
wrangler pages deploy . --project-name=plombipro-app

# Or use the root directory approach:
# Create a production branch with pre-built files
git checkout -b cloudflare-production
git add -f build/web
git commit -m "Add pre-built web app for Cloudflare"
git push -u origin cloudflare-production

# Then configure in Cloudflare Dashboard:
# - Branch: cloudflare-production
# - Root directory: build/web
# - Build command: (empty)
```

### 2B: Deploy Mobile Apps

#### Android Deployment

```bash
# Using the deployment script (easiest)
./scripts/deploy_to_firebase.sh --platform android --notes "Testing new features"

# Or manually:
# 1. Build APK
flutter build apk --release

# 2. Deploy to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:268663350911:android:d84cfcc42f6b4b9a66014a \
  --groups testers \
  --release-notes "Manual deployment for testing"
```

#### iOS Deployment (macOS only)

```bash
# Using the deployment script
./scripts/deploy_to_firebase.sh --platform ios --notes "Testing iOS build"

# Or manually:
# 1. Build IPA
flutter build ipa --release

# 2. Deploy to Firebase App Distribution
firebase appdistribution:distribute build/ios/ipa/*.ipa \
  --app 1:268663350911:ios:93817ef0f50de33b66014a \
  --groups testers \
  --release-notes "iOS test build"

# Note: iOS builds require proper code signing configuration
```

#### Deploy Both Platforms at Once

```bash
./scripts/deploy_to_firebase.sh --platform both --notes "Testing on all platforms"
```

---

## 📱 Testing on Devices

### Test Web App (Computer & Smartphone)

#### On Computer:
1. Open browser and navigate to: **https://plombipro-devlpt.web.app**
2. Test all features in desktop view
3. Use browser DevTools to test responsive design

#### On Smartphone (Any Device):
1. Open the URL on your phone: **https://plombipro-devlpt.web.app**
2. Test in mobile browser
3. **Add to Home Screen** for app-like experience:

   **iPhone**:
   - Open in Safari
   - Tap Share button (box with arrow)
   - Tap "Add to Home Screen"
   - Icon will appear on home screen

   **Android**:
   - Open in Chrome
   - Tap menu (⋮)
   - Tap "Add to Home screen"
   - Icon will appear on home screen

### Test Android App (Android Devices)

#### Method 1: Firebase App Distribution (Recommended)

1. **Add yourself as a tester** (one-time):
   ```bash
   firebase appdistribution:testers:add your-email@example.com \
     --project plombipro-devlpt

   # Add to tester group
   firebase appdistribution:group:create testers --project plombipro-devlpt
   firebase appdistribution:group:add-testers testers your-email@example.com
   ```

2. **After deployment**:
   - Check your email for download link
   - Tap "Download" on your Android phone
   - Install the app

3. **Or access via Firebase Console**:
   - Go to: https://console.firebase.google.com/project/plombipro-devlpt/appdistribution
   - Download APK directly
   - Transfer to phone and install

#### Method 2: Direct APK Install

1. **Build and transfer APK**:
   ```bash
   # Build APK
   flutter build apk --release

   # APK location: build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Transfer to phone**:
   - Email to yourself
   - Upload to Google Drive/Dropbox
   - Use USB cable and file manager
   - Use `adb install` command

3. **Install on phone**:
   - Enable "Install from Unknown Sources" in Settings
   - Open APK file
   - Tap "Install"

### Test iOS App (iPhone/iPad)

#### Method 1: TestFlight (Recommended for distributed testing)

1. **Upload to App Store Connect** (requires Apple Developer account):
   ```bash
   # Build and deploy via GitHub Actions (automatic)
   # Or manually using Fastlane (requires setup)
   cd ios
   bundle exec fastlane beta
   ```

2. **Add testers in App Store Connect**:
   - Go to: https://appstoreconnect.apple.com
   - Select your app → TestFlight
   - Add internal/external testers

3. **Testers install**:
   - Receive email invitation
   - Download TestFlight app from App Store
   - Open invitation → Install app

#### Method 2: Firebase App Distribution (Easier, but limited)

1. **Deploy iOS build**:
   ```bash
   ./scripts/deploy_to_firebase.sh --platform ios --notes "iOS testing"
   ```

2. **Testers receive email** with installation link
   - Requires devices to be registered with Apple Developer account

#### Method 3: Development Install (USB cable, for your own device)

```bash
# Connect iPhone via USB
# Trust computer on iPhone
# Run:
flutter run --release -d <your-iphone-id>

# Or build and install via Xcode:
flutter build ios --release
open ios/Runner.xcworkspace
# In Xcode: Select device → Product → Run
```

---

## 📊 Deployment Platforms Summary

| Platform | URL/Access | Best For | Setup Time |
|----------|-----------|----------|------------|
| **Firebase Hosting** | https://plombipro-devlpt.web.app | Web app testing (computer & phone) | 5 min |
| **Cloudflare Pages** | Custom domain or Pages URL | Alternative web hosting | 10 min |
| **Firebase App Distribution** | Email links to testers | Android/iOS app testing | 10 min |
| **TestFlight** | App Store Connect | iOS production testing | 30 min |
| **GitHub Actions** | Automatic on push | CI/CD automation | 15 min |

---

## 🔧 Troubleshooting

### Build Failures

```bash
# Clean everything
flutter clean
flutter pub get

# For iOS (macOS only)
cd ios
pod deintegrate
pod install
cd ..

# For Android
cd android
./gradlew clean
cd ..

# Try building again
flutter build web --release
flutter build apk --release
```

### Firebase Authentication Issues

```bash
# Logout and login again
firebase logout
firebase login --reauth

# Verify you're using the correct project
firebase use plombipro-devlpt
firebase projects:list
```

### GitHub Actions Failing

1. **Check the logs**:
   - Go to: https://github.com/lightmyfireadmin/plombipro-app/actions
   - Click on the failed workflow
   - Review error messages

2. **Common issues**:
   - Missing secrets: Add required secrets (see Step 1 above)
   - Dependency conflicts: Update `pubspec.yaml` and push again
   - Code signing issues (iOS): Check Apple Developer account setup

### Environment Variables Not Loading

```bash
# Verify .env file exists
cat lib/.env

# Should contain:
# SUPABASE_URL=https://...
# SUPABASE_ANON_KEY=eyJ...
# STRIPE_PUBLISHABLE_KEY=pk_test_...

# If missing, copy from example:
cp lib/.env.example lib/.env
# Then edit lib/.env with your actual credentials
```

### Firebase App Distribution - No Email Received

```bash
# Verify tester is added
firebase appdistribution:testers:list --project plombipro-devlpt

# Add tester if missing
firebase appdistribution:testers:add your-email@example.com \
  --project plombipro-devlpt

# Check spam folder in email
# Or access directly via Firebase Console:
# https://console.firebase.google.com/project/plombipro-devlpt/appdistribution
```

### Cloudflare Pages - Blank Screen

```bash
# Rebuild with correct base href
flutter build web --release --base-href "/"

# Check browser console for errors
# Verify CORS settings in Supabase if API calls fail
```

### iOS Code Signing Issues

For Firebase App Distribution (iOS):
```bash
# Devices must be registered in Apple Developer Portal
# Build requires valid provisioning profile

# Alternative: Use TestFlight instead
# Or test on iOS Simulator (no code signing needed):
flutter run -d "iPhone 14"
```

---

## 🎯 Recommended Workflow

### For Quick Testing
```bash
# 1. Build web app locally
flutter build web --release

# 2. Deploy to Firebase
firebase deploy --only hosting

# 3. Test on any device via browser
# https://plombipro-devlpt.web.app
```

### For Team Testing (Android)
```bash
# Push to GitHub - automatic deployment
git add .
git commit -m "feat: Ready for testing"
git push origin main

# Team receives email with download link
# Or use manual script:
./scripts/deploy_to_firebase.sh --platform android --notes "Ready for team testing"
```

### For Production Release
```bash
# 1. Build release versions
flutter build appbundle --release  # Android (Play Store)
flutter build ipa --release         # iOS (App Store)

# 2. Upload to stores manually or via Fastlane
# 3. Or use GitHub Actions for automated releases
```

---

## 📚 Additional Resources

- **Build Instructions**: [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)
- **Setup Guide**: [SETUP_AND_DEPLOYMENT_GUIDE.md](SETUP_AND_DEPLOYMENT_GUIDE.md)
- **Quick Testing**: [QUICK_START_TESTING.md](QUICK_START_TESTING.md)
- **Cloudflare Setup**: [CLOUDFLARE_PAGES_SETUP.md](CLOUDFLARE_PAGES_SETUP.md)
- **Testing Guide**: [TESTING.md](TESTING.md)

### External Documentation
- **Firebase Hosting**: https://firebase.google.com/docs/hosting
- **Firebase App Distribution**: https://firebase.google.com/docs/app-distribution
- **Cloudflare Pages**: https://developers.cloudflare.com/pages/
- **Flutter Deployment**: https://docs.flutter.dev/deployment
- **GitHub Actions**: https://docs.github.com/en/actions

---

## 🆘 Need Help?

1. **Check existing documentation** in the repository
2. **Review GitHub Actions logs** for automated deployments
3. **Check Firebase Console** for deployment status
4. **Run diagnostics**:
   ```bash
   flutter doctor -v
   firebase projects:list
   git status
   ```

---

## 🎉 Summary - Choose Your Method

| Method | Command | Result |
|--------|---------|--------|
| **Automatic (Web)** | `git push origin main` | Auto-deploys to Firebase Hosting |
| **Manual (Web)** | `flutter build web --release && firebase deploy --only hosting` | Deploy web app |
| **Automatic (Android)** | `git push origin main` | Auto-deploys to Firebase App Distribution |
| **Manual (Android)** | `./scripts/deploy_to_firebase.sh --platform android --notes "Test"` | Deploy Android APK |
| **Manual (iOS)** | `./scripts/deploy_to_firebase.sh --platform ios --notes "Test"` | Deploy iOS app |
| **All Platforms** | `./scripts/deploy_to_firebase.sh --platform both --notes "Test all"` | Deploy everything |

---

**Pro Tip**: For regular development, use GitHub Actions (automatic). For quick tests, use manual Firebase deployment. For production releases, use the appropriate app store submission process.

**Last Updated**: November 6, 2025
**Version**: 2.0
