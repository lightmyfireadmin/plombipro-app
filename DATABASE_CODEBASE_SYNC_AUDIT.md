# DATABASE-CODEBASE SYNCHRONIZATION AUDIT REPORT

**Project:** PlombiPro Application
**Date:** 2025-11-12
**Auditor:** Claude Code Comprehensive Analysis
**Scope:** 8 Core Tables vs Flutter Models

---

## Executive Summary

**Overall Sync Status:** 62.5% (5/8 tables have issues)

| Metric | Count |
|--------|-------|
| Tables Audited | 8 |
| Critical Issues | 12 |
| Warnings | 15 |
| Info Items | 8 |
| Perfectly Synced Tables | 3 |

**Critical Finding:** Multiple schema mismatches exist between database and Flutter models, particularly in:
- Column naming inconsistencies (snake_case vs camelCase mapping errors)
- Missing columns in database (user_id references)
- Data type mismatches (especially in products and invoices)
- Nullability conflicts between DB and Dart models

---

## Detailed Findings

### 1. PROFILES Table
**Status:** ✅ SYNCED

**Database Columns:** 20
**Model Fields:** 20

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String | Required/Required | ✅ OK |
| email | email | text | String? | Nullable/Nullable | ✅ OK |
| first_name | firstName | text | String? | Nullable/Nullable | ✅ OK |
| last_name | lastName | text | String? | Nullable/Nullable | ✅ OK |
| company_name | companyName | text | String? | Nullable/Nullable | ✅ OK |
| siret | siret | text | String? | Nullable/Nullable | ✅ OK |
| phone | phone | text | String? | Nullable/Nullable | ✅ OK |
| address | address | text | String? | Nullable/Nullable | ✅ OK |
| postal_code | postalCode | text | String? | Nullable/Nullable | ✅ OK |
| city | city | text | String? | Nullable/Nullable | ✅ OK |
| country | country | text | String? | Nullable/Nullable | ✅ OK |
| tva_number | vatNumber | text | String? | Nullable/Nullable | ✅ OK |
| logo_url | logoUrl | text | String? | Nullable/Nullable | ✅ OK |
| iban | iban | text | String? | Nullable/Nullable | ✅ OK |
| bic | bic | text | String? | Nullable/Nullable | ✅ OK |
| subscription_plan | subscriptionPlan | text | String? | Nullable/Nullable | ✅ OK |
| subscription_status | subscriptionStatus | text | String? | Nullable/Nullable | ✅ OK |
| trial_end_date | trialEndDate | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| created_at | createdAt | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| updated_at | updatedAt | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| stripe_connect_id | stripeConnectId | text | String? | Nullable/Nullable | ✅ OK |

**Issues Found:**
None - Perfect synchronization

---

### 2. CLIENTS Table
**Status:** ⚠️ MINOR ISSUES

**Database Columns:** ~18
**Model Fields:** 22

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String? | Yes/Optional | ✅ OK |
| user_id | userId | uuid | String | NOT NULL/Required | ✅ OK |
| client_type | clientType | text | String | Default 'individual'/Default | ✅ OK |
| salutation | salutation | text | String? | Nullable/Nullable | ✅ OK |
| first_name | firstName | text | String? | Nullable/Nullable | ✅ OK |
| last_name | name* | text | String | Nullable/Required | ⚠️ WARNING |
| company_name | name* | text | String | Nullable/Required | ⚠️ WARNING |
| email | email | text | String? | Nullable/Nullable | ✅ OK |
| phone | phone | text | String? | Nullable/Nullable | ✅ OK |
| mobile_phone | mobilePhone | text | String? | Nullable/Nullable | ✅ OK |
| address | address | text | String? | Nullable/Nullable | ✅ OK |
| postal_code | postalCode | text | String? | Nullable/Nullable | ✅ OK |
| city | city | text | String? | Nullable/Nullable | ✅ OK |
| country | country | text | String? | Default 'France'/Default | ✅ OK |
| billing_address | billingAddress | text | String? | Nullable/Nullable | ✅ OK |
| siret | siret | text | String? | Nullable/Nullable | ✅ OK |
| vat_number | vatNumber | text | String? | Nullable/Nullable | ✅ OK |
| default_payment_terms | defaultPaymentTerms | integer | int? | Nullable/Nullable | ✅ OK |
| default_discount | defaultDiscount | decimal | double? | Nullable/Nullable | ✅ OK |
| tags | tags | text[] | List<String>? | Nullable/Nullable | ✅ OK |
| is_favorite | isFavorite | boolean | bool | Default false/Default false | ✅ OK |
| notes | notes | text | String? | Nullable/Nullable | ✅ OK |

**Issues Found:**

- ⚠️ **WARNING:** `name` field in Dart model maps to BOTH `company_name` AND `last_name` depending on client_type. This is handled in fromJson() but creates ambiguity
- ⚠️ **WARNING:** toJson() writes the same value to both company_name and last_name (line 53-54 in client.dart)
- ℹ️ **INFO:** Model has conditional logic for name field that could cause data inconsistency

**Recommendations:**
1. Consider separating company clients and individual clients into different models or use better field naming
2. Fix toJson() to conditionally write to company_name OR last_name based on client_type

---

### 3. PRODUCTS Table
**Status:** ❌ CRITICAL ISSUES

**Database Columns:** ~15
**Model Fields:** 13

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String? | Yes/Optional | ✅ OK |
| user_id | (MISSING) | uuid | N/A | NOT NULL/N/A | ❌ CRITICAL |
| ref | ref | text | String? | Nullable/Nullable | ✅ OK |
| reference | (duplicate) | text | N/A | Nullable/N/A | ⚠️ WARNING |
| name | name | text | String | NOT NULL/Required | ✅ OK |
| description | description | text | String? | Nullable/Nullable | ✅ OK |
| price_buy | priceBuy | decimal(10,2) | double? | Nullable/Nullable | ✅ OK |
| price_sell | unitPrice | decimal(10,2) | double | Nullable/Required | ⚠️ WARNING |
| purchase_price_ht | (duplicate?) | decimal(10,2) | N/A | Nullable/N/A | ⚠️ WARNING |
| selling_price_ht | (duplicate?) | decimal(10,2) | N/A | Nullable/N/A | ⚠️ WARNING |
| price | (computed?) | decimal(10,2) | N/A | N/A/N/A | ℹ️ INFO |
| unit | unit | text | String? | Default 'unité'/Default | ✅ OK |
| photo_url | photoUrl | text | String? | Nullable/Nullable | ✅ OK |
| category | category | text | String? | Nullable/Nullable | ✅ OK |
| supplier | supplier | text | String? | Nullable/Nullable | ✅ OK |
| supplier_name | (duplicate?) | text | N/A | Nullable/N/A | ⚠️ WARNING |
| is_favorite | isFavorite | boolean | bool | Default false/Default false | ✅ OK |
| usage_count | usageCount | integer | int | Default 0/Default 0 | ✅ OK |
| last_used | (MISSING) | timestamp | N/A | Nullable/N/A | ⚠️ WARNING |
| source | source | text | String? | Nullable/Nullable | ✅ OK |
| vat_rate | (MISSING) | decimal(5,2) | N/A | Default 20.0/N/A | ⚠️ WARNING |

**Issues Found:**

- ❌ **CRITICAL:** Model does NOT include `user_id` field, but DB requires it (NOT NULL constraint). This will cause INSERT failures from Flutter
- ❌ **CRITICAL:** Multiple duplicate columns exist (ref/reference, price_buy/purchase_price_ht, price_sell/selling_price_ht, supplier/supplier_name)
- ⚠️ **WARNING:** Migration 20251111_add_missing_product_columns.sql adds both `ref` and copies from `reference`, creating redundancy
- ⚠️ **WARNING:** DB has `price` as computed column (line 168 in ultimate_schema_fix.sql), but model uses unitPrice directly
- ⚠️ **WARNING:** price_sell in DB should match unitPrice but nullability differs (DB nullable, Dart required)
- ℹ️ **INFO:** Model has getter `sellingPriceHt` that returns unitPrice (line 17)

**Recommendations:**
1. **URGENT:** Add user_id field to Product model
2. **URGENT:** Standardize on ONE set of column names: use ref (not reference), price_buy/price_sell (not purchase_price_ht/selling_price_ht)
3. Drop duplicate columns from database or update migrations to only create one set
4. Add vat_rate field to Product model if needed
5. Add last_used field to Product model for usage tracking

---

### 4. QUOTES Table
**Status:** ⚠️ MINOR ISSUES

**Database Columns:** ~17
**Model Fields:** 16

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String? | Yes/Optional | ✅ OK |
| user_id | (MISSING) | uuid | N/A | NOT NULL/N/A | ❌ CRITICAL |
| quote_number | quoteNumber | text | String | NOT NULL/Required | ✅ OK |
| client_id | clientId | uuid | String | NOT NULL/Required | ✅ OK |
| quote_date | date | date | DateTime | Default CURRENT_DATE/Required | ⚠️ WARNING |
| expiry_date | expiryDate | date | DateTime? | Nullable/Nullable | ✅ OK |
| status | status | text | String | Default 'draft'/Default 'draft' | ✅ OK |
| total_ht | totalHt | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| subtotal_ht | totalHt | decimal(10,2) | double | Default 0/Default 0 | ⚠️ WARNING |
| total_tva | totalTva | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| total_vat | totalTva | decimal(10,2) | double | Default 0/Default 0 | ⚠️ WARNING |
| total_ttc | totalTtc | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| items | items | jsonb | List<LineItem> | Default '[]'/Default [] | ✅ OK |
| notes | notes | text | String? | Nullable/Nullable | ✅ OK |
| payment_terms | (MISSING) | integer | N/A | Nullable/N/A | ⚠️ WARNING |
| converted_to_invoice_id | (MISSING) | uuid | N/A | Nullable/N/A | ℹ️ INFO |

**Issues Found:**

- ❌ **CRITICAL:** Model does NOT include `user_id` field, but DB requires it (NOT NULL constraint)
- ⚠️ **WARNING:** Column name confusion: DB has both `total_ht` and `subtotal_ht`, model calls them both totalHt
- ⚠️ **WARNING:** Column name confusion: DB has both `total_tva` and `total_vat`, model maps both to totalTva
- ⚠️ **WARNING:** fromJson uses 'quote_date' but field is called 'date' in model (line 8, 38)
- ⚠️ **WARNING:** fromJson uses 'subtotal_ht' (line 41) but toJson uses different names
- ℹ️ **INFO:** DB tracks converted_to_invoice_id for quote-to-invoice conversion, model doesn't

**Recommendations:**
1. **URGENT:** Add user_id field to Quote model
2. Standardize column names: use subtotal_ht and total_vat consistently
3. Ensure fromJson() and toJson() use exact same column names
4. Consider adding converted_to_invoice_id to model for tracking

---

### 5. INVOICES Table
**Status:** ❌ CRITICAL ISSUES

**Database Columns:** ~25
**Model Fields:** 22

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String? | Yes/Optional | ✅ OK |
| user_id | (MISSING) | uuid | N/A | NOT NULL/N/A | ❌ CRITICAL |
| invoice_number | number | text | String | UNIQUE/Required | ✅ OK |
| client_id | clientId | uuid | String | NOT NULL/Required | ✅ OK |
| invoice_date | date | date | DateTime | Default CURRENT_DATE/Required | ✅ OK |
| due_date | dueDate | date | DateTime? | Nullable/Nullable | ✅ OK |
| status | status | text | String | Default 'draft'/Default 'draft' | ✅ OK |
| payment_status | paymentStatus | text | String | Default 'unpaid'/Default 'unpaid' | ✅ OK |
| subtotal_ht | totalHt | decimal(10,2) | double | Default 0/Default 0 | ⚠️ WARNING |
| total_ht | totalHt | decimal(10,2) | double | Default 0/Default 0 | ⚠️ WARNING |
| total_vat | totalTva | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| total_ttc | totalTtc | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| amount_paid | amountPaid | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| balance_due | balanceDue | decimal(10,2) | double | Default 0/Default 0 | ✅ OK |
| items | items | jsonb | List<LineItem> | Default '[]'/Default [] | ⚠️ WARNING |
| notes | notes | text | String? | Nullable/Nullable | ✅ OK |
| payment_method | paymentMethod | text | String? | Nullable/Nullable | ✅ OK |
| payment_terms | (MISSING) | integer | N/A | Default 30/N/A | ⚠️ WARNING |
| payment_date | (MISSING) | date | N/A | Nullable/N/A | ⚠️ WARNING |
| is_electronic | isElectronic | boolean | bool? | Nullable/Nullable | ✅ OK |
| xml_url | xmlUrl | text | String? | Nullable/Nullable | ✅ OK |
| pdf_url | (MISSING) | text | N/A | Nullable/N/A | ℹ️ INFO |
| legal_mentions | (MISSING) | text | N/A | Nullable/N/A | ℹ️ INFO |
| created_from_quote_id | (MISSING) | uuid | N/A | Nullable/N/A | ℹ️ INFO |

**Issues Found:**

- ❌ **CRITICAL:** Model does NOT include `user_id` field, but DB requires it (NOT NULL constraint)
- ⚠️ **WARNING:** Column naming inconsistency: DB has both `total_ht` and `subtotal_ht`, model uses totalHt for subtotal
- ⚠️ **WARNING:** Migration 20251111_add_missing_invoice_columns.sql renames total_ht to subtotal_ht (line 33-35), creating confusion
- ⚠️ **WARNING:** fromJson() expects 'subtotal_ht' (line 54) but DB might have 'total_ht'
- ⚠️ **WARNING:** Model stores items as List<LineItem> but DB stores as jsonb - no schema validation
- ⚠️ **WARNING:** toJson() missing 'status' field (line 70-86), only in copyWith
- ℹ️ **INFO:** DB has payment_terms, payment_date, pdf_url, legal_mentions, created_from_quote_id that model doesn't track

**Recommendations:**
1. **URGENT:** Add user_id field to Invoice model
2. **URGENT:** Standardize on subtotal_ht everywhere (drop total_ht column or vice versa)
3. Add 'status' field to toJson() method
4. Consider adding payment_terms, payment_date to model for better tracking
5. Ensure items jsonb structure is documented and validated

---

### 6. PAYMENTS Table
**Status:** ✅ SYNCED

**Database Columns:** 13
**Model Fields:** 12

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String | NOT NULL/Required | ✅ OK |
| user_id | userId | uuid | String | NOT NULL/Required | ✅ OK |
| invoice_id | invoiceId | uuid | String | NOT NULL/Required | ✅ OK |
| payment_date | paymentDate | date | DateTime | Default CURRENT_DATE/Required | ✅ OK |
| amount | amount | decimal(10,2) | double | NOT NULL/Required | ✅ OK |
| payment_method | paymentMethod | text | String? | Nullable/Nullable | ✅ OK |
| transaction_reference | transactionReference | text | String? | Nullable/Nullable | ✅ OK |
| stripe_payment_id | stripePaymentId | text | String? | Nullable/Nullable | ✅ OK |
| notes | notes | text | String? | Nullable/Nullable | ✅ OK |
| receipt_url | receiptUrl | text | String? | Nullable/Nullable | ✅ OK |
| is_reconciled | isReconciled | boolean | bool | Default false/Default false | ✅ OK |
| created_at | createdAt | timestamp | DateTime | Default NOW()/Required | ✅ OK |

**Issues Found:**
None - Perfect synchronization

**Notes:**
- Uses json_annotation with @JsonSerializable() for automatic serialization
- All fields properly mapped
- Constraints match between DB and Dart

---

### 7. JOB_SITES Table
**Status:** ⚠️ MINOR ISSUES

**Database Columns:** ~24
**Model Fields:** 24

**Column Mapping:**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String | NOT NULL/Required | ✅ OK |
| user_id | userId | uuid | String | NOT NULL/Required | ✅ OK |
| client_id | clientId | uuid | String | NOT NULL/Required | ✅ OK |
| job_name | jobName | text | String | NOT NULL/Required | ✅ OK |
| reference_number | referenceNumber | text | String? | Nullable/Nullable | ✅ OK |
| address | address | text | String? | Nullable/Nullable | ✅ OK |
| city | city | text | String? | Nullable/Nullable | ✅ OK |
| postal_code | postalCode | text | String? | Nullable/Nullable | ✅ OK |
| contact_person | contactPerson | text | String? | Nullable/Nullable | ✅ OK |
| contact_phone | contactPhone | text | String? | Nullable/Nullable | ✅ OK |
| description | description | text | String? | Nullable/Nullable | ✅ OK |
| start_date | startDate | date | DateTime? | Nullable/Nullable | ✅ OK |
| estimated_end_date | estimatedEndDate | date | DateTime? | Nullable/Nullable | ✅ OK |
| actual_end_date | actualEndDate | date | DateTime? | Nullable/Nullable | ✅ OK |
| status | status | text | String? | Nullable/Nullable | ✅ OK |
| progress_percentage | progressPercentage | integer | int | Default 0/Default 0 | ✅ OK |
| related_quote_id | relatedQuoteId | uuid | String? | Nullable/Nullable | ✅ OK |
| estimated_budget | estimatedBudget | decimal(10,2) | double? | Nullable/Nullable | ✅ OK |
| actual_cost | actualCost | decimal(10,2) | double? | Nullable/Nullable | ✅ OK |
| profit_margin | profitMargin | decimal(10,2) | double? | Nullable/Nullable | ✅ OK |
| notes | notes | text | String? | Nullable/Nullable | ✅ OK |
| created_at | createdAt | timestamp | DateTime | Default NOW()/Required | ✅ OK |
| updated_at | updatedAt | timestamp | DateTime? | Nullable/Nullable | ✅ OK |

**Issues Found:**

- ℹ️ **INFO:** Uses json_annotation with @JsonSerializable() - good practice
- ℹ️ **INFO:** All fields properly mapped with @JsonKey annotations
- ℹ️ **INFO:** Has comprehensive copyWith() method

**Recommendations:**
- None - this is a well-implemented model with proper synchronization

---

### 8. APPOINTMENTS Table
**Status:** ❌ CRITICAL ISSUES

**Database Columns:** 39 (including related tables)
**Model Fields:** 38

**Column Mapping (Main Appointment Fields):**

| DB Column | Dart Field | DB Type | Dart Type | Nullable Match | Status |
|-----------|------------|---------|-----------|----------------|---------|
| id | id | uuid | String | NOT NULL/Required | ✅ OK |
| user_id | userId | uuid | String | NOT NULL/Required | ✅ OK |
| client_id | clientId | uuid | String? | Nullable/Nullable | ✅ OK |
| job_site_id | jobSiteId | uuid | String? | Nullable/Nullable | ✅ OK |
| title | title | text | String | NOT NULL/Required | ✅ OK |
| description | description | text | String? | Nullable/Nullable | ✅ OK |
| appointment_date | appointmentDate | date | DateTime | NOT NULL/Required | ✅ OK |
| appointment_time | appointmentTime | time | String | NOT NULL/Required | ⚠️ WARNING |
| estimated_duration_minutes | estimatedDurationMinutes | integer | int | Default 60/Default 60 | ✅ OK |
| actual_start_time | actualStartTime | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| actual_end_time | actualEndTime | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| address_line1 | addressLine1 | text | String | NOT NULL/Required | ✅ OK |
| address_line2 | addressLine2 | text | String? | Nullable/Nullable | ✅ OK |
| postal_code | postalCode | text | String | NOT NULL/Required | ✅ OK |
| city | city | text | String | NOT NULL/Required | ✅ OK |
| country | country | text | String | Default 'FR'/Default 'FR' | ✅ OK |
| latitude | latitude | double | double? | Nullable/Nullable | ✅ OK |
| longitude | longitude | double | double? | Nullable/Nullable | ✅ OK |
| planned_eta | plannedEta | timestamp | DateTime | NOT NULL/Required | ✅ OK |
| current_eta | currentEta | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| last_eta_update | lastEtaUpdate | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| eta_update_interval_minutes | etaUpdateIntervalMinutes | integer | int | Default 15/Default 15 | ✅ OK |
| daily_sequence | dailySequence | integer | int? | Nullable/Nullable | ✅ OK |
| route_distance_meters | routeDistanceMeters | integer | int? | Nullable/Nullable | ✅ OK |
| route_duration_minutes | routeDurationMinutes | integer | int? | Nullable/Nullable | ✅ OK |
| status | status | text | AppointmentStatus | NOT NULL/Required | ✅ OK |
| sms_notifications_enabled | smsNotificationsEnabled | boolean | bool | Default true/Default true | ✅ OK |
| last_sms_sent_at | lastSmsSentAt | timestamp | DateTime? | Nullable/Nullable | ✅ OK |
| sms_count | smsCount | integer | int | Default 0/Default 0 | ✅ OK |
| internal_notes | internalNotes | text | String? | Nullable/Nullable | ✅ OK |
| customer_notes | customerNotes | text | String? | Nullable/Nullable | ✅ OK |
| created_at | createdAt | timestamp | DateTime | Default NOW()/Required | ✅ OK |
| updated_at | updatedAt | timestamp | DateTime | Default NOW()/Required | ✅ OK |

**Migration Conflicts:**

| Migration File | Column Name | Type |
|----------------|-------------|------|
| 20251109_create_appointments_table.sql | start_time | timestamp with time zone |
| 20251111_ultimate_schema_fix.sql | Renamed scheduled_date to start_time | timestamp with time zone |
| Appointment.dart Model | appointmentDate + appointmentTime | date + time (string) |

**Issues Found:**

- ❌ **CRITICAL:** MAJOR SCHEMA MISMATCH - Migration 20251109 creates simple appointments table with start_time/end_time
- ❌ **CRITICAL:** Dart model expects MUCH MORE complex schema with 38 fields including ETA tracking, SMS, route optimization
- ❌ **CRITICAL:** Model expects separate appointment_date (DATE) and appointment_time (TIME), but DB migration has combined start_time (TIMESTAMP)
- ❌ **CRITICAL:** Model has extensive ETA and SMS features (lines 45-72) that don't exist in DB migration
- ⚠️ **WARNING:** Migration creates 'location' TEXT field (line 14), but model has address_line1, address_line2, postal_code, city, country
- ⚠️ **WARNING:** Migration creates 'duration_minutes' (line 19), model uses 'estimated_duration_minutes'
- ⚠️ **WARNING:** Status enum values differ: Migration allows 'in_progress', model uses 'inProgress' (camelCase)

**Related Tables (Model has, DB unknown):**
- DailyRoute table (lines 294-412)
- AppointmentEtaHistory table (lines 426-457)
- AppointmentSmsLog table (lines 473-513)

**Recommendations:**
1. **URGENT:** Run comprehensive migration to add ALL appointment fields from model
2. **URGENT:** Create daily_routes, appointment_eta_history, appointment_sms_log tables
3. **URGENT:** Migrate from start_time (timestamp) to appointment_date (date) + appointment_time (time)
4. **URGENT:** Add all ETA tracking fields (planned_eta, current_eta, etc.)
5. **URGENT:** Add all SMS notification fields
6. **URGENT:** Add route optimization fields
7. Align status enum values (use snake_case in DB, camelCase in Dart with @JsonValue)

---

## Summary of Issues

### Critical Issues (Must Fix Immediately):

1. **Products Table:** Missing user_id field in Product model - will cause INSERT failures
2. **Products Table:** Duplicate columns (ref/reference, price_buy/purchase_price_ht, price_sell/selling_price_ht)
3. **Quotes Table:** Missing user_id field in Quote model - will cause INSERT failures
4. **Invoices Table:** Missing user_id field in Invoice model - will cause INSERT failures
5. **Invoices Table:** Confusion between total_ht and subtotal_ht column names
6. **Appointments Table:** MASSIVE schema mismatch - simple DB vs complex model with 38+ fields
7. **Appointments Table:** Missing ETA tracking infrastructure (planned_eta, current_eta, etc.)
8. **Appointments Table:** Missing SMS notification infrastructure
9. **Appointments Table:** Missing route optimization fields
10. **Appointments Table:** Missing related tables: daily_routes, appointment_eta_history, appointment_sms_log
11. **Appointments Table:** Schema conflict - start_time (timestamp) vs appointment_date (date) + appointment_time (time)
12. **Appointments Table:** Address field mismatch - location (text) vs structured address fields

### Warnings (Should Fix Soon):

1. **Clients Table:** Ambiguous name field mapping to both company_name and last_name
2. **Clients Table:** toJson() writes same value to both company_name and last_name
3. **Products Table:** price_sell nullability mismatch (DB nullable, Dart required)
4. **Products Table:** Multiple pricing column duplicates need cleanup
5. **Quotes Table:** Column name confusion: total_ht vs subtotal_ht, total_tva vs total_vat
6. **Quotes Table:** fromJson/toJson column name inconsistencies
7. **Invoices Table:** subtotal_ht vs total_ht naming inconsistency
8. **Invoices Table:** Missing 'status' in toJson() method
9. **Invoices Table:** JSONB items structure not validated
10. **Appointments Table:** Status enum value format (in_progress vs inProgress)
11. **Appointments Table:** Duration field naming (duration_minutes vs estimated_duration_minutes)
12. **Appointments Table:** Location structure mismatch

### Info Items (Nice to Have):

1. **Products Table:** Consider adding vat_rate field to model
2. **Products Table:** Consider adding last_used field to model
3. **Quotes Table:** Consider adding converted_to_invoice_id to model
4. **Invoices Table:** Consider adding payment_terms, payment_date, pdf_url fields
5. **Invoices Table:** Consider adding legal_mentions, created_from_quote_id fields
6. **All Models:** Document JSONB field structures for items arrays
7. **Job Sites:** Well-implemented model - use as template for others
8. **Payments:** Well-implemented model - use as template for others

---

## Recommendations

### Immediate Actions (Before Next Deploy):

1. **Create Emergency Migration File:** `20251112_fix_critical_user_id_fields.sql`
   - Purpose: Ensure all core tables that need user_id have the column
   - Add user_id handling to Product, Quote, Invoice models

2. **Create Appointments Schema Migration:** `20251112_appointments_complete_schema.sql`
   - Add all 35+ missing fields from Appointment model
   - Create daily_routes table
   - Create appointment_eta_history table
   - Create appointment_sms_log table
   - Migrate data from start_time to appointment_date + appointment_time

3. **Column Name Standardization Migration:** `20251112_standardize_column_names.sql`
   - Drop duplicate columns: reference (keep ref), purchase_price_ht (keep price_buy), etc.
   - Standardize on subtotal_ht (not total_ht)
   - Standardize on total_vat (not total_tva)

### Short-term Actions (This Sprint):

1. **Update Flutter Models:**
   - Add user_id to Product model
   - Add user_id to Quote model
   - Add user_id to Invoice model
   - Fix Client model toJson() to conditionally write company_name OR last_name
   - Add 'status' to Invoice toJson()
   - Fix all fromJson/toJson column name mismatches

2. **Add Field Validation:**
   - Create Dart validators for JSONB fields (items arrays)
   - Add schema validation for quote_items, invoice_items structures
   - Ensure enum values match between DB and Dart (@JsonValue annotations)

3. **Documentation:**
   - Document JSONB field structures
   - Create data dictionary mapping DB columns to Dart fields
   - Add comments to models explaining any naming differences

### Medium-term Actions (Next Sprint):

1. **Refactor Client Model:**
   - Consider creating CompanyClient and IndividualClient subclasses
   - Or use better field naming (displayName that maps correctly)

2. **Add Missing Model Fields:**
   - vat_rate to Product
   - last_used to Product
   - payment_terms to Invoice
   - payment_date to Invoice
   - converted_to_invoice_id to Quote

3. **Create Database Views:**
   - Create views that handle column name mapping
   - Could simplify Flutter code if view handles snake_case to camelCase

4. **Add Integration Tests:**
   - Test inserting data from Flutter models
   - Verify all fields persist correctly
   - Test null handling matches expectations

### Long-term Actions (Future Releases):

1. **Schema Migration Strategy:**
   - Implement proper migration versioning
   - Add migration rollback capability
   - Create schema validation tests

2. **Type Safety:**
   - Consider using TypeScript for database schema definitions
   - Generate Dart models from schema (or vice versa)
   - Use tools like supabase_flutter code generation

3. **Performance:**
   - Review all indexes mentioned in migrations
   - Ensure foreign keys have indexes
   - Add indexes for commonly queried fields

---

## Migration Priority Matrix

| Priority | Migration | Risk | Effort | Impact |
|----------|-----------|------|--------|--------|
| P0 | Add user_id to products, quotes, invoices | HIGH | Low | HIGH |
| P0 | Complete appointments schema | HIGH | High | HIGH |
| P1 | Standardize column names | MEDIUM | Medium | HIGH |
| P1 | Remove duplicate columns | MEDIUM | Low | MEDIUM |
| P2 | Add missing model fields | LOW | Medium | MEDIUM |
| P3 | Refactor client model | LOW | High | LOW |

---

## Testing Checklist

Before considering schema synchronized:

- [ ] Insert Profile from Flutter - verify all fields persist
- [ ] Insert Client (individual) from Flutter - verify all fields
- [ ] Insert Client (company) from Flutter - verify all fields
- [ ] Insert Product from Flutter - verify user_id persists
- [ ] Insert Quote from Flutter - verify user_id and totals persist
- [ ] Insert Invoice from Flutter - verify user_id and all fields persist
- [ ] Insert Payment from Flutter - verify all fields persist
- [ ] Insert JobSite from Flutter - verify all fields persist
- [ ] Insert Appointment from Flutter - verify all 38+ fields persist
- [ ] Query all tables and verify fromJson() works
- [ ] Test null handling for optional fields
- [ ] Verify enum values serialize correctly
- [ ] Test JSONB fields (items arrays) serialize correctly
- [ ] Verify foreign key constraints work
- [ ] Test cascade deletes work as expected

---

## Conclusion

The database schema and Flutter models have **significant synchronization issues** that will cause runtime failures, particularly:

1. **Missing user_id fields** in 3 critical models (Product, Quote, Invoice)
2. **Massive appointments schema gap** - model has 38 fields, DB has ~10
3. **Column naming inconsistencies** causing fromJson/toJson failures
4. **Duplicate columns** creating confusion and potential data corruption

**Estimated Time to Full Synchronization:**
- Critical fixes: 4-8 hours
- Complete synchronization: 16-24 hours
- Testing and validation: 8-16 hours
- **Total: 28-48 hours of focused work**

**Recommendation:** Stop feature development and fix these critical issues immediately. Current codebase will fail in production on INSERT operations for products, quotes, and invoices.

---

**Audit Completed:** 2025-11-12
**Report Generated By:** Claude Code Comprehensive Analysis
**Next Review Date:** After critical migrations are applied
