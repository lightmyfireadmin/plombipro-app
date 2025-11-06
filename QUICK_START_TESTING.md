# Quick Start Testing Guide

Get your app running on both iOS and Android in minutes!

## 🚀 Fastest Route to Test

### For iOS (MacBook Intel)

**Option 1: Wireless Testing (Fastest - No Cable!)**

```bash
# 1. Connect iPhone to same WiFi as Mac
# 2. Enable Developer Mode on iPhone (Settings > Privacy & Security > Developer Mode)
# 3. Connect iPhone via USB ONCE to pair
# 4. In Xcode: Window > Devices and Simulators > Check "Connect via network"
# 5. Disconnect cable and run:

flutter run -d "Your iPhone Name"
```

**Option 2: iOS Simulator (No Device Needed)**

```bash
# Run on simulator (instant testing)
open -a Simulator
flutter run
```

### For Android (Pixel 9 Pro XL - No Cable!)

**Option 1: Firebase App Distribution (Best for Wireless)**

```bash
# One-time setup
curl -sL https://firebase.tools | bash
firebase login

# Build and deploy wirelessly
./scripts/deploy_to_firebase.sh --platform android --notes "Testing build"

# Install on your Pixel 9 Pro:
# 1. Check email on your phone
# 2. Tap "Download" link
# 3. App installs automatically!
```

**Option 2: Wireless ADB (For Development)**

```bash
# Connect via USB ONCE, then:
adb tcpip 5555
adb shell ip -f inet addr show wlan0  # Note the IP address

# Disconnect cable, then connect wirelessly:
adb connect <phone-ip>:5555

# Deploy wirelessly
flutter run -d "Pixel 9"
```

## ⚡ Super Quick Commands

```bash
# Test on iOS (wireless after initial pairing)
flutter run -d "iPhone"

# Test on Android (wireless after ADB setup)
flutter run -d "Pixel"

# Deploy to Firebase (both platforms, no cable)
./scripts/deploy_to_firebase.sh --platform both --notes "New features"

# Run on both simulators (no devices needed)
flutter run -d "iPhone 14 Pro"  # iOS Simulator
flutter run -d "android"         # Android Emulator
```

## 📱 Online Testing Setup (30 Minutes)

### Step 1: Firebase App Distribution Setup (10 min)

```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash

# Login to Firebase
firebase login

# Add yourself as a tester
firebase appdistribution:testers:add your-email@example.com \
  --project plombipro-devlpt

# Create tester group
firebase appdistribution:group:create testers --project plombipro-devlpt
firebase appdistribution:group:add-testers testers your-email@example.com
```

### Step 2: GitHub Actions Setup (15 min)

1. Go to your GitHub repository
2. Settings > Secrets and Variables > Actions > New repository secret
3. Add these secrets:

```
FIREBASE_TOKEN
# Get it with: firebase login:ci
# Then paste the token

# For iOS TestFlight (optional):
APPLE_ID=your-apple-id@example.com
APPLE_APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx
FASTLANE_SESSION=<from fastlane spaceauth>
MATCH_PASSWORD=your-secure-password
```

4. Push any code to trigger automatic builds:

```bash
git add .
git commit -m "Test automated builds"
git push
```

### Step 3: Done! 🎉

Now every push automatically:
- Builds iOS and Android
- Runs tests
- Deploys to Firebase App Distribution
- Notifies testers via email

## 🔧 Common Issues & Fixes

### iOS Wireless Won't Connect

```bash
# Reconnect via USB once, then:
# Xcode > Window > Devices > Uncheck and recheck "Connect via network"
```

### Android ADB Connection Lost

```bash
# Reconnect wirelessly
adb connect <phone-ip>:5555

# Or restart ADB
adb kill-server
adb start-server
```

### Firebase Login Issues

```bash
# Logout and login again
firebase logout
firebase login --reauth
```

### Build Failures

```bash
# Clean everything
flutter clean
flutter pub get

# iOS specific
cd ios && pod deintegrate && pod install && cd ..

# Android specific
cd android && ./gradlew clean && cd ..
```

## 📚 Next Steps

- **Full guide**: See [TESTING.md](./TESTING.md) for comprehensive instructions
- **Firebase Console**: https://console.firebase.google.com/project/plombipro-devlpt/appdistribution
- **GitHub Actions**: Check `.github/workflows/` for CI/CD status

## 💡 Pro Tips

1. **Use simulators** for quick UI testing (no device needed)
2. **Use Firebase** for sharing builds with team (wireless!)
3. **Use GitHub Actions** for automated testing (set it and forget it!)
4. **Keep wireless ADB** connected for fast iterations

## 🆘 Need Help?

- Check build logs in GitHub Actions tab
- View Firebase deployments in console
- Run `flutter doctor` to verify setup
- See [TESTING.md](./TESTING.md) for troubleshooting

---

**TIP**: Bookmark this page for quick reference! 🔖
