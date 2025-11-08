# PlombiPro Technology Stack (Definitive Reference)
**Last Updated**: November 5, 2025
**Status**: MVP Phase 1 (55% Complete)
**Version**: 1.0

---

## ⚠️ IMPORTANT: SINGLE SOURCE OF TRUTH

This document is the **AUTHORITATIVE** reference for PlombiPro's technology stack.
If you find discrepancies between this file and other documentation, **this file takes precedence**.

Please update this document first, then propagate changes to other files.

---

## 🎯 PROJECT OVERVIEW

| Aspect | Details |
|--------|---------|
| **Project Name** | PlombiPro |
| **Purpose** | Invoice & Quote Management for French Plumbers |
| **Target Market** | France (French language UI) |
| **Platform** | iOS, Android, Web (PWA) |
| **Development Status** | MVP Phase 1 - 55% Feature Complete |
| **Target Launch** | Q1 2026 (Beta), Q2 2026 (Production) |

---

## 📱 FRONTEND STACK

### Core Framework
```yaml
Framework: Flutter 3.x
Language: Dart SDK ^3.9.2
UI Library: Material Design 3
Minimum iOS: 11.0
Minimum Android: API 21 (Android 5.0)
```

### Key Packages (from pubspec.yaml)
| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^2.5.3 | Database, Auth, Storage |
| `flutter_stripe` | ^12.1.0 | Payment processing |
| `go_router` | ^14.1.4 | Navigation/routing |
| `pdf` | ^3.11.0 | PDF generation |
| `intl` | ^0.20.2 | Internationalization (French) |
| `image_picker` | ^1.1.2 | Camera/gallery access |
| `permission_handler` | ^12.0.1 | Permission management |
| `dio` | ^5.5.0+1 | HTTP client |
| `signature` | ^5.4.0 | Digital signatures |
| `fl_chart` | ^1.1.1 | Charts/analytics |
| `google_fonts` | ^6.2.1 | Typography |
| `flutter_dotenv` | ^5.1.0 | Environment variables |

### State Management
**Status**: ⚠️ **TO BE DETERMINED**
- Not explicitly defined in current codebase
- Appears to use basic setState/Provider pattern
- **Recommendation**: Document actual pattern used

---

## ⚙️ BACKEND STACK

### Primary Backend: Supabase
```
Service: Supabase (supabase.com)
Database: PostgreSQL 15+
Region: Frankfurt, Germany (EU compliance)
Features Used:
  - Authentication (JWT)
  - PostgreSQL Database with Row Level Security
  - Realtime subscriptions
  - Storage (avatars, documents, PDFs, photos)
  - Edge Functions (NOT USED - using Google Cloud Functions instead)
```

### Cloud Functions: Google Cloud Platform
```
Platform: Google Cloud Functions
Runtime: Python 3.11
Region: europe-west1 (Belgium - EU)
Deployment: gcloud CLI
```

**Deployed Functions (Actual Names)**:
1. `ocr_processor` - OCR processing with Google Vision API
2. `invoice_generator` - Invoice PDF generation
3. `facturx_generator` - Electronic invoice (Factur-X/CII XML)
4. `send_email` - Email notifications
5. `payment_reminder_scheduler` - Scheduled payment reminders
6. `quote_expiry_checker` - Quote expiration monitoring
7. `stripe_webhook_handler` - Stripe webhook processing
8. `chorus_pro_submitter` - French PPF (Chorus Pro) submission
9. `scraper_point_p` - Point.P catalog scraper ⚠️ (Status: Unknown)
10. `scraper_cedeo` - Cedeo catalog scraper ⚠️ (Status: Unknown)

---

## 🔌 THIRD-PARTY APIs & SERVICES

### OCR Processing
```
Service: Google Cloud Vision API
Tier: Pay-as-you-go
Pricing: ~$1.50 per 1,000 requests
Features: Text detection, document OCR
Alternative Considered: OCR.space (FREE tier 25k/month)
Status: ✅ IMPLEMENTED
```

### Email Service
```
Service: Resend (resend.com)
Tier: Free (3,000 emails/month)
Pricing After: $20/month for 50k emails
Features: Transactional emails, templates
Alternative Considered: SendGrid
Status: ⚠️ NEEDS VERIFICATION - Some docs mention SendGrid
```

**🚨 ACTION REQUIRED**: Verify which email service is actually deployed:
- [ ] Check cloud_functions/send_email/main.py
- [ ] Update all documentation to match actual service
- [ ] If using SendGrid, update README.md
- [ ] If using Resend, update Part 2 & Part 3 docs

### Payment Processing
```
Service: Stripe (stripe.com)
Package: flutter_stripe ^12.1.0
Mode: Test mode (sandbox) currently
Features: Payment intents, webhooks, refunds
Pricing: 1.5% + €0.25 per transaction (EU cards)
Status: ✅ IMPLEMENTED (not deployed)
```

### Electronic Invoicing (2026 Compliance)
```
Standard: Factur-X (EN16931)
Format: PDF/A-3 with embedded XML (CII)
Submission: Chorus Pro API (French PPF)
Status: ⚠️ CODE READY, NOT TESTED IN PRODUCTION
```

---

## 🗄️ DATABASE SCHEMA

### Supabase Tables (12 Total)
```sql
Core Tables:
1. users - User authentication (managed by Supabase Auth)
2. profiles - User profile & company info
3. clients - Customer/client records
4. quotes - Devis (quotes)
5. quote_items - Line items for quotes
6. invoices - Factures (invoices)
7. invoice_items - Line items for invoices
8. products - Product catalog (personal)
9. worksites - Chantiers (job sites)
10. payments - Payment tracking
11. scans - OCR scan records
12. documents - Document metadata
```

**Row Level Security (RLS)**: ✅ Enabled on all tables

### Storage Buckets (6 Total)
```
1. avatars - User profile pictures
2. logos - Company logos
3. documents - PDFs (quotes, invoices)
4. signatures - Electronic signatures (Factur-X)
5. worksite_photos - Job site photos
6. scans - Scanned invoice images
```

**Bucket Policies**: Authenticated users only, user isolation enforced

---

## 🔐 AUTHENTICATION & SECURITY

### Authentication
```
Provider: Supabase Auth
Method: Email/Password (JWT tokens)
Session: 1 hour default, refresh token 30 days
Future: OAuth (Google, Apple) planned
```

### Security Measures
- ✅ Row Level Security (RLS) on all tables
- ✅ HTTPS only (enforced)
- ✅ JWT token validation
- ✅ Input validation on all forms
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS protection in PDF generation
- ⚠️ CORS headers (needs review)
- ❌ Rate limiting (NOT YET IMPLEMENTED)

---

## 🛠️ DEVELOPMENT TOOLS

### IDEs & Editors
- Visual Studio Code (recommended)
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

### Command Line Tools
```bash
flutter --version  # Flutter 3.x
dart --version     # Dart 3.9.2
gcloud version     # Google Cloud SDK
supabase --version # Supabase CLI
```

### Version Control
```
Platform: GitHub
Repository: lightmyfireadmin/plombipro-app
Branch Strategy:
  - main: Production-ready code
  - develop: Development branch
  - feature/*: Feature branches
  - claude/*: AI-assisted development branches
```

---

## 🚀 DEPLOYMENT TARGETS

### Mobile Apps
```
iOS:
  - Target: App Store (Apple)
  - Min Version: iOS 11.0
  - Build Tool: Xcode 14.3+
  - Provisioning: Apple Developer Program
  - Status: ⏳ Not yet submitted

Android:
  - Target: Google Play Store
  - Min SDK: API 21 (Android 5.0)
  - Target SDK: API 33 (Android 13)
  - Build Tool: Gradle 7.3+
  - Signing: Android Keystore
  - Status: ⏳ Not yet submitted
```

### Web App (PWA)
```
Hosting: ⚠️ TBD (Vercel? Firebase Hosting? Supabase?)
Domain: plombipro.app (to be configured)
PWA: Manifest + Service Worker
Status: ⏳ Not yet deployed
```

### Cloud Functions
```
Platform: Google Cloud Functions
Region: europe-west1
Trigger: HTTP (all functions)
Status: ✅ DEPLOYED (most functions)
```

---

## 💰 COST BREAKDOWN (Monthly Estimates)

### MVP Phase (Current - Low Usage)
| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Supabase | Free | €0 |
| Google Cloud Functions | Pay-per-use | €5-20 |
| Google Vision API | Pay-per-use | €10-30 |
| Resend | Free (3k emails) | €0 |
| Stripe | Transaction fees only | Variable |
| Domain & SSL | - | €10 |
| **TOTAL** | | **€25-60** |

### Production Phase (Higher Usage)
| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Supabase | Pro | €25 |
| Google Cloud Functions | Pay-per-use | €50-100 |
| Google Vision API | Pay-per-use | €50-100 |
| Resend | Pro ($20) | €19 |
| Stripe | Transaction fees | Variable |
| Domain & SSL | - | €10 |
| Monitoring & Logging | - | €20 |
| **TOTAL** | | **€174-274** |

**Note**: Stripe fees (1.5% + €0.25) are separate and vary with transaction volume.

---

## 📊 FEATURE IMPLEMENTATION STATUS

### ✅ Operational (Production-Ready)
- Quotes CRUD (Create, Read, Update, Delete)
- Invoices CRUD
- PDF generation (quotes & invoices)
- Client management
- Worksite tracking
- Product catalog (personal)
- Dashboard with statistics
- User authentication
- Company profile setup

### ⚠️ Partial / Beta (Code Exists, Needs Testing)
- OCR scanning (basic extraction only, not automated quote generation)
- Stripe payments (code ready, webhook not tested)
- Electronic invoicing (Factur-X code ready, not validated)
- Email notifications (function deployed, templates need review)
- Payment reminders (scheduler exists, needs production testing)

### ❌ Not Yet Implemented (Documented but Missing)
- Offline mode (Hive/local storage)
- Auto-scraped product catalogs (20K+ products from suppliers)
- Multi-user / team features
- Emergency pricing mode (+50%/+100%)
- Advanced analytics dashboard
- Accounting software integration (Pennylane, Indy)
- Mobile push notifications (FCM)

### 🗑️ Removed / Deprecated
- Supabase Edge Functions (switched to Google Cloud Functions)
- OCR.space API (switched to Google Vision API)

---

## 🔄 MIGRATION NOTES

### Changes from Original Documentation

| Original | Current | Reason |
|----------|---------|--------|
| OCR.space API | Google Vision API | Better accuracy, EU data residency |
| SendGrid? | Resend | Modern API, better DX (NEEDS VERIFICATION) |
| Supabase Edge Functions | Google Cloud Functions | More mature ecosystem |
| flutter_stripe | flutter_stripe ^12.1.0 | Updated package name |

---

## 🚨 KNOWN ISSUES & LIMITATIONS

### Critical Issues
1. ⚠️ **Email Service Confusion**: Documentation inconsistent (SendGrid vs Resend)
2. ⚠️ **Missing Services**: ocr_service.dart and email_service.dart documented but not implemented
3. ⚠️ **Scraper Status Unknown**: Point.P and Cedeo scrapers listed but status unclear
4. ⚠️ **No Rate Limiting**: APIs vulnerable to abuse
5. ⚠️ **No Monitoring**: No error tracking or performance monitoring

### Medium Priority
1. ⏳ State management pattern not documented
2. ⏳ CI/CD pipeline not set up
3. ⏳ Web hosting not configured
4. ⏳ Testing strategy not defined

### Low Priority
1. 🔹 Version numbers drift between docs and pubspec.yaml
2. 🔹 Some FlutterFlow prompts reference non-existent features
3. 🔹 Cost estimates need quarterly review

---

## 📝 DOCUMENTATION REFERENCES

### Primary Documents
1. `README.md` - Project overview
2. `TECH_STACK.md` - This file (authoritative)
3. `KNOWLEDGE_BASE_REVIEW.md` - Documentation audit
4. `WEBSITE_CONTENT_AUDIT_SUMMARY.md` - Marketing vs reality check

### Technical Guides (plombipro_part*.md)
1. Part 1: UI Layouts & Components
2. Part 2: Cloud Functions & Backend
3. Part 3: Flutter Services & Models
4. Part 4: Deployment & FlutterFlow Prompts
5. Part 5: Summary & Checklists

**⚠️ WARNING**: Parts 2, 3, and 5 contain outdated information. See KNOWLEDGE_BASE_REVIEW.md for details.

---

## 🔄 MAINTENANCE & UPDATES

### Update Schedule
- **Weekly**: Review for version drift
- **Monthly**: Audit for accuracy
- **Quarterly**: Cost estimate review
- **After Major Changes**: Immediate update

### How to Update This File
1. Make changes to TECH_STACK.md first
2. Add update date and version bump
3. Update affected documentation files
4. Run consistency check
5. Commit with descriptive message

### Last Updated By
**Date**: November 5, 2025
**Author**: Claude Code Assistant
**Changes**: Initial creation, established as single source of truth

---

## ✅ VERIFIED INFORMATION

The following has been verified against actual project files:
- ✅ pubspec.yaml dependencies (Nov 5, 2025)
- ✅ Cloud function names in cloud_functions/ directory
- ✅ Service files in lib/services/
- ✅ Supabase configuration
- ✅ Flutter SDK version

**Not yet verified**:
- ⏳ Email service (SendGrid vs Resend)
- ⏳ Scraper function status
- ⏳ Production deployment status
- ⏳ Actual cost data

---

## 📞 QUESTIONS?

If you find errors or have questions:
1. Check KNOWLEDGE_BASE_REVIEW.md for known issues
2. Verify against actual project files
3. Update this document if you find discrepancies
4. Document your findings

**This is a living document. Keep it accurate!**

---

**End of Tech Stack Documentation**
**Version 1.0 - November 5, 2025**
