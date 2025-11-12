# 🚀 PlombiPro Deployment & Testing Guide

**Last Updated:** November 11, 2025
**Status:** ✅ Ready for Testing

---

## 📋 Quick Start Checklist

- [x] **Build Errors Fixed** - App compiles successfully (75.6MB APK)
- [x] **Models Synchronized** - JobSite + Profile models updated
- [x] **Seed Data Created** - Comprehensive test data ready
- [ ] **Seed Data Loaded** - Execute in Supabase (YOU DO THIS)
- [ ] **Schema Verified** - Run sync checker (YOU DO THIS)
- [ ] **App Tested** - Login and verify features (YOU DO THIS)

---

## 🎯 What Was Fixed

### 1. JobSite Model ✅
**File:** `lib/models/job_site.dart`

**Added Fields:**
```dart
final String? city;           // Line 13
final String? postalCode;     // Line 14
```

**Issue:** Flutter code referenced these fields but they were missing from the model.
**Solution:** Added fields with proper JSON serialization.

### 2. Profile Model ✅
**File:** `lib/models/profile.dart`

**Renamed Field:**
```dart
// OLD: final String? tvaNumber;
final String? vatNumber;      // Line 13
```

**Mapping:** Still correctly maps to `tva_number` in database
**Files Updated:**
- `lib/models/profile.dart` (main model)
- `lib/screens/company/company_profile_page.dart` (usage)
- `lib/services/report_export_service.dart` (references)

### 3. Build Status ✅
```bash
✓ Built build/app/outputs/flutter-apk/app-release.apk (75.6MB)
```

All compilation errors resolved!

---

## 📦 Files Created for You

### 1. Seed Data SQL
**Location:** `supabase/migrations/20251111_comprehensive_seed_data.sql`
**Size:** 104KB
**Content:**
- 15 realistic clients (businesses + individuals)
- 30 plumbing products (Grohe, Hansgrohe, Geberit brands)
- 10 job sites (various statuses)
- 15 quotes (all workflow states)
- 12 invoices (paid, unpaid, overdue, partial)
- 5 payments
- 8 appointments

### 2. Execution Scripts
**Files:**
- `run-seed-data.sh` - Execute seed data
- `verify-schema-sync.sh` - Verify synchronization
- Both are executable: `chmod +x *.sh`

### 3. SQL Schema Checker
**File:** `check-schema-sync.sql`
**Purpose:** Comprehensive database schema verification
**Checks:**
- All tables exist
- All required columns present
- Data types match
- Test data loaded correctly

### 4. Documentation
**Files:**
- `SCHEMA_SYNC_AUDIT_REPORT.md` - Complete audit results
- `EXECUTE_SEED_DATA.md` - Step-by-step execution guide
- `README_DEPLOYMENT.md` - This file

---

## 🚀 STEP-BY-STEP: Load Seed Data

### Method 1: Supabase Dashboard (Easiest)

#### Step 1: Open SQL Editor
```
https://supabase.com/dashboard/project/itugqculhbghypclhyfb/sql
```

#### Step 2: Execute Seed Data
1. Click **"New Query"**
2. Open file: `supabase/migrations/20251111_comprehensive_seed_data.sql`
3. Copy ALL content (Cmd+A, Cmd+C)
4. Paste into SQL Editor
5. Click **"Run"** or press `Cmd+Enter`

#### Step 3: Verify Success
You should see output:
```
✅ SEED DATA SUCCESSFULLY LOADED!
📊 STATISTICS:
  - Clients: 15
  - Products: 30
  - Quotes: 15
  - Invoices: 12
  - Payments: 5
  - Job Sites: 10
  - Appointments: 8
```

---

### Method 2: Using Script (If CLI is linked)

```bash
./run-seed-data.sh
```

---

## 🔍 VERIFY: Schema Synchronization

### Option 1: Run SQL Checker

1. Open SQL Editor: https://supabase.com/dashboard/project/itugqculhbghypclhyfb/sql
2. Open file: `check-schema-sync.sql`
3. Copy all content
4. Paste and run

**Expected Result:**
```
✅ SCHEMA SYNC CHECK PASSED!
All database columns match Flutter models.
Database and codebase are fully synchronized.
```

### Option 2: Quick Manual Check

Run this query:
```sql
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name IN ('profiles', 'job_sites', 'clients')
AND column_name IN ('city', 'postal_code', 'tva_number', 'vat_number')
ORDER BY table_name, column_name;
```

**Expected Results:**
| table_name | column_name  | data_type | is_nullable |
|------------|--------------|-----------|-------------|
| clients    | city         | text      | YES         |
| clients    | postal_code  | text      | YES         |
| clients    | vat_number   | text      | YES         |
| job_sites  | city         | text      | YES         |
| job_sites  | postal_code  | text      | YES         |
| profiles   | city         | text      | YES         |
| profiles   | postal_code  | text      | YES         |
| profiles   | tva_number   | text      | YES         |

**⚠️ IMPORTANT:** If `job_sites.city` or `job_sites.postal_code` are **missing**, you need to add them:

```sql
ALTER TABLE job_sites
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS postal_code TEXT;
```

---

## 📱 TEST: App with Seed Data

### Login Credentials
```
Email: test@plombipro.fr
User ID: 6b1d26bf-40d7-46c0-9b07-89a120191971
Company: Plomberie Pro Services SARL
```

### Test Scenarios

#### ✅ Dashboard
- Should show: 15 clients, 30 products, 15 quotes, 12 invoices
- Recent activity visible
- Financial stats calculated

#### ✅ Clients List
- **15 clients** displayed
- Mix of individuals and companies
- VIP clients marked with star
- Tags visible (VIP, Récurrent, etc.)

**Test Clients:**
1. **Jean Dupont** - VIP individual, 5 years loyalty
2. **Immobilière Parisienne** - Large property mgmt company
3. **Restaurant Le Bon Vivant** - Commercial client
4. **Hôtel de la Tour** - Premium 4-star hotel

#### ✅ Products Catalog
- **30 products** in various categories
- Categories: Robinetterie, Sanitaires, Tuyauterie, Chauffage
- Real suppliers: Grohe, Hansgrohe, Geberit, Atlantic
- Usage counts and last used dates

**Sample Products:**
1. Mitigeur lavabo chromé Eurosmart (Grohe) - 145€
2. WC suspendu Subway 2.0 (Villeroy) - 495€
3. Tube PER nu Ø16mm (Rehau) - 1.45€/ml

#### ✅ Quotes
- **15 quotes** with varied statuses:
  - ✅ **8 Accepted** (will become jobs/invoices)
  - 📤 **2 Sent** (awaiting client response)
  - 📝 **2 Draft** (being prepared)
  - ❌ **1 Rejected** (lost to competition)
  - ⏰ **1 Expired** (needs follow-up)

**Test Quote:** DEV-2025-001 (€12,500) - Bathroom renovation for VIP client

#### ✅ Invoices
- **12 invoices** with realistic states:
  - ✅ **4 Paid** (various payment methods)
  - 📤 **3 Sent/Unpaid** (awaiting payment)
  - ⚠️ **2 Overdue** (need reminders)
  - 📝 **2 Draft** (being prepared)
  - 💰 **1 Partial** (payment plan)

**Test Overdue:** FACT-2024-145 (€2,340) - 30 days late, needs follow-up

#### ✅ Job Sites
- **10 projects** with progress tracking:
  - 🔨 **4 In Progress** (40%-70% complete)
  - 📅 **3 Planned** (scheduled to start)
  - ✅ **3 Completed** (finished successfully)

**Test Project:** Rénovation 2 SdB Haussmann - 70% complete, €8,750 spent of €12,500 budget

#### ✅ Appointments
- **8 appointments** on calendar:
  - 📅 **5 Upcoming** (scheduled)
  - ✅ **3 Completed** (past)

**Test Appointment:** Suite rénovation SdB - Scheduled in 2 days, 5 hours duration

#### ✅ Payments
- **5 payment records** linked to invoices
- Various methods: bank transfer, cash, check, card
- Proper tracking and reconciliation

---

## 🎯 Real-World Test Scenarios

### Scenario 1: VIP Client Journey
1. View **Jean Dupont** (VIP client)
2. See his project: Création SdB - €16,800 (completed)
3. Check invoice FACT-2024-078: Fully paid by bank transfer
4. Verify payment record exists
5. **Expected:** Full audit trail visible

### Scenario 2: Overdue Invoice Follow-up
1. Go to Invoices
2. Filter by "Overdue" status
3. Find FACT-2024-145 (Marie Martin) - 30 days late
4. See notes: "2 relances envoyées"
5. **Action:** Practice sending reminder

### Scenario 3: Project Progress Tracking
1. View Job Sites
2. Select "Rénovation 2 SdB Immeuble Haussmann"
3. Check progress: 70% complete
4. Compare: Budget €12,500 vs Actual €8,750
5. **Profit Margin:** 30% (healthy!)

### Scenario 4: Quote to Invoice Workflow
1. View Quote DEV-2025-001 (Accepted)
2. Convert to Invoice (if feature exists)
3. See related job site created
4. Track progress through completion

### Scenario 5: Appointment Management
1. Open Calendar
2. View upcoming appointment in 2 days
3. Check client: Immobilière Parisienne
4. See linked job site
5. Review notes: "Prévoir échelle et assistant"

---

## 📊 Expected Data Counts

| Entity      | Count | Status                          |
|-------------|-------|---------------------------------|
| Clients     | 15    | Mix individual/company          |
| Products    | 30    | All categories covered          |
| Quotes      | 15    | All statuses represented        |
| Invoices    | 12    | Paid, unpaid, overdue, partial  |
| Job Sites   | 10    | Planned, active, completed      |
| Appointments| 8     | Past and upcoming               |
| Payments    | 5     | Various payment methods         |

---

## ⚠️ Known Issues & Solutions

### Issue 1: job_sites.city Missing in Database

**Symptom:** Flutter model has `city` and `postalCode` but database doesn't

**Solution:** Run this migration:
```sql
ALTER TABLE job_sites
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS postal_code TEXT;
```

**Verification:**
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'job_sites'
AND column_name IN ('city', 'postal_code');
```

### Issue 2: MCP Tools Not Loaded

**Symptom:** Can't execute SQL directly via Claude

**Solution:** Use Supabase Dashboard SQL Editor (Method 1 above)

---

## 🔧 Troubleshooting

### Seed Data Won't Load

**Check 1:** Is test user profile already there?
```sql
SELECT * FROM profiles WHERE id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
```

**Fix:** The seed data uses `ON CONFLICT DO UPDATE`, so it's safe to re-run.

### Column Missing Errors

**Check 2:** Run schema sync checker
```bash
./verify-schema-sync.sh
```
OR execute `check-schema-sync.sql` in dashboard

**Fix:** Add missing columns with ALTER TABLE (see Issue 1 above)

### Zero Data After Load

**Check 3:** Verify user_id filter
```sql
SELECT user_id, COUNT(*) as count
FROM clients
GROUP BY user_id;
```

**Expected:** See count for `6b1d26bf-40d7-46c0-9b07-89a120191971`

---

## 📞 Need Help?

### Quick Commands

**Run seed data:**
```bash
./run-seed-data.sh
```

**Verify schema:**
```bash
./verify-schema-sync.sh
```

**Check build:**
```bash
flutter build apk --release
```

### File Locations

```
plombipro-app/
├── supabase/
│   └── migrations/
│       └── 20251111_comprehensive_seed_data.sql    ← SEED DATA
├── lib/
│   ├── models/
│   │   ├── job_site.dart          ← FIXED (added city, postalCode)
│   │   └── profile.dart           ← FIXED (tvaNumber → vatNumber)
│   └── screens/
│       └── company/
│           └── company_profile_page.dart  ← UPDATED
├── check-schema-sync.sql          ← SCHEMA VERIFIER
├── run-seed-data.sh               ← EXECUTOR
├── verify-schema-sync.sh          ← CHECKER
├── EXECUTE_SEED_DATA.md           ← INSTRUCTIONS
├── SCHEMA_SYNC_AUDIT_REPORT.md    ← AUDIT
└── README_DEPLOYMENT.md           ← THIS FILE
```

---

## ✅ Success Criteria

Your deployment is successful when:

- [x] Build completes with 0 errors ✅
- [ ] Seed data loaded (15 clients, 30 products, etc.)
- [ ] Schema checker shows all ✅ green checks
- [ ] App launches without crashes
- [ ] Dashboard displays correct counts
- [ ] Can navigate to clients, products, quotes, invoices
- [ ] Job sites show progress bars
- [ ] Calendar displays 8 appointments
- [ ] Overdue invoices marked in red

---

## 🎉 What You Get

With this seed data, you have a **fully functional plumbing business** simulation:

- ✅ **5 years** of business history
- ✅ **€180,000+** in total invoiced amounts
- ✅ **15 realistic clients** with detailed notes
- ✅ **€12,500** major renovation project in progress
- ✅ **2 overdue invoices** to practice collections
- ✅ **VIP clients** with loyalty tracking
- ✅ **Commercial contracts** (hotels, restaurants, gyms)
- ✅ **Complete product catalog** with real brands
- ✅ **Profit margins** and cost tracking
- ✅ **Payment history** and methods

Everything is **realistic, comprehensive, and ready to demo**!

---

**Questions?** Check the audit report: `SCHEMA_SYNC_AUDIT_REPORT.md`

**Ready to begin?** Start with: `./run-seed-data.sh` or open Supabase Dashboard! 🚀
