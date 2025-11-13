-- PlombiPro Database Fix: RLS Policies and Permissions
-- Date: 2025-11-12
-- Purpose: Fix Row Level Security policies to allow proper CRUD operations

-- =====================================================
-- 1. CLIENTS TABLE RLS POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own clients" ON clients;
DROP POLICY IF EXISTS "Users can insert their own clients" ON clients;
DROP POLICY IF EXISTS "Users can update their own clients" ON clients;
DROP POLICY IF EXISTS "Users can delete their own clients" ON clients;

-- Enable RLS on clients table
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

-- Create comprehensive RLS policies for clients
CREATE POLICY "Users can view their own clients"
  ON clients FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own clients"
  ON clients FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own clients"
  ON clients FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own clients"
  ON clients FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- 2. QUOTES TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can insert their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can update their own quotes" ON quotes;
DROP POLICY IF EXISTS "Users can delete their own quotes" ON quotes;

ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 3. QUOTE_ITEMS TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can insert quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can update quote items" ON quote_items;
DROP POLICY IF EXISTS "Users can delete quote items" ON quote_items;

ALTER TABLE quote_items ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 4. INVOICES TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can insert their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can update their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can delete their own invoices" ON invoices;

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 5. INVOICE_ITEMS TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can insert invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can update invoice items" ON invoice_items;
DROP POLICY IF EXISTS "Users can delete invoice items" ON invoice_items;

ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 6. PRODUCTS TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own products" ON products;
DROP POLICY IF EXISTS "Users can insert their own products" ON products;
DROP POLICY IF EXISTS "Users can update their own products" ON products;
DROP POLICY IF EXISTS "Users can delete their own products" ON products;

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 7. PAYMENTS TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own payments" ON payments;
DROP POLICY IF EXISTS "Users can insert their own payments" ON payments;
DROP POLICY IF EXISTS "Users can update their own payments" ON payments;
DROP POLICY IF EXISTS "Users can delete their own payments" ON payments;

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 8. JOB_SITES TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can insert their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can update their own job_sites" ON job_sites;
DROP POLICY IF EXISTS "Users can delete their own job_sites" ON job_sites;

ALTER TABLE job_sites ENABLE ROW LEVEL SECURITY;

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

-- =====================================================
-- 9. PROFILES TABLE RLS POLICIES
-- =====================================================

DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- =====================================================
-- 10. DIAGNOSTIC FUNCTION
-- =====================================================

-- Create a function to check RLS policies
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

-- =====================================================
-- 11. INDEXES FOR PERFORMANCE
-- =====================================================

-- Add indexes on user_id columns for better query performance
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_job_sites_user_id ON job_sites(user_id);

-- Add indexes on foreign keys
CREATE INDEX IF NOT EXISTS idx_quotes_client_id ON quotes(client_id);
CREATE INDEX IF NOT EXISTS idx_invoices_client_id ON invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_quote_items_quote_id ON quote_items(quote_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items(invoice_id);

-- =====================================================
-- VERIFICATION QUERIES (Run these manually to test)
-- =====================================================

-- Run this to verify the policies are created:
-- SELECT schemaname, tablename, policyname
-- FROM pg_policies
-- WHERE tablename IN ('clients', 'quotes', 'invoices', 'products', 'payments', 'job_sites');

-- Run this to test data access (as authenticated user):
-- SELECT * FROM check_user_data_access();
