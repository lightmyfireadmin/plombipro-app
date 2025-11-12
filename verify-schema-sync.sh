#!/bin/bash
################################################################################
# PlombiPro - Verify Database Schema Synchronization
# This script checks if database schema matches Flutter models
################################################################################

set -e

echo "========================================="
echo "  Schema Synchronization Checker"
echo "========================================="
echo ""

# SQL query to check database schema
SCHEMA_CHECK_SQL="
-- Check critical tables exist
SELECT
    'Table Existence Check' as check_type,
    table_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = t.table_name
    ) THEN '✅' ELSE '❌' END as exists
FROM (VALUES
    ('profiles'),
    ('clients'),
    ('products'),
    ('quotes'),
    ('invoices'),
    ('payments'),
    ('job_sites'),
    ('appointments')
) AS t(table_name);

-- Check critical columns in profiles table
SELECT
    'Profile Columns' as check_type,
    column_name,
    data_type,
    CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('id', 'email', 'company_name', 'siret', 'tva_number', 'phone', 'address', 'postal_code', 'city', 'iban', 'bic')
ORDER BY ordinal_position;

-- Check critical columns in job_sites table
SELECT
    'JobSite Columns' as check_type,
    column_name,
    data_type,
    CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_name = 'job_sites'
AND column_name IN ('id', 'user_id', 'client_id', 'job_name', 'address', 'city', 'postal_code', 'status', 'progress_percentage')
ORDER BY ordinal_position;

-- Check critical columns in clients table
SELECT
    'Client Columns' as check_type,
    column_name,
    data_type,
    CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_name = 'clients'
AND column_name IN ('id', 'user_id', 'client_type', 'email', 'phone', 'address', 'postal_code', 'city', 'siret', 'vat_number')
ORDER BY ordinal_position;

-- Check data counts for test user
SELECT
    'Test Data Counts' as check_type,
    'Clients' as item,
    COUNT(*)::text as count
FROM clients
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Test Data Counts', 'Products', COUNT(*)::text
FROM products
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Test Data Counts', 'Quotes', COUNT(*)::text
FROM quotes
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Test Data Counts', 'Invoices', COUNT(*)::text
FROM invoices
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
UNION ALL
SELECT 'Test Data Counts', 'Job Sites', COUNT(*)::text
FROM job_sites
WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
"

echo "Attempting to verify schema via Supabase CLI..."
echo ""

if command -v supabase &> /dev/null; then
    if supabase db remote list &> /dev/null 2>&1; then
        echo "Executing schema verification queries..."
        echo ""
        echo "$SCHEMA_CHECK_SQL" | supabase db execute

        echo ""
        echo "========================================="
        echo "✅ Schema Verification Complete"
        echo "========================================="
        echo ""
        echo "Key Points to Verify:"
        echo "  ✓ All core tables should exist"
        echo "  ✓ profiles.tva_number should exist (maps to vatNumber in Dart)"
        echo "  ✓ job_sites.city and postal_code should exist"
        echo "  ✓ clients.vat_number should exist"
        echo ""
        echo "Expected test data counts:"
        echo "  - Clients: 15"
        echo "  - Products: 30"
        echo "  - Quotes: 15"
        echo "  - Invoices: 12"
        echo "  - Job Sites: 10"
        echo ""

        exit 0
    else
        echo "⚠️  Not linked to Supabase project"
        echo ""
        echo "To link, run: supabase link --project-ref itugqculhbghypclhyfb"
    fi
else
    echo "⚠️  Supabase CLI not installed"
fi

echo ""
echo "========================================="
echo "Manual Verification Steps"
echo "========================================="
echo ""
echo "1. Open Supabase Dashboard SQL Editor:"
echo "   https://supabase.com/dashboard/project/itugqculhbghypclhyfb/sql"
echo ""
echo "2. Run this query to check schema:"
echo ""
echo "----------------------------------------"
cat << 'EOF'
-- Quick schema sync check
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name IN ('profiles', 'job_sites', 'clients')
AND column_name IN ('city', 'postal_code', 'tva_number', 'vat_number')
ORDER BY table_name, ordinal_position;
EOF
echo "----------------------------------------"
echo ""
echo "3. Expected results:"
echo "   - profiles.tva_number (text, YES)"
echo "   - job_sites.city (text, YES) ← Should exist"
echo "   - job_sites.postal_code (text, YES) ← Should exist"
echo "   - clients.postal_code (text, YES)"
echo "   - clients.city (text, YES)"
echo "   - clients.vat_number (text, YES)"
echo ""
echo "4. If columns are missing, you may need to run a migration to add them."
echo ""
echo "========================================="
