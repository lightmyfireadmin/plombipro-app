# PlombiPro Testing Guide - Mac & Android

This guide helps you test the app on both Mac and Android phone after setting up Firebase auto-deployment.

---

## 🌐 Option 1: Test Web Version (Easiest - Works on Both Mac & Android)

Your Firebase auto-deploy builds the web version. Access it from any device:

### Step 1: Get Your Firebase Hosting URL

```bash
# In your project directory
firebase hosting:channel:list
```

Or check your Firebase Console:
- Go to: https://console.firebase.google.com/project/plombipro-devlpt/hosting
- Find your live URL (usually: `https://plombipro-devlpt.web.app`)

### Step 2: Access on Any Device

**On Mac:**
- Open Safari or Chrome
- Navigate to your Firebase hosting URL
- Bookmark it for easy access

**On Android Phone:**
- Open Chrome browser
- Navigate to your Firebase hosting URL
- Tap menu → "Add to Home Screen" for app-like experience

**Note:** The web version updates automatically when you push to GitHub!

---

## 📱 Option 2: Native Android App (Best Performance)

### Prerequisites on Your Mac

1. **Install Android Studio:**
   ```bash
   # Download from: https://developer.android.com/studio
   # Or via Homebrew:
   brew install --cask android-studio
   ```

2. **Verify Flutter Android setup:**
   ```bash
   flutter doctor -v
   ```

   Fix any Android-related issues shown.

### Step 1: Enable Developer Mode on Your Android Phone

1. Go to **Settings → About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings → Developer Options**
4. Enable **USB Debugging**
5. Enable **Install via USB** (if available)

### Step 2: Connect Phone to Mac

**Via USB Cable:**
```bash
# Connect phone with USB cable
# On phone, allow "USB debugging" when prompted

# Verify connection:
flutter devices
# Should show your phone model
```

**Via Wireless Debugging (Android 11+):**
```bash
# On phone: Settings → Developer Options → Wireless Debugging
# Tap "Pair device with pairing code"
# Note the IP address and pairing code

# On Mac:
adb pair <IP>:<PORT>
# Enter pairing code when prompted

# Verify:
flutter devices
```

### Step 3: Build and Install APK

**Method A: Direct Install (Recommended)**
```bash
cd /path/to/plombipro-app

# Install directly to connected phone:
flutter run --release -d <device-id>

# Or let Flutter auto-detect:
flutter run --release
# Select your phone from the list
```

**Method B: Build APK File**
```bash
# Build APK:
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk

# Install manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Method C: Build App Bundle (For Play Store)**
```bash
flutter build appbundle --release
# Location: build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Transfer APK to Phone (If ADB Doesn't Work)

```bash
# Build the APK first:
flutter build apk --release

# Transfer via various methods:

# 1. Email yourself:
open build/app/outputs/flutter-apk/
# Attach app-release.apk to email, open on phone

# 2. Google Drive:
# Upload app-release.apk to Drive, download on phone

# 3. AirDrop alternative - use Snapdrop:
# Go to https://snapdrop.net on both devices
```

On phone:
1. Download the APK
2. Tap the file to install
3. Allow "Install from Unknown Sources" if prompted

---

## 🖥️ Option 3: Test on Mac Desktop

Flutter supports macOS desktop apps:

### Step 1: Enable macOS Desktop Support

```bash
flutter config --enable-macos-desktop
flutter create --platforms=macos .
```

### Step 2: Run on Mac

```bash
flutter run -d macos
```

### Step 3: Build macOS App Bundle

```bash
flutter build macos --release

# App location:
# build/macos/Build/Products/Release/app.app

# Open the app:
open build/macos/Build/Products/Release/app.app
```

---

## 🔥 Option 4: Firebase App Distribution (Best for Testing)

Share beta builds easily with Firebase App Distribution:

### Step 1: Install Firebase CLI Tools

```bash
# Already have Firebase CLI, add App Distribution:
firebase setup:emulators:ui
```

### Step 2: Build and Upload to App Distribution

```bash
# Install Fastlane for easy distribution:
brew install fastlane

# Build Android APK:
flutter build apk --release

# Upload to Firebase App Distribution:
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:268663350911:android:d84cfcc42f6b4b9a66014a \
  --groups testers \
  --release-notes "Latest build from $(date)"
```

### Step 3: Download on Android Phone

1. Install **Firebase App Distribution** app from Play Store
2. Sign in with your Google account
3. Get notifications for new builds
4. Tap to install directly

---

## ⚡ Quick Testing Workflow

### Daily Development Flow:

```bash
# 1. Make changes to your code
# 2. Test locally on Mac browser:
flutter run -d chrome

# 3. When ready, test on Android:
flutter run --release -d <your-phone-device-id>

# 4. Push to GitHub (auto-deploys web):
git add .
git commit -m "Your changes"
git push
```

### Get Device ID:
```bash
flutter devices

# Example output:
# Chrome (web)        • chrome        • web-javascript • Google Chrome
# macOS (desktop)     • macos         • darwin-arm64   • macOS 14.0
# SM G991B (mobile)   • R58M123ABC    • android-arm64  • Android 13
#                       ^^^^^^^^^^
#                       This is your device ID
```

---

## 🔧 Environment Variables Setup

Before testing, ensure `.env` file exists:

### Step 1: Check if .env exists

```bash
ls -la lib/.env
```

### Step 2: If missing, create from template

```bash
cat > lib/.env << 'EOF'
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_key_here
OCR_API_KEY=your_ocr_space_key_here
RESEND_API_KEY=your_resend_key_here
EOF
```

### Step 3: Get actual values from:

- **Supabase:** https://app.supabase.com/project/YOUR_PROJECT/settings/api
- **Stripe:** https://dashboard.stripe.com/apikeys
- **OCR.space:** https://ocr.space/ocrapi
- **Resend:** https://resend.com/api-keys

---

## 🐛 Troubleshooting

### "No devices found"

```bash
# Check Flutter setup:
flutter doctor -v

# Check connected devices:
adb devices
flutter devices

# Restart ADB server:
adb kill-server
adb start-server
```

### "Gradle build failed" on Android

```bash
# Clear Flutter cache:
flutter clean
flutter pub get

# Update Android licenses:
flutter doctor --android-licenses

# Retry:
flutter run --release
```

### "Pod install failed" on iOS/macOS

```bash
cd ios  # or cd macos
pod deintegrate
pod install
cd ..
flutter run
```

### APK install fails on phone

```bash
# Check minimum SDK version
# In android/app/build.gradle, ensure:
# minSdkVersion >= 21

# Rebuild:
flutter clean
flutter build apk --release
```

### Web app doesn't load

```bash
# Check Firebase hosting deployment:
firebase hosting:channel:list

# Redeploy manually:
flutter build web --release
firebase deploy --only hosting
```

---

## 📊 Recommended Testing Setup

**For Daily Development:**
1. **Mac Browser** - `flutter run -d chrome` (fastest iteration)
2. **Android Phone** - Keep USB connected, `flutter run --release` when needed

**For Sharing with Others:**
1. **Web Version** - Share Firebase hosting URL
2. **Firebase App Distribution** - Share beta builds

**For Final Testing Before Release:**
1. **Physical Android Device** - Test all features
2. **iOS Simulator** - Test iOS-specific features (if targeting iOS)

---

## 🎯 Next Steps

1. **Choose your preferred method** from above
2. **Test the app** on both Mac and Android
3. **Report any issues** you encounter
4. **Iterate quickly** using the daily development flow

---

## 📞 Quick Command Reference

```bash
# See all devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build Android APK
flutter build apk --release

# Build for macOS
flutter build macos --release

# Check Firebase hosting URL
firebase hosting:channel:list

# Deploy web version manually
flutter build web --release && firebase deploy --only hosting

# Install to connected phone
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

**Ready to test! Start with the Web Version (Option 1) - it's the easiest and works immediately.** 🚀
