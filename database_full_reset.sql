-- ============================================================================
-- PlombiPro - Complete Database Reset and Recreation Script
-- ============================================================================
-- WARNING: This script will COMPLETELY ERASE all data in the database
-- USE WITH EXTREME CAUTION - Only run this in development or for fresh setup
-- ============================================================================
-- Date: 2025-11-06
-- Description: Complete database reset including:
--   - Drop all tables, triggers, functions
--   - Recreate schema from scratch
--   - Apply all migrations
--   - Set up RLS policies
--   - Create all functions and triggers
-- ============================================================================

-- ============================================================================
-- STEP 1: DROP ALL EXISTING OBJECTS (CORRECTED ORDER)
-- ============================================================================

-- Drop all tables first (CASCADE will automatically drop triggers and policies)
-- This prevents errors when trying to drop triggers on non-existent tables
DROP TABLE IF EXISTS job_site_documents CASCADE;
DROP TABLE IF EXISTS job_site_notes CASCADE;
DROP TABLE IF EXISTS job_site_time_logs CASCADE;
DROP TABLE IF EXISTS job_site_tasks CASCADE;
DROP TABLE IF EXISTS job_site_photos CASCADE;
DROP TABLE IF EXISTS job_sites CASCADE;
DROP TABLE IF EXISTS stripe_subscriptions CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS settings CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS scans CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS templates CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS quotes CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Drop all functions (CASCADE will handle dependencies)
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS calculate_invoice_balance() CASCADE;
DROP FUNCTION IF EXISTS calculate_document_totals() CASCADE;
DROP FUNCTION IF EXISTS update_client_totals() CASCADE;
DROP FUNCTION IF EXISTS calculate_deposit_amount() CASCADE;
DROP FUNCTION IF EXISTS generate_quote_number(uuid) CASCADE;
DROP FUNCTION IF EXISTS generate_invoice_number(uuid) CASCADE;
DROP FUNCTION IF EXISTS auto_generate_quote_number() CASCADE;
DROP FUNCTION IF EXISTS auto_generate_invoice_number() CASCADE;
DROP FUNCTION IF EXISTS update_modified_column() CASCADE;
DROP FUNCTION IF EXISTS update_product_usage() CASCADE;

-- ============================================================================
-- STEP 2: CREATE ALL TABLES
-- ============================================================================

-- Profiles table
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email text,
    first_name text,
    last_name text,
    company_name text,
    siret text,
    phone text,
    address text,
    postal_code text,
    city text,
    country text DEFAULT 'France',
    vat_number text,
    logo_url text,
    iban text,
    bic text,
    subscription_plan text DEFAULT 'free',
    subscription_status text,
    trial_end_date timestamp,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Clients table
CREATE TABLE clients (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    client_type text,
    salutation text,
    first_name text,
    last_name text,
    company_name text,
    email text NOT NULL,
    phone text NOT NULL,
    mobile_phone text,
    address text,
    postal_code text,
    city text,
    country text DEFAULT 'France',
    billing_address text,
    billing_postal_code text,
    billing_city text,
    siret text,
    vat_number text,
    default_payment_terms int DEFAULT 30,
    default_discount decimal DEFAULT 0,
    tags text[],
    is_favorite boolean DEFAULT false,
    notes text,
    total_invoiced decimal DEFAULT 0,
    outstanding_balance decimal DEFAULT 0,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    reference text,
    name text NOT NULL,
    description text,
    category text,
    supplier_name text,
    supplier_reference text,
    purchase_price_ht decimal DEFAULT 0,
    margin_percentage decimal DEFAULT 0,
    selling_price_ht decimal DEFAULT 0,
    vat_rate decimal DEFAULT 20.0,
    unit text DEFAULT 'unit',
    stock_quantity int DEFAULT 0,
    reorder_point int DEFAULT 0,
    image_urls text[],
    notes text,
    is_favorite boolean DEFAULT false,
    is_active boolean DEFAULT true,
    tags text[],
    source text,
    last_used timestamp,
    times_used int DEFAULT 0,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Quotes table
CREATE TABLE quotes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    client_id uuid REFERENCES clients(id) ON DELETE SET NULL,
    quote_number text UNIQUE,
    quote_date date DEFAULT CURRENT_DATE,
    validity_days int DEFAULT 30,
    expiry_date date,
    status text DEFAULT 'draft',
    job_site_address text,
    reference_description text,
    line_items jsonb DEFAULT '[]'::jsonb,
    subtotal_ht decimal DEFAULT 0,
    total_discount decimal DEFAULT 0,
    total_vat decimal DEFAULT 0,
    total_ttc decimal DEFAULT 0,
    deposit_percentage decimal DEFAULT 0,
    deposit_amount decimal DEFAULT 0,
    terms_conditions text,
    notes text,
    pdf_url text,
    signature_url text,
    signed_at timestamp,
    sent_at timestamp,
    accepted_at timestamp,
    converted_to_invoice_id uuid,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Invoices table
CREATE TABLE invoices (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    client_id uuid REFERENCES clients(id) ON DELETE SET NULL,
    related_quote_id uuid REFERENCES quotes(id) ON DELETE SET NULL,
    invoice_number text UNIQUE,
    invoice_type text DEFAULT 'standard',
    invoice_date date DEFAULT CURRENT_DATE,
    due_date date,
    payment_terms text,
    payment_methods_accepted text[],
    job_site_address text,
    reference_description text,
    line_items jsonb DEFAULT '[]'::jsonb,
    subtotal_ht decimal DEFAULT 0,
    total_discount decimal DEFAULT 0,
    total_vat decimal DEFAULT 0,
    total_ttc decimal DEFAULT 0,
    amount_paid decimal DEFAULT 0,
    balance_due decimal DEFAULT 0,
    payment_status text DEFAULT 'unpaid',
    terms_conditions text,
    legal_mentions text,
    notes text,
    pdf_url text,
    facturx_xml_url text,
    is_electronic_invoice boolean DEFAULT false,
    chorus_pro_status text,
    chorus_pro_submitted_at timestamp,
    sent_at timestamp,
    paid_at timestamp,
    reminder_sent_count int DEFAULT 0,
    last_reminder_sent timestamp,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    invoice_id uuid REFERENCES invoices(id) ON DELETE CASCADE,
    payment_date date DEFAULT CURRENT_DATE,
    amount decimal NOT NULL,
    payment_method text,
    transaction_reference text,
    stripe_payment_id text,
    notes text,
    receipt_url text,
    is_reconciled boolean DEFAULT false,
    created_at timestamp DEFAULT NOW()
);

-- Scans table (for OCR invoice scanning)
CREATE TABLE scans (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    scan_type text DEFAULT 'invoice',
    original_image_url text,
    scan_date timestamp DEFAULT CURRENT_TIMESTAMP,
    extraction_status text DEFAULT 'pending',
    extracted_data jsonb,
    reviewed boolean DEFAULT false,
    converted_to_purchase boolean DEFAULT false,
    purchase_id uuid,
    generated_quote_id uuid REFERENCES quotes(id) ON DELETE SET NULL,
    created_at timestamp DEFAULT NOW()
);

-- Templates table
CREATE TABLE templates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    template_name text NOT NULL,
    template_type text,
    category text,
    line_items jsonb DEFAULT '[]'::jsonb,
    terms_conditions text,
    is_system_template boolean DEFAULT false,
    times_used int DEFAULT 0,
    last_used timestamp,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Purchases table
CREATE TABLE purchases (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    supplier_name text,
    invoice_number text,
    invoice_date date,
    due_date date,
    line_items jsonb DEFAULT '[]'::jsonb,
    subtotal_ht decimal DEFAULT 0,
    total_vat decimal DEFAULT 0,
    total_ttc decimal DEFAULT 0,
    payment_status text DEFAULT 'unpaid',
    payment_method text,
    job_site_id uuid,
    scan_id uuid,
    invoice_image_url text,
    notes text,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Job Sites table
CREATE TABLE job_sites (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    client_id uuid REFERENCES clients(id) ON DELETE SET NULL,
    job_name text NOT NULL,
    reference_number text,
    address text,
    contact_person text,
    contact_phone text,
    description text,
    start_date date,
    estimated_end_date date,
    actual_end_date date,
    status text DEFAULT 'planned',
    progress_percentage int DEFAULT 0,
    related_quote_id uuid REFERENCES quotes(id) ON DELETE SET NULL,
    estimated_budget decimal DEFAULT 0,
    actual_cost decimal DEFAULT 0,
    profit_margin decimal DEFAULT 0,
    notes text,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Job Site Photos table
CREATE TABLE job_site_photos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    photo_url text NOT NULL,
    photo_type text,
    caption text,
    uploaded_at timestamp DEFAULT NOW()
);

-- Job Site Tasks table
CREATE TABLE job_site_tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    task_description text NOT NULL,
    is_completed boolean DEFAULT false,
    completed_at timestamp,
    created_at timestamp DEFAULT NOW()
);

-- Job Site Time Logs table
CREATE TABLE job_site_time_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    log_date date DEFAULT CURRENT_DATE,
    hours_worked decimal NOT NULL,
    description text,
    hourly_rate decimal DEFAULT 0,
    labor_cost decimal DEFAULT 0,
    created_at timestamp DEFAULT NOW()
);

-- Job Site Notes table
CREATE TABLE job_site_notes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    note_text text NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Job Site Documents table
CREATE TABLE job_site_documents (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    document_name text NOT NULL,
    document_url text NOT NULL,
    document_type text,
    file_size int,
    uploaded_at timestamp DEFAULT NOW(),
    created_at timestamp DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    category_name text NOT NULL,
    parent_category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
    order_index int DEFAULT 0,
    created_at timestamp DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    notification_type text,
    title text,
    message text,
    link_url text,
    is_read boolean DEFAULT false,
    created_at timestamp DEFAULT NOW()
);

-- Settings table
CREATE TABLE settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    invoice_prefix text DEFAULT 'FACT-',
    quote_prefix text DEFAULT 'DEV-',
    invoice_starting_number int DEFAULT 1,
    quote_starting_number int DEFAULT 1,
    reset_numbering_annually boolean DEFAULT false,
    default_payment_terms_days int DEFAULT 30,
    default_quote_validity_days int DEFAULT 30,
    default_vat_rate decimal DEFAULT 20.0,
    late_payment_interest_rate decimal DEFAULT 0,
    default_quote_footer text,
    default_invoice_footer text,
    enable_facturx boolean DEFAULT false,
    chorus_pro_enabled boolean DEFAULT false,
    chorus_pro_credentials jsonb,
    email_notifications jsonb,
    sms_notifications jsonb,
    theme text DEFAULT 'light',
    language text DEFAULT 'fr',
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Stripe Subscriptions table
CREATE TABLE stripe_subscriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    stripe_customer_id text,
    stripe_subscription_id text UNIQUE,
    plan_id text,
    status text,
    current_period_start timestamp,
    current_period_end timestamp,
    cancel_at_period_end boolean DEFAULT false,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- ============================================================================
-- STEP 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Clients indexes
CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_clients_company_name ON clients(company_name);

-- Products indexes
CREATE INDEX idx_products_user_id ON products(user_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_source ON products(source);
CREATE INDEX idx_products_favorite ON products(user_id, is_favorite) WHERE is_favorite = true;

-- Quotes indexes
CREATE INDEX idx_quotes_user_id ON quotes(user_id);
CREATE INDEX idx_quotes_client_id ON quotes(client_id);
CREATE INDEX idx_quotes_status ON quotes(status);
CREATE INDEX idx_quotes_user_number ON quotes(user_id, quote_number);
CREATE INDEX idx_quotes_date ON quotes(quote_date DESC);

-- Invoices indexes
CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_payment_status ON invoices(payment_status);
CREATE INDEX idx_invoices_user_number ON invoices(user_id, invoice_number);
CREATE INDEX idx_invoices_date ON invoices(invoice_date DESC);
CREATE INDEX idx_invoices_client_payment ON invoices(client_id, payment_status);
CREATE INDEX idx_invoices_client_balance ON invoices(client_id, balance_due) WHERE payment_status != 'paid';

-- Payments indexes
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_date ON payments(payment_date DESC);

-- Job Sites indexes
CREATE INDEX idx_job_sites_user_id ON job_sites(user_id);
CREATE INDEX idx_job_sites_client_id ON job_sites(client_id);
CREATE INDEX idx_job_sites_status ON job_sites(status);
CREATE INDEX idx_job_site_photos_job_site_id ON job_site_photos(job_site_id);
CREATE INDEX idx_job_site_tasks_job_site_id ON job_site_tasks(job_site_id);
CREATE INDEX idx_job_site_time_logs_job_site_id ON job_site_time_logs(job_site_id);
CREATE INDEX idx_job_site_notes_job_site_id ON job_site_notes(job_site_id);
CREATE INDEX idx_job_site_documents_job_site_id ON job_site_documents(job_site_id);
CREATE INDEX idx_job_site_documents_type ON job_site_documents(document_type);

-- Other indexes
CREATE INDEX idx_scans_user_id ON scans(user_id);
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_templates_user_id ON templates(user_id);
CREATE INDEX idx_categories_user_id ON categories(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- ============================================================================
-- STEP 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_site_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_site_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_site_time_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_site_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_site_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE stripe_subscriptions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 5: CREATE RLS POLICIES
-- ============================================================================

-- Clients policies
CREATE POLICY "Users can only see their own clients" ON clients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own clients" ON clients FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own clients" ON clients FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own clients" ON clients FOR DELETE USING (auth.uid() = user_id);

-- Products policies
CREATE POLICY "Users can only see their own products" ON products FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own products" ON products FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own products" ON products FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own products" ON products FOR DELETE USING (auth.uid() = user_id);

-- Quotes policies
CREATE POLICY "Users can only see their own quotes" ON quotes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own quotes" ON quotes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own quotes" ON quotes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own quotes" ON quotes FOR DELETE USING (auth.uid() = user_id);

-- Invoices policies
CREATE POLICY "Users can only see their own invoices" ON invoices FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own invoices" ON invoices FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own invoices" ON invoices FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own invoices" ON invoices FOR DELETE USING (auth.uid() = user_id);

-- Payments policies
CREATE POLICY "Users can only see their own payments" ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own payments" ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own payments" ON payments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own payments" ON payments FOR DELETE USING (auth.uid() = user_id);

-- Scans policies
CREATE POLICY "Users can only see their own scans" ON scans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own scans" ON scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own scans" ON scans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own scans" ON scans FOR DELETE USING (auth.uid() = user_id);

-- Templates policies
CREATE POLICY "Users can only see their own templates" ON templates FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own templates" ON templates FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own templates" ON templates FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own templates" ON templates FOR DELETE USING (auth.uid() = user_id);

-- Purchases policies
CREATE POLICY "Users can only see their own purchases" ON purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own purchases" ON purchases FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own purchases" ON purchases FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own purchases" ON purchases FOR DELETE USING (auth.uid() = user_id);

-- Job Sites policies
CREATE POLICY "Users can only see their own job sites" ON job_sites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job sites" ON job_sites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job sites" ON job_sites FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job sites" ON job_sites FOR DELETE USING (auth.uid() = user_id);

-- Job Site Photos policies
CREATE POLICY "Users can only see their own job site photos" ON job_site_photos FOR SELECT USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can insert their own job site photos" ON job_site_photos FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can update their own job site photos" ON job_site_photos FOR UPDATE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can delete their own job site photos" ON job_site_photos FOR DELETE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));

-- Job Site Tasks policies
CREATE POLICY "Users can only see their own job site tasks" ON job_site_tasks FOR SELECT USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can insert their own job site tasks" ON job_site_tasks FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can update their own job site tasks" ON job_site_tasks FOR UPDATE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can delete their own job site tasks" ON job_site_tasks FOR DELETE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));

-- Job Site Time Logs policies
CREATE POLICY "Users can only see their own job site time logs" ON job_site_time_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job site time logs" ON job_site_time_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job site time logs" ON job_site_time_logs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job site time logs" ON job_site_time_logs FOR DELETE USING (auth.uid() = user_id);

-- Job Site Notes policies
CREATE POLICY "Users can only see their own job site notes" ON job_site_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job site notes" ON job_site_notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job site notes" ON job_site_notes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job site notes" ON job_site_notes FOR DELETE USING (auth.uid() = user_id);

-- Job Site Documents policies
CREATE POLICY "Users can only see documents from their job sites" ON job_site_documents FOR SELECT USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can insert documents to their job sites" ON job_site_documents FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can update their job site documents" ON job_site_documents FOR UPDATE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can delete their job site documents" ON job_site_documents FOR DELETE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));

-- Categories policies
CREATE POLICY "Users can only see their own categories" ON categories FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own categories" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own categories" ON categories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own categories" ON categories FOR DELETE USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can only see their own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- Settings policies
CREATE POLICY "Users can only see their own settings" ON settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own settings" ON settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own settings" ON settings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own settings" ON settings FOR DELETE USING (auth.uid() = user_id);

-- Stripe Subscriptions policies
CREATE POLICY "Users can only see their own stripe subscriptions" ON stripe_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own stripe subscriptions" ON stripe_subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own stripe subscriptions" ON stripe_subscriptions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own stripe subscriptions" ON stripe_subscriptions FOR DELETE USING (auth.uid() = user_id);

-- ============================================================================
-- STEP 6: CREATE FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to generate quote numbers
CREATE OR REPLACE FUNCTION generate_quote_number(p_user_id uuid)
RETURNS text AS $$
DECLARE
    v_prefix text;
    v_starting_number int;
    v_reset_annually boolean;
    v_current_year text;
    v_last_quote_number text;
    v_last_number int;
    v_next_number int;
    v_new_quote_number text;
BEGIN
    SELECT
        COALESCE(quote_prefix, 'DEV-'),
        COALESCE(quote_starting_number, 1),
        COALESCE(reset_numbering_annually, false)
    INTO v_prefix, v_starting_number, v_reset_annually
    FROM settings
    WHERE user_id = p_user_id;

    IF v_prefix IS NULL THEN
        v_prefix := 'DEV-';
        v_starting_number := 1;
        v_reset_annually := false;
    END IF;

    v_current_year := TO_CHAR(CURRENT_DATE, 'YYYY');

    SELECT quote_number INTO v_last_quote_number
    FROM quotes
    WHERE user_id = p_user_id
      AND quote_number IS NOT NULL
      AND quote_number != 'DRAFT'
    ORDER BY created_at DESC, quote_number DESC
    LIMIT 1;

    IF v_last_quote_number IS NULL THEN
        v_next_number := v_starting_number;
    ELSE
        IF v_reset_annually AND v_last_quote_number LIKE v_prefix || v_current_year || '-%' THEN
            v_last_number := SUBSTRING(v_last_quote_number FROM LENGTH(v_prefix || v_current_year || '-') + 1)::int;
            v_next_number := v_last_number + 1;
        ELSIF NOT v_reset_annually AND v_last_quote_number LIKE v_prefix || '%' THEN
            v_last_number := SUBSTRING(v_last_quote_number FROM LENGTH(v_prefix) + 1)::int;
            v_next_number := v_last_number + 1;
        ELSE
            v_next_number := v_starting_number;
        END IF;
    END IF;

    IF v_reset_annually THEN
        v_new_quote_number := v_prefix || v_current_year || '-' || LPAD(v_next_number::text, 4, '0');
    ELSE
        v_new_quote_number := v_prefix || LPAD(v_next_number::text, 6, '0');
    END IF;

    RETURN v_new_quote_number;
END;
$$ LANGUAGE plpgsql;

-- Function to generate invoice numbers
CREATE OR REPLACE FUNCTION generate_invoice_number(p_user_id uuid)
RETURNS text AS $$
DECLARE
    v_prefix text;
    v_starting_number int;
    v_reset_annually boolean;
    v_current_year text;
    v_last_invoice_number text;
    v_last_number int;
    v_next_number int;
    v_new_invoice_number text;
BEGIN
    SELECT
        COALESCE(invoice_prefix, 'FACT-'),
        COALESCE(invoice_starting_number, 1),
        COALESCE(reset_numbering_annually, false)
    INTO v_prefix, v_starting_number, v_reset_annually
    FROM settings
    WHERE user_id = p_user_id;

    IF v_prefix IS NULL THEN
        v_prefix := 'FACT-';
        v_starting_number := 1;
        v_reset_annually := false;
    END IF;

    v_current_year := TO_CHAR(CURRENT_DATE, 'YYYY');

    SELECT invoice_number INTO v_last_invoice_number
    FROM invoices
    WHERE user_id = p_user_id
      AND invoice_number IS NOT NULL
      AND invoice_number != 'DRAFT'
    ORDER BY created_at DESC, invoice_number DESC
    LIMIT 1;

    IF v_last_invoice_number IS NULL THEN
        v_next_number := v_starting_number;
    ELSE
        IF v_reset_annually AND v_last_invoice_number LIKE v_prefix || v_current_year || '-%' THEN
            v_last_number := SUBSTRING(v_last_invoice_number FROM LENGTH(v_prefix || v_current_year || '-') + 1)::int;
            v_next_number := v_last_number + 1;
        ELSIF NOT v_reset_annually AND v_last_invoice_number LIKE v_prefix || '%' THEN
            v_last_number := SUBSTRING(v_last_invoice_number FROM LENGTH(v_prefix) + 1)::int;
            v_next_number := v_last_number + 1;
        ELSE
            v_next_number := v_starting_number;
        END IF;
    END IF;

    IF v_reset_annually THEN
        v_new_invoice_number := v_prefix || v_current_year || '-' || LPAD(v_next_number::text, 4, '0');
    ELSE
        v_new_invoice_number := v_prefix || LPAD(v_next_number::text, 6, '0');
    END IF;

    RETURN v_new_invoice_number;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-generate quote number
CREATE OR REPLACE FUNCTION auto_generate_quote_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quote_number IS NULL OR NEW.quote_number = 'DRAFT' THEN
        NEW.quote_number := generate_quote_number(NEW.user_id);
    END IF;

    IF NEW.created_at IS NULL THEN
        NEW.created_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-generate invoice number
CREATE OR REPLACE FUNCTION auto_generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.invoice_number IS NULL OR NEW.invoice_number = 'DRAFT' THEN
        NEW.invoice_number := generate_invoice_number(NEW.user_id);
    END IF;

    IF NEW.created_at IS NULL THEN
        NEW.created_at := NOW();
    END IF;

    IF NEW.balance_due IS NULL THEN
        NEW.balance_due := COALESCE(NEW.total_ttc, 0) - COALESCE(NEW.amount_paid, 0);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        NOW(),
        NOW()
    );

    INSERT INTO public.settings (
        id,
        user_id,
        quote_prefix,
        invoice_prefix,
        quote_starting_number,
        invoice_starting_number,
        reset_numbering_annually,
        default_payment_terms_days,
        default_quote_validity_days,
        default_vat_rate,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        NEW.id,
        'DEV-',
        'FACT-',
        1,
        1,
        false,
        30,
        30,
        20.0,
        NOW(),
        NOW()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate invoice balance
CREATE OR REPLACE FUNCTION calculate_invoice_balance()
RETURNS TRIGGER AS $$
BEGIN
    NEW.balance_due := COALESCE(NEW.total_ttc, 0) - COALESCE(NEW.amount_paid, 0);

    IF NEW.balance_due <= 0 THEN
        NEW.payment_status := 'paid';
        IF NEW.paid_at IS NULL THEN
            NEW.paid_at := NOW();
        END IF;
    ELSIF NEW.amount_paid > 0 AND NEW.balance_due > 0 THEN
        NEW.payment_status := 'partial';
    ELSE
        NEW.payment_status := 'unpaid';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate document totals from line items
CREATE OR REPLACE FUNCTION calculate_document_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_subtotal_ht decimal := 0;
    v_total_vat decimal := 0;
    v_total_ttc decimal := 0;
    v_item jsonb;
    v_quantity decimal;
    v_unit_price decimal;
    v_vat_rate decimal;
    v_line_total_ht decimal;
    v_line_vat decimal;
BEGIN
    IF NEW.line_items IS NOT NULL THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(NEW.line_items)
        LOOP
            v_quantity := COALESCE((v_item->>'quantity')::decimal, 0);
            v_unit_price := COALESCE((v_item->>'unit_price')::decimal, 0);
            v_vat_rate := COALESCE((v_item->>'vat_rate')::decimal, 20.0);

            v_line_total_ht := v_quantity * v_unit_price;
            v_line_vat := v_line_total_ht * (v_vat_rate / 100);

            v_subtotal_ht := v_subtotal_ht + v_line_total_ht;
            v_total_vat := v_total_vat + v_line_vat;
        END LOOP;

        v_total_ttc := v_subtotal_ht + v_total_vat;

        IF NEW.total_discount IS NOT NULL AND NEW.total_discount > 0 THEN
            v_subtotal_ht := v_subtotal_ht - NEW.total_discount;
            v_total_ttc := v_subtotal_ht + v_total_vat;
        END IF;

        NEW.subtotal_ht := v_subtotal_ht;
        NEW.total_vat := v_total_vat;
        NEW.total_ttc := v_total_ttc;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update client totals
CREATE OR REPLACE FUNCTION update_client_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_client_id uuid;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_client_id := OLD.client_id;
    ELSE
        v_client_id := NEW.client_id;
    END IF;

    UPDATE clients
    SET
        total_invoiced = (
            SELECT COALESCE(SUM(total_ttc), 0)
            FROM invoices
            WHERE client_id = v_client_id
        ),
        outstanding_balance = (
            SELECT COALESCE(SUM(balance_due), 0)
            FROM invoices
            WHERE client_id = v_client_id
              AND payment_status != 'paid'
        )
    WHERE id = v_client_id;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate deposit amount
CREATE OR REPLACE FUNCTION calculate_deposit_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deposit_percentage IS NOT NULL AND NEW.deposit_percentage > 0 THEN
        NEW.deposit_amount := (NEW.total_ttc * NEW.deposit_percentage) / 100;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update product usage
CREATE OR REPLACE FUNCTION update_product_usage()
RETURNS TRIGGER AS $$
DECLARE
    item jsonb;
BEGIN
    FOR item IN SELECT * FROM jsonb_array_elements(NEW.line_items)
    LOOP
        IF item->>'product_id' IS NOT NULL THEN
            UPDATE products
            SET times_used = times_used + 1,
                last_used = NOW()
            WHERE id = (item->>'product_id')::uuid;
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 7: CREATE TRIGGERS
-- ============================================================================

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- Triggers for auto-generating numbers
CREATE TRIGGER trigger_auto_generate_quote_number
    BEFORE INSERT ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_quote_number();

CREATE TRIGGER trigger_auto_generate_invoice_number
    BEFORE INSERT ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_invoice_number();

-- Triggers for updating updated_at timestamp
CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_clients_modtime BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_products_modtime BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_quotes_modtime BEFORE UPDATE ON quotes FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_invoices_modtime BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_templates_modtime BEFORE UPDATE ON templates FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_purchases_modtime BEFORE UPDATE ON purchases FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_job_sites_modtime BEFORE UPDATE ON job_sites FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_job_site_notes_modtime BEFORE UPDATE ON job_site_notes FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_settings_modtime BEFORE UPDATE ON settings FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_stripe_subscriptions_modtime BEFORE UPDATE ON stripe_subscriptions FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Triggers for business logic
CREATE TRIGGER trigger_calculate_invoice_balance
    BEFORE INSERT OR UPDATE OF total_ttc, amount_paid ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION calculate_invoice_balance();

CREATE TRIGGER trigger_calculate_quote_totals
    BEFORE INSERT OR UPDATE OF line_items, total_discount ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION calculate_document_totals();

CREATE TRIGGER trigger_calculate_invoice_totals
    BEFORE INSERT OR UPDATE OF line_items, total_discount ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION calculate_document_totals();

CREATE TRIGGER trigger_update_client_totals
    AFTER INSERT OR UPDATE OR DELETE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION update_client_totals();

CREATE TRIGGER trigger_calculate_deposit
    BEFORE INSERT OR UPDATE OF total_ttc, deposit_percentage ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION calculate_deposit_amount();

CREATE TRIGGER update_product_usage_quotes
    AFTER INSERT ON quotes
    FOR EACH ROW EXECUTE FUNCTION update_product_usage();

CREATE TRIGGER update_product_usage_invoices
    AFTER INSERT ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_product_usage();

-- ============================================================================
-- STEP 8: ADD COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON FUNCTION generate_quote_number(uuid) IS 'Generates sequential quote numbers with custom prefix from user settings';
COMMENT ON FUNCTION generate_invoice_number(uuid) IS 'Generates sequential invoice numbers with custom prefix from user settings';
COMMENT ON FUNCTION auto_generate_quote_number() IS 'Trigger function to automatically generate quote numbers on insert';
COMMENT ON FUNCTION auto_generate_invoice_number() IS 'Trigger function to automatically generate invoice numbers on insert';
COMMENT ON FUNCTION handle_new_user() IS 'Automatically creates profile and settings when new user signs up';
COMMENT ON FUNCTION calculate_invoice_balance() IS 'Automatically calculates invoice balance and updates payment status';
COMMENT ON FUNCTION calculate_document_totals() IS 'Automatically calculates totals from line items for quotes and invoices';
COMMENT ON FUNCTION update_client_totals() IS 'Updates client total_invoiced and outstanding_balance when invoices change';
COMMENT ON FUNCTION calculate_deposit_amount() IS 'Calculates deposit amount based on deposit percentage';
COMMENT ON FUNCTION update_product_usage() IS 'Updates product usage statistics when used in quotes/invoices';

COMMENT ON TABLE job_site_documents IS 'Stores documents attached to job sites including PDFs, images, contracts, and invoices';
COMMENT ON COLUMN job_site_documents.document_type IS 'Type of document: invoice, quote, contract, photo, pdf, or other';
COMMENT ON COLUMN job_site_documents.file_size IS 'File size in bytes for display purposes';

-- ============================================================================
-- DATABASE RESET COMPLETE
-- ============================================================================
-- Next steps:
-- 1. Create storage buckets manually in Supabase Dashboard (see STORAGE_BUCKETS.md)
-- 2. Apply bucket policies (run supabase_bucket_policies.sql)
-- 3. Configure environment variables in app
-- 4. Deploy cloud functions
-- ============================================================================
