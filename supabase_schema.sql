
-- Create the "profiles" table
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id),
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
    created_at timestamp,
    updated_at timestamp
);

-- Create the "clients" table
CREATE TABLE clients (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
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
    country text,
    billing_address text,
    billing_postal_code text,
    billing_city text,
    siret text,
    vat_number text,
    default_payment_terms int,
    default_discount decimal,
    tags text[],
    is_favorite boolean,
    notes text,
    total_invoiced decimal,
    outstanding_balance decimal,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "products" table
CREATE TABLE products (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    reference text,
    name text NOT NULL,
    description text,
    category text,
    supplier_name text,
    supplier_reference text,
    purchase_price_ht decimal,
    margin_percentage decimal,
    selling_price_ht decimal,
    vat_rate decimal DEFAULT 20.0,
    unit text DEFAULT 'unit',
    stock_quantity int,
    reorder_point int,
    image_urls text[],
    notes text,
    is_favorite boolean,
    is_active boolean DEFAULT true,
    tags text[],
    source text,
    last_used timestamp,
    times_used int DEFAULT 0,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "quotes" table
CREATE TABLE quotes (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    client_id uuid REFERENCES clients(id),
    quote_number text UNIQUE,
    quote_date date DEFAULT CURRENT_DATE,
    validity_days int DEFAULT 30,
    expiry_date date,
    status text,
    job_site_address text,
    reference_description text,
    line_items jsonb,
    subtotal_ht decimal,
    total_discount decimal,
    total_vat decimal,
    total_ttc decimal,
    deposit_percentage decimal,
    deposit_amount decimal,
    terms_conditions text,
    notes text,
    pdf_url text,
    signature_url text,
    signed_at timestamp,
    sent_at timestamp,
    accepted_at timestamp,
    converted_to_invoice_id uuid,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "invoices" table
CREATE TABLE invoices (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    client_id uuid REFERENCES clients(id),
    related_quote_id uuid REFERENCES quotes(id),
    invoice_number text UNIQUE,
    invoice_type text,
    invoice_date date DEFAULT CURRENT_DATE,
    due_date date,
    payment_terms text,
    payment_methods_accepted text[],
    job_site_address text,
    reference_description text,
    line_items jsonb,
    subtotal_ht decimal,
    total_discount decimal,
    total_vat decimal,
    total_ttc decimal,
    amount_paid decimal DEFAULT 0,
    balance_due decimal,
    payment_status text,
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
    created_at timestamp,
    updated_at timestamp
);

-- Create the "payments" table
CREATE TABLE payments (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    invoice_id uuid REFERENCES invoices(id),
    payment_date date,
    amount decimal,
    payment_method text,
    transaction_reference text,
    stripe_payment_id text,
    notes text,
    receipt_url text,
    is_reconciled boolean DEFAULT false,
    created_at timestamp
);

-- Create the "scans" table
CREATE TABLE scans (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    scan_type text,
    original_image_url text,
    scan_date timestamp DEFAULT CURRENT_TIMESTAMP,
    extraction_status text,
    extracted_data jsonb,
    reviewed boolean DEFAULT false,
    converted_to_purchase boolean DEFAULT false,
    purchase_id uuid,
    generated_quote_id uuid REFERENCES quotes(id),
    created_at timestamp
);

-- Create the "templates" table
CREATE TABLE templates (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    template_name text NOT NULL,
    template_type text,
    category text,
    line_items jsonb,
    terms_conditions text,
    is_system_template boolean DEFAULT false,
    times_used int DEFAULT 0,
    last_used timestamp,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "purchases" table
CREATE TABLE purchases (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    supplier_name text,
    invoice_number text,
    invoice_date date,
    due_date date,
    line_items jsonb,
    subtotal_ht decimal,
    total_vat decimal,
    total_ttc decimal,
    payment_status text,
    payment_method text,
    job_site_id uuid,
    scan_id uuid,
    invoice_image_url text,
    notes text,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "job_sites" table
CREATE TABLE job_sites (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    client_id uuid REFERENCES clients(id),
    job_name text NOT NULL,
    reference_number text,
    address text,
    contact_person text,
    contact_phone text,
    description text,
    start_date date,
    estimated_end_date date,
    actual_end_date date,
    status text,
    progress_percentage int DEFAULT 0,
    related_quote_id uuid REFERENCES quotes(id),
    estimated_budget decimal,
    actual_cost decimal,
    profit_margin decimal,
    notes text,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "job_site_photos" table
CREATE TABLE job_site_photos (
    id uuid PRIMARY KEY,
    job_site_id uuid REFERENCES job_sites(id),
    photo_url text,
    photo_type text,
    caption text,
    uploaded_at timestamp
);

-- Create the "job_site_tasks" table
CREATE TABLE job_site_tasks (
    id uuid PRIMARY KEY,
    job_site_id uuid REFERENCES job_sites(id),
    task_description text,
    is_completed boolean DEFAULT false,
    completed_at timestamp,
    created_at timestamp
);

-- Create the "job_site_time_logs" table
CREATE TABLE job_site_time_logs (
    id uuid PRIMARY KEY,
    job_site_id uuid REFERENCES job_sites(id),
    user_id uuid REFERENCES profiles(id),
    log_date date,
    hours_worked decimal,
    description text,
    hourly_rate decimal,
    labor_cost decimal,
    created_at timestamp
);

-- Create the "job_site_notes" table
CREATE TABLE job_site_notes (
    id uuid PRIMARY KEY,
    job_site_id uuid REFERENCES job_sites(id),
    user_id uuid REFERENCES profiles(id),
    note_text text,
    created_at timestamp,
    updated_at timestamp
);

-- Create the "categories" table
CREATE TABLE categories (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    category_name text NOT NULL,
    parent_category_id uuid REFERENCES categories(id),
    order_index int,
    created_at timestamp
);

-- Create the "notifications" table
CREATE TABLE notifications (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    notification_type text,
    title text,
    message text,
    link_url text,
    is_read boolean DEFAULT false,
    created_at timestamp
);

-- Create the "settings" table
CREATE TABLE settings (
    id uuid PRIMARY KEY,
    user_id uuid UNIQUE REFERENCES profiles(id),
    invoice_prefix text DEFAULT 'FACT-',
    quote_prefix text DEFAULT 'DEV-',
    invoice_starting_number int DEFAULT 1,
    quote_starting_number int DEFAULT 1,
    reset_numbering_annually boolean DEFAULT false,
    default_payment_terms_days int DEFAULT 30,
    default_quote_validity_days int DEFAULT 30,
    default_vat_rate decimal DEFAULT 20.0,
    late_payment_interest_rate decimal,
    default_quote_footer text,
    default_invoice_footer text,
    enable_facturx boolean DEFAULT false,
    chorus_pro_enabled boolean DEFAULT false,
    chorus_pro_credentials jsonb,
    email_notifications jsonb,
    sms_notifications jsonb,
    theme text DEFAULT 'light',
    language text DEFAULT 'fr',
    created_at timestamp,
    updated_at timestamp
);

-- Create the "stripe_subscriptions" table
CREATE TABLE stripe_subscriptions (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES profiles(id),
    stripe_customer_id text,
    stripe_subscription_id text,
    plan_id text,
    status text,
    current_period_start timestamp,
    current_period_end timestamp,
    cancel_at_period_end boolean,
    created_at timestamp,
    updated_at timestamp
);

-- RLS policies for all tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own clients." ON clients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own clients." ON clients FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own clients." ON clients FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own clients." ON clients FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own products." ON products FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own products." ON products FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own products." ON products FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own products." ON products FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own quotes." ON quotes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own quotes." ON quotes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own quotes." ON quotes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own quotes." ON quotes FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own invoices." ON invoices FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own invoices." ON invoices FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own invoices." ON invoices FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own invoices." ON invoices FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own payments." ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own payments." ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own payments." ON payments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own payments." ON payments FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own scans." ON scans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own scans." ON scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own scans." ON scans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own scans." ON scans FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own templates." ON templates FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own templates." ON templates FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own templates." ON templates FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own templates." ON templates FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own purchases." ON purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own purchases." ON purchases FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own purchases." ON purchases FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own purchases." ON purchases FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE job_sites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own job sites." ON job_sites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job sites." ON job_sites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job sites." ON job_sites FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job sites." ON job_sites FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE job_site_photos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own job site photos." ON job_site_photos FOR SELECT USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can insert their own job site photos." ON job_site_photos FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can update their own job site photos." ON job_site_photos FOR UPDATE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can delete their own job site photos." ON job_site_photos FOR DELETE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));

ALTER TABLE job_site_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own job site tasks." ON job_site_tasks FOR SELECT USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can insert their own job site tasks." ON job_site_tasks FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can update their own job site tasks." ON job_site_tasks FOR UPDATE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));
CREATE POLICY "Users can delete their own job site tasks." ON job_site_tasks FOR DELETE USING (auth.uid() = (SELECT user_id FROM job_sites WHERE id = job_site_id));

ALTER TABLE job_site_time_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own job site time logs." ON job_site_time_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job site time logs." ON job_site_time_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job site time logs." ON job_site_time_logs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job site time logs." ON job_site_time_logs FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE job_site_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own job site notes." ON job_site_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own job site notes." ON job_site_notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own job site notes." ON job_site_notes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own job site notes." ON job_site_notes FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own categories." ON categories FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own categories." ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own categories." ON categories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own categories." ON categories FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own notifications." ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own notifications." ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications." ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications." ON notifications FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own settings." ON settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own settings." ON settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own settings." ON settings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own settings." ON settings FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE stripe_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own stripe subscriptions." ON stripe_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own stripe subscriptions." ON stripe_subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own stripe subscriptions." ON stripe_subscriptions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own stripe subscriptions." ON stripe_subscriptions FOR DELETE USING (auth.uid() = user_id);


-- Functions and Triggers
CREATE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at column
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


CREATE FUNCTION update_product_usage()
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

CREATE TRIGGER update_product_usage_quotes
AFTER INSERT ON quotes
FOR EACH ROW EXECUTE FUNCTION update_product_usage();

CREATE TRIGGER update_product_usage_invoices
AFTER INSERT ON invoices
FOR EACH ROW EXECUTE FUNCTION update_product_usage();
