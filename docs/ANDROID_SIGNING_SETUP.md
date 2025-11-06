# Android Signing Configuration Guide

This guide explains how to set up proper Android app signing for release builds.

## Why You Need This

Currently, the app is signed with debug keys. For production releases and Play Store uploads, you need:
- **Upload key**: For signing app bundles uploaded to Google Play
- **Proper signing configuration**: To enable release builds

## Quick Setup (5 Minutes)

### Step 1: Generate a Keystore

```bash
# Navigate to android directory
cd android

# Generate upload keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

# You'll be prompted for:
# - Keystore password (choose a strong password)
# - Key password (can be same as keystore password)
# - Your name, organization, location (for certificate)
```

**IMPORTANT**: Save your passwords securely! You'll need them for every release.

### Step 2: Create key.properties File

```bash
# In the android directory, create key.properties
cat > key.properties << EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/your-username/upload-keystore.jks
EOF
```

Replace:
- `YOUR_KEYSTORE_PASSWORD`: Password you set in Step 1
- `YOUR_KEY_PASSWORD`: Key password from Step 1
- `/Users/your-username/`: Path to where you saved the keystore

### Step 3: Secure the Keystore

```bash
# Add key.properties to .gitignore (already done)
echo "key.properties" >> .gitignore

# Back up your keystore securely
# Option 1: Cloud storage (encrypted)
# Option 2: Password manager
# Option 3: Secure USB drive

# NEVER commit the keystore or key.properties to git!
```

### Step 4: Update Build Configuration

Replace the contents of `android/app/build.gradle.kts` with the configuration below.

<details>
<summary>Click to see the updated build.gradle.kts</summary>

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.app"  // TODO: Update to your package name
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Signing configurations
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.app"  // TODO: Update to your package name
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (keystorePropertiesFile.exists()) "release" else "debug"
            )

            // Enable optimization for release builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }
}

flutter {
    source = "../.."
}
```

</details>

### Step 5: Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```bash
cat > app/proguard-rules.pro << EOF
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase
-dontwarn org.slf4j.**
-dontwarn org.bouncycastle.**
-keep class io.github.jan.supabase.** { *; }

# Stripe
-keep class com.stripe.android.** { *; }
EOF
```

### Step 6: Test Release Build

```bash
# From project root
flutter build apk --release

# Or build app bundle for Play Store
flutter build appbundle --release

# Check signing
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## Updating Package Name (Optional)

If you want to change from `com.example.app` to something like `com.yourcompany.plombipro`:

### 1. Update Android Configuration

**File: `android/app/build.gradle.kts`**
```kotlin
namespace = "com.yourcompany.plombipro"
applicationId = "com.yourcompany.plombipro"
```

### 2. Update Android Manifest

**File: `android/app/src/main/AndroidManifest.xml`**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.plombipro">
```

### 3. Move Kotlin/Java Files

```bash
cd android/app/src/main/kotlin/com/example/app
# Move files to new package structure
mkdir -p ../../yourcompany/plombipro
mv MainActivity.kt ../../yourcompany/plombipro/
cd ../../
rm -rf example
```

### 4. Update MainActivity.kt

**File: `android/app/src/main/kotlin/com/yourcompany/plombipro/MainActivity.kt`**
```kotlin
package com.yourcompany.plombipro

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

### 5. Update Fastlane Configuration

**File: `android/fastlane/Appfile`**
```ruby
package_name("com.yourcompany.plombipro")
```

### 6. Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## CI/CD Configuration

### For GitHub Actions

Add these secrets to your GitHub repository:

1. **ANDROID_KEYSTORE_BASE64**
   ```bash
   # Encode keystore to base64
   base64 -i ~/upload-keystore.jks | pbcopy
   # Paste into GitHub secret
   ```

2. **ANDROID_KEYSTORE_PASSWORD**
   ```
   Your keystore password
   ```

3. **ANDROID_KEY_ALIAS**
   ```
   upload
   ```

4. **ANDROID_KEY_PASSWORD**
   ```
   Your key password
   ```

The GitHub Actions workflow will automatically decode and use these for building releases.

## Google Play Console Setup

### First Time Setup

1. **Create App in Play Console**
   - Go to https://play.google.com/console
   - Create new app
   - Fill in app details

2. **Upload First Release Manually**
   ```bash
   # Build app bundle
   flutter build appbundle --release

   # Upload to Play Console > Internal Testing
   # This establishes the upload key
   ```

3. **Setup API Access for Automated Uploads**
   - Play Console > Setup > API access
   - Create service account
   - Grant permissions
   - Download JSON key file
   - Add to `android/` directory (don't commit!)

4. **Update Fastlane Configuration**
   ```ruby
   # android/fastlane/Appfile
   json_key_file("path/to/service-account.json")
   package_name("com.yourcompany.plombipro")
   ```

### Subsequent Releases

```bash
# Deploy to internal testing
cd android
fastlane internal

# Or use Fastlane for beta/production
fastlane beta
fastlane production
```

## Troubleshooting

### "Keystore was tampered with"
```bash
# Verify keystore integrity
keytool -list -v -keystore ~/upload-keystore.jks
# Re-enter the correct password
```

### "java.security.UnrecoverableKeyException"
```bash
# Your key password is incorrect
# Update key.properties with correct password
```

### "Duplicate entry"
```bash
# Clean build
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk --release
```

### ProGuard Issues
```bash
# Add rules to proguard-rules.pro for any missing classes
# Check build logs for hints
```

## Security Best Practices

1. ✅ **NEVER commit**:
   - `key.properties`
   - `*.jks` or `*.keystore` files
   - Service account JSON files

2. ✅ **DO backup**:
   - Keystore file (encrypted)
   - Keystore passwords (password manager)
   - Service account JSON (secure location)

3. ✅ **DO use**:
   - Strong passwords (20+ characters)
   - Different passwords for keystore and key
   - Password manager for storage

4. ✅ **DO verify** `.gitignore` includes:
   ```
   key.properties
   **/*.keystore
   **/*.jks
   **/service-account*.json
   ```

## Resources

- [Android App Signing Docs](https://developer.android.com/studio/publish/app-signing)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Fastlane Android Setup](https://docs.fastlane.tools/getting-started/android/setup/)

## Need Help?

- Lost your keystore? Contact Google Play support for app signing recovery
- Forgot password? Unfortunately, keystores cannot be recovered
- Need to regenerate? You'll need to publish as a new app

---

**Remember**: Your keystore and passwords are critical. Losing them means you cannot update your app!
