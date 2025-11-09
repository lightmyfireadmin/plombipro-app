# PlombiPro - Complete Deployment Guide (Step-by-Step)

## 📋 Overview

This guide walks you through deploying PlombiPro from zero to testers' devices using Firebase App Distribution.

**Estimated Time**: 2-3 hours (first time)
**Prerequisites**: 
- Mac or Linux computer
- Android device or emulator for testing
- Supabase account (free)
- Firebase account (free)
- Code editor (VS Code recommended)

---

## Part 1: Database Setup (30 minutes)

### Step 1.1: Create Supabase Project

1. Go to https://app.supabase.com
2. Click "New project"
3. Fill in:
   - **Name**: PlombiPro
   - **Database Password**: (create strong password, SAVE IT!)
   - **Region**: Europe West (Paris) - best for France
   - **Pricing Plan**: Free
4. Click "Create new project"
5. Wait 2-3 minutes for setup

### Step 1.2: Run Database Migrations

1. In Supabase dashboard, click "SQL Editor" (left sidebar)
2. Click "New query"
3. Open `COMPLETE_DATABASE_SETUP.sql` from this repo
4. Copy entire content
5. Paste into SQL Editor
6. Click "Run" (or press Cmd/Ctrl + Enter)
7. Wait for "Success" message
8. Verify:
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' 
   ORDER BY table_name;
   ```
9. Should see 19 tables (appointments, clients, invoices, etc.)

### Step 1.3: Get API Keys

1. In Supabase, click "Settings" → "API"
2. Copy these values:
   - **URL**: https://xxxxx.supabase.co
   - **anon/public key**: eyJhbG... (long string)
3. Save in secure note/password manager

### Step 1.4: Configure Authentication

1. Go to "Authentication" → "Providers"
2. Enable "Email" provider
3. Disable "Confirm email" (for testing only!)
4. Save configuration

---

## Part 2: Get API Keys (15 minutes)

### Step 2.1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: "PlombiPro"
4. Disable Google Analytics (or enable if you want)
5. Click "Create project"
6. Wait for setup

### Step 2.2: Add Android App to Firebase

1. Click "Add app" → Android icon
2. Fill in:
   - **Package name**: `com.plombipro.app`
   - **App nickname**: PlombiPro
   - **SHA-1**: Leave empty for now
3. Click "Register app"
4. Download `google-services.json`
5. Place file in: `android/app/google-services.json`
6. Click "Next" → "Next" → "Continue to console"

### Step 2.3: Set Up Sentry (Optional but Recommended)

1. Go to https://sentry.io
2. Sign up (free: 5,000 errors/month)
3. Create organization: "PlombiPro"
4. Create project:
   - **Platform**: Flutter
   - **Project name**: PlombiPro
5. Copy DSN: `https://xxxxx@oxxxxx.ingest.sentry.io/xxxxxx`
6. Save it

---

## Part 3: Prepare App Code (20 minutes)

### Step 3.1: Create Config Files

**Create**: `android/app/build-config.properties`
```properties
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-from-step-1.3
SENTRY_DSN=your-sentry-dsn-from-step-2.3
```

**Create**: `android/key.properties`
```properties
storePassword=plombipro2024
keyPassword=plombipro2024
keyAlias=plombipro
storeFile=../plombipro-release-key.jks
```

### Step 3.2: Generate Signing Key

```bash
# Navigate to android folder
cd android

# Generate keystore
keytool -genkey -v -keystore plombipro-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias plombipro

# Enter password: plombipro2024 (when prompted)
# Fill in organization details:
#   - Name: Your name
#   - Organization: PlombiPro
#   - City: Your city
#   - State: Your state
#   - Country: FR

# Verify keystore created
ls -la plombipro-release-key.jks
```

### Step 3.3: Update Package Name

**File**: `android/app/build.gradle`
```gradle
android {
    namespace "com.plombipro.app"  // Line ~10
    defaultConfig {
        applicationId "com.plombipro.app"  // Line ~15
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest package="com.plombipro.app">  <!-- Line 2 -->
    <application android:label="PlombiPro">  <!-- Line ~10 -->
```

### Step 3.4: Add Graphic Assets

**Quick Option** - Use Icon Kitchen:
1. Go to https://icon.kitchen
2. Upload a simple wrench icon (find on flaticon.com)
3. Background color: #0066CC
4. Generate all sizes
5. Download ZIP
6. Extract to `android/app/src/main/res/` (replace all mipmap folders)

**OR Manual Option**:
- Follow specifications in `GRAPHIC_ASSETS_SPECS.md`
- Create all icon sizes manually
- Place in correct mipmap folders

---

## Part 4: Build the App (30 minutes)

### Step 4.1: Install Dependencies

```bash
# From project root
flutter clean
flutter pub get

# Generate code (Riverpod providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Wait for completion (may take 2-3 minutes)
```

### Step 4.2: Test Build Locally

```bash
# Connect Android device via USB
# OR start Android emulator

# Verify device connected
flutter devices

# Should show your device

# Run in debug mode first
flutter run

# App should open on device
# Test login/signup works
# Verify no errors in console
```

### Step 4.3: Build Release APK

```bash
# Build signed release APK
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SENTRY_DSN=your-sentry-dsn

# Wait 5-10 minutes for build
# Output will be at: build/app/outputs/flutter-apk/app-release.apk
```

### Step 4.4: Verify APK

```bash
# Check file exists
ls -lh build/app/outputs/flutter-apk/app-release.apk

# File should be 30-50 MB

# Install on device to test
adb install build/app/outputs/flutter-apk/app-release.apk

# Open app and verify it works
```

---

## Part 5: Firebase App Distribution (30 minutes)

### Step 5.1: Install Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Follow browser prompts to authenticate
```

### Step 5.2: Initialize Firebase in Project

```bash
# From project root
firebase init

# Select:
#  (*) App Distribution (use spacebar to select)

# Choose project: PlombiPro (the one you created)

# Complete setup
```

### Step 5.3: Create Tester Group

1. Go to https://console.firebase.google.com
2. Select PlombiPro project
3. Click "App Distribution" (left sidebar)
4. Click "Testers & Groups" tab
5. Click "Add group"
6. Name: "Internal Testers"
7. Add tester emails (your email + team members)
8. Save

### Step 5.4: Upload APK to Firebase

**Option A - Firebase CLI**:
```bash
# Get your Firebase App ID
# Go to: Firebase Console → Project Settings → Your apps
# Copy the App ID (looks like: 1:12345:android:abcdef)

# Upload build
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "internal-testers" \
  --release-notes "PlombiPro v1.0.0 - First test build"
```

**Option B - Firebase Console** (Easier for first time):
1. Go to Firebase Console → App Distribution
2. Click "Get started" (if first time)
3. Click "Distribute app"
4. Click "Upload APK"
5. Select `build/app/outputs/flutter-apk/app-release.apk`
6. Add release notes:
   ```
   PlombiPro v1.0.0 - Test Build

   Features:
   - Modern dashboard
   - Quote/Invoice creation  
   - E-signatures
   - Client management
   - Appointments
   - Bank reconciliation

   Please test and report bugs!
   ```
7. Select group: "Internal Testers"
8. Click "Distribute"

---

## Part 6: Testers Install App (10 minutes)

### Step 6.1: Testers Receive Email

Testers will get email: "You've been invited to test PlombiPro"

### Step 6.2: Testers Install Firebase App Tester

1. Open email on Android device
2. Click "Get started"
3. If prompted, install "Firebase App Tester" from Play Store
4. Open Firebase App Tester app
5. Sign in with invited email

### Step 6.3: Install PlombiPro

1. In Firebase App Tester, tap PlombiPro
2. Tap "Download"
3. Install APK (may need to allow "Install from unknown sources")
4. Open PlombiPro app
5. Create account and test!

---

## Part 7: Verify Everything Works (15 minutes)

### Test Checklist for Testers:

- [ ] **Login/Signup**
  - Create account with email/password
  - Logout
  - Login again
  - Password reset (if implemented)

- [ ] **Dashboard**
  - View shows metrics
  - Charts render correctly
  - Quick actions work

- [ ] **Clients**
  - Create new client
  - Edit client
  - View client details
  - Delete client

- [ ] **Quotes**
  - Create quote
  - Add line items
  - View PDF preview
  - Send quote

- [ ] **Invoices**
  - Create invoice
  - Add line items
  - View PDF preview
  - Mark as paid

- [ ] **Appointments**
  - Create appointment
  - View calendar
  - Update status
  - Delete appointment

- [ ] **Products**
  - Browse supplier catalogs
  - Search products
  - Add to favorites
  - Create custom product

- [ ] **Tools**
  - Use hydraulic calculator
  - Try different calculators
  - Check results

- [ ] **General**
  - All screens load
  - No crashes
  - Animations smooth
  - Dark mode toggle (if implemented)

---

## Part 8: Collect Feedback (Ongoing)

### Set Up Feedback Channel

**Option A - Google Form**:
1. Create form at https://forms.google.com
2. Questions:
   - What device are you using?
   - What features did you test?
   - Did you encounter any bugs? (describe)
   - What did you like?
   - What needs improvement?
   - Screenshots (optional upload)
3. Share form link with testers

**Option B - Email**:
- Create dedicated email: feedback@plombipro.fr
- Testers send reports there

**Option C - Sentry**:
- Monitor crashes automatically in Sentry dashboard
- View stack traces and user sessions

### Track Issues

Create simple spreadsheet or use Trello/Notion:
- Bug reports
- Feature requests
- Priority (High/Medium/Low)
- Status (New/In Progress/Fixed/Closed)

---

## Common Issues & Solutions

### Build Fails: "SUPABASE_URL not defined"
```bash
# Always include --dart-define flags
flutter build apk --release \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

### App Crashes on Launch
```bash
# Check logs
adb logcat | grep Flutter

# Common causes:
# 1. google-services.json missing
# 2. Supabase keys wrong
# 3. Database migrations not run
```

### Can't Sign APK
```bash
# Verify keystore exists
ls android/plombipro-release-key.jks

# Verify key.properties correct
cat android/key.properties

# Regenerate if needed
```

### Firebase Upload Fails
```bash
# Login again
firebase login --reauth

# Get correct app ID
firebase apps:list

# Try CLI upload again
```

### Testers Can't Install
```
# Common causes:
# 1. Wrong email used for invitation
# 2. "Unknown sources" not enabled
# 3. Old version not uninstalled first

# Solution: Uninstall old version, enable unknown sources
```

---

## Next Steps After Testing

### If Tests Go Well:
1. Fix any critical bugs found
2. Implement feedback
3. Build new version (v1.0.1)
4. Upload to Firebase again
5. Repeat until stable

### When Ready for Production:
1. Create production Supabase project
2. Get production API keys
3. Test with production data
4. Prepare Play Store listing
5. Submit to Google Play

---

## Build Commands Reference

### Development Build:
```bash
flutter run
```

### Debug APK:
```bash
flutter build apk --debug
```

### Release APK:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=SENTRY_DSN=your-dsn
```

### App Bundle (for Play Store later):
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

### With All Options:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=SENTRY_DSN=https://your@sentry.io/12345 \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your-key \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

---

## Timeline

**First Time** (with this guide):
- Part 1 (Database): 30 min
- Part 2 (API Keys): 15 min
- Part 3 (Code Prep): 20 min
- Part 4 (Build): 30 min
- Part 5 (Firebase): 30 min
- Part 6-7 (Testing): 25 min
**Total: ~2.5 hours**

**Subsequent Builds**:
- Code changes: 10 min
- Build: 10 min
- Upload: 5 min
**Total: ~25 minutes**

---

## Success Criteria

You know deployment succeeded when:
✅ App installs on tester devices
✅ Login/signup works
✅ Data saves to Supabase
✅ All core features functional
✅ No crashes during basic use
✅ Testers can provide feedback

---

## Help & Support

**Documentation**:
- This repo: All .md files
- Flutter: https://docs.flutter.dev
- Supabase: https://supabase.com/docs
- Firebase: https://firebase.google.com/docs

**Community**:
- Flutter Discord: https://discord.gg/flutter
- r/FlutterDev: https://reddit.com/r/FlutterDev
- Stack Overflow: Tag [flutter]

**Emergency**:
- Check logs: `adb logcat`
- Check Sentry dashboard for crashes
- Review Supabase logs for API errors
- Test in debug mode first

---

🎉 **You're ready to deploy!** Follow each step carefully and you'll have your app in testers' hands within a few hours.

Good luck! 🚀
