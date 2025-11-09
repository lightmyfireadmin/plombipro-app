# Firebase App Distribution Guide

## 🔐 Authentication Token Error - SOLVED

### Problem
The app shows a **token error** during authentication because Supabase credentials weren't provided during the build process.

### Root Cause
In `lib/main.dart`, the app expects environment variables:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

When these are empty (not provided during build), Supabase initialization fails → token errors.

---

## ✅ Solution: Build with Credentials

### Step 1: Create lib/.env file

```bash
# Copy the example file
cp lib/.env.example lib/.env

# Edit with your actual credentials
nano lib/.env  # or use any text editor
```

**Get your Supabase credentials:**
1. Go to: https://app.supabase.com/project/plombipro-devlpt/settings/api
2. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`

**Example lib/.env:**
```env
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJl...
SENTRY_DSN=  # Optional
```

### Step 2: Build and Distribute

#### Option A: Use the Build Script (Easiest)

```bash
# Make script executable (first time only)
chmod +x build-release.sh distribute-firebase.sh

# Build and distribute in one command
./distribute-firebase.sh "0.5.0" "Fixed authentication token issue"
```

#### Option B: Manual Build

```bash
# Build with credentials
flutter build apk --release \
  --dart-define=SUPABASE_URL="$(grep SUPABASE_URL lib/.env | cut -d '=' -f2)" \
  --dart-define=SUPABASE_ANON_KEY="$(grep SUPABASE_ANON_KEY lib/.env | cut -d '=' -f2)"

# Distribute to Firebase
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app 1:268663350911:android:d84cfcc42f6b4b9a66014a \
  --groups "internal-testers" \
  --release-notes "PlombiPro v0.5.0 - Fixed auth token issue"
```

---

## 📱 For Production: Create Proper Firebase App

The current Firebase app uses package name `com.example.app`. For production, create a new app with `com.plombipro.app`:

### 1. Add New Android App in Firebase

1. Go to: https://console.firebase.google.com/project/plombipro-devlpt
2. **Project Settings** → **Add app** → **Android**
3. **Package name:** `com.plombipro.app`
4. **App nickname:** "PlombiPro Android (Production)"
5. Download the new `google-services.json`

### 2. Update Android Configuration

```bash
# Update package name in build.gradle.kts
# Change from: com.example.app
# Change to:   com.plombipro.app

# Update MainActivity package
# Move from: android/app/src/main/kotlin/com/example/app/
# Move to:   android/app/src/main/kotlin/com/plombipro/app/
```

### 3. Place google-services.json

```bash
# Place the downloaded file at:
cp ~/Downloads/google-services.json android/app/google-services.json
```

### 4. Get New Firebase App ID

After creating the app, you'll get a new App ID like:
```
1:268663350911:android:XXXXXXXXXX
```

Update `distribute-firebase.sh` with the new App ID.

---

## 🚀 Quick Reference

### Build Commands

```bash
# Debug build (no credentials needed)
flutter run

# Release build with credentials
./build-release.sh

# Build + distribute to Firebase
./distribute-firebase.sh "1.0.0" "Production release"
```

### Verify APK Package Name

```bash
# Check package name in built APK
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep package:
```

Expected output:
```
package: name='com.example.app' versionCode='1' versionName='1.0.0'
```

---

## 🐛 Troubleshooting

### "Token error" on authentication
- **Cause:** Missing Supabase credentials during build
- **Fix:** Use `build-release.sh` or add `--dart-define` arguments

### "Package name mismatch" on Firebase upload
- **Cause:** APK package name doesn't match Firebase app
- **Fix:** Either:
  - Upload to matching Firebase app
  - Create new Firebase app with correct package name

### "google-services.json not found"
- **Cause:** Missing Firebase configuration file
- **Fix:** Download from Firebase Console → Project Settings → Your apps

### Build fails with "SUPABASE_URL not set"
- **Cause:** `lib/.env` file missing or incomplete
- **Fix:** Create `lib/.env` from `lib/.env.example` and fill in values

---

## 📝 Important Notes

1. **Never commit lib/.env** - It's in .gitignore for security
2. **Use test credentials** for development/testing
3. **Use production credentials** only for release builds
4. **Rotate keys** if accidentally exposed

---

## 🔗 Useful Links

- Firebase Console: https://console.firebase.google.com/project/plombipro-devlpt
- Supabase Dashboard: https://app.supabase.com/project/plombipro-devlpt
- App Distribution: https://appdistribution.firebase.dev/i/d84cfcc42f6b4b9a66014a
