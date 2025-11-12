# Execute Seed Data - Quick Guide

## 🎯 Your Supabase Project
- **Project URL**: https://itugqculhbghypclhyfb.supabase.co
- **Project Ref**: itugqculhbghypclhyfb
- **Dashboard**: https://supabase.com/dashboard/project/itugqculhbghypclhyfb

---

## 📋 Method 1: Supabase Dashboard (Recommended - 2 minutes)

### Step 1: Open SQL Editor
1. Go to: https://supabase.com/dashboard/project/itugqculhbghypclhyfb/sql
2. Click **"New Query"**

### Step 2: Load Seed Data
1. Open the file: `supabase/migrations/20251111_comprehensive_seed_data.sql`
2. Copy ALL content (Cmd+A, Cmd+C)
3. Paste into the SQL Editor
4. Click **"Run"** (or press Cmd+Enter)

### Step 3: Wait for Success
You should see:
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

## 📋 Method 2: Using Scripts (If Supabase CLI is Linked)

### Option A: Run Seed Data
```bash
./run-seed-data.sh
```

### Option B: Verify Schema Sync
```bash
./verify-schema-sync.sh
```

---

## 🔍 Quick Verification Query

After running the seed data, execute this query to verify:

```sql
SELECT
  'Clients' as table_name, COUNT(*) as count
FROM clients
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Products', COUNT(*)
FROM products
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Quotes', COUNT(*)
FROM quotes
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Invoices', COUNT(*)
FROM invoices
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Job Sites', COUNT(*)
FROM job_sites
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
```

**Expected Results:**
| table_name | count |
|------------|-------|
| Clients    | 15    |
| Products   | 30    |
| Quotes     | 15    |
| Invoices   | 12    |
| Job Sites  | 10    |

---

## ✅ Schema Sync Verification

After loading seed data, run this to check schema is synced:

```sql
-- Verify critical columns exist
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name IN ('profiles', 'job_sites', 'clients')
  AND column_name IN ('city', 'postal_code', 'tva_number', 'vat_number')
ORDER BY table_name, ordinal_position;
```

**Expected Results:**
```
profiles     | tva_number   | text | YES ✅
job_sites    | city         | text | YES ✅ (Should exist from fixes)
job_sites    | postal_code  | text | YES ✅ (Should exist from fixes)
clients      | city         | text | YES ✅
clients      | postal_code  | text | YES ✅
clients      | vat_number   | text | YES ✅
```

---

## 🚨 If Columns Are Missing

If `job_sites.city` or `job_sites.postal_code` don't exist in the database, run this migration:

```sql
-- Add missing job_sites columns
ALTER TABLE job_sites
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS postal_code TEXT;

-- Verify
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_sites'
AND column_name IN ('city', 'postal_code');
```

---

## 📱 Test in App

Once seed data is loaded, test in your Flutter app:

1. **Login Credentials:**
   - Email: `test@plombipro.fr`
   - User ID: `6b1d26bf-40d7-46c0-9b07-89a120191971`

2. **What to Test:**
   - ✅ Dashboard shows 15 clients
   - ✅ Product catalog shows 30 items
   - ✅ Quotes list shows 15 quotes with various statuses
   - ✅ Invoices show paid, unpaid, overdue states
   - ✅ Job sites show progress tracking
   - ✅ Calendar shows 8 appointments

---

## 🎯 Files Created

1. **Seed Data SQL**: `supabase/migrations/20251111_comprehensive_seed_data.sql`
2. **Audit Report**: `SCHEMA_SYNC_AUDIT_REPORT.md`
3. **Execution Scripts**:
   - `run-seed-data.sh`
   - `verify-schema-sync.sh`

---

## ✅ What's Been Fixed

1. **JobSite Model** - Added `city` and `postalCode` ✅
2. **Profile Model** - Renamed `tvaNumber` → `vatNumber` ✅
3. **CompanyProfilePage** - Updated references ✅
4. **Build Errors** - All resolved ✅
5. **Comprehensive Seed Data** - Created ✅

---

**Need Help?** Run `./run-seed-data.sh` for interactive guidance!
