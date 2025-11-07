# PlombiPro - Complete API Endpoints Documentation

**Date:** 2025-11-06
**App Version:** Production-ready
**Last Updated:** main branch

This document lists ALL APIs, external services, and endpoints used throughout the PlombiPro application, including the mobile app, cloud functions, and integrations.

---

## Table of Contents

1. [Supabase APIs](#1-supabase-apis)
2. [Stripe Payment APIs](#2-stripe-payment-apis)
3. [Google Cloud APIs](#3-google-cloud-apis)
4. [Government APIs (Chorus Pro)](#4-government-apis-chorus-pro)
5. [Supplier Catalog APIs](#5-supplier-catalog-apis)
6. [Cloud Functions (HTTP Endpoints)](#6-cloud-functions-http-endpoints)
7. [Supabase Edge Functions](#7-supabase-edge-functions)
8. [Storage APIs](#8-storage-apis)

---

## 1. Supabase APIs

### 1.1 Authentication API
**Base URL:** `{SUPABASE_URL}/auth/v1`

| Endpoint | Method | Purpose | Calling Location |
|----------|--------|---------|------------------|
| `/signup` | POST | User registration | `lib/services/supabase_service.dart:signUp()` |
| `/token?grant_type=password` | POST | User login | `lib/services/supabase_service.dart:signIn()` |
| `/logout` | POST | User logout | `lib/services/supabase_service.dart:signOut()` |
| `/recover` | POST | Password recovery | `lib/screens/auth/forgot_password_page.dart` |
| `/user` | GET | Get current user | Used by Supabase client automatically |

### 1.2 Database REST API (PostgREST)
**Base URL:** `{SUPABASE_URL}/rest/v1`

All database operations use the Supabase client which calls these endpoints:

| Table/Resource | Operations | Calling Service |
|----------------|------------|-----------------|
| `profiles` | SELECT, INSERT, UPDATE | `lib/services/supabase_service.dart` |
| `clients` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:fetchClients(), createClient(), updateClient(), deleteClient()` |
| `products` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:fetchProducts(), createProduct(), updateProduct(), deleteProduct()` |
| `quotes` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:fetchQuotes(), createQuote(), updateQuote(), deleteQuote()` |
| `invoices` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:fetchInvoices(), createInvoice(), updateInvoice(), deleteInvoice()` |
| `payments` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:recordPayment(), getPayments(), updatePayment(), deletePayment()` |
| `scans` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addScan(), getScanHistory(), updateScan(), deleteScan()` |
| `templates` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:saveTemplate(), getTemplates(), updateTemplate(), deleteTemplate()` |
| `purchases` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addPurchase(), getPurchases(), updatePurchase(), deletePurchase()` |
| `job_sites` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addJobSite(), getJobSites(), updateJobSite(), deleteJobSite()` |
| `job_site_photos` | SELECT, INSERT, DELETE | `lib/services/supabase_service.dart:addJobSitePhoto(), getJobSitePhotosForJobSite(), deleteJobSitePhoto()` |
| `job_site_tasks` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addTaskToJobSite(), getTasksForJobSite(), updateJobSiteTask(), deleteJobSiteTask()` |
| `job_site_time_logs` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addTimeLogToJobSite(), getTimeLogsForJobSite(), updateJobSiteTimeLog(), deleteJobSiteTimeLog()` |
| `job_site_notes` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addNoteToJobSite(), getNotesForJobSite(), updateJobSiteNote(), deleteJobSiteNote()` |
| `job_site_documents` | SELECT, INSERT, UPDATE, DELETE | Used in job site detail pages |
| `categories` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addCategory(), getCategories(), updateCategory(), deleteCategory()` |
| `notifications` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:addNotification(), getNotifications(), markNotificationAsRead(), deleteNotification()` |
| `settings` | SELECT, INSERT, UPDATE | `lib/services/supabase_service.dart:getUserSettings(), updateUserSettings(), createUserSettings()` |
| `stripe_subscriptions` | SELECT, INSERT, UPDATE, DELETE | `lib/services/supabase_service.dart:createStripeSubscription(), getStripeSubscription(), updateStripeSubscription(), deleteStripeSubscription()` |

### 1.3 Realtime API
**Base URL:** `{SUPABASE_URL}/realtime/v1`

| Subscription | Purpose | Calling Location |
|--------------|---------|------------------|
| `quotes` stream | Real-time quote updates | `lib/services/supabase_service.dart:streamQuotes()` |

---

## 2. Stripe Payment APIs

### 2.1 Stripe SDK
**Calling Service:** `lib/services/stripe_service.dart`

| API Call | Purpose | Method |
|----------|---------|--------|
| `Stripe.instance.initPaymentSheet()` | Initialize payment sheet | `processPayment()` |
| `Stripe.instance.presentPaymentSheet()` | Show payment UI | `processPayment()` |

### 2.2 Stripe API (via Supabase Edge Functions)
**Base URL:** `https://api.stripe.com/v1`

These are called from Supabase Edge Functions:

| Endpoint | Purpose | Supabase Function |
|----------|---------|-------------------|
| `/payment_intents` | Create payment intent | `create-payment-intent` |
| `/refunds` | Process refund | `refund-payment` |
| `/webhooks` | Handle webhook events | Cloud function: `stripe_webhook_handler` |

**Calling from App:**
- `lib/services/stripe_service.dart:processPayment()` → Calls Supabase function `create-payment-intent`
- `lib/services/stripe_service.dart:refundPayment()` → Calls Supabase function `refund-payment`

---

## 3. Google Cloud APIs

### 3.1 Cloud Vision API
**Base URL:** `https://vision.googleapis.com/v1`

| Endpoint | Purpose | Calling Location |
|----------|---------|------------------|
| `/images:annotate` | OCR text extraction from invoices | `cloud_functions/ocr_processor/main.py:process_ocr()` |

**Authentication:** Service account key or ADC (Application Default Credentials)

### 3.2 Cloud Functions API
**Base URL:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net`

| Function Name | HTTP Method | Purpose |
|---------------|-------------|---------|
| `invoice_generator` | POST | Generate PDF invoices |
| `ocr_processor` | POST | Process scanned invoices with OCR |
| `facturx_generator` | POST | Generate Factur-X XML for e-invoicing |
| `chorus_pro_submitter` | POST | Submit invoices to Chorus Pro |
| `send_email` | POST | Send emails to clients |
| `stripe_webhook_handler` | POST | Handle Stripe webhook events |
| `scrape_point_p` | POST | Scrape Point P catalog |
| `scrape_cedeo` | POST | Scrape Cedeo catalog |
| `payment_reminder_scheduler` | Scheduled | Send payment reminders |
| `quote_expiry_checker` | Scheduled | Check for expiring quotes |

**Calling Locations:**
- `lib/services/pdf_generator.dart` → Calls `invoice_generator`
- `lib/services/chorus_pro_service.dart` → Calls `chorus_pro_submitter`
- `lib/screens/ocr/scan_invoice_page.dart` → Calls `ocr_processor`

---

## 4. Government APIs (Chorus Pro)

### 4.1 Chorus Pro Test Environment
**Base URL:** `https://sandbox.chorus-pro.gouv.fr`

| Endpoint | Method | Purpose | Calling Location |
|----------|--------|---------|------------------|
| `/oauth/token` | POST | OAuth authentication | `cloud_functions/chorus_pro_submitter/main.py:authenticate()` |
| `/api/v1/factures/deposer` | POST | Submit invoice | `cloud_functions/chorus_pro_submitter/main.py:submit_invoice()` |
| `/api/v1/factures/{id}/statut` | GET | Check invoice status | `cloud_functions/chorus_pro_submitter/main.py:check_status()` |
| `/api/v1/factures/{id}` | GET | Get invoice details | `cloud_functions/chorus_pro_submitter/main.py:get_invoice_details()` |

### 4.2 Chorus Pro Production Environment
**Base URL:** `https://chorus-pro.gouv.fr`

Same endpoints as test environment, used when `test_mode=false`

**Calling from App:**
- `lib/services/chorus_pro_service.dart:submitInvoice()` → Calls cloud function which calls Chorus Pro API
- `lib/services/chorus_pro_service.dart:checkStatus()` → Calls cloud function which calls Chorus Pro API

---

## 5. Supplier Catalog APIs

### 5.1 Point P
**Base URL:** `https://www.pointp.fr`

| Endpoint Pattern | Method | Purpose | Calling Location |
|------------------|--------|---------|------------------|
| `/plomberie` | GET | Scrape plumbing products | `cloud_functions/scraper_point_p/main.py` |
| `/sanitaire` | GET | Scrape sanitary products | `cloud_functions/scraper_point_p/main.py` |
| `/chauffage` | GET | Scrape heating products | `cloud_functions/scraper_point_p/main.py` |

**Calling Method:** Web scraping (BeautifulSoup)
**Frequency:** Scheduled via Cloud Scheduler

### 5.2 Cedeo
**Base URL:** `https://www.cedeo.fr`

| Endpoint Pattern | Method | Purpose | Calling Location |
|------------------|--------|---------|------------------|
| `/plomberie` | GET | Scrape plumbing products | `cloud_functions/scraper_cedeo/main.py` |
| `/sanitaire` | GET | Scrape sanitary products | `cloud_functions/scraper_cedeo/main.py` |
| `/chauffage` | GET | Scrape heating products | `cloud_functions/scraper_cedeo/main.py` |

**Calling Method:** Web scraping (BeautifulSoup)
**Frequency:** Scheduled via Cloud Scheduler

---

## 6. Cloud Functions (HTTP Endpoints)

All cloud functions are deployed to Google Cloud Functions.

### 6.1 Invoice Generator
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/invoice_generator`

**Request:**
```json
{
  "invoice_id": "uuid",
  "company_info": {...},
  "client_info": {...},
  "line_items": [...],
  "totals": {...}
}
```

**Response:**
```json
{
  "success": true,
  "invoice_url": "https://storage.googleapis.com/..."
}
```

**Calling Location:** `lib/services/pdf_generator.dart`

### 6.2 OCR Processor
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/ocr_processor`

**Request:**
```json
{
  "image_url": "https://...",
  "scan_id": "uuid"
}
```

**Response:**
```json
{
  "success": true,
  "extracted_data": {
    "invoice_number": "...",
    "date": "...",
    "total_amount": 123.45,
    "supplier_name": "...",
    "line_items": [...]
  }
}
```

**Calling Location:** `lib/screens/ocr/scan_invoice_page.dart`

### 6.3 Factur-X Generator
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/facturx_generator`

**Request:**
```json
{
  "invoice_id": "uuid",
  "invoice_data": {...},
  "seller_info": {...},
  "buyer_info": {...}
}
```

**Response:**
```json
{
  "success": true,
  "xml_url": "https://storage.googleapis.com/..."
}
```

**Calling Location:** `lib/services/facturx_service.dart`

### 6.4 Chorus Pro Submitter
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/chorus_pro_submitter`

**Request:**
```json
{
  "invoice_id": "uuid",
  "action": "submit|check_status|get_details",
  "test_mode": true
}
```

**Response:**
```json
{
  "success": true,
  "chorus_invoice_id": "...",
  "status": "DEPOSE"
}
```

**Calling Location:** `lib/services/chorus_pro_service.dart`

### 6.5 Send Email
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/send_email`

**Request:**
```json
{
  "to": "client@example.com",
  "subject": "...",
  "body": "...",
  "attachments": [...]
}
```

**Calling Location:** `lib/services/email_service.dart`

### 6.6 Stripe Webhook Handler
**Endpoint:** `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/stripe_webhook_handler`

**Request:** Stripe webhook payload

**Purpose:** Handle payment success, subscription updates, etc.

### 6.7 Payment Reminder Scheduler
**Trigger:** Cloud Scheduler (daily at 9:00 AM)

**Purpose:** Send automatic payment reminders for overdue invoices

### 6.8 Quote Expiry Checker
**Trigger:** Cloud Scheduler (daily at 8:00 AM)

**Purpose:** Check for expiring quotes and notify users

### 6.9 Scraper Functions
**Endpoints:**
- `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/scrape_point_p`
- `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/scrape_cedeo`

**Trigger:** Cloud Scheduler or HTTP request

**Purpose:** Scrape supplier catalogs and update product database

---

## 7. Supabase Edge Functions

**Base URL:** `{SUPABASE_URL}/functions/v1`

| Function Name | Purpose | Calling Location |
|---------------|---------|------------------|
| `create-payment-intent` | Create Stripe payment intent | `lib/services/stripe_service.dart:processPayment()` |
| `refund-payment` | Process Stripe refund | `lib/services/stripe_service.dart:refundPayment()` |

**Authentication:** JWT token from `auth.currentUser`

---

## 8. Storage APIs

### 8.1 Supabase Storage API
**Base URL:** `{SUPABASE_URL}/storage/v1`

| Bucket | Operations | Calling Locations |
|--------|------------|-------------------|
| `avatars` | Upload, Download, Delete | `lib/screens/profile/user_profile_page.dart` |
| `logos` | Upload, Download, Delete | `lib/screens/company/company_profile_page.dart` |
| `documents` | Upload, Download, Delete | PDF generation, invoice/quote storage |
| `signatures` | Upload, Download, Delete | Quote signing functionality |
| `worksite_photos` | Upload, Download, Delete | `lib/screens/job_sites/job_site_detail_page.dart` |
| `scans` | Upload, Download, Delete | `lib/screens/ocr/scan_invoice_page.dart` |

**API Endpoints:**
- `/object/{bucket}/{path}` - Upload/Download files
- `/object/list/{bucket}` - List files in bucket
- `/object/move` - Move/rename files
- `/object/public/{bucket}/{path}` - Public file access (avatars, logos)

---

## Environment Variables Required

### App (Flutter)
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

### Cloud Functions
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=service_role_key
GOOGLE_CLOUD_PROJECT=your-project-id
STRIPE_SECRET_KEY=sk_test_xxx
CHORUS_PRO_CLIENT_ID=xxx
CHORUS_PRO_CLIENT_SECRET=xxx
SENDGRID_API_KEY=xxx (if using SendGrid for emails)
```

---

## API Rate Limits and Quotas

### Supabase
- **Database:** Based on plan (unlimited for paid plans)
- **Storage:** Based on plan
- **Edge Functions:** 500,000 invocations/month (free tier)

### Stripe
- **Test Mode:** No rate limits
- **Production:** 100 requests/second

### Google Cloud Vision API
- **Free Tier:** 1,000 units/month
- **Paid:** Pay per request

### Chorus Pro
- **Rate Limit:** Not officially documented, but recommended to throttle requests
- **Authentication:** OAuth token expires after 1 hour

### Supplier Websites (Point P, Cedeo)
- **Rate Limit:** Respectful scraping (delays between requests)
- **Robots.txt:** Must be honored
- **User-Agent:** Must be set appropriately

---

## Security Considerations

1. **API Keys:** Never commit API keys to version control
2. **Supabase RLS:** All database access is protected by Row Level Security
3. **Authentication:** All API calls require valid JWT tokens
4. **HTTPS:** All endpoints use HTTPS encryption
5. **Webhook Signatures:** Stripe webhooks are verified using signatures
6. **CORS:** Cloud Functions have CORS configured for app domain only

---

## Testing Endpoints

For development, most cloud functions can be tested locally:

```bash
# Test invoice generator
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"invoice_id": "test-123", ...}'

# Test OCR processor
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://...", "scan_id": "test-456"}'
```

---

## Monitoring and Logging

- **Supabase:** Dashboard > Logs
- **Google Cloud Functions:** Cloud Console > Logging
- **Stripe:** Dashboard > Developers > Events
- **Chorus Pro:** API returns detailed error messages

---

## Support and Documentation Links

- **Supabase:** https://supabase.com/docs
- **Stripe:** https://stripe.com/docs
- **Google Cloud Vision:** https://cloud.google.com/vision/docs
- **Chorus Pro:** https://chorus-pro.gouv.fr/documentation
- **Factur-X:** https://www.en16931-3-reader.de/

---

**End of API Documentation**
