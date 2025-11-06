# 🚀 PlombiPro - Quick Deployment Reference Card

**One-page cheat sheet for pushing, building, and deploying**

---

## 🎯 Fastest Path to Production

### For Web Testing (Computer + Smartphone)

```bash
# 1. Build web app
flutter build web --release

# 2. Deploy to Firebase
firebase deploy --only hosting

# 3. Test immediately at:
# https://plombipro-devlpt.web.app
# (Works on ANY device with a browser!)
```

**Time**: 2-3 minutes | **Device**: Any computer or smartphone with browser

---

### For Android Testing (Without Building on Device)

```bash
# Option 1: Automated (one command)
./scripts/deploy_to_firebase.sh --platform android --notes "Test build"
# → Builds APK → Deploys to Firebase → Emails download link

# Option 2: GitHub Actions (zero commands, just push)
git push origin main
# → Auto-builds → Auto-deploys → Emails download link

# Option 3: Manual APK
flutter build apk --release
# → Transfer APK from build/app/outputs/flutter-apk/app-release.apk to phone
# → Install on phone
```

**Time**: 5-10 minutes | **Device**: Any Android phone

---

### For iOS Testing (Without Building on Device)

```bash
# Option 1: Automated
./scripts/deploy_to_firebase.sh --platform ios --notes "Test build"
# → Builds IPA → Deploys to Firebase → Emails download link
# (Requires code signing setup)

# Option 2: GitHub Actions
git push origin main
# → Auto-builds → Deploys to TestFlight (if configured)

# Option 3: Simulator (NO DEVICE NEEDED)
open -a Simulator
flutter run
# → Runs on iOS Simulator on your Mac
```

**Time**: 10-30 minutes | **Device**: iPhone/iPad or iOS Simulator

---

## 📋 One-Time Setup (Do This First!)

### Setup Firebase CLI (5 minutes)

```bash
# Install
curl -sL https://firebase.tools | bash

# Login
firebase login

# Verify
firebase projects:list
# Should show: plombipro-devlpt
```

### Setup Environment Variables (2 minutes)

```bash
# Copy example file
cp lib/.env.example lib/.env

# Edit with your credentials
nano lib/.env  # or use any text editor

# Required values:
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=eyJ...
# STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### Setup GitHub Secrets for Auto-Deploy (10 minutes)

1. Go to: https://github.com/lightmyfireadmin/plombipro-app/settings/secrets/actions
2. Add secret: `FIREBASE_TOKEN`
   - Get token: `firebase login:ci`
   - Copy and paste the token
3. Push code → Automatic deployment! 🎉

---

## 🔄 Daily Workflow

### Quick Test Cycle

```bash
# Make your changes in code editor

# Test locally first
flutter run -d chrome

# Build and deploy
flutter build web --release
firebase deploy --only hosting

# Or for mobile:
./scripts/deploy_to_firebase.sh --platform android --notes "Testing feature X"

# Test on device
# → Check email for download link
# → Or open https://plombipro-devlpt.web.app
```

### Automated Deploy Cycle

```bash
# Make your changes

# Commit and push
git add .
git commit -m "feat: Add new feature"
git push origin main

# GitHub Actions automatically:
# ✅ Runs tests
# ✅ Builds web app → Deploys to Firebase Hosting
# ✅ Builds Android → Deploys to Firebase App Distribution
# ✅ Builds iOS → Deploys to TestFlight (if configured)
# ✅ Emails all testers

# Check status:
# https://github.com/lightmyfireadmin/plombipro-app/actions
```

---

## 📱 Testing URLs & Access

| Platform | Access URL | How to Test |
|----------|------------|-------------|
| **Web (Computer)** | https://plombipro-devlpt.web.app | Open in any browser |
| **Web (Smartphone)** | https://plombipro-devlpt.web.app | Open in Safari/Chrome → Add to Home Screen |
| **Android APK** | Email link from Firebase | Tap download link → Install |
| **iOS TestFlight** | Email invitation | Download TestFlight app → Accept invitation |
| **Firebase Console** | https://console.firebase.google.com/project/plombipro-devlpt/appdistribution | Download builds directly |

---

## 🎯 Command Quick Reference

```bash
# Build Commands
flutter build web --release              # Web production build
flutter build apk --release              # Android APK
flutter build appbundle --release        # Android App Bundle (Play Store)
flutter build ipa --release              # iOS IPA (requires macOS)

# Deploy Commands
firebase deploy --only hosting                           # Deploy web app
./scripts/deploy_to_firebase.sh --platform android       # Deploy Android
./scripts/deploy_to_firebase.sh --platform ios           # Deploy iOS
./scripts/deploy_to_firebase.sh --platform both          # Deploy Android + iOS

# Test Commands
flutter run -d chrome                    # Test on Chrome
flutter run -d "iPhone 14"               # Test on iOS Simulator
flutter run                              # Test on connected device

# Cleanup Commands
flutter clean                            # Clean build cache
flutter pub get                          # Re-install dependencies
firebase logout && firebase login        # Reset Firebase auth
```

---

## 🔧 Emergency Troubleshooting

```bash
# Nothing works? Reset everything:
flutter clean
flutter pub get
firebase logout
firebase login
rm -rf build/

# Then try again:
flutter build web --release
firebase deploy --only hosting

# Still failing? Check:
flutter doctor -v                        # Flutter installation
cat lib/.env                             # Environment variables
firebase projects:list                   # Firebase authentication
git status                               # Git status
```

---

## 💡 Pro Tips

1. **Web is fastest**: Deploy to Firebase Hosting for instant testing on any device
2. **Use GitHub Actions**: Set it up once, never manually deploy again
3. **Test on Web first**: Catches 90% of issues before building mobile apps
4. **Add to Home Screen**: Web app feels like native app
5. **Use Firebase App Distribution**: Easiest way to share builds with team

---

## 📞 Quick Links

- **Deployment Guide (Full)**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **GitHub Actions**: https://github.com/lightmyfireadmin/plombipro-app/actions
- **Firebase Console**: https://console.firebase.google.com/project/plombipro-devlpt
- **Firebase Hosting**: https://plombipro-devlpt.web.app
- **Firebase App Distribution**: https://console.firebase.google.com/project/plombipro-devlpt/appdistribution

---

## 🎉 The Absolute Quickest Way

```bash
# For Web (30 seconds)
flutter build web --release && firebase deploy --only hosting

# For Android (2 minutes)
./scripts/deploy_to_firebase.sh --platform android --notes "Quick test"

# For Automated Everything (just push)
git add . && git commit -m "Update" && git push origin main
```

**Bookmark this page for instant reference!** 🔖

---

**Updated**: November 6, 2025 | **Version**: 1.0
