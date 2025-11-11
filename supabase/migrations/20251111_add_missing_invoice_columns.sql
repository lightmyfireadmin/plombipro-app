-- Add missing invoice_number column to invoices table
-- This column is needed for the invoice numbering system

DO $$
BEGIN
    -- Add invoice_number column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'invoice_number'
    ) THEN
        ALTER TABLE invoices ADD COLUMN invoice_number TEXT UNIQUE;
        RAISE NOTICE 'Added invoice_number column to invoices table';
    END IF;

    -- Add payment_method column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'payment_method'
    ) THEN
        ALTER TABLE invoices ADD COLUMN payment_method TEXT;
        RAISE NOTICE 'Added payment_method column to invoices table';
    END IF;

    -- Add subtotal_ht column if it doesn't exist (might be named total_ht)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'subtotal_ht'
    ) THEN
        -- Check if total_ht exists and rename it
        IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'invoices' AND column_name = 'total_ht'
        ) THEN
            ALTER TABLE invoices RENAME COLUMN total_ht TO subtotal_ht;
            RAISE NOTICE 'Renamed total_ht to subtotal_ht in invoices table';
        ELSE
            ALTER TABLE invoices ADD COLUMN subtotal_ht DECIMAL(10,2) DEFAULT 0;
            RAISE NOTICE 'Added subtotal_ht column to invoices table';
        END IF;
    END IF;

    -- Add total_vat column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'total_vat'
    ) THEN
        ALTER TABLE invoices ADD COLUMN total_vat DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Added total_vat column to invoices table';
    END IF;

    -- Add payment_date column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'payment_date'
    ) THEN
        ALTER TABLE invoices ADD COLUMN payment_date DATE;
        RAISE NOTICE 'Added payment_date column to invoices table';
    END IF;

    -- Add legal_mentions column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'legal_mentions'
    ) THEN
        ALTER TABLE invoices ADD COLUMN legal_mentions TEXT;
        RAISE NOTICE 'Added legal_mentions column to invoices table';
    END IF;

    -- Add status column if it doesn't exist (distinct from payment_status)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'status'
    ) THEN
        ALTER TABLE invoices ADD COLUMN status TEXT;
        RAISE NOTICE 'Added status column to invoices table';
    END IF;

END $$;
