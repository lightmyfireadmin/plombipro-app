# SUPABASE AGENT PROMPT - PlombiPro Database Verification & Fix

**CONTEXT:** You are verifying the PlombiPro database before a production build. This is a Flutter mobile app for plumbers to manage clients, quotes, invoices, and payments. The database schema was recently fixed with RLS policies to resolve an authentication issue where `auth.uid()` was returning NULL.

**OBJECTIVE:** Execute comprehensive database diagnostics, report status, and apply fixes if any issues are found.

---

## CRITICAL BACKGROUND INFORMATION

### Known Working State (Verified 2025-11-12)
- Test user ID: `6b1d26bf-40d7-46c0-9b07-89a120191971`
- This user has: 11 clients, 5 quotes, 4 invoices, 22 products, 2 payments, 4 job sites
- Latest migration applied: `20251112_fix_rls_policies.sql`
- RLS policies were fixed to use `auth.uid() = user_id` pattern

### Core Tables (9 total)
1. `clients` - Customer information
2. `quotes` - Price estimates for jobs
3. `invoices` - Bills sent to clients
4. `invoice_items` - Line items for invoices
5. `products` - Service/product catalog
6. `payments` - Payment records
7. `job_sites` - Work locations
8. `user_profiles` - User account details
9. `company_profiles` - Business information

### Expected Database State
- **36 RLS policies** total (9 tables × 4 policies: SELECT, INSERT, UPDATE, DELETE)
- **9 user_id indexes** for performance
- **All policies** must use `auth.uid() = user_id` pattern
- **0 orphaned records** (no broken foreign keys)

---

## STEP 1: EXECUTE DIAGNOSTIC QUERIES

Run each query below **in sequence** and record the results. After each query, I've noted the **expected result** and what to do if it differs.

### Query 1: Verify All Tables Exist

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Expected Result:** At minimum, these 9 tables must exist:
- `clients`
- `company_profiles`
- `invoice_items`
- `invoices`
- `job_sites`
- `payments`
- `products`
- `quotes`
- `user_profiles`

**If Different:** Report which tables are missing. These are critical core tables.

---

### Query 2: Verify RLS is Enabled

```sql
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
```

**Expected Result:** All 9 tables show `rls_enabled = true`

**If Any Show FALSE:** Note which tables have RLS disabled. This is a critical security issue.

---

### Query 3: Count RLS Policies Per Table

```sql
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
```

**Expected Result:** Each table should have **exactly 4 policies**:
- 1 SELECT policy
- 1 INSERT policy
- 1 UPDATE policy
- 1 DELETE policy

**Total across all tables: 36 policies**

**If Different:**
- If any table has < 4 policies: Note which policies are missing
- If any table has 0 policies: This table has no RLS policies at all (critical issue)
- If total ≠ 36: Some tables are missing policies

---

### Query 4: Verify Policies Use Correct Auth Pattern

```sql
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
    'payments', 'job_sites', 'user_profiles',
    'company_profiles', 'invoice_items'
  )
ORDER BY tablename, cmd;
```

**Expected Result:** ALL policies should show "Uses auth.uid() ✅"

**If Any Show "MISSING auth.uid() ⚠️":** These policies will not work correctly and users won't be able to access their data. Note which policies are broken.

---

### Query 5: Verify user_id Columns Exist

```sql
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
```

**Expected Result:** All 6 core tables should have:
- `column_name = 'user_id'`
- `data_type = 'uuid'`
- `is_nullable = 'NO'`

**If Missing:** If any table doesn't appear in results, it's missing the user_id column (critical issue).

---

### Query 6: Verify Foreign Key Relationships

```sql
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
```

**Expected Relationships:**
- `quotes.client_id` → `clients.id`
- `invoices.client_id` → `clients.id`
- `invoices.quote_id` → `quotes.id` (may be optional/nullable)
- `invoice_items.invoice_id` → `invoices.id`
- `invoice_items.product_id` → `products.id` (may be optional/nullable)
- `payments.invoice_id` → `invoices.id`
- `job_sites.client_id` → `clients.id`

**If Missing:** Note which foreign keys are missing. These ensure data integrity.

---

### Query 7: Verify Performance Indexes

```sql
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
```

**Expected Result:** Each of the 6 core tables should have at least one index on `user_id` for RLS query performance.

**If Missing:** Note which tables lack indexes. This will cause slow queries.

---

### Query 8: Check for Orphaned Data

```sql
-- Orphaned quotes (quotes without valid clients)
SELECT COUNT(*) as orphaned_quotes
FROM quotes q
LEFT JOIN clients c ON q.client_id = c.id
WHERE c.id IS NULL;

-- Orphaned invoices (invoices without valid clients)
SELECT COUNT(*) as orphaned_invoices
FROM invoices i
LEFT JOIN clients c ON i.client_id = c.id
WHERE c.id IS NULL;

-- Orphaned payments (payments without valid invoices)
SELECT COUNT(*) as orphaned_payments
FROM payments p
LEFT JOIN invoices i ON p.invoice_id = i.id
WHERE i.id IS NULL;

-- Orphaned invoice items (items without valid invoices)
SELECT COUNT(*) as orphaned_invoice_items
FROM invoice_items ii
LEFT JOIN invoices i ON ii.invoice_id = i.id
WHERE i.id IS NULL;
```

**Expected Result:** All counts should be **0**

**If Any > 0:** There is orphaned data that should be cleaned up or fixed.

---

### Query 9: Verify Test User Data (Smoke Test)

```sql
-- Count records for known test user
SELECT
  'clients' as table_name,
  COUNT(*) as record_count
FROM clients
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'quotes', COUNT(*)
FROM quotes
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'invoices', COUNT(*)
FROM invoices
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'products', COUNT(*)
FROM products
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'payments', COUNT(*)
FROM payments
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'job_sites', COUNT(*)
FROM job_sites
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
```

**Expected Result:**
- clients: 11
- quotes: 5
- invoices: 4
- products: 22
- payments: 2
- job_sites: 4

**If Different:** Data may have been lost or the user_id filtering isn't working.

---

### Query 10: Verify Recent Migrations Applied

```sql
SELECT *
FROM supabase_migrations.schema_migrations
ORDER BY version DESC
LIMIT 10;
```

**Expected Result:** Should include migration `20251112_fix_rls_policies` or similar recent migration.

**If Missing:** The latest RLS policy fixes may not have been applied.

---

## STEP 2: ANALYZE RESULTS & REPORT STATUS

After running all queries, provide a comprehensive report in this format:

```
═══════════════════════════════════════════════════════
PLOMBIPRO DATABASE DIAGNOSTIC REPORT
Date: [Current Date]
═══════════════════════════════════════════════════════

✅ PASSED CHECKS:
- [List each check that passed with expected values]

⚠️ ISSUES FOUND:
- [List each check that failed with actual vs expected values]

📊 SUMMARY:
- Total Checks: 10
- Passed: X
- Failed: Y
- Critical Issues: Z

🔧 FIXES NEEDED:
- [List specific fixes required, if any]
```

---

## STEP 3: APPLY FIXES (If Issues Found)

### Fix 1: Missing RLS Policies

If Query 3 shows any table with < 4 policies, apply fixes for that specific table.

**Example for `products` table:**

```sql
-- Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can view their own products" ON products;
DROP POLICY IF EXISTS "Users can insert their own products" ON products;
DROP POLICY IF EXISTS "Users can update their own products" ON products;
DROP POLICY IF EXISTS "Users can delete their own products" ON products;

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create all 4 policies
CREATE POLICY "Users can view their own products"
  ON products FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own products"
  ON products FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own products"
  ON products FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own products"
  ON products FOR DELETE
  USING (auth.uid() = user_id);
```

**Repeat this pattern for each table missing policies:**
- Replace `products` with the table name
- Replace `"Users can view their own products"` with appropriate policy name

**For all 9 core tables:**
- clients
- quotes
- invoices
- invoice_items
- products
- payments
- job_sites
- user_profiles
- company_profiles

---

### Fix 2: Missing user_id Indexes

If Query 7 shows missing indexes:

```sql
-- Create indexes on user_id for RLS performance
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_job_sites_user_id ON job_sites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(id);
CREATE INDEX IF NOT EXISTS idx_company_profiles_user_id ON company_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items(invoice_id);
```

---

### Fix 3: Enable RLS on Tables

If Query 2 shows RLS disabled on any table:

```sql
-- Enable RLS for all core tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_profiles ENABLE ROW LEVEL SECURITY;
```

---

### Fix 4: Clean Orphaned Data

If Query 8 shows orphaned records > 0:

**⚠️ WARNING:** Only run these if you understand the data implications!

```sql
-- Delete orphaned quotes (use with caution!)
DELETE FROM quotes q
WHERE NOT EXISTS (
  SELECT 1 FROM clients c WHERE c.id = q.client_id
);

-- Delete orphaned invoices
DELETE FROM invoices i
WHERE NOT EXISTS (
  SELECT 1 FROM clients c WHERE c.id = i.client_id
);

-- Delete orphaned payments
DELETE FROM payments p
WHERE NOT EXISTS (
  SELECT 1 FROM invoices i WHERE i.id = p.invoice_id
);

-- Delete orphaned invoice items
DELETE FROM invoice_items ii
WHERE NOT EXISTS (
  SELECT 1 FROM invoices i WHERE i.id = ii.invoice_id
);
```

---

## STEP 4: RE-RUN DIAGNOSTICS

After applying any fixes, re-run ALL diagnostic queries (Step 1) to verify fixes were successful.

---

## STEP 5: FINAL REPORT

Provide a final status report:

```
═══════════════════════════════════════════════════════
PLOMBIPRO DATABASE - FINAL STATUS
═══════════════════════════════════════════════════════

✅ DATABASE READY FOR BUILD: [YES/NO]

FINAL STATE:
- Total Tables: 9/9 ✅
- RLS Enabled: 9/9 ✅
- Total Policies: 36/36 ✅
- Policies Using auth.uid(): 36/36 ✅
- user_id Indexes: 9/9 ✅
- Foreign Keys: 7/7 ✅
- Orphaned Records: 0 ✅
- Test User Data: Accessible ✅

🔧 FIXES APPLIED:
- [List all fixes that were applied]

⚠️ REMAINING ISSUES:
- [List any issues that couldn't be fixed automatically]

📋 RECOMMENDATIONS:
- [Any recommendations for the dev team]

═══════════════════════════════════════════════════════
```

---

## SUCCESS CRITERIA

The database is **READY FOR BUILD** when ALL of these are true:

✅ All 9 core tables exist
✅ All 9 tables have RLS enabled
✅ All 9 tables have exactly 4 policies (36 total)
✅ All 36 policies use `auth.uid() = user_id` pattern
✅ All 6 data tables have user_id column (UUID, NOT NULL)
✅ All expected foreign keys exist
✅ All 6 data tables have user_id indexes
✅ 0 orphaned records
✅ Test user can access their 11 clients, 5 quotes, 4 invoices, etc.
✅ Latest migration (20251112_fix_rls_policies) is applied

---

## ERROR HANDLING

If you encounter errors during fix application:

1. **Permission Denied Error:**
   - Ensure you're using a connection with sufficient privileges
   - May need SUPERUSER or schema owner privileges

2. **Policy Already Exists:**
   - Use `DROP POLICY IF EXISTS` before creating new ones

3. **Foreign Key Constraint Violation:**
   - Don't delete orphaned data if there are dependencies
   - Report the issue for manual review

4. **Syntax Errors:**
   - Verify PostgreSQL version compatibility
   - Check table/column names for typos

---

## IMPORTANT NOTES

1. **DO NOT** modify data in production without backup
2. **DO NOT** delete orphaned data without dev team approval
3. **DO** report all findings, even if no issues found
4. **DO** provide specific table names and policy names for any issues
5. **DO** re-run diagnostics after applying fixes
6. **DO** export the final report for the dev team

---

## OUTPUT FORMAT

Please structure your response as:

1. **Diagnostic Results** (from Step 1)
2. **Analysis** (from Step 2)
3. **Fixes Applied** (from Step 3, if needed)
4. **Re-verification Results** (from Step 4, if fixes were applied)
5. **Final Status Report** (from Step 5)

---

## READY TO BEGIN?

Please execute this prompt by:
1. Running all diagnostic queries in sequence
2. Recording results carefully
3. Analyzing against expected values
4. Applying fixes only if issues found
5. Providing comprehensive final report

**START DIAGNOSTICS NOW**
