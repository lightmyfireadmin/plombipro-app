-- Add missing product columns that the Flutter app expects
-- The app uses ref and supplier, but database has reference and supplier_name

DO $$
BEGIN
    -- Add ref column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'ref'
    ) THEN
        -- If reference exists, copy data to ref
        IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'products' AND column_name = 'reference'
        ) THEN
            ALTER TABLE products ADD COLUMN ref TEXT;
            UPDATE products SET ref = reference WHERE reference IS NOT NULL;
            RAISE NOTICE 'Added ref column and copied data from reference';
        ELSE
            ALTER TABLE products ADD COLUMN ref TEXT;
            RAISE NOTICE 'Added ref column to products table';
        END IF;
    END IF;

    -- Add supplier column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'supplier'
    ) THEN
        -- If supplier_name exists, copy data to supplier
        IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'products' AND column_name = 'supplier_name'
        ) THEN
            ALTER TABLE products ADD COLUMN supplier TEXT;
            UPDATE products SET supplier = supplier_name WHERE supplier_name IS NOT NULL;
            RAISE NOTICE 'Added supplier column and copied data from supplier_name';
        ELSE
            ALTER TABLE products ADD COLUMN supplier TEXT;
            RAISE NOTICE 'Added supplier column to products table';
        END IF;
    END IF;

    -- Add purchase_price_ht if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'purchase_price_ht'
    ) THEN
        ALTER TABLE products ADD COLUMN purchase_price_ht DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Added purchase_price_ht column to products table';
    END IF;

    -- Add selling_price_ht if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'selling_price_ht'
    ) THEN
        ALTER TABLE products ADD COLUMN selling_price_ht DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Added selling_price_ht column to products table';
    END IF;

END $$;
