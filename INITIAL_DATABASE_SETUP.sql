-- ============================================================================
-- PlombiPro - Initial Database Setup (First Time Only)
-- ============================================================================
-- Use this script for FIRST-TIME database setup on a fresh Supabase project
-- For resetting an existing database, use COMPLETE_DATABASE_RESET.sql instead
-- ============================================================================
-- Date: 2025-11-06
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE ALL TABLES
-- ============================================================================

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
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
CREATE TABLE IF NOT EXISTS clients (
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
CREATE TABLE IF NOT EXISTS products (
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
CREATE TABLE IF NOT EXISTS quotes (
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
CREATE TABLE IF NOT EXISTS invoices (
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
CREATE TABLE IF NOT EXISTS payments (
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

-- Scans table
CREATE TABLE IF NOT EXISTS scans (
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
CREATE TABLE IF NOT EXISTS templates (
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
CREATE TABLE IF NOT EXISTS purchases (
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
CREATE TABLE IF NOT EXISTS job_sites (
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
CREATE TABLE IF NOT EXISTS job_site_photos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    photo_url text NOT NULL,
    photo_type text,
    caption text,
    uploaded_at timestamp DEFAULT NOW()
);

-- Job Site Tasks table
CREATE TABLE IF NOT EXISTS job_site_tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    task_description text NOT NULL,
    is_completed boolean DEFAULT false,
    completed_at timestamp,
    created_at timestamp DEFAULT NOW()
);

-- Job Site Time Logs table
CREATE TABLE IF NOT EXISTS job_site_time_logs (
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
CREATE TABLE IF NOT EXISTS job_site_notes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    job_site_id uuid REFERENCES job_sites(id) ON DELETE CASCADE,
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    note_text text NOT NULL,
    created_at timestamp DEFAULT NOW(),
    updated_at timestamp DEFAULT NOW()
);

-- Job Site Documents table
CREATE TABLE IF NOT EXISTS job_site_documents (
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
CREATE TABLE IF NOT EXISTS categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
    category_name text NOT NULL,
    parent_category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
    order_index int DEFAULT 0,
    created_at timestamp DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
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
CREATE TABLE IF NOT EXISTS settings (
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
CREATE TABLE IF NOT EXISTS stripe_subscriptions (
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

-- Now source the rest from the other files
-- You can run these in order:
-- 1. This file (INITIAL_DATABASE_SETUP.sql) - Creates tables
-- 2. Run indexes and RLS from COMPLETE_DATABASE_RESET.sql (starting from STEP 3)
-- Or just continue below...

-- ============================================================================
-- Note: To complete the setup, also run:
-- 1. Indexes (see COMPLETE_DATABASE_RESET.sql STEP 3)
-- 2. RLS Policies (see COMPLETE_DATABASE_RESET.sql STEP 4-5)
-- 3. Functions (see COMPLETE_DATABASE_RESET.sql STEP 6)
-- 4. Triggers (see COMPLETE_DATABASE_RESET.sql STEP 7)
-- 5. Storage bucket policies (see supabase_bucket_policies.sql)
-- ============================================================================
