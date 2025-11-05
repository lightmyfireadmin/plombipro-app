-- Migration: Remaining Database Triggers
-- Date: 2025-11-05
-- Purpose: Implement auto-create profile, auto-calculate totals, and balance updates

-- ============================================================================
-- 1. Auto-create profile on user signup
-- ============================================================================

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

    -- Also create default settings for the new user
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

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- 2. Auto-calculate invoice balance
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_invoice_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate balance_due based on total_ttc and amount_paid
    NEW.balance_due := COALESCE(NEW.total_ttc, 0) - COALESCE(NEW.amount_paid, 0);

    -- Update payment status based on balance
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

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_calculate_invoice_balance ON invoices;

-- Create trigger for invoices
CREATE TRIGGER trigger_calculate_invoice_balance
    BEFORE INSERT OR UPDATE OF total_ttc, amount_paid ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION calculate_invoice_balance();

-- ============================================================================
-- 3. Auto-calculate quote/invoice totals from line items
-- ============================================================================

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
    -- Only calculate if line_items is not null
    IF NEW.line_items IS NOT NULL THEN
        -- Loop through each line item and calculate totals
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

        -- Apply discount if present
        IF NEW.total_discount IS NOT NULL AND NEW.total_discount > 0 THEN
            v_subtotal_ht := v_subtotal_ht - NEW.total_discount;
            v_total_ttc := v_subtotal_ht + v_total_vat;
        END IF;

        -- Update the totals
        NEW.subtotal_ht := v_subtotal_ht;
        NEW.total_vat := v_total_vat;
        NEW.total_ttc := v_total_ttc;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS trigger_calculate_quote_totals ON quotes;
DROP TRIGGER IF EXISTS trigger_calculate_invoice_totals ON invoices;

-- Create trigger for quotes
CREATE TRIGGER trigger_calculate_quote_totals
    BEFORE INSERT OR UPDATE OF line_items, total_discount ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION calculate_document_totals();

-- Create trigger for invoices
CREATE TRIGGER trigger_calculate_invoice_totals
    BEFORE INSERT OR UPDATE OF line_items, total_discount ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION calculate_document_totals();

-- ============================================================================
-- 4. Update client totals when invoices change
-- ============================================================================

CREATE OR REPLACE FUNCTION update_client_totals()
RETURNS TRIGGER AS $$
DECLARE
    v_client_id uuid;
BEGIN
    -- Get the client_id (works for both INSERT/UPDATE and DELETE)
    IF TG_OP = 'DELETE' THEN
        v_client_id := OLD.client_id;
    ELSE
        v_client_id := NEW.client_id;
    END IF;

    -- Recalculate totals for the client
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

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_update_client_totals ON invoices;

-- Create trigger
CREATE TRIGGER trigger_update_client_totals
    AFTER INSERT OR UPDATE OR DELETE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION update_client_totals();

-- ============================================================================
-- 5. Calculate deposit amount when deposit percentage is set
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_deposit_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deposit_percentage IS NOT NULL AND NEW.deposit_percentage > 0 THEN
        NEW.deposit_amount := (NEW.total_ttc * NEW.deposit_percentage) / 100;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_calculate_deposit ON quotes;

-- Create trigger
CREATE TRIGGER trigger_calculate_deposit
    BEFORE INSERT OR UPDATE OF total_ttc, deposit_percentage ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION calculate_deposit_amount();

-- ============================================================================
-- Indexes for performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_invoices_client_payment ON invoices(client_id, payment_status);
CREATE INDEX IF NOT EXISTS idx_invoices_client_balance ON invoices(client_id, balance_due) WHERE payment_status != 'paid';

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON FUNCTION handle_new_user() IS 'Automatically creates profile and settings when new user signs up';
COMMENT ON FUNCTION calculate_invoice_balance() IS 'Automatically calculates invoice balance and updates payment status';
COMMENT ON FUNCTION calculate_document_totals() IS 'Automatically calculates totals from line items for quotes and invoices';
COMMENT ON FUNCTION update_client_totals() IS 'Updates client total_invoiced and outstanding_balance when invoices change';
COMMENT ON FUNCTION calculate_deposit_amount() IS 'Calculates deposit amount based on deposit percentage';
