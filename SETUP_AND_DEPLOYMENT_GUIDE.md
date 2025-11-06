# PlombiPro Setup and Deployment Guide

This guide provides step-by-step instructions for setting up environment variables locally and deploying the PlombiPro app for testing.

---

## 📋 Table of Contents

1. [Environment Variables Setup](#-environment-variables-setup)
2. [Local Development Setup](#-local-development-setup)
3. [Testing Locally](#-testing-locally)
4. [Web Deployment (Firebase Hosting)](#-web-deployment-firebase-hosting)
5. [Mobile Testing (Android/iOS)](#-mobile-testing-androidios)
6. [Testing on Smartphone](#-testing-on-smartphone)

---

## 🔐 Environment Variables Setup

### Where to Put Environment Variables Locally

PlombiPro uses the `flutter_dotenv` package to manage environment variables. You need to create a `.env` file in the `lib/` directory.

### Step 1: Create Your .env File

```bash
# Copy the example file
cp lib/.env.example lib/.env
```

### Step 2: Fill in Your Credentials

Open `lib/.env` and add your actual credentials:

```env
# ===== SUPABASE CONFIGURATION =====
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ===== STRIPE CONFIGURATION =====
STRIPE_PUBLISHABLE_KEY=pk_test_51Abc123...
```

### Where to Get These Values:

#### Supabase Credentials:
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Select your project (or create a new one)
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`

#### Stripe Publishable Key:
1. Go to [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Navigate to **Developers** → **API keys**
3. Copy the **Publishable key** (use TEST key for development)
   - Test mode: `pk_test_...`
   - Live mode: `pk_live_...` (only for production)

### Important Security Notes:

- ✅ The `.env` file is already in `.gitignore` - it won't be committed to git
- ✅ Never commit real credentials to version control
- ✅ Use TEST keys for development
- ✅ Keep production keys secure and separate

---

## 🚀 Local Development Setup

### Prerequisites

Make sure you have the following installed:

```bash
# Check Flutter installation
flutter doctor -v

# Required:
# ✓ Flutter SDK 3.x
# ✓ Dart 3.9.2+
# ✓ Chrome (for web development)
# ✓ Android Studio / Xcode (for mobile development)
```

### Step 1: Install Dependencies

```bash
# Navigate to project directory
cd plombipro-app

# Get Flutter packages
flutter pub get
```

### Step 2: Verify Environment Variables

```bash
# Make sure your .env file exists and is properly configured
cat lib/.env

# You should see your SUPABASE_URL and SUPABASE_ANON_KEY
```

### Step 3: Set Up Supabase Database

If you haven't already set up your Supabase database:

```bash
# 1. Go to your Supabase project
# 2. Navigate to SQL Editor
# 3. Run the schema file:
```

Execute the contents of `supabase_schema.sql` in your Supabase SQL Editor.

```bash
# 4. Set up storage buckets and policies:
```

Execute the contents of `supabase_bucket_policies.sql` in your Supabase SQL Editor.

---

## 🧪 Testing Locally

### Web Development (Recommended for Testing)

The fastest way to test your app:

```bash
# Run on Chrome
flutter run -d chrome

# Or with hot reload for faster development
flutter run -d chrome --hot
```

The app will open in Chrome at `http://localhost:port` (Flutter will show you the port number).

### Mobile Simulators

#### iOS Simulator (macOS only):

```bash
# Start iOS Simulator
open -a Simulator

# Run the app
flutter run -d "iPhone 14"
```

#### Android Emulator:

```bash
# List available devices
flutter devices

# Start an Android emulator (if not already running)
flutter emulators --launch <emulator_id>

# Run the app
flutter run -d <device_id>
```

---

## 🌐 Web Deployment (Firebase Hosting)

Deploy the web version for testing on any device via a public URL.

### Prerequisites

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### Step 1: Build for Web

```bash
# Build the web app (production mode)
flutter build web --release

# The output will be in build/web/
```

### Step 2: Configure Firebase Project

```bash
# Initialize Firebase (if not already done)
firebase init hosting

# Select:
# - Use existing project: plombipro-devlpt
# - Public directory: build/web
# - Configure as SPA: Yes
# - Overwrite index.html: No
```

### Step 3: Deploy to Firebase Hosting

```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Firebase will provide you with a URL like:
# https://plombipro-devlpt.web.app
```

### Step 4: Test the Deployed App

Open the URL provided by Firebase in any browser (computer or smartphone):

```
https://plombipro-devlpt.web.app
```

### Alternative: Deploy to Preview Channel (for testing)

```bash
# Deploy to a preview channel (temporary URL for testing)
firebase hosting:channel:deploy preview-test

# This creates a temporary URL like:
# https://plombipro-devlpt--preview-test-xxxxx.web.app
```

---

## 📱 Mobile Testing (Android/iOS)

### Android Testing

#### Option 1: Build APK for Testing

```bash
# Build debug APK (for testing only)
flutter build apk --debug

# The APK will be at:
# build/app/outputs/flutter-apk/app-debug.apk
```

#### Option 2: Build Release APK (for distribution)

```bash
# Build release APK (optimized)
flutter build apk --release

# The APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Option 3: Build App Bundle (for Play Store)

```bash
# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# The bundle will be at:
# build/app/outputs/bundle/release/app-release.aab
```

### iOS Testing (macOS only)

#### Build for iOS Simulator:

```bash
# Build for iOS simulator
flutter build ios --simulator --debug

# Run on simulator
flutter run -d "iPhone 14"
```

#### Build for Physical iOS Device:

```bash
# Build for physical device (requires Apple Developer account)
flutter build ios --release

# Then open Xcode:
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your device
# 2. Product → Archive
# 3. Distribute App → Ad Hoc (for testing)
```

---

## 📲 Testing on Smartphone

### Method 1: Web App (Easiest - Works on All Devices)

1. **Deploy to Firebase Hosting** (see above)
2. **Open the URL on your smartphone**:
   - https://plombipro-devlpt.web.app
3. **Add to Home Screen** (makes it feel like a native app):

   **On iPhone:**
   - Open in Safari
   - Tap the Share button
   - Tap "Add to Home Screen"

   **On Android:**
   - Open in Chrome
   - Tap the menu (⋮)
   - Tap "Add to Home screen"

### Method 2: Android APK (Android Devices)

1. **Build and transfer APK**:
   ```bash
   # Build debug APK
   flutter build apk --debug

   # The APK is at: build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Transfer APK to your phone**:
   - Email it to yourself
   - Upload to Google Drive
   - Use ADB: `adb install build/app/outputs/flutter-apk/app-debug.apk`
   - Use a file transfer tool

3. **Install on your Android phone**:
   - Enable "Install from Unknown Sources" in Settings
   - Open the APK file
   - Tap "Install"

### Method 3: iOS TestFlight (iOS Devices - Requires Apple Developer Account)

1. **Build and upload to App Store Connect**:
   ```bash
   # Build iOS app
   flutter build ios --release

   # Open Xcode
   open ios/Runner.xcworkspace

   # In Xcode:
   # Product → Archive
   # Distribute App → App Store Connect
   ```

2. **Set up TestFlight**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Add testers (email addresses)
   - Testers will receive an email with TestFlight invitation

3. **Install on iPhone**:
   - Testers download TestFlight app from App Store
   - Open invitation link
   - Install the app via TestFlight

### Method 4: Direct USB Install (During Development)

**Android:**
```bash
# Connect phone via USB
# Enable USB Debugging on phone
# Run:
flutter run --release
```

**iOS (macOS only):**
```bash
# Connect iPhone via USB
# Trust computer on iPhone
# Run:
flutter run --release
```

---

## 🔧 Troubleshooting

### Environment Variables Not Loading

```bash
# Make sure .env file exists
ls -la lib/.env

# Check the file contents (should not be empty)
cat lib/.env

# Rebuild the app
flutter clean
flutter pub get
flutter run
```

### Supabase Connection Issues

1. Verify your Supabase URL and anon key in `lib/.env`
2. Check Supabase project is not paused (free tier pauses after inactivity)
3. Test connection in Supabase dashboard

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade

# For iOS (macOS only)
cd ios
pod deintegrate
pod install
cd ..

# For Android
cd android
./gradlew clean
cd ..
```

### Firebase Hosting Issues

```bash
# Make sure you're logged in
firebase login

# Verify project
firebase projects:list

# Use the correct project
firebase use plombipro-devlpt

# Try deploying again
firebase deploy --only hosting
```

---

## 📝 Quick Reference Commands

### Local Development
```bash
# Web (fastest for testing)
flutter run -d chrome

# Android emulator
flutter run

# iOS simulator (macOS only)
flutter run -d "iPhone 14"
```

### Build for Distribution
```bash
# Web
flutter build web --release
firebase deploy --only hosting

# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

### Testing URLs
```bash
# After Firebase deployment:
Production: https://plombipro-devlpt.web.app
Preview: https://plombipro-devlpt--preview-test-xxxxx.web.app
```

---

## 🎉 Next Steps

Once you have the app running:

1. **Test the authentication flow** - Sign up with a test account
2. **Create a test client** - Add a sample client
3. **Create a test quote** - Test the quote creation flow
4. **Generate a PDF** - Test PDF generation
5. **Test on mobile** - Try the app on your smartphone

For production deployment (App Store / Play Store), see the detailed deployment guide in `plombipro_part4_deployment_prompts.md`.

---

## 📞 Need Help?

- Check the [README.md](README.md) for project overview
- Review [TECH_STACK.md](TECH_STACK.md) for technical details
- Supabase docs: https://supabase.com/docs
- Flutter docs: https://docs.flutter.dev
- Firebase Hosting docs: https://firebase.google.com/docs/hosting

---

**Last Updated**: November 6, 2025
**Version**: 1.0
