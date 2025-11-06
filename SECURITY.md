# PlombiPro Security Implementation

This document outlines the security measures implemented in PlombiPro to protect user data and prevent unauthorized access.

## Table of Contents

1. [Database Security](#database-security)
2. [Cloud Functions Security](#cloud-functions-security)
3. [Input Validation](#input-validation)
4. [Rate Limiting](#rate-limiting)
5. [Environment Configuration](#environment-configuration)
6. [Storage Security](#storage-security)
7. [Deployment Checklist](#deployment-checklist)

---

## Database Security

### Row Level Security (RLS)

All database tables have RLS policies enabled to ensure users can only access their own data.

**Implementation Files:**
- `supabase_schema.sql` - Contains RLS policies for all main tables
- `supabase_rls_profiles_fix.sql` - Additional RLS policy for profiles table

**Protected Tables:**
- `profiles` - User profile information
- `clients` - Client contacts
- `products` - Product catalog
- `quotes` - Customer quotes
- `invoices` - Customer invoices
- `payments` - Payment records
- `scans` - OCR scans
- `templates` - Document templates
- `purchases` - Supplier invoices
- `job_sites` - Job site management
- `categories` - User categories
- `notifications` - User notifications
- `settings` - User settings
- `stripe_subscriptions` - Subscription data

**Policy Pattern:**
```sql
-- Example for clients table
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own clients"
  ON clients FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own clients"
  ON clients FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**How to Deploy:**
```bash
# Apply the schema to your Supabase project
psql -h db.yourproject.supabase.co -U postgres -d postgres -f supabase_schema.sql
psql -h db.yourproject.supabase.co -U postgres -d postgres -f supabase_rls_profiles_fix.sql
```

---

## Cloud Functions Security

### JWT Authentication

All HTTP Cloud Functions require valid Supabase JWT tokens for authentication.

**Implementation Files:**
- `cloud_functions/shared/auth_utils.py` - Shared authentication utilities
- `cloud_functions/shared/requirements.txt` - PyJWT dependency

**Secured Functions:**
1. ✅ `ocr_processor` - OCR text extraction
2. ✅ `send_email` - Email sending
3. ✅ `invoice_generator` - PDF invoice generation
4. ✅ `facturx_generator` - Factur-X XML generation
5. ✅ `chorus_pro_submitter` - Chorus Pro submission

**Scheduled Functions (No User Auth Required):**
- `payment_reminder_scheduler` - Triggered by Cloud Scheduler
- `quote_expiry_checker` - Triggered by Cloud Scheduler
- `scraper_cedeo` - Triggered by Cloud Scheduler
- `scraper_point_p` - Triggered by Cloud Scheduler

**Webhook Functions (Signature Verification):**
- `stripe_webhook_handler` - Uses Stripe signature verification

**Usage Example:**
```python
from shared.auth_utils import require_auth

@functions_framework.http
@require_auth
def my_function(request):
    # Access authenticated user ID
    user_id = request.user_id
    # Function logic here
```

**Client-Side Usage:**
```dart
// Flutter client must include Authorization header
final token = Supabase.instance.client.auth.currentSession?.accessToken;
final response = await dio.post(
  functionUrl,
  data: {...},
  options: Options(headers: {
    'Authorization': 'Bearer $token',
  }),
);
```

---

## Input Validation

### Comprehensive Validators

French-specific validators for all user inputs.

**Implementation File:**
- `lib/utils/validators.dart`

**Validators Available:**
- ✅ Email (RFC 5322 compliant)
- ✅ SIRET (14 digits with Luhn check)
- ✅ SIREN (9 digits with Luhn check)
- ✅ French VAT number (with check digit validation)
- ✅ French phone number (10 digits)
- ✅ French postal code (5 digits)
- ✅ IBAN (with mod-97 checksum)
- ✅ BIC/SWIFT code
- ✅ Monetary amounts (max 2 decimals)
- ✅ Percentages (0-100)
- ✅ Invoice numbers
- ✅ Text length validation
- ✅ Date validation

**Usage Example:**
```dart
import 'package:app/utils/validators.dart';

TextFormField(
  validator: Validators.validateEmail,
  decoration: InputDecoration(labelText: 'Email'),
),

TextFormField(
  validator: Validators.validateSIRET,
  decoration: InputDecoration(labelText: 'SIRET'),
),
```

**Security Benefits:**
- Prevents SQL injection
- Prevents XSS attacks
- Ensures data integrity
- Provides user-friendly error messages

---

## Rate Limiting

### Client-Side Rate Limiting

Token bucket algorithm to prevent API abuse.

**Implementation File:**
- `lib/utils/rate_limiter.dart`
- Initialized in `lib/main.dart`

**Configuration:**
- Default: 60 requests per minute
- Default: 1000 requests per hour
- Configurable via `.env` file

**Usage Example:**
```dart
import 'package:app/utils/rate_limiter.dart';

try {
  await checkRateLimit(); // Throws RateLimitException if exceeded
  // Make API call
  await supabase.from('clients').select();
} on RateLimitException catch (e) {
  // Show user-friendly error
  showDialog(context, e.message);
}
```

### Server-Side Rate Limiting

PostgreSQL-based rate limiting at database level.

**Implementation File:**
- `supabase_rate_limiting.sql`

**Features:**
- Per-user rate tracking
- Automatic window reset
- SQL functions: `check_rate_limit()` and `get_rate_limit_status()`

**How to Deploy:**
```bash
psql -h db.yourproject.supabase.co -U postgres -d postgres -f supabase_rate_limiting.sql
```

**Usage in Functions:**
```sql
-- Check rate limit before processing
SELECT check_rate_limit(auth.uid(), 60, 1000);
```

---

## Environment Configuration

### Centralized Environment Management

Standardized on `flutter_dotenv` for all environment variables.

**Implementation Files:**
- `lib/config/env_config.dart` - Centralized configuration
- `lib/.env.example` - Template for Flutter app
- `cloud_functions/.env.example` - Template for Cloud Functions

**Required Variables:**
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `SUPABASE_JWT_SECRET` - JWT secret for Cloud Functions
- `STRIPE_PUBLISHABLE_KEY` - Stripe public key

**Setup Instructions:**
```bash
# 1. Copy example files
cp lib/.env.example lib/.env
cp cloud_functions/.env.example cloud_functions/.env

# 2. Fill in your actual values
nano lib/.env

# 3. NEVER commit .env files (already in .gitignore)
```

**Validation:**
The app validates all required environment variables on startup:
```dart
// In main.dart
EnvConfig.validate(); // Throws if any required var is missing
```

---

## Storage Security

### Supabase Storage Bucket Policies

Fine-grained access control for file uploads.

**Implementation File:**
- `supabase_bucket_policies.sql`

**Bucket Configuration:**

| Bucket | Access | Max Size | MIME Types |
|--------|--------|----------|------------|
| `avatars` | Public read, user upload | 1 MB | image/jpeg, image/png, image/webp |
| `logos` | Public read, user upload | 1 MB | image/jpeg, image/png, image/webp, image/svg+xml |
| `documents` | Private | 5 MB | application/pdf, application/xml |
| `signatures` | Private | 500 KB | image/png, image/jpeg |
| `worksite_photos` | Private | 5 MB | image/jpeg, image/png, image/webp |
| `scans` | Private | 5 MB | image/jpeg, image/png, application/pdf |

**Security Features:**
- ✅ User-scoped access (users can only access their own files)
- ✅ File size limits enforced
- ✅ MIME type validation
- ✅ Prevents directory traversal attacks

**How to Deploy:**
```bash
psql -h db.yourproject.supabase.co -U postgres -d postgres -f supabase_bucket_policies.sql
```

---

## Deployment Checklist

### Before Going to Production

#### 1. Environment Variables
- [ ] Copy `.env.example` to `.env` and fill in production values
- [ ] Use production Supabase URL and keys
- [ ] Use live Stripe keys (not test keys)
- [ ] Set `ENVIRONMENT=production`
- [ ] Set `DEBUG_MODE=false`

#### 2. Database Security
- [ ] Deploy all RLS policies: `supabase_schema.sql`
- [ ] Deploy profiles RLS fix: `supabase_rls_profiles_fix.sql`
- [ ] Deploy rate limiting: `supabase_rate_limiting.sql`
- [ ] Deploy storage policies: `supabase_bucket_policies.sql`
- [ ] Verify RLS is enabled on all tables

#### 3. Cloud Functions
- [ ] Deploy all Cloud Functions with authentication
- [ ] Set `SUPABASE_JWT_SECRET` in each function's environment
- [ ] Configure Cloud Scheduler for scheduled functions
- [ ] Set up Stripe webhook with signature verification
- [ ] Test authentication on all HTTP endpoints

#### 4. Validation & Rate Limiting
- [ ] Test all input validators with edge cases
- [ ] Configure appropriate rate limits for production
- [ ] Monitor rate limit hits in logs
- [ ] Set up alerts for rate limit violations

#### 5. Testing
- [ ] Test RLS policies (try accessing other users' data)
- [ ] Test Cloud Function authentication (try without token)
- [ ] Test rate limiting (exceed limits intentionally)
- [ ] Test input validation (try SQL injection, XSS)
- [ ] Test storage policies (try uploading wrong MIME types)

#### 6. Monitoring
- [ ] Set up error tracking (e.g., Sentry)
- [ ] Monitor Supabase dashboard for suspicious activity
- [ ] Set up alerts for failed authentication attempts
- [ ] Review Cloud Function logs regularly

#### 7. Documentation
- [ ] Update API documentation with authentication requirements
- [ ] Document rate limits for API consumers
- [ ] Share security policy with team
- [ ] Keep this SECURITY.md up to date

---

## Security Incident Response

If you discover a security vulnerability:

1. **Do NOT** open a public GitHub issue
2. Email security@plombipro.com immediately
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours.

---

## Security Audit History

| Date | Auditor | Findings | Status |
|------|---------|----------|--------|
| 2024-11-05 | Claude AI | Critical security gaps identified | ✅ Fixed |
| | | - No RLS on profiles table | ✅ Fixed |
| | | - No Cloud Function authentication | ✅ Fixed |
| | | - No input validation | ✅ Fixed |
| | | - No rate limiting | ✅ Fixed |

---

## Additional Resources

- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [French GDPR Compliance](https://www.cnil.fr/en/home)
- [Stripe Security](https://stripe.com/docs/security/stripe)

---

## License

This security documentation is part of PlombiPro and is confidential.
