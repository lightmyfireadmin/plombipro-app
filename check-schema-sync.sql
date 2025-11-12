-- =====================================================
-- PlombiPro Schema Synchronization Check
-- Run this in Supabase SQL Editor to verify sync
-- =====================================================

BEGIN;

-- Create temporary result table
CREATE TEMP TABLE sync_check_results (
    check_category TEXT,
    check_item TEXT,
    status TEXT,
    details TEXT
);

-- =====================================================
-- 1. CHECK CORE TABLES EXIST
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'Table Existence' as check_category,
    t.table_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name = t.table_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    '' as details
FROM (VALUES
    ('profiles'),
    ('clients'),
    ('products'),
    ('quotes'),
    ('invoices'),
    ('invoice_items'),
    ('payments'),
    ('job_sites'),
    ('appointments'),
    ('job_site_notes'),
    ('job_site_photos'),
    ('job_site_tasks'),
    ('job_site_time_logs'),
    ('job_site_documents')
) AS t(table_name);

-- =====================================================
-- 2. CHECK PROFILES TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'profiles columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'profiles'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'profiles' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('email'),
    ('first_name'),
    ('last_name'),
    ('company_name'),
    ('siret'),
    ('tva_number'),  -- Maps to vatNumber in Dart
    ('phone'),
    ('address'),
    ('postal_code'),
    ('city'),
    ('country'),
    ('iban'),
    ('bic'),
    ('logo_url'),
    ('subscription_plan'),
    ('subscription_status'),
    ('trial_end_date'),
    ('stripe_connect_id'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 3. CHECK JOB_SITES TABLE COLUMNS (CRITICAL FIXES)
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'job_sites columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'job_sites'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING - NEEDS MIGRATION'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'job_sites' AND column_name = c.column_name),
        'Column missing - Flutter model has it!'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('client_id'),
    ('job_name'),
    ('reference_number'),
    ('address'),
    ('city'),           -- ⚠️ ADDED IN MODEL FIX
    ('postal_code'),    -- ⚠️ ADDED IN MODEL FIX
    ('contact_person'),
    ('contact_phone'),
    ('description'),
    ('start_date'),
    ('estimated_end_date'),
    ('actual_end_date'),
    ('status'),
    ('progress_percentage'),
    ('related_quote_id'),
    ('estimated_budget'),
    ('actual_cost'),
    ('profit_margin'),
    ('notes'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 4. CHECK CLIENTS TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'clients columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'clients'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'clients' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('client_type'),
    ('salutation'),
    ('first_name'),
    ('last_name'),
    ('company_name'),
    ('email'),
    ('phone'),
    ('mobile_phone'),
    ('address'),
    ('postal_code'),
    ('city'),
    ('country'),
    ('billing_address'),
    ('billing_postal_code'),
    ('billing_city'),
    ('siret'),
    ('vat_number'),
    ('default_payment_terms'),
    ('default_discount'),
    ('tags'),
    ('is_favorite'),
    ('notes'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 5. CHECK PRODUCTS TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'products columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'products'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'products' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('ref'),
    ('reference'),
    ('name'),
    ('description'),
    ('category'),
    ('supplier'),
    ('supplier_name'),
    ('price_buy'),
    ('price_sell'),
    ('purchase_price_ht'),
    ('selling_price_ht'),
    ('price'),
    ('vat_rate'),
    ('unit'),
    ('is_favorite'),
    ('times_used'),
    ('last_used'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 6. CHECK QUOTES TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'quotes columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'quotes'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'quotes' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('client_id'),
    ('quote_number'),
    ('quote_date'),
    ('expiry_date'),
    ('status'),
    ('subtotal_ht'),
    ('total_ht'),
    ('total_vat'),
    ('total_tva'),
    ('total_ttc'),
    ('items'),
    ('notes'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 7. CHECK INVOICES TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'invoices columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'invoices'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'invoices' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('client_id'),
    ('invoice_number'),
    ('number'),
    ('invoice_date'),
    ('date'),
    ('due_date'),
    ('payment_date'),
    ('status'),
    ('payment_status'),
    ('payment_method'),
    ('subtotal_ht'),
    ('total_ht'),
    ('total_vat'),
    ('total_tva'),
    ('tva_amount'),
    ('total_ttc'),
    ('amount_paid'),
    ('balance_due'),
    ('items'),
    ('notes'),
    ('legal_mentions'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 8. CHECK PAYMENTS TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'payments columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'payments'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'payments' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('invoice_id'),
    ('payment_date'),
    ('amount'),
    ('payment_method'),
    ('transaction_reference'),
    ('notes'),
    ('created_at')
) AS c(column_name);

-- =====================================================
-- 9. CHECK APPOINTMENTS TABLE COLUMNS
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'appointments columns' as check_category,
    c.column_name as check_item,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'appointments'
            AND column_name = c.column_name
        ) THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COALESCE(
        (SELECT data_type || CASE WHEN is_nullable = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
         FROM information_schema.columns
         WHERE table_name = 'appointments' AND column_name = c.column_name),
        'Column missing'
    ) as details
FROM (VALUES
    ('id'),
    ('user_id'),
    ('client_id'),
    ('job_site_id'),
    ('title'),
    ('description'),
    ('start_time'),
    ('end_time'),
    ('duration_minutes'),
    ('status'),
    ('notes'),
    ('created_at'),
    ('updated_at')
) AS c(column_name);

-- =====================================================
-- 10. CHECK TEST DATA (if seed data was run)
-- =====================================================
INSERT INTO sync_check_results
SELECT
    'Test Data' as check_category,
    data_type as check_item,
    CASE
        WHEN count > 0 THEN '✅ ' || count::TEXT || ' records'
        ELSE '⚠️ NO DATA'
    END as status,
    'Expected: ' || expected::TEXT as details
FROM (
    SELECT 'Clients' as data_type, COUNT(*) as count, 15 as expected
    FROM clients WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Products', COUNT(*), 30
    FROM products WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Quotes', COUNT(*), 15
    FROM quotes WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Invoices', COUNT(*), 12
    FROM invoices WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Job Sites', COUNT(*), 10
    FROM job_sites WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Appointments', COUNT(*), 8
    FROM appointments WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
    UNION ALL
    SELECT 'Payments', COUNT(*), 5
    FROM payments WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
) counts;

-- =====================================================
-- DISPLAY RESULTS
-- =====================================================

-- Summary by category
SELECT
    check_category,
    COUNT(*) as total_checks,
    SUM(CASE WHEN status LIKE '✅%' THEN 1 ELSE 0 END) as passed,
    SUM(CASE WHEN status LIKE '❌%' THEN 1 ELSE 0 END) as failed,
    SUM(CASE WHEN status LIKE '⚠️%' THEN 1 ELSE 0 END) as warnings
FROM sync_check_results
GROUP BY check_category
ORDER BY
    CASE check_category
        WHEN 'Table Existence' THEN 1
        WHEN 'profiles columns' THEN 2
        WHEN 'job_sites columns' THEN 3
        WHEN 'clients columns' THEN 4
        WHEN 'products columns' THEN 5
        WHEN 'quotes columns' THEN 6
        WHEN 'invoices columns' THEN 7
        WHEN 'payments columns' THEN 8
        WHEN 'appointments columns' THEN 9
        WHEN 'Test Data' THEN 10
        ELSE 99
    END;

-- Show all results
SELECT
    check_category,
    check_item,
    status,
    details
FROM sync_check_results
ORDER BY
    CASE check_category
        WHEN 'Table Existence' THEN 1
        WHEN 'profiles columns' THEN 2
        WHEN 'job_sites columns' THEN 3
        WHEN 'clients columns' THEN 4
        WHEN 'products columns' THEN 5
        WHEN 'quotes columns' THEN 6
        WHEN 'invoices columns' THEN 7
        WHEN 'payments columns' THEN 8
        WHEN 'appointments columns' THEN 9
        WHEN 'Test Data' THEN 10
        ELSE 99
    END,
    check_item;

-- Show only failed checks
SELECT
    '⚠️ ISSUES FOUND' as alert,
    check_category,
    check_item,
    status,
    details
FROM sync_check_results
WHERE status LIKE '❌%'
ORDER BY check_category, check_item;

ROLLBACK;  -- Don't save temp table

-- =====================================================
-- FINAL MESSAGE
-- =====================================================
DO $$
DECLARE
    failed_count INT;
BEGIN
    SELECT COUNT(*) INTO failed_count
    FROM (SELECT * FROM sync_check_results WHERE status LIKE '❌%') t;

    IF failed_count = 0 THEN
        RAISE NOTICE '========================================';
        RAISE NOTICE '✅ SCHEMA SYNC CHECK PASSED!';
        RAISE NOTICE '========================================';
        RAISE NOTICE 'All database columns match Flutter models.';
        RAISE NOTICE 'Database and codebase are fully synchronized.';
        RAISE NOTICE '========================================';
    ELSE
        RAISE NOTICE '========================================';
        RAISE NOTICE '⚠️ SCHEMA SYNC ISSUES FOUND: % missing columns', failed_count;
        RAISE NOTICE '========================================';
        RAISE NOTICE 'Check the query results above for details.';
        RAISE NOTICE 'You may need to run migrations to add missing columns.';
        RAISE NOTICE '========================================';
    END IF;
END $$;
