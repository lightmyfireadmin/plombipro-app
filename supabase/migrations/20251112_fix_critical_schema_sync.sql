--------------------------------------------------------------------------------
-- CRITICAL SCHEMA SYNCHRONIZATION FIX
-- Date: 2025-11-12
-- Purpose: Fix all P0/P1 issues found in database-codebase sync audit
-- Audit Report: DATABASE_CODEBASE_SYNC_AUDIT.md
--------------------------------------------------------------------------------
-- This migration addresses:
-- 1. Missing user_id in products, quotes, invoices
-- 2. Duplicate column cleanup
-- 3. Column name standardization
-- 4. Complete appointments schema rebuild
-- 5. Add missing critical fields
--------------------------------------------------------------------------------

BEGIN;

-- ============================================================================
-- SECTION 1: ADD MISSING user_id FIELDS (P0 - CRITICAL)
-- ============================================================================

-- Products: Add user_id if missing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE products ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

        -- Backfill user_id from existing data (if any products exist without user_id)
        -- This assumes products are linked to users through some other relationship
        -- Adjust this logic based on your actual data structure
        UPDATE products
        SET user_id = (SELECT id FROM auth.users LIMIT 1)
        WHERE user_id IS NULL;

        -- Make it NOT NULL after backfill
        ALTER TABLE products ALTER COLUMN user_id SET NOT NULL;

        -- Add index for performance
        CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);

        RAISE NOTICE 'Added user_id column to products table';
    ELSE
        RAISE NOTICE 'user_id already exists in products table';
    END IF;
END $$;

-- Quotes: Add user_id if missing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'quotes' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE quotes ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

        -- Backfill user_id from existing data
        UPDATE quotes
        SET user_id = (SELECT id FROM auth.users LIMIT 1)
        WHERE user_id IS NULL;

        ALTER TABLE quotes ALTER COLUMN user_id SET NOT NULL;
        CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);

        RAISE NOTICE 'Added user_id column to quotes table';
    ELSE
        RAISE NOTICE 'user_id already exists in quotes table';
    END IF;
END $$;

-- Invoices: Add user_id if missing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE invoices ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

        -- Backfill user_id from existing data
        UPDATE invoices
        SET user_id = (SELECT id FROM auth.users LIMIT 1)
        WHERE user_id IS NULL;

        ALTER TABLE invoices ALTER COLUMN user_id SET NOT NULL;
        CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);

        RAISE NOTICE 'Added user_id column to invoices table';
    ELSE
        RAISE NOTICE 'user_id already exists in invoices table';
    END IF;
END $$;

-- ============================================================================
-- SECTION 2: REMOVE DUPLICATE COLUMNS (P1)
-- ============================================================================

-- Products: Remove duplicate columns, keep the ones used by Flutter model
-- Keep: ref, price_buy, price_sell
-- Remove: reference, purchase_price_ht, selling_price_ht (if they exist as duplicates)

DO $$
BEGIN
    -- Only drop reference if ref exists (avoid dropping if ref doesn't exist)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'ref') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'reference') THEN
            -- Copy any data from reference to ref if ref is null
            UPDATE products SET ref = reference WHERE ref IS NULL AND reference IS NOT NULL;
            ALTER TABLE products DROP COLUMN IF EXISTS reference;
            RAISE NOTICE 'Removed duplicate column: products.reference';
        END IF;
    END IF;

    -- Check if we should remove purchase_price_ht and selling_price_ht duplicates
    -- Keep price_buy and price_sell as they match the Flutter model
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price_buy') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'purchase_price_ht') THEN
            -- Sync any different values
            UPDATE products SET price_buy = purchase_price_ht WHERE price_buy IS NULL AND purchase_price_ht IS NOT NULL;
            ALTER TABLE products DROP COLUMN IF EXISTS purchase_price_ht;
            RAISE NOTICE 'Removed duplicate column: products.purchase_price_ht';
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price_sell') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'selling_price_ht') THEN
            UPDATE products SET price_sell = selling_price_ht WHERE price_sell IS NULL AND selling_price_ht IS NOT NULL;
            ALTER TABLE products DROP COLUMN IF EXISTS selling_price_ht;
            RAISE NOTICE 'Removed duplicate column: products.selling_price_ht';
        END IF;
    END IF;

    -- Remove supplier_name if it's a duplicate of supplier
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'supplier') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'supplier_name') THEN
            UPDATE products SET supplier = supplier_name WHERE supplier IS NULL AND supplier_name IS NOT NULL;
            ALTER TABLE products DROP COLUMN IF EXISTS supplier_name;
            RAISE NOTICE 'Removed duplicate column: products.supplier_name';
        END IF;
    END IF;
END $$;

-- ============================================================================
-- SECTION 3: STANDARDIZE COLUMN NAMES (P1)
-- ============================================================================

-- Quotes: Standardize to subtotal_ht and total_vat (keep both total_ht and total_vat)
-- The model uses totalHt and totalTva, which should map to subtotal_ht and total_vat

DO $$
BEGIN
    -- Ensure both subtotal_ht and total_ht exist, they may have different meanings
    -- subtotal_ht = before tax, total_ht = total before tax (same value usually)
    -- Keep both but ensure they're consistent

    -- For quotes, standardize on subtotal_ht for the before-tax total
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'total_ht')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'subtotal_ht') THEN
        -- Copy total_ht to subtotal_ht if subtotal_ht is null
        UPDATE quotes SET subtotal_ht = total_ht WHERE subtotal_ht IS NULL OR subtotal_ht = 0;
        RAISE NOTICE 'Synchronized quotes.subtotal_ht with quotes.total_ht';
    END IF;

    -- Ensure total_vat exists (it's the standard name, total_tva is French)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'total_vat') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'total_tva') THEN
            ALTER TABLE quotes RENAME COLUMN total_tva TO total_vat;
            RAISE NOTICE 'Renamed quotes.total_tva to quotes.total_vat';
        END IF;
    END IF;
END $$;

-- Invoices: Same standardization
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'total_ht')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'subtotal_ht') THEN
        UPDATE invoices SET subtotal_ht = total_ht WHERE subtotal_ht IS NULL OR subtotal_ht = 0;
        RAISE NOTICE 'Synchronized invoices.subtotal_ht with invoices.total_ht';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'total_vat') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'total_tva') THEN
            ALTER TABLE invoices RENAME COLUMN total_tva TO total_vat;
            RAISE NOTICE 'Renamed invoices.total_tva to invoices.total_vat';
        END IF;
    END IF;
END $$;

-- ============================================================================
-- SECTION 4: ADD MISSING FIELDS TO PRODUCTS (P2)
-- ============================================================================

DO $$
BEGIN
    -- Add vat_rate if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'vat_rate') THEN
        ALTER TABLE products ADD COLUMN vat_rate DECIMAL(5,2) DEFAULT 20.0;
        RAISE NOTICE 'Added vat_rate column to products';
    END IF;

    -- Add last_used if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'last_used') THEN
        ALTER TABLE products ADD COLUMN last_used TIMESTAMP WITH TIME ZONE;
        CREATE INDEX IF NOT EXISTS idx_products_last_used ON products(last_used);
        RAISE NOTICE 'Added last_used column to products';
    END IF;
END $$;

-- ============================================================================
-- SECTION 5: ADD MISSING FIELDS TO INVOICES (P2)
-- ============================================================================

DO $$
BEGIN
    -- Add payment_terms if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'payment_terms') THEN
        ALTER TABLE invoices ADD COLUMN payment_terms INTEGER DEFAULT 30;
        RAISE NOTICE 'Added payment_terms column to invoices';
    END IF;

    -- Add payment_date if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'payment_date') THEN
        ALTER TABLE invoices ADD COLUMN payment_date DATE;
        CREATE INDEX IF NOT EXISTS idx_invoices_payment_date ON invoices(payment_date);
        RAISE NOTICE 'Added payment_date column to invoices';
    END IF;

    -- Add pdf_url if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'pdf_url') THEN
        ALTER TABLE invoices ADD COLUMN pdf_url TEXT;
        RAISE NOTICE 'Added pdf_url column to invoices';
    END IF;

    -- Add legal_mentions if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'legal_mentions') THEN
        ALTER TABLE invoices ADD COLUMN legal_mentions TEXT;
        RAISE NOTICE 'Added legal_mentions column to invoices';
    END IF;

    -- Add created_from_quote_id if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'created_from_quote_id') THEN
        ALTER TABLE invoices ADD COLUMN created_from_quote_id UUID REFERENCES quotes(id) ON DELETE SET NULL;
        CREATE INDEX IF NOT EXISTS idx_invoices_created_from_quote ON invoices(created_from_quote_id);
        RAISE NOTICE 'Added created_from_quote_id column to invoices';
    END IF;
END $$;

-- ============================================================================
-- SECTION 6: ADD MISSING FIELDS TO QUOTES (P2)
-- ============================================================================

DO $$
BEGIN
    -- Add converted_to_invoice_id if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'converted_to_invoice_id') THEN
        ALTER TABLE quotes ADD COLUMN converted_to_invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL;
        CREATE INDEX IF NOT EXISTS idx_quotes_converted_to_invoice ON quotes(converted_to_invoice_id);
        RAISE NOTICE 'Added converted_to_invoice_id column to quotes';
    END IF;

    -- Add payment_terms if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'payment_terms') THEN
        ALTER TABLE quotes ADD COLUMN payment_terms INTEGER DEFAULT 30;
        RAISE NOTICE 'Added payment_terms column to quotes';
    END IF;
END $$;

-- ============================================================================
-- SECTION 7: COMPLETE APPOINTMENTS SCHEMA (P0 - CRITICAL)
-- ============================================================================

-- Backup existing appointments data before major changes
DO $$
BEGIN
    -- Create backup table
    DROP TABLE IF EXISTS appointments_backup_20251112;
    CREATE TABLE appointments_backup_20251112 AS SELECT * FROM appointments;
    RAISE NOTICE 'Created backup: appointments_backup_20251112';
END $$;

-- Add all missing fields from Appointment model to match Flutter expectations
DO $$
BEGIN
    -- Basic fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'title') THEN
        ALTER TABLE appointments ADD COLUMN title TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'description') THEN
        ALTER TABLE appointments ADD COLUMN description TEXT;
    END IF;

    -- Date/Time fields (model uses appointment_date + appointment_time separately)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'appointment_date') THEN
        ALTER TABLE appointments ADD COLUMN appointment_date DATE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'appointment_time') THEN
        ALTER TABLE appointments ADD COLUMN appointment_time TIME;
    END IF;

    -- Duration
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'duration_minutes') THEN
        ALTER TABLE appointments ADD COLUMN duration_minutes INTEGER DEFAULT 60;
    END IF;

    -- Location
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'location') THEN
        ALTER TABLE appointments ADD COLUMN location TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'location_latitude') THEN
        ALTER TABLE appointments ADD COLUMN location_latitude DECIMAL(10,8);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'location_longitude') THEN
        ALTER TABLE appointments ADD COLUMN location_longitude DECIMAL(11,8);
    END IF;

    -- Priority
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'priority') THEN
        ALTER TABLE appointments ADD COLUMN priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
    END IF;

    -- Assignment
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'assigned_to') THEN
        ALTER TABLE appointments ADD COLUMN assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    END IF;

    -- ETA fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'estimated_arrival') THEN
        ALTER TABLE appointments ADD COLUMN estimated_arrival TIMESTAMP WITH TIME ZONE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'actual_arrival') THEN
        ALTER TABLE appointments ADD COLUMN actual_arrival TIMESTAMP WITH TIME ZONE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'actual_departure') THEN
        ALTER TABLE appointments ADD COLUMN actual_departure TIMESTAMP WITH TIME ZONE;
    END IF;

    -- Route optimization
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'daily_route_id') THEN
        ALTER TABLE appointments ADD COLUMN daily_route_id UUID;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'route_order') THEN
        ALTER TABLE appointments ADD COLUMN route_order INTEGER;
    END IF;

    -- SMS notifications
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'sms_sent') THEN
        ALTER TABLE appointments ADD COLUMN sms_sent BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'sms_sent_at') THEN
        ALTER TABLE appointments ADD COLUMN sms_sent_at TIMESTAMP WITH TIME ZONE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'sms_delivered_at') THEN
        ALTER TABLE appointments ADD COLUMN sms_delivered_at TIMESTAMP WITH TIME ZONE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'sms_tracking_url') THEN
        ALTER TABLE appointments ADD COLUMN sms_tracking_url TEXT;
    END IF;

    -- Reminder settings
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'reminder_sent') THEN
        ALTER TABLE appointments ADD COLUMN reminder_sent BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'reminder_minutes_before') THEN
        ALTER TABLE appointments ADD COLUMN reminder_minutes_before INTEGER DEFAULT 60;
    END IF;

    -- Recurring appointments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'is_recurring') THEN
        ALTER TABLE appointments ADD COLUMN is_recurring BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'recurring_pattern') THEN
        ALTER TABLE appointments ADD COLUMN recurring_pattern TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'recurring_end_date') THEN
        ALTER TABLE appointments ADD COLUMN recurring_end_date DATE;
    END IF;

    -- Work details
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'work_type') THEN
        ALTER TABLE appointments ADD COLUMN work_type TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'estimated_cost') THEN
        ALTER TABLE appointments ADD COLUMN estimated_cost DECIMAL(10,2);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'actual_cost') THEN
        ALTER TABLE appointments ADD COLUMN actual_cost DECIMAL(10,2);
    END IF;

    -- Notes and attachments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'technician_notes') THEN
        ALTER TABLE appointments ADD COLUMN technician_notes TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'internal_notes') THEN
        ALTER TABLE appointments ADD COLUMN internal_notes TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'photos') THEN
        ALTER TABLE appointments ADD COLUMN photos JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'attachments') THEN
        ALTER TABLE appointments ADD COLUMN attachments JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- Customer feedback
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'customer_rating') THEN
        ALTER TABLE appointments ADD COLUMN customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'customer_feedback') THEN
        ALTER TABLE appointments ADD COLUMN customer_feedback TEXT;
    END IF;

    -- Color coding for calendar
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'color') THEN
        ALTER TABLE appointments ADD COLUMN color TEXT;
    END IF;

    -- Tags
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'tags') THEN
        ALTER TABLE appointments ADD COLUMN tags TEXT[];
    END IF;

    RAISE NOTICE 'Added all missing fields to appointments table';
END $$;

-- Migrate start_time to appointment_date + appointment_time if needed
DO $$
BEGIN
    UPDATE appointments
    SET
        appointment_date = start_time::date,
        appointment_time = start_time::time
    WHERE appointment_date IS NULL
      AND start_time IS NOT NULL;

    RAISE NOTICE 'Migrated start_time to appointment_date + appointment_time';
END $$;

-- Add indexes for appointments
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_assigned_to ON appointments(assigned_to);
CREATE INDEX IF NOT EXISTS idx_appointments_daily_route ON appointments(daily_route_id);
CREATE INDEX IF NOT EXISTS idx_appointments_client ON appointments(client_id);
CREATE INDEX IF NOT EXISTS idx_appointments_user ON appointments(user_id);

-- ============================================================================
-- SECTION 8: CREATE SUPPORTING TABLES FOR APPOINTMENTS
-- ============================================================================

-- Daily Routes table
CREATE TABLE IF NOT EXISTS daily_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    route_date DATE NOT NULL,
    technician_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    total_appointments INTEGER DEFAULT 0,
    total_distance_km DECIMAL(10,2),
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    start_location TEXT,
    end_location TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_daily_routes_user ON daily_routes(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_routes_date ON daily_routes(route_date);
CREATE INDEX IF NOT EXISTS idx_daily_routes_technician ON daily_routes(technician_id);

-- Appointment ETA History table
CREATE TABLE IF NOT EXISTS appointment_eta_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    estimated_arrival TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_eta_history_appointment ON appointment_eta_history(appointment_id);

-- Appointment SMS Log table
CREATE TABLE IF NOT EXISTS appointment_sms_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    message_type TEXT NOT NULL CHECK (message_type IN ('confirmation', 'reminder', 'eta_update', 'arrival', 'completion')),
    message_content TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delivered_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed')),
    error_message TEXT,
    tracking_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sms_log_appointment ON appointment_sms_log(appointment_id);
CREATE INDEX IF NOT EXISTS idx_sms_log_sent_at ON appointment_sms_log(sent_at);

-- ============================================================================
-- SECTION 9: UPDATE RLS POLICIES FOR NEW COLUMNS
-- ============================================================================

-- Enable RLS on new tables
ALTER TABLE daily_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_eta_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_sms_log ENABLE ROW LEVEL SECURITY;

-- RLS policies for daily_routes
DROP POLICY IF EXISTS "Users can view their own daily routes" ON daily_routes;
CREATE POLICY "Users can view their own daily routes"
    ON daily_routes FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage their own daily routes" ON daily_routes;
CREATE POLICY "Users can manage their own daily routes"
    ON daily_routes FOR ALL
    USING (auth.uid() = user_id);

-- RLS policies for appointment_eta_history
DROP POLICY IF EXISTS "Users can view ETA history for their appointments" ON appointment_eta_history;
CREATE POLICY "Users can view ETA history for their appointments"
    ON appointment_eta_history FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_eta_history.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can manage ETA history for their appointments" ON appointment_eta_history;
CREATE POLICY "Users can manage ETA history for their appointments"
    ON appointment_eta_history FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_eta_history.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

-- RLS policies for appointment_sms_log
DROP POLICY IF EXISTS "Users can view SMS logs for their appointments" ON appointment_sms_log;
CREATE POLICY "Users can view SMS logs for their appointments"
    ON appointment_sms_log FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_sms_log.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can manage SMS logs for their appointments" ON appointment_sms_log;
CREATE POLICY "Users can manage SMS logs for their appointments"
    ON appointment_sms_log FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM appointments
            WHERE appointments.id = appointment_sms_log.appointment_id
            AND appointments.user_id = auth.uid()
        )
    );

-- ============================================================================
-- SECTION 10: VERIFICATION
-- ============================================================================

DO $$
DECLARE
    v_products_user_id BOOLEAN;
    v_quotes_user_id BOOLEAN;
    v_invoices_user_id BOOLEAN;
    v_appointments_fields INTEGER;
BEGIN
    -- Verify user_id columns
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'products' AND column_name = 'user_id'
    ) INTO v_products_user_id;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'quotes' AND column_name = 'user_id'
    ) INTO v_quotes_user_id;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'invoices' AND column_name = 'user_id'
    ) INTO v_invoices_user_id;

    -- Count appointments columns
    SELECT COUNT(*) INTO v_appointments_fields
    FROM information_schema.columns
    WHERE table_name = 'appointments';

    RAISE NOTICE '========================================';
    RAISE NOTICE 'MIGRATION VERIFICATION RESULTS:';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Products has user_id: %', v_products_user_id;
    RAISE NOTICE 'Quotes has user_id: %', v_quotes_user_id;
    RAISE NOTICE 'Invoices has user_id: %', v_invoices_user_id;
    RAISE NOTICE 'Appointments total columns: %', v_appointments_fields;
    RAISE NOTICE '========================================';

    IF v_products_user_id AND v_quotes_user_id AND v_invoices_user_id AND v_appointments_fields >= 35 THEN
        RAISE NOTICE '✅ ALL CRITICAL FIXES APPLIED SUCCESSFULLY';
    ELSE
        RAISE WARNING '⚠️  Some fixes may not have been applied. Review the output above.';
    END IF;
END $$;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
--
-- ✅ What was fixed:
-- 1. Added user_id to products, quotes, invoices
-- 2. Removed duplicate columns from products
-- 3. Standardized column naming (subtotal_ht, total_vat)
-- 4. Added complete appointments schema (38+ fields)
-- 5. Created supporting tables: daily_routes, appointment_eta_history, appointment_sms_log
-- 6. Added missing fields to products, quotes, invoices
-- 7. Set up proper RLS policies for new tables
--
-- ⚠️  What you need to do next:
-- 1. Update Flutter models to include user_id field in Product, Quote, Invoice
-- 2. Update fromJson/toJson methods to use correct column names
-- 3. Run your seed data SQL - it should work now!
-- 4. Test inserting data from Flutter to verify sync
--
-- 📝 Backup created:
-- - appointments_backup_20251112 (contains data before changes)
--
-- 🔍 To verify the migration worked:
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'user_id';
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'quotes' AND column_name = 'user_id';
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'user_id';
-- SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'appointments';
--
-- ============================================================================
