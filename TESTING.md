# Testing Guide for PlombiPro App

This guide provides step-by-step instructions for testing the app on both iOS and Android platforms, including wireless deployment options and automated online testing.

## Prerequisites

### Required Tools
- **macOS**: macOS 11.0 or later (for iOS builds)
- **Xcode**: 14.0+ with iOS SDK
- **Flutter**: 3.9.2 or later
- **Android Studio**: Optional (for Android debugging)
- **Firebase CLI**: For deployment to Firebase App Distribution
- **Fastlane**: For automated iOS/Android deployment

### Install Prerequisites

```bash
# Install Flutter (if not already installed)
# Follow instructions at: https://docs.flutter.dev/get-started/install/macos

# Install Firebase CLI
curl -sL https://firebase.tools | bash

# Install Fastlane
sudo gem install fastlane -NV

# Login to Firebase
firebase login

# Verify installations
flutter doctor
firebase --version
fastlane --version
```

## Quick Start - Local Testing

### 1. Initial Setup

```bash
# Navigate to project directory
cd /path/to/plombipro-app

# Install dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

### 2. iOS Testing (Wireless via Network)

#### Option A: Direct Wireless Deployment (Fastest)

```bash
# Step 1: Connect your iPhone to the same WiFi as your Mac

# Step 2: Enable wireless debugging on your iPhone
# - Connect iPhone via USB ONCE
# - In Xcode: Window > Devices and Simulators > Devices
# - Select your iPhone, check "Connect via network"
# - Disconnect USB cable

# Step 3: Build and deploy wirelessly
flutter run -d <device-name>
```

#### Option B: TestFlight Deployment (For Beta Testing)

```bash
# Build iOS archive
flutter build ipa --release

# Upload to TestFlight using Fastlane (see Fastlane section below)
cd ios
fastlane beta
```

**TestFlight Benefits**:
- No cable needed after initial setup
- Test on multiple devices
- Easy version management
- Over-the-air (OTA) updates

### 3. Android Testing (Wireless)

#### Option A: Firebase App Distribution (Recommended)

```bash
# Build Android APK
flutter build apk --release

# Or build App Bundle (for Play Store)
flutter build appbundle --release

# Deploy to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:268663350911:android:d84cfcc42f6b4b9a66014a \
  --groups testers \
  --release-notes "Latest test build"
```

**Firebase App Distribution Benefits**:
- Wireless distribution to testers
- No cable connection needed
- Automatic notifications to testers
- Version tracking and rollback

#### Option B: Wireless ADB Debugging

```bash
# Step 1: Connect Pixel 9 Pro XL via USB ONCE
adb tcpip 5555

# Step 2: Find your phone's IP address
# Settings > About phone > Status > IP address
# Or run: adb shell ip -f inet addr show wlan0

# Step 3: Connect wirelessly
adb connect <phone-ip>:5555

# Step 4: Disconnect USB cable and deploy
flutter run -d <device-name>
```

## Automated Online Testing & Deployment

### GitHub Actions CI/CD

The project includes automated workflows for:
- **Build & Test**: Runs on every push/PR
- **Deploy to Firebase**: Automatic deployment to App Distribution
- **TestFlight Upload**: Automated iOS beta distribution

#### Configuration Files

1. **`.github/workflows/build-and-deploy.yml`**: Main CI/CD pipeline
2. **`.github/workflows/test.yml`**: Automated testing
3. **`fastlane/Fastfile`**: iOS/Android automation scripts

#### Setup Steps

1. **Configure GitHub Secrets** (Repository Settings > Secrets and Variables > Actions):

   ```
   FIREBASE_TOKEN              # Firebase CI token (run: firebase login:ci)
   APPLE_ID                    # Your Apple ID email
   APPLE_APP_SPECIFIC_PASSWORD # App-specific password from appleid.apple.com
   MATCH_PASSWORD              # Password for certificate encryption
   FASTLANE_SESSION            # Fastlane session token
   ANDROID_KEYSTORE_BASE64     # Base64 encoded keystore file
   ANDROID_KEYSTORE_PASSWORD   # Keystore password
   ANDROID_KEY_ALIAS           # Key alias
   ANDROID_KEY_PASSWORD        # Key password
   ```

2. **Generate Firebase Token**:
   ```bash
   firebase login:ci
   # Copy the token and add to GitHub secrets
   ```

3. **Configure Apple Credentials**:
   ```bash
   # Generate app-specific password at appleid.apple.com
   # Add to GitHub secrets as APPLE_APP_SPECIFIC_PASSWORD
   ```

4. **Push to GitHub** and workflows will run automatically

### Firebase App Distribution Setup

1. **Enable App Distribution** in Firebase Console:
   - Go to https://console.firebase.google.com/project/plombipro-devlpt
   - Navigate to App Distribution
   - Add testers and create groups

2. **Add Testers**:
   ```bash
   # Add individual tester
   firebase appdistribution:testers:add tester@example.com --project plombipro-devlpt

   # Create tester group
   firebase appdistribution:group:create testers --project plombipro-devlpt

   # Add tester to group
   firebase appdistribution:group:add-testers testers tester@example.com
   ```

3. **Distribute Build**:
   ```bash
   # Android
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
     --app 1:268663350911:android:d84cfcc42f6b4b9a66014a \
     --groups testers

   # iOS
   firebase appdistribution:distribute build/ios/ipa/app.ipa \
     --app 1:268663350911:ios:93817ef0f50de33b66014a \
     --groups testers
   ```

## Fastlane Automation

### iOS TestFlight Deployment

```bash
cd ios
fastlane beta
```

This will:
1. Increment build number
2. Build the app
3. Sign with certificates
4. Upload to TestFlight
5. Submit for review (optional)

### Android Firebase Distribution

```bash
cd android
fastlane beta
```

This will:
1. Build release APK
2. Sign with release keys
3. Upload to Firebase App Distribution
4. Notify testers

### Custom Lanes

```bash
# Build only (no deployment)
fastlane build

# Take screenshots for App Store
fastlane screenshots

# Run tests
fastlane test
```

## Testing Workflows

### Daily Development Testing

1. **Local changes**: Use wireless debugging for quick iterations
   ```bash
   flutter run --debug
   ```

2. **Feature testing**: Deploy to Firebase App Distribution
   ```bash
   flutter build apk --release
   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Release candidate**: Deploy to TestFlight
   ```bash
   cd ios && fastlane beta
   ```

### Continuous Testing (Automated)

Every push to main branch will:
1. Run unit tests
2. Build iOS and Android apps
3. Deploy to Firebase App Distribution (Android)
4. Upload to TestFlight (iOS)
5. Notify testers via email

## Troubleshooting

### iOS Issues

**Problem**: "Developer Mode Required" on iOS 16+
```bash
# Enable Developer Mode on iPhone:
# Settings > Privacy & Security > Developer Mode > Enable
```

**Problem**: Certificate issues
```bash
# Reset certificates with Fastlane Match
cd ios
fastlane match development --force_for_new_devices
fastlane match appstore --force_for_new_devices
```

**Problem**: Provisioning profile mismatch
```bash
# Clean and rebuild
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

### Android Issues

**Problem**: Wireless ADB disconnects
```bash
# Reconnect
adb connect <phone-ip>:5555

# Keep connection alive
adb shell settings put global stay_on_while_plugged_in 3
```

**Problem**: Signing issues
```bash
# Verify keystore
keytool -list -v -keystore ~/upload-keystore.jks

# Generate new keystore if needed
keytool -genkey -v -keystore ~/upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

### General Issues

**Problem**: Dependencies out of sync
```bash
flutter clean
flutter pub get
cd ios && pod repo update && pod install
cd android && ./gradlew clean
```

**Problem**: Build cache issues
```bash
flutter clean
rm -rf build/
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle android/build
flutter pub get
```

## Best Practices

1. **Version Management**:
   - Always increment version before releasing
   - Use semantic versioning (MAJOR.MINOR.PATCH)
   - Keep changelog updated

2. **Testing Groups**:
   - **Internal**: Core team for daily builds
   - **Beta**: Extended testers for weekly releases
   - **Staging**: Pre-production testing

3. **Build Flavors** (Future enhancement):
   - Dev: Development builds with debug tools
   - Staging: Pre-production testing
   - Production: Release builds

4. **Monitoring**:
   - Check Sentry for crash reports
   - Monitor Firebase Analytics for usage
   - Review TestFlight feedback

## Resources

- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [TestFlight Guidelines](https://developer.apple.com/testflight/)
- [Android App Distribution](https://support.google.com/googleplay/android-developer/answer/9844679)

## Support

For issues or questions:
- Check build logs in GitHub Actions
- Review Firebase App Distribution console
- Contact the development team
