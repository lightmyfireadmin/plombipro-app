# PlombiPro Pre-Build Database Checklist
**Date:** 2025-11-12
**Purpose:** Verify database is ready for production build

---

## ✅ VERIFIED WORKING (From Previous Session)

### Database Connection
- ✅ 11 clients exist for test user
- ✅ 5 quotes exist
- ✅ 4 invoices exist
- ✅ 22 products exist
- ✅ 2 payments exist
- ✅ 4 job sites exist

### RLS Policies
- ✅ Applied migration `20251112_fix_rls_policies.sql`
- ✅ All 9 core tables have SELECT/INSERT/UPDATE/DELETE policies
- ✅ Policies correctly use `auth.uid() = user_id`

### Test User
- ✅ User ID: `6b1d26bf-40d7-46c0-9b07-89a120191971`
- ✅ Has complete test data

---

## 🔍 PRE-BUILD VERIFICATION QUERIES

### To run in Supabase SQL Editor or via AI agent:

```sql
-- =====================================================
-- 1. VERIFY ALL TABLES EXIST
-- =====================================================
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Expected tables:
-- clients, quotes, invoices, invoice_items, products, payments
-- job_sites, user_profiles, company_profiles
-- (9+ core tables)

-- =====================================================
-- 2. VERIFY RLS IS ENABLED ON ALL CORE TABLES
-- =====================================================
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'clients', 'quotes', 'invoices', 'invoice_items',
    'products', 'payments', 'job_sites',
    'user_profiles', 'company_profiles'
  )
ORDER BY tablename;

-- All should show: rls_enabled = true

-- =====================================================
-- 3. VERIFY ALL TABLES HAVE 4 RLS POLICIES
-- =====================================================
SELECT
  schemaname,
  tablename,
  COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'clients', 'quotes', 'invoices', 'invoice_items',
    'products', 'payments', 'job_sites',
    'user_profiles', 'company_profiles'
  )
GROUP BY schemaname, tablename
ORDER BY tablename;

-- Each table should have 4 policies (SELECT, INSERT, UPDATE, DELETE)
-- If any table has < 4, policies are missing!

-- =====================================================
-- 4. VERIFY POLICIES USE CORRECT AUTH CHECK
-- =====================================================
SELECT
  tablename,
  policyname,
  CASE
    WHEN qual::text LIKE '%auth.uid()%' THEN 'Uses auth.uid() ✅'
    ELSE 'MISSING auth.uid() ⚠️'
  END as auth_check,
  cmd as command_type
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'clients', 'quotes', 'invoices', 'products',
    'payments', 'job_sites', 'user_profiles'
  )
ORDER BY tablename, cmd;

-- All should show "Uses auth.uid() ✅"

-- =====================================================
-- 5. VERIFY ALL TABLES HAVE user_id COLUMN
-- =====================================================
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'user_id'
  AND table_name IN (
    'clients', 'quotes', 'invoices', 'products',
    'payments', 'job_sites'
  )
ORDER BY table_name;

-- All core tables should have user_id UUID NOT NULL

-- =====================================================
-- 6. VERIFY FOREIGN KEY RELATIONSHIPS
-- =====================================================
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN (
    'quotes', 'invoices', 'invoice_items',
    'payments', 'job_sites'
  )
ORDER BY tc.table_name, kcu.column_name;

-- Expected relationships:
-- quotes.client_id → clients.id
-- invoices.client_id → clients.id
-- invoices.quote_id → quotes.id
-- invoice_items.invoice_id → invoices.id
-- invoice_items.product_id → products.id
-- payments.invoice_id → invoices.id
-- job_sites.client_id → clients.id

-- =====================================================
-- 7. VERIFY INDEXES FOR PERFORMANCE
-- =====================================================
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'clients', 'quotes', 'invoices', 'products',
    'payments', 'job_sites'
  )
  AND indexname LIKE '%user_id%'
ORDER BY tablename;

-- Each table should have index on user_id for RLS performance

-- =====================================================
-- 8. CHECK FOR MISSING COLUMNS (Common Issues)
-- =====================================================

-- Check clients table has all required columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'clients'
ORDER BY ordinal_position;

-- Expected columns: id, user_id, client_type, first_name, last_name,
-- company_name, email, phone, address, city, postal_code, country,
-- notes, created_at, updated_at

-- Check invoices table has all required columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'invoices'
ORDER BY ordinal_position;

-- Expected columns: id, user_id, client_id, quote_id, invoice_number,
-- date, due_date, status, payment_status, subtotal_ht, tax_amount,
-- total_ttc, balance_due, payment_terms, notes, created_at, updated_at

-- Check products table has all required columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
ORDER BY ordinal_position;

-- Expected columns: id, user_id, name, description, reference, category,
-- unit, unit_price, tax_rate, supplier, stock_quantity, min_stock_level,
-- is_favorite, created_at, updated_at

-- =====================================================
-- 9. VERIFY NO ORPHANED DATA
-- =====================================================

-- Check for quotes without valid clients
SELECT COUNT(*) as orphaned_quotes
FROM quotes q
LEFT JOIN clients c ON q.client_id = c.id
WHERE c.id IS NULL;
-- Should return 0

-- Check for invoices without valid clients
SELECT COUNT(*) as orphaned_invoices
FROM invoices i
LEFT JOIN clients c ON i.client_id = c.id
WHERE c.id IS NULL;
-- Should return 0

-- Check for payments without valid invoices
SELECT COUNT(*) as orphaned_payments
FROM payments p
LEFT JOIN invoices i ON p.invoice_id = i.id
WHERE i.id IS NULL;
-- Should return 0

-- =====================================================
-- 10. VERIFY TRIGGERS AND FUNCTIONS
-- =====================================================

-- Check for updated_at triggers
SELECT
  trigger_name,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE '%updated_at%'
ORDER BY event_object_table;

-- Each table should have trigger to auto-update updated_at timestamp

-- =====================================================
-- 11. TEST ACTUAL DATA ACCESS WITH AUTH
-- =====================================================

-- IMPORTANT: Run this as authenticated user to verify RLS works
-- (This requires running through Supabase client with JWT, not SQL editor)

-- Test query that should work:
SELECT COUNT(*) FROM clients WHERE user_id = auth.uid();
-- Should return count > 0 for authenticated user

-- Test query that should block other users' data:
SELECT COUNT(*) FROM clients WHERE user_id != auth.uid();
-- Should return 0 (RLS blocks other users' data)

-- =====================================================
-- 12. VERIFY RECENT MIGRATIONS APPLIED
-- =====================================================

SELECT *
FROM supabase_migrations.schema_migrations
ORDER BY version DESC
LIMIT 10;

-- Should include:
-- 20251112_fix_rls_policies
-- 20251111_z_seed_test_user_data (or latest data migration)

```

---

## 🚨 CRITICAL CHECKS BEFORE BUILD

### Must Be True:
- ✅ All core tables exist
- ✅ All core tables have RLS enabled
- ✅ All core tables have 4 policies (SELECT, INSERT, UPDATE, DELETE)
- ✅ All policies use `auth.uid() = user_id`
- ✅ All tables have `user_id` column indexed
- ✅ No orphaned foreign key references
- ✅ All migrations applied successfully

### Expected Results:
1. **9 core tables** exist
2. **36 RLS policies** total (9 tables × 4 policies)
3. **9 indexes** on user_id columns
4. **0 orphaned records**

---

## 🔧 COMMON ISSUES TO CHECK

### Issue 1: Missing RLS Policies
**Symptom:** Policy count < 4 for any table
**Fix:** Run the RLS policies migration again
```sql
-- Re-run for specific table (example: products)
DROP POLICY IF EXISTS "Users can view their own products" ON products;
DROP POLICY IF EXISTS "Users can insert their own products" ON products;
DROP POLICY IF EXISTS "Users can update their own products" ON products;
DROP POLICY IF EXISTS "Users can delete their own products" ON products;

CREATE POLICY "Users can view their own products"
  ON products FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own products"
  ON products FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own products"
  ON products FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own products"
  ON products FOR DELETE USING (auth.uid() = user_id);
```

### Issue 2: Missing user_id Index
**Symptom:** Slow queries, RLS performance issues
**Fix:**
```sql
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_job_sites_user_id ON job_sites(user_id);
```

### Issue 3: Missing Columns
**Symptom:** App crashes when accessing specific fields
**Fix:** Apply column migrations from `supabase/migrations/` directory

### Issue 4: Orphaned Data
**Symptom:** Foreign key constraint violations
**Fix:** Clean up orphaned records or add missing parent records

---

## 📋 SUPABASE AGENT PROMPT (If Database Issues Found)

Use this optimized prompt if you encounter database issues:

```
I need you to verify and fix the PlombiPro database schema. Please run the following diagnostic queries and report any issues:

1. **Check RLS Status:**
   - Verify all 9 core tables (clients, quotes, invoices, invoice_items, products, payments, job_sites, user_profiles, company_profiles) have RLS enabled
   - Count RLS policies per table (should be 4 each: SELECT, INSERT, UPDATE, DELETE)
   - Verify all policies use auth.uid() = user_id pattern

2. **Check Schema Integrity:**
   - Verify all tables have user_id UUID NOT NULL column
   - Check foreign key relationships are intact
   - Verify indexes exist on user_id columns

3. **Test Data Access:**
   - For user 6b1d26bf-40d7-46c0-9b07-89a120191971, verify they can access:
     * Their 11 clients
     * Their 5 quotes
     * Their 4 invoices
     * Their 22 products
   - Confirm RLS blocks access to other users' data

4. **If Issues Found:**
   - Report which policies are missing
   - Report which indexes are missing
   - Suggest specific SQL fixes
   - Apply fixes if authorized

Expected state:
- 9 tables with RLS enabled
- 36 total policies (9 × 4)
- 9 user_id indexes
- 0 orphaned records
- Test user can access all their data

Please format the response as:
✅ PASSED: [list of checks that passed]
⚠️ ISSUES: [list of issues found]
🔧 FIXES APPLIED: [list of fixes executed]
```

---

## ✅ FINAL VERIFICATION CHECKLIST

Before proceeding with build, confirm:

- [ ] All diagnostic queries executed successfully
- [ ] All tables have RLS enabled
- [ ] All tables have 4 policies each
- [ ] All policies use auth.uid() correctly
- [ ] All foreign keys are intact
- [ ] No orphaned data
- [ ] Test user can access their data
- [ ] Test user cannot access other users' data
- [ ] All migrations are applied
- [ ] Performance indexes exist

---

## 🚀 READY TO BUILD WHEN...

All checks above pass ✅

If any check fails, run the Supabase agent prompt above to diagnose and fix.

---

**Last Updated:** 2025-11-12
**Migration Version:** 20251112_fix_rls_policies.sql
**Test User:** 6b1d26bf-40d7-46c0-9b07-89a120191971
