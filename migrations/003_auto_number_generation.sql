-- Migration: Auto-generate quote and invoice numbers
-- Date: 2025-11-05
-- Purpose: Implement sequential numbering with custom prefixes for quotes and invoices

-- Function to generate next quote number
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
    -- Get user settings
    SELECT
        COALESCE(quote_prefix, 'DEV-'),
        COALESCE(quote_starting_number, 1),
        COALESCE(reset_numbering_annually, false)
    INTO v_prefix, v_starting_number, v_reset_annually
    FROM settings
    WHERE user_id = p_user_id;

    -- If no settings exist, use defaults
    IF v_prefix IS NULL THEN
        v_prefix := 'DEV-';
        v_starting_number := 1;
        v_reset_annually := false;
    END IF;

    v_current_year := TO_CHAR(CURRENT_DATE, 'YYYY');

    -- Get the last quote number for this user
    SELECT quote_number INTO v_last_quote_number
    FROM quotes
    WHERE user_id = p_user_id
      AND quote_number IS NOT NULL
      AND quote_number != 'DRAFT'
    ORDER BY created_at DESC, quote_number DESC
    LIMIT 1;

    -- If no previous quotes, start with the starting number
    IF v_last_quote_number IS NULL THEN
        v_next_number := v_starting_number;
    ELSE
        -- Extract the numeric part from the last quote number
        -- Expected format: PREFIX-YYYY-NNNN or PREFIX-NNNN
        IF v_reset_annually AND v_last_quote_number LIKE v_prefix || v_current_year || '-%' THEN
            -- Extract number after year
            v_last_number := SUBSTRING(v_last_quote_number FROM LENGTH(v_prefix || v_current_year || '-') + 1)::int;
            v_next_number := v_last_number + 1;
        ELSIF NOT v_reset_annually AND v_last_quote_number LIKE v_prefix || '%' THEN
            -- Extract number after prefix (without year)
            v_last_number := SUBSTRING(v_last_quote_number FROM LENGTH(v_prefix) + 1)::int;
            v_next_number := v_last_number + 1;
        ELSE
            -- Different year or different format, reset to starting number
            v_next_number := v_starting_number;
        END IF;
    END IF;

    -- Generate the new quote number
    IF v_reset_annually THEN
        v_new_quote_number := v_prefix || v_current_year || '-' || LPAD(v_next_number::text, 4, '0');
    ELSE
        v_new_quote_number := v_prefix || LPAD(v_next_number::text, 6, '0');
    END IF;

    RETURN v_new_quote_number;
END;
$$ LANGUAGE plpgsql;

-- Function to generate next invoice number
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
    -- Get user settings
    SELECT
        COALESCE(invoice_prefix, 'FACT-'),
        COALESCE(invoice_starting_number, 1),
        COALESCE(reset_numbering_annually, false)
    INTO v_prefix, v_starting_number, v_reset_annually
    FROM settings
    WHERE user_id = p_user_id;

    -- If no settings exist, use defaults
    IF v_prefix IS NULL THEN
        v_prefix := 'FACT-';
        v_starting_number := 1;
        v_reset_annually := false;
    END IF;

    v_current_year := TO_CHAR(CURRENT_DATE, 'YYYY');

    -- Get the last invoice number for this user
    SELECT invoice_number INTO v_last_invoice_number
    FROM invoices
    WHERE user_id = p_user_id
      AND invoice_number IS NOT NULL
      AND invoice_number != 'DRAFT'
    ORDER BY created_at DESC, invoice_number DESC
    LIMIT 1;

    -- If no previous invoices, start with the starting number
    IF v_last_invoice_number IS NULL THEN
        v_next_number := v_starting_number;
    ELSE
        -- Extract the numeric part from the last invoice number
        -- Expected format: PREFIX-YYYY-NNNN or PREFIX-NNNN
        IF v_reset_annually AND v_last_invoice_number LIKE v_prefix || v_current_year || '-%' THEN
            -- Extract number after year
            v_last_number := SUBSTRING(v_last_invoice_number FROM LENGTH(v_prefix || v_current_year || '-') + 1)::int;
            v_next_number := v_last_number + 1;
        ELSIF NOT v_reset_annually AND v_last_invoice_number LIKE v_prefix || '%' THEN
            -- Extract number after prefix (without year)
            v_last_number := SUBSTRING(v_last_invoice_number FROM LENGTH(v_prefix) + 1)::int;
            v_next_number := v_last_number + 1;
        ELSE
            -- Different year or different format, reset to starting number
            v_next_number := v_starting_number;
        END IF;
    END IF;

    -- Generate the new invoice number
    IF v_reset_annually THEN
        v_new_invoice_number := v_prefix || v_current_year || '-' || LPAD(v_next_number::text, 4, '0');
    ELSE
        v_new_invoice_number := v_prefix || LPAD(v_next_number::text, 6, '0');
    END IF;

    RETURN v_new_invoice_number;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-generate quote number before insert
CREATE OR REPLACE FUNCTION auto_generate_quote_number()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate if quote_number is NULL or 'DRAFT'
    IF NEW.quote_number IS NULL OR NEW.quote_number = 'DRAFT' THEN
        NEW.quote_number := generate_quote_number(NEW.user_id);
    END IF;

    -- Set created_at if not set
    IF NEW.created_at IS NULL THEN
        NEW.created_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to auto-generate invoice number before insert
CREATE OR REPLACE FUNCTION auto_generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate if invoice_number is NULL or 'DRAFT'
    IF NEW.invoice_number IS NULL OR NEW.invoice_number = 'DRAFT' THEN
        NEW.invoice_number := generate_invoice_number(NEW.user_id);
    END IF;

    -- Set created_at if not set
    IF NEW.created_at IS NULL THEN
        NEW.created_at := NOW();
    END IF;

    -- Calculate balance_due if not set
    IF NEW.balance_due IS NULL THEN
        NEW.balance_due := COALESCE(NEW.total_ttc, 0) - COALESCE(NEW.amount_paid, 0);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS trigger_auto_generate_quote_number ON quotes;
DROP TRIGGER IF EXISTS trigger_auto_generate_invoice_number ON invoices;

-- Create triggers
CREATE TRIGGER trigger_auto_generate_quote_number
    BEFORE INSERT ON quotes
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_quote_number();

CREATE TRIGGER trigger_auto_generate_invoice_number
    BEFORE INSERT ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_invoice_number();

-- Add index for better performance on number generation
CREATE INDEX IF NOT EXISTS idx_quotes_user_number ON quotes(user_id, quote_number);
CREATE INDEX IF NOT EXISTS idx_invoices_user_number ON invoices(user_id, invoice_number);

-- Comments for documentation
COMMENT ON FUNCTION generate_quote_number(uuid) IS 'Generates sequential quote numbers with custom prefix from user settings';
COMMENT ON FUNCTION generate_invoice_number(uuid) IS 'Generates sequential invoice numbers with custom prefix from user settings';
COMMENT ON FUNCTION auto_generate_quote_number() IS 'Trigger function to automatically generate quote numbers on insert';
COMMENT ON FUNCTION auto_generate_invoice_number() IS 'Trigger function to automatically generate invoice numbers on insert';
