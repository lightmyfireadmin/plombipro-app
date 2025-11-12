# Migration Execution Guide

**Critical Schema Synchronization Fix**
**Date:** 2025-11-12

---

## ⚠️ IMPORTANT - READ FIRST

This migration will:
- ✅ Add `user_id` to products, quotes, invoices
- ✅ Remove duplicate columns
- ✅ Standardize column naming  
- ✅ Complete appointments schema (adds 35+ fields)
- ✅ Create supporting tables for appointments
- ⚠️ Create backup of appointments data

**Estimated Time:** 5-10 minutes
**Rollback:** Backup table created (appointments_backup_20251112)

---

## Step 1: Backup Your Database (CRITICAL!)

Before running ANY migration, create a full backup:

### Option A: Via Supabase Dashboard
1. Go to https://supabase.com/dashboard/project/itugqculhbghypclhyfb
2. Settings → Database → Create Backup
3. Download backup file

### Option B: Via CLI
```bash
# If you have Supabase CLI linked
supabase db dump -f backup_before_migration_$(date +%Y%m%d_%H%M%S).sql
```

---

## Step 2: Execute the Migration

### Option A: Via Supabase Dashboard (RECOMMENDED)

1. **Open SQL Editor:**
   ```
   https://supabase.com/dashboard/project/itugqculhbghypclhyfb/editor/sql
   ```

2. **Open migration file:**
   ```
   /Users/utilisateur/Desktop/plombipro/plombipro-app/supabase/migrations/20251112_fix_critical_schema_sync.sql
   ```

3. **Copy entire file content** (Cmd+A, Cmd+C)

4. **Paste into SQL Editor** (Cmd+V)

5. **Click "Run"** or press Cmd+Enter

6. **Wait for completion** - You should see:
   ```
   ✅ ALL CRITICAL FIXES APPLIED SUCCESSFULLY
   ```

### Option B: Via Supabase CLI

```bash
cd /Users/utilisateur/Desktop/plombipro/plombipro-app

# Execute the migration
supabase db execute --file supabase/migrations/20251112_fix_critical_schema_sync.sql
```

---

## Step 3: Verify Migration Success

Run these verification queries in SQL Editor:

```sql
-- Verify user_id columns exist
SELECT 
    'products' as table_name,
    EXISTS (SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'products' AND column_name = 'user_id') as has_user_id
UNION ALL
SELECT 
    'quotes',
    EXISTS (SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'quotes' AND column_name = 'user_id')
UNION ALL
SELECT 
    'invoices',
    EXISTS (SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'invoices' AND column_name = 'user_id');

-- Verify appointments has all fields
SELECT COUNT(*) as appointment_columns
FROM information_schema.columns
WHERE table_name = 'appointments';
-- Should return 40+ columns

-- Verify supporting tables created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('daily_routes', 'appointment_eta_history', 'appointment_sms_log');
-- Should return 3 rows

-- Check for duplicate columns (should return 0)
SELECT column_name, COUNT(*)
FROM information_schema.columns
WHERE table_name = 'products'
  AND column_name IN ('reference', 'purchase_price_ht', 'selling_price_ht', 'supplier_name')
GROUP BY column_name;
-- Should return 0 rows if duplicates were removed
```

Expected results:
- ✅ products has_user_id: true
- ✅ quotes has_user_id: true  
- ✅ invoices has_user_id: true
- ✅ appointment_columns: 40+
- ✅ 3 supporting tables exist
- ✅ 0 duplicate columns

---

## Step 4: Update Flutter Models

**Follow the guide:**
```
FLUTTER_MODEL_UPDATES_REQUIRED.md
```

**Critical changes:**
1. Add `userId` to Product, Quote, Invoice models
2. Fix column names in toJson/fromJson (subtotal_ht, total_vat)
3. Add `status` to Invoice toJson()
4. Fix Client toJson() to conditionally write company_name OR last_name

---

## Step 5: Test the Changes

### Test 1: Insert Product from Flutter
```dart
final product = Product(
  userId: 'your-test-user-id',
  name: 'Test Product',
  unitPrice: 100.0,
);
await supabase.from('products').insert(product.toJson());
```

Should succeed without errors.

### Test 2: Insert Quote from Flutter
```dart
final quote = Quote(
  userId: 'your-test-user-id',
  quoteNumber: 'TEST-001',
  clientId: 'your-client-id',
  date: DateTime.now(),
);
await supabase.from('quotes').insert(quote.toJson());
```

Should succeed without errors.

### Test 3: Insert Invoice from Flutter
```dart
final invoice = Invoice(
  userId: 'your-test-user-id',
  number: 'INV-TEST-001',
  clientId: 'your-client-id',
  date: DateTime.now(),
  status: 'draft',
);
await supabase.from('invoices').insert(invoice.toJson());
```

Should succeed without errors.

---

## Step 6: Run Seed Data

**NOW you can run your seed data!**

The seed data SQL should work perfectly after this migration because:
- ✅ All required fields exist
- ✅ Column names are standardized
- ✅ Constraints are correct
- ✅ No duplicate columns

```bash
# Open SQL Editor
open "https://supabase.com/dashboard/project/itugqculhbghypclhyfb/editor/sql"

# Paste your seed data SQL (from clipboard)
# Click Run
```

---

## Troubleshooting

### Error: "column user_id does not exist"
**Cause:** Migration didn't run completely
**Fix:** Re-run the migration SQL

### Error: "null value in column user_id violates not-null constraint"
**Cause:** Flutter model not updated with userId
**Fix:** Add `userId` field to model and pass value when creating instances

### Error: "column status of relation invoices does not exist"  
**Cause:** Old migration created invoices without status column
**Fix:** 
```sql
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft';
```

### Error: "column reference does not exist"
**Cause:** Expected duplicate column was removed
**Fix:** Update code to use `ref` instead of `reference`

### Migration seems stuck
**Cause:** Long-running queries (especially if lots of data)
**Fix:** Wait 5-10 minutes. Check Supabase logs for progress.

---

## Rollback Instructions

If something goes wrong and you need to rollback:

### Rollback appointments only:
```sql
-- Drop new tables
DROP TABLE IF EXISTS appointment_sms_log CASCADE;
DROP TABLE IF EXISTS appointment_eta_history CASCADE;
DROP TABLE IF EXISTS daily_routes CASCADE;

-- Restore appointments from backup
DROP TABLE appointments;
ALTER TABLE appointments_backup_20251112 RENAME TO appointments;
```

### Rollback everything:
Use your full database backup from Step 1.

---

## Post-Migration Checklist

- [ ] Migration ran successfully (saw success message)
- [ ] Verification queries all pass
- [ ] Flutter models updated
- [ ] Test inserts work for products, quotes, invoices
- [ ] Seed data executes successfully
- [ ] App can create new records from UI
- [ ] No console errors in Flutter
- [ ] Data appears correctly in Supabase dashboard

---

## Success Indicators

✅ **Migration Successful** if you see:
```
✅ ALL CRITICAL FIXES APPLIED SUCCESSFULLY
```

✅ **Flutter Sync Successful** if:
- You can create products from Flutter
- You can create quotes from Flutter
- You can create invoices from Flutter
- No "column does not exist" errors
- No "null constraint violation" errors

✅ **Seed Data Successful** if:
- Seed SQL executes without errors
- Expected row counts match
- Data appears in all tables

---

## Next Steps

After successful migration:

1. ✅ Run your comprehensive seed data
2. ✅ Test all CRUD operations from Flutter
3. ✅ Deploy to staging/production
4. ✅ Monitor for any issues
5. ✅ Archive old backup files after 1 week of stable operation

---

## Need Help?

**Check these files:**
- `DATABASE_CODEBASE_SYNC_AUDIT.md` - Full analysis
- `DATABASE_CODEBASE_SYNC_AUDIT_SUMMARY.md` - Quick summary
- `FLUTTER_MODEL_UPDATES_REQUIRED.md` - Model changes needed

**Supabase Logs:**
https://supabase.com/dashboard/project/itugqculhbghypclhyfb/logs/explorer

**Database Logs:**
https://supabase.com/dashboard/project/itugqculhbghypclhyfb/logs/postgres-logs

---

**Migration Created:** 2025-11-12
**Status:** Ready for execution
**Risk Level:** Medium (creates backups, can be rolled back)
