# PlombiPro Database Fix - For Supabase AI Agent

## 🎯 PROBLEM STATEMENT

The PlombiPro application is experiencing critical database access issues:

1. **Dashboard displays ZERO clients** despite 11 clients existing in the database
2. **Creating new clients FAILS completely** - operation throws errors
3. **All CRUD operations are broken** (Create, Read, Update, Delete)
4. **Data exists in database but is NOT VISIBLE to the application**

## 🔍 ROOT CAUSE ANALYSIS

The issue is **Row Level Security (RLS) policies** that are either:
- Missing entirely
- Too restrictive (blocking legitimate access)
- Incorrectly configured (not matching user_id properly)

## 🎯 GOALS

We need to:
1. **Enable RLS** on all core tables
2. **Create proper policies** that allow users to access only THEIR OWN data
3. **Fix any missing policies** that are blocking CRUD operations
4. **Add performance indexes** on user_id columns
5. **Create diagnostic functions** to verify the fix works

## 📊 DATABASE SCHEMA CONTEXT

The application uses these core tables (all should have `user_id uuid` column):
- `profiles` - User profile information
- `clients` - Customer/client records
- `quotes` - Quote/estimate documents
- `quote_items` - Line items within quotes
- `invoices` - Invoice documents
- `invoice_items` - Line items within invoices
- `products` - Product/service catalog
- `payments` - Payment records
- `job_sites` - Job site management
- `job_site_photos`, `job_site_tasks`, `job_site_time_logs`, `job_site_notes` - Related to job sites

**Key Relationship:** All tables (except child tables like `quote_items`) have a `user_id` column that should match `auth.uid()`.

---

## 🔧 SQL FIXES TO APPLY

### PART 1: CORE RLS POLICIES

Please execute the following SQL to fix RLS policies. Each section fixes one table.

---

### 1.1 CLIENTS TABLE - FIX RLS POLICIES

**Purpose:** Allow users to view, create, edit, and delete their own clients.

```sql
-- Drop existing policies if they exist (prevents conflicts)
DROP POLICY IF EXISTS "Users can view their own clients" ON clients;
DROP POLICY IF EXISTS "Users can insert their own clients" ON clients;
DROP POLICY IF EXISTS "Users can update their own clients" ON clients;
DROP POLICY IF EXISTS "Users can delete their own clients" ON clients;

-- Enable RLS (if not already enabled)
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

-- Create SELECT policy (viewing data)
CREATE POLICY "Users can view their own clients"
  ON clients FOR SELECT
  USING (auth.uid() = user_id);

-- Create INSERT policy (creating new clients)
CREATE POLICY "Users can insert their own clients"
  ON clients FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create UPDATE policy (editing existing clients)
CREATE POLICY "Users can update their own clients"
  ON clients FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create DELETE policy (deleting clients)
CREATE POLICY "Users can delete their own clients"
  ON clients FOR DELETE
  USING (auth.uid() = user_id);

-- Add performance index
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
```

**Expected Result:** Users can now see their 11 clients and create new ones.

---

### 1.2 QUOTES TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage their own quotes.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can insert their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can update their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can delete their own quotes" ON quotes;

-- Enable RLS
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own quotes"
  ON quotes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quotes"
  ON quotes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quotes"
  ON quotes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own quotes"
  ON quotes FOR DELETE
  USING (auth.uid() = user_id);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_client_id ON quotes(client_id);
```

---

### 1.3 QUOTE_ITEMS TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage quote line items (linked to their quotes).

**Note:** This is a child table, so policies check the parent `quotes` table.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can insert quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can update quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can delete quote items" ON quote_items;

-- Enable RLS
ALTER TABLE quote_items ENABLE ROW LEVEL SECURITY;

-- Create policies (checking parent quote ownership)
CREATE POLICY "Users can view quote items"
  ON quote_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quotes
      WHERE quotes.id = quote_items.quote_id
      AND quotes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert quote items"
  ON quote_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quotes
      WHERE quotes.id = quote_items.quote_id
      AND quotes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update quote items"
  ON quote_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM quotes
      WHERE quotes.id = quote_items.quote_id
      AND quotes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete quote items"
  ON quote_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM quotes
      WHERE quotes.id = quote_items.quote_id
      AND quotes.user_id = auth.uid()
    )
  );

-- Add index
CREATE INDEX IF NOT EXISTS idx_quote_items_quote_id ON quote_items(quote_id);
```

---

### 1.4 INVOICES TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage their own invoices.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can insert their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can update their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can delete their own invoices" ON invoices;

-- Enable RLS
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own invoices"
  ON invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invoices"
  ON invoices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own invoices"
  ON invoices FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invoices"
  ON invoices FOR DELETE
  USING (auth.uid() = user_id);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_client_id ON invoices(client_id);
```

---

### 1.5 INVOICE_ITEMS TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage invoice line items (linked to their invoices).

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can insert invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can update invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can delete invoice items" ON invoice_items;

-- Enable RLS
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

-- Create policies (checking parent invoice ownership)
CREATE POLICY "Users can view invoice items"
  ON invoice_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM invoices
      WHERE invoices.id = invoice_items.invoice_id
      AND invoices.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert invoice items"
  ON invoice_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM invoices
      WHERE invoices.id = invoice_items.invoice_id
      AND invoices.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update invoice items"
  ON invoice_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM invoices
      WHERE invoices.id = invoice_items.invoice_id
      AND invoices.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete invoice items"
  ON invoice_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM invoices
      WHERE invoices.id = invoice_items.invoice_id
      AND invoices.user_id = auth.uid()
    )
  );

-- Add index
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items(invoice_id);
```

---

### 1.6 PRODUCTS TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage their product catalog.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own products" ON products;
DROP POLICY IF EXISTS "Users can insert their own products" ON products;
DROP POLICY IF EXISTS "Users can update their own products" ON products;
DROP POLICY IF EXISTS "Users can delete their own products" ON products;

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Add index
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
```

---

### 1.7 PAYMENTS TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage payment records.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own payments" ON payments;
DROP POLICY IF EXISTS "Users can insert their own payments" ON payments;
DROP POLICY IF EXISTS "Users can update their own payments" ON payments;
DROP POLICY IF EXISTS "Users can delete their own payments" ON payments;

-- Enable RLS
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own payments"
  ON payments FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own payments"
  ON payments FOR DELETE
  USING (auth.uid() = user_id);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON payments(invoice_id);
```

---

### 1.8 JOB_SITES TABLE - FIX RLS POLICIES

**Purpose:** Allow users to manage job sites.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can insert their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can update their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can delete their own job_sites" ON job_sites;

-- Enable RLS
ALTER TABLE job_sites ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own job_sites"
  ON job_sites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own job_sites"
  ON job_sites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own job_sites"
  ON job_sites FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own job_sites"
  ON job_sites FOR DELETE
  USING (auth.uid() = user_id);

-- Add index
CREATE INDEX IF NOT EXISTS idx_job_sites_user_id ON job_sites(user_id);
```

---

### 1.9 PROFILES TABLE - FIX RLS POLICIES

**Purpose:** Allow users to view and update their own profile.

**Note:** Profiles use `id` column (not `user_id`) which matches `auth.uid()`.

```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Note: No INSERT policy - profiles created via auth trigger
-- Note: No DELETE policy - profile deletion handled separately
```

---

## PART 2: DIAGNOSTIC FUNCTIONS

### 2.1 CREATE DIAGNOSTIC FUNCTION

**Purpose:** Create a function to quickly check data access for the current user.

```sql
-- Create function to check user data access
CREATE OR REPLACE FUNCTION check_user_data_access()
RETURNS TABLE (
  table_name text,
  row_count bigint,
  user_id uuid
) AS $$
BEGIN
  RETURN QUERY
  SELECT 'clients'::text, COUNT(*)::bigint, auth.uid()
  FROM clients WHERE user_id = auth.uid()
  UNION ALL
  SELECT 'quotes'::text, COUNT(*)::bigint, auth.uid()
  FROM quotes WHERE user_id = auth.uid()
  UNION ALL
  SELECT 'invoices'::text, COUNT(*)::bigint, auth.uid()
  FROM invoices WHERE user_id = auth.uid()
  UNION ALL
  SELECT 'products'::text, COUNT(*)::bigint, auth.uid()
  FROM products WHERE user_id = auth.uid()
  UNION ALL
  SELECT 'payments'::text, COUNT(*)::bigint, auth.uid()
  FROM payments WHERE user_id = auth.uid()
  UNION ALL
  SELECT 'job_sites'::text, COUNT(*)::bigint, auth.uid()
  FROM job_sites WHERE user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION check_user_data_access() TO authenticated;
```

---

## PART 3: VERIFICATION QUERIES

**Purpose:** Run these queries to verify the fix worked.

### 3.1 CHECK RLS IS ENABLED

```sql
-- Verify RLS is enabled on all tables
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename IN (
  'clients', 'quotes', 'quote_items', 'invoices', 'invoice_items',
  'products', 'payments', 'job_sites', 'profiles'
)
AND schemaname = 'public'
ORDER BY tablename;
```

**Expected Result:** All tables should show `rls_enabled = true`

---

### 3.2 CHECK POLICIES EXIST

```sql
-- List all policies created
SELECT
  schemaname,
  tablename,
  policyname,
  cmd as command_type
FROM pg_policies
WHERE tablename IN (
  'clients', 'quotes', 'quote_items', 'invoices', 'invoice_items',
  'products', 'payments', 'job_sites', 'profiles'
)
ORDER BY tablename, cmd;
```

**Expected Result:** Should see 4 policies per main table (SELECT, INSERT, UPDATE, DELETE)

---

### 3.3 TEST DATA ACCESS (AS AUTHENTICATED USER)

```sql
-- Run this to check data counts for current user
SELECT * FROM check_user_data_access();
```

**Expected Result:**
```
table_name | row_count | user_id
-----------+-----------+----------
clients    | 11        | <user-id>
quotes     | <count>   | <user-id>
invoices   | <count>   | <user-id>
products   | <count>   | <user-id>
payments   | <count>   | <user-id>
job_sites  | <count>   | <user-id>
```

**This should show 11 clients!**

---

### 3.4 CHECK INDEXES CREATED

```sql
-- Verify performance indexes exist
SELECT
  tablename,
  indexname
FROM pg_indexes
WHERE indexname LIKE 'idx_%_user_id'
OR indexname LIKE 'idx_%_client_id'
OR indexname LIKE 'idx_%_quote_id'
OR indexname LIKE 'idx_%_invoice_id'
ORDER BY tablename;
```

**Expected Result:** Should see indexes on user_id for all main tables.

---

## PART 4: TEST CRUD OPERATIONS

### 4.1 TEST INSERT (Create)

```sql
-- Test creating a new client
INSERT INTO clients (
  user_id,
  client_type,
  first_name,
  last_name,
  email,
  phone
) VALUES (
  auth.uid(),
  'individual',
  'Test',
  'Client',
  'test@example.com',
  '0000000000'
)
RETURNING id, first_name, last_name;
```

**Expected Result:** Should return the new client ID and name (no errors).

---

### 4.2 TEST SELECT (Read)

```sql
-- Test reading clients
SELECT
  id,
  first_name,
  last_name,
  email,
  created_at
FROM clients
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 5;
```

**Expected Result:** Should see at least 11 clients (including the test one).

---

### 4.3 TEST UPDATE (Edit)

```sql
-- Test updating the test client (replace <test-client-id> with actual ID from 4.1)
UPDATE clients
SET first_name = 'Updated Test'
WHERE email = 'test@example.com'
AND user_id = auth.uid()
RETURNING id, first_name;
```

**Expected Result:** Should return the updated client with new first name.

---

### 4.4 TEST DELETE (Remove)

```sql
-- Test deleting the test client
DELETE FROM clients
WHERE email = 'test@example.com'
AND user_id = auth.uid()
RETURNING id;
```

**Expected Result:** Should return the deleted client ID (cleanup successful).

---

## 🎯 SUCCESS CRITERIA

After running all the above SQL:

### ✅ Verification Checklist:

1. **RLS Enabled:** All tables show `rls_enabled = true`
2. **Policies Created:** Each table has 4 policies (SELECT, INSERT, UPDATE, DELETE)
3. **Data Visible:** `check_user_data_access()` shows 11 clients
4. **Indexes Created:** Performance indexes exist on user_id columns
5. **CRUD Works:** Can INSERT, SELECT, UPDATE, DELETE test client without errors

### ✅ Application Verification:

After running the SQL, verify in the Flutter app:
1. Dashboard shows **11 clients** (not 0)
2. Can create new client successfully
3. Can view client list with all data
4. Can edit existing client
5. Can delete client
6. Same for quotes, invoices, products

---

## 🚨 TROUBLESHOOTING

### If still shows 0 clients after running SQL:

**Check 1: Verify user_id matches**
```sql
-- Check what user_ids exist in clients table
SELECT DISTINCT user_id, COUNT(*) as count
FROM clients
GROUP BY user_id;

-- Check current authenticated user
SELECT auth.uid() as current_user_id;
```

If these don't match, the 11 clients belong to a different user.

**Check 2: Verify policies are active**
```sql
-- Check policies are actually applied
SELECT * FROM pg_policies WHERE tablename = 'clients';
```

Should see 4 policies with correct definitions.

**Check 3: Test with service role**
```sql
-- Disable RLS temporarily to see ALL data (service role only)
ALTER TABLE clients DISABLE ROW LEVEL SECURITY;
SELECT COUNT(*) FROM clients;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
```

This shows if data exists but RLS is blocking it.

---

## 📝 NOTES FOR SUPABASE AI AGENT

When executing these queries:

1. **Run queries in order** (Part 1 → Part 2 → Part 3 → Part 4)
2. **Check for errors** after each major section
3. **User must be authenticated** for verification queries (Part 3 & 4)
4. **Some queries modify data** (Part 4) - these are tests, they create/delete a test client
5. **Expected result** is provided after each query

### Execution Context:
- Database: PlombiPro production database
- Project: itugqculhbghypclhyfb.supabase.co
- Purpose: Fix RLS policies blocking data access
- Impact: Read/Write operations on core tables

### Safety:
- All `DROP POLICY IF EXISTS` statements are safe (idempotent)
- All indexes use `IF NOT EXISTS` (safe to rerun)
- Test data created in Part 4 is cleaned up in Part 4.4

---

## ✅ FINAL CONFIRMATION

Once all SQL is executed successfully, you should see:

```sql
SELECT * FROM check_user_data_access();
```

Returns:
```
clients    | 11
quotes     | [your count]
invoices   | [your count]
products   | [your count]
```

**If clients shows 11, the fix is successful! 🎉**

The Flutter app will now be able to see and manage all data properly.

---

**Created:** 2025-11-12
**Purpose:** Fix critical database access issues in PlombiPro
**Priority:** P0 - Critical (blocks all operations)
**Status:** Ready to execute
