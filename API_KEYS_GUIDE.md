# PlombiPro - API Keys & Configuration Guide

## Required API Keys

### 1. Supabase (REQUIRED) ⭐

**Where to Get**:
1. Go to https://app.supabase.com
2. Select your PlombiPro project (or create new one)
3. Click "Settings" → "API"
4. Copy these values:

**Keys Needed**:
```
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc.....(very long key)
```

**Used In App**:
- `lib/main.dart` - App initialization
- All database operations via repositories
- Authentication (login/signup)
- File uploads (PDFs, signatures)
- Real-time subscriptions

**Setup in Supabase**:
```bash
# 1. Create project at app.supabase.com
#    - Project name: PlombiPro
#    - Database password: (save this!)
#    - Region: Europe (Paris) for best latency in France

# 2. Run database migrations:
#    - Go to SQL Editor
#    - Copy from COMPLETE_DATABASE_SETUP.sql
#    - Click "Run"

# 3. Enable authentication:
#    - Go to Authentication → Settings
#    - Enable Email authentication
#    - Disable email confirmations (for testing)
#    - Set site URL: http://localhost (for now)

# 4. Set up storage buckets:
#    - Go to Storage
#    - Create bucket: "invoices" (public)
#    - Create bucket: "quotes" (public)  
#    - Create bucket: "signatures" (private)
```

---

### 2. Sentry (OPTIONAL - Error Tracking)

**Where to Get**:
1. Go to https://sentry.io
2. Sign up (free tier: 5,000 errors/month)
3. Create new project:
   - Platform: Flutter
   - Project name: PlombiPro
4. Copy DSN

**Key Needed**:
```
SENTRY_DSN=https://xxxxx@oxxxxx.ingest.sentry.io/xxxxxx
```

**Used In App**:
- `lib/services/error_service.dart`
- Automatic crash reporting
- Performance monitoring
- Error tracking with stack traces
- User feedback collection

**Setup**:
```dart
// In lib/main.dart (already configured)
if (sentryDsn.isNotEmpty) {
  await ErrorService.initialize(sentryDsn: sentryDsn);
}
```

**Features**:
- Real-time error alerts
- Release tracking
- Performance metrics
- User session replays
- Stack trace source maps

---

### 3. Stripe (OPTIONAL - Payments)

**Where to Get**:
1. Go to https://dashboard.stripe.com
2. Sign up
3. Get test keys: Developers → API keys

**Keys Needed**:
```
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...  (keep server-side only!)
```

**Used In App**:
- Client portal invoice payments
- Subscription billing (future)
- One-time payments
- Payment method management

**Setup**:
```dart
// In lib/main.dart (currently commented out)
// Uncomment when ready for payments:
const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
if (stripePublishableKey.isNotEmpty) {
  Stripe.publishableKey = stripePublishableKey;
}
```

**Important**:
- Never commit secret key to git
- Use test keys for development
- Switch to live keys only for production
- Set up webhooks for payment events

---

### 4. Google Maps (OPTIONAL - Address Autocomplete)

**Where to Get**:
1. Go to https://console.cloud.google.com
2. Create new project: "PlombiPro"
3. Enable APIs:
   - Maps SDK for Android
   - Places API
   - Geocoding API
4. Create credentials → API key
5. Restrict key to your app's package name

**Key Needed**:
```
GOOGLE_MAPS_API_KEY=AIzaSy...
```

**Used In App**:
- Job site address input with autocomplete
- Client address autocomplete
- Map view for appointments (future)
- Distance calculations (future)

**Setup in AndroidManifest.xml**:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

---

### 5. Firebase (REQUIRED for App Distribution)

**Where to Get**:
1. Go to https://console.firebase.google.com
2. Create project: "PlombiPro"
3. Add Android app
4. Download `google-services.json`

**File Needed**:
```
google-services.json → android/app/
```

**Used In App**:
- App Distribution for testing
- Analytics (optional)
- Crash Reporting (optional)
- Remote Config (optional)
- Cloud Messaging (future push notifications)

**Setup**:
```bash
# 1. Download google-services.json
# 2. Place in android/app/
# 3. Add to android/app/build.gradle:
apply plugin: 'com.google.gms.google-services'
```

---

## Configuration Files

### 1. Create: `build-config.properties`

**Location**: `android/app/build-config.properties`

```properties
# Supabase (REQUIRED)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Sentry (Optional - Error Tracking)
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id

# Stripe (Optional - Payments)
STRIPE_PUBLISHABLE_KEY=pk_test_your-test-key

# Google Maps (Optional - Address Autocomplete)
GOOGLE_MAPS_API_KEY=AIzaSy-your-key-here
```

**Important**: Add to `.gitignore`:
```
android/app/build-config.properties
```

### 2. Create: `key.properties`

**Location**: `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=plombipro
storeFile=/Users/yourname/plombipro-release-key.jks
```

**Important**: Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

### 3. Update: `.gitignore`

Add these lines:
```
# API Keys & Secrets
android/app/build-config.properties
android/key.properties
*.jks
*.keystore
google-services.json

# Environment
.env
.env.local
.env.production
```

---

## Using Keys in Build

### Method 1: Dart Defines (Recommended)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SENTRY_DSN=your-sentry-dsn \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your-key
```

### Method 2: Environment File

**Create**: `.env` (local development only)
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENTRY_DSN=your-sentry-dsn
```

**Load in Dart**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: ".env");
final supabaseUrl = dotenv.env['SUPABASE_URL']!;
```

### Method 3: Config File (Android)

Already set up in `build-config.properties` → automatically loaded by Gradle.

---

## Security Best Practices

### DO ✅
- Use environment variables for all keys
- Use different keys for dev/staging/production
- Restrict API keys to specific domains/packages
- Use `.gitignore` to exclude config files
- Rotate keys regularly
- Use Supabase RLS for data security
- Monitor API usage and set quotas

### DON'T ❌
- Commit API keys to git
- Share keys in screenshots/videos
- Use production keys in development
- Hardcode keys in source code
- Use same keys across projects
- Expose secret keys to client-side
- Disable security features for convenience

---

## Key Restrictions

### Supabase
- Enable RLS on all tables
- Set up proper auth policies
- Use anon key for public access
- Use service role key only server-side

### Stripe
- Restrict publishable key to your domain
- Keep secret key server-side only
- Enable webhook signature verification
- Use test mode for development

### Google Maps
- Restrict to Android app package name
- Set daily quota limits
- Enable only required APIs
- Monitor usage dashboard

---

## Testing Keys

### Test All Keys Work:

```bash
# Test Supabase connection
curl https://your-project.supabase.co/rest/v1/ \
  -H "apikey: your-anon-key"

# Should return API info

# Test in app
flutter run --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key

# Try to login/signup - should work
```

---

## Troubleshooting

### Issue: "SUPABASE_URL not found"
**Solution**: Always pass `--dart-define` in build command

### Issue: "Invalid API key"
**Solution**: Regenerate key in Supabase dashboard → API settings

### Issue: "RLS policy violation"
**Solution**: Check policies allow authenticated users to access data

### Issue: "Stripe: No such customer"
**Solution**: Using test keys with production data or vice versa

### Issue: "Google Maps not loading"
**Solution**: Check API key is correct and Maps SDK is enabled

---

## Production Checklist

Before going live:
- [ ] Create production Supabase project
- [ ] Get production API keys (separate from dev)
- [ ] Enable Stripe live mode
- [ ] Set up production Sentry project
- [ ] Configure production Firebase project
- [ ] Update all keys in build-config.properties
- [ ] Test production build thoroughly
- [ ] Set up monitoring and alerts
- [ ] Document key rotation schedule
- [ ] Set up backup/recovery plan

---

## Key Storage Locations

**Development**:
- `android/app/build-config.properties` (local, gitignored)
- `--dart-define` in build commands
- Environment variables in CI/CD

**Production**:
- GitHub Secrets (for GitHub Actions)
- Fastlane Match (for certificates)
- Secure CI/CD variables
- Team password manager (1Password, etc.)

---

## Need Help?

- Supabase: https://supabase.com/docs
- Sentry: https://docs.sentry.io/platforms/flutter/
- Stripe: https://stripe.com/docs/payments
- Google Maps: https://developers.google.com/maps/documentation
- Firebase: https://firebase.google.com/docs

**Support**:
- Supabase Discord: https://discord.supabase.com
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag with [flutter] [supabase]
