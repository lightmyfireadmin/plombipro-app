# 🚀 Quick Start - Test PlombiPro Right Now!

You've completed the Firebase auto-deploy setup. Here's what to do **right now** on your Mac:

---

## ✅ What's Already Set Up

Your GitHub Actions workflow auto-deploys when you push to `main` or `develop`:
- ✅ **Web app** → Firebase Hosting
- ✅ **Android APK** → Firebase App Distribution
- ✅ **Builds** triggered on every push

---

## 🎯 Immediate Next Steps (On Your Mac)

### Step 1: Add Missing Firebase Secret

Your workflow needs one more secret:

1. **Go to Firebase Console:**
   ```
   https://console.firebase.google.com/project/plombipro-devlpt/settings/serviceaccounts/adminsdk
   ```

2. **Generate new private key:**
   - Click "Generate new private key"
   - Download the JSON file

3. **Convert to base64:**
   ```bash
   # On your Mac terminal:
   cat ~/Downloads/plombipro-devlpt-*.json | base64 | pbcopy
   ```

4. **Add to GitHub Secrets:**
   ```
   https://github.com/lightmyfireadmin/plombipro-app/settings/secrets/actions
   ```
   - Click "New repository secret"
   - Name: `FIREBASE_SERVICE_ACCOUNT`
   - Value: Paste from clipboard (base64 string)
   - Click "Add secret"

### Step 2: Trigger Auto-Deploy

```bash
# On your Mac, in the project directory:
cd /path/to/plombipro-app

# Make a small change to trigger deployment:
echo "# Auto-deploy test" >> README.md

# Commit and push:
git add README.md
git commit -m "Test auto-deploy"
git push origin main
```

### Step 3: Monitor Deployment

1. **Watch GitHub Actions:**
   ```
   https://github.com/lightmyfireadmin/plombipro-app/actions
   ```
   - Wait 5-10 minutes for build to complete
   - All checks should turn green ✅

2. **Check what was deployed:**
   - **Web:** Build and deploy to Firebase Hosting
   - **Android APK:** Build and upload to Firebase App Distribution
   - **Artifacts:** APK saved for 30 days

---

## 📱 Test the Web App (Easiest - Do This First!)

### On Mac:

```bash
# Get your Firebase Hosting URL:
firebase hosting:channel:list
```

Or go directly to:
```
https://plombipro-devlpt.web.app
```

**Open in browser and test!**

### On Android Phone:

1. Open Chrome browser
2. Go to: `https://plombipro-devlpt.web.app`
3. Tap menu (⋮) → "Add to Home screen"
4. Name it "PlombiPro"
5. Now it works like a native app!

---

## 📲 Get Android APK (Native App)

### Option A: Download from GitHub Actions

1. **Go to latest workflow run:**
   ```
   https://github.com/lightmyfireadmin/plombipro-app/actions
   ```

2. **Click the latest "Build and Deploy" run**

3. **Scroll to "Artifacts" section**

4. **Download "android-apk"**

5. **Extract the ZIP → get app-release.apk**

6. **Transfer to your phone:**
   - Email it to yourself
   - Upload to Google Drive
   - Use AirDrop alternative: https://snapdrop.net

7. **On phone:**
   - Tap the APK file
   - Allow "Install from Unknown Sources"
   - Install!

### Option B: Firebase App Distribution (Better!)

1. **Add testers group in Firebase:**
   ```
   https://console.firebase.google.com/project/plombipro-devlpt/appdistribution
   ```
   - Click "Testers & Groups"
   - Create group called "testers"
   - Add your email

2. **Install Firebase App Distribution on phone:**
   - Play Store: "Firebase App Distribution"
   - Sign in with your email

3. **After next push to main:**
   - You'll get email notification
   - Tap "Download" in email
   - Or open Firebase App Distribution app
   - Install directly!

---

## 🖥️ Test on Mac (Native Desktop App)

```bash
# On your Mac terminal:
cd /path/to/plombipro-app

# Enable macOS support (one-time):
flutter config --enable-macos-desktop

# Install dependencies:
flutter pub get

# Run the app:
flutter run -d macos
```

**The app will launch as a native Mac application!**

---

## ⚡ Even Faster: Test Locally Before Deploying

```bash
# Test on Mac browser (instant):
flutter run -d chrome

# Or build and run locally:
flutter run -d macos
```

---

## 🔍 Check Current Deployment Status

```bash
# On your Mac:
cd /path/to/plombipro-app

# Check Firebase hosting:
firebase hosting:channel:list

# Should show:
# - live channel → your production URL
```

---

## 📋 Complete Testing Checklist

- [ ] Add `FIREBASE_SERVICE_ACCOUNT` secret to GitHub
- [ ] Push to `main` branch to trigger deploy
- [ ] Wait for GitHub Actions to complete (~10 min)
- [ ] Test web app on Mac browser
- [ ] Test web app on Android Chrome (Add to Home Screen)
- [ ] Download APK from GitHub Actions artifacts
- [ ] Install APK on Android phone
- [ ] (Optional) Set up Firebase App Distribution
- [ ] (Optional) Test native Mac app with `flutter run -d macos`

---

## 🎉 You're Ready When...

✅ **Web app loads** at `https://plombipro-devlpt.web.app`
✅ **Android APK available** in GitHub Actions artifacts
✅ **Can test on Mac** with `flutter run -d chrome` or `-d macos`

---

## 🆘 Quick Troubleshooting

### "GitHub Actions failing"

```bash
# Check the workflow logs:
# Go to: https://github.com/lightmyfireadmin/plombipro-app/actions
# Click the failed run
# Check which step failed
```

Common issues:
- Missing `FIREBASE_SERVICE_ACCOUNT` secret → Add it (Step 1 above)
- Missing `.env` file → See TESTING_GUIDE_MAC_ANDROID.md

### "Can't run Flutter commands"

```bash
# Install Flutter first:
# Download from: https://docs.flutter.dev/get-started/install/macos

# Or via Homebrew:
brew install flutter

# Verify:
flutter doctor
```

### "Firebase commands not working"

```bash
# Login to Firebase:
firebase login

# Set project:
firebase use plombipro-devlpt

# Verify:
firebase projects:list
```

---

## 📖 For More Details

See **TESTING_GUIDE_MAC_ANDROID.md** for:
- Complete setup instructions
- USB debugging setup
- Wireless testing options
- Advanced deployment options
- Full troubleshooting guide

---

## 🔥 Recommended First Steps

**Do these IN ORDER:**

1. **Add the Firebase secret** (Step 1 above) - 2 minutes
2. **Push to main** to trigger deploy (Step 2) - 30 seconds
3. **Test web app** on Mac browser (Step 3) - Immediate!
4. **Test web app** on Android phone - 1 minute
5. **Download APK** from Actions and install - 5 minutes

**Total time: ~10 minutes to test on both platforms!**

---

## 🚀 Daily Workflow Going Forward

```bash
# 1. Make code changes
# 2. Test locally (instant):
flutter run -d chrome

# 3. When ready to deploy:
git add .
git commit -m "Your changes"
git push origin main

# 4. Auto-deploy happens:
#    - Web app updates in ~10 min
#    - New APK available in Actions
#    - (Optional) Firebase App Distribution notification
```

**That's it! Your testing setup is ready.** 🎯
