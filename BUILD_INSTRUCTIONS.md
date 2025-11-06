# PlombiPro - Build Instructions

## Prerequisites

### Required Software

1. **Flutter SDK** (3.9.2 or higher)
   - Install from: https://docs.flutter.dev/get-started/install
   - Verify installation: `flutter --version`

2. **Dart SDK** (included with Flutter)
   - Verify installation: `dart --version`

3. **Platform-Specific Tools**:
   - **Android**: Android Studio + Android SDK
   - **iOS**: Xcode (macOS only)
   - **Web**: Chrome browser
   - **Desktop**: Platform-specific build tools

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd plombipro-app
```

### 2. Configure Environment Variables

**CRITICAL**: The app will not run without proper environment configuration.

1. Copy the example environment file:
```bash
cp lib/.env.example lib/.env
```

2. Edit `lib/.env` and add your credentials:

```env
# Supabase Configuration (REQUIRED)
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key-here

# Stripe Configuration (REQUIRED for payments)
STRIPE_PUBLISHABLE_KEY=pk_test_your-stripe-publishable-key-here
STRIPE_SECRET_KEY=sk_test_your-stripe-secret-key-here
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret-here

# Google Cloud Platform (REQUIRED for cloud functions)
GCP_PROJECT_ID=your-gcp-project-id-here
```

**Where to get these values:**
- **Supabase**: https://app.supabase.com/project/_/settings/api
- **Stripe**: https://dashboard.stripe.com/test/apikeys
- **GCP**: Your Google Cloud Console project ID

See `CREDENTIALS_SETUP_GUIDE.md` for detailed setup instructions.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code

The app uses `json_serializable` for model serialization. Generate required files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note**: Run this command whenever you modify model classes with `@JsonSerializable()` annotations.

## Building the App

### Development Build

#### Android
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

#### iOS (macOS only)
```bash
flutter build ios --debug --no-codesign
```

#### Web
```bash
flutter build web
# Output: build/web/
```

### Production Build

#### Android (APK)
```bash
flutter build apk --release
```

#### Android (App Bundle - recommended for Play Store)
```bash
flutter build appbundle --release
```

#### iOS (macOS only)
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## Running the App

### Run on Connected Device/Emulator
```bash
flutter run
```

### Run on Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Run in Debug Mode with Hot Reload
```bash
flutter run --debug
```

## Troubleshooting

### Issue: "Missing .env file"
**Solution**: Ensure `lib/.env` exists with all required variables. Copy from `lib/.env.example`.

### Issue: "Missing generated files (*.g.dart)"
**Solution**: Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Build fails with dependency conflicts
**Solution**:
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

### Issue: "Gradle build failed" (Android)
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

## Code Quality Checks

### Run Static Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Format Code
```bash
flutter format lib/
```

## Project Structure

```
plombipro-app/
├── lib/
│   ├── config/          # App configuration (router, theme)
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic & API calls
│   ├── widgets/         # Reusable UI components
│   ├── .env             # Environment variables (DO NOT COMMIT)
│   └── main.dart        # App entry point
├── assets/
│   └── templates/       # Document templates
├── cloud_functions/     # Google Cloud Functions
├── android/            # Android platform code
├── ios/                # iOS platform code
└── web/                # Web platform code
```

## Important Notes

1. **Never commit `lib/.env`** - This file is in `.gitignore` for security
2. **Regenerate code** after modifying models with `@JsonSerializable()`
3. **Use test keys** for Stripe during development
4. **Set up Supabase** database schema before running the app (see `supabase_schema.sql`)

## Additional Documentation

- **Setup Guide**: `CREDENTIALS_SETUP_GUIDE.md`
- **Implementation Status**: `IMPLEMENTATION_SUMMARY.md`
- **Database Schema**: `supabase_schema.sql`
- **Cloud Functions**: `cloud_functions/*/README.md`

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the documentation files
3. Check Flutter documentation: https://docs.flutter.dev
4. Check Supabase documentation: https://supabase.com/docs
