#!/bin/bash
################################################################################
# PlombiPro - Execute Seed Data SQL
# This script runs the comprehensive seed data migration
################################################################################

set -e  # Exit on error

echo "========================================="
echo "  PlombiPro Seed Data Executor"
echo "========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "supabase/migrations/20251111_comprehensive_seed_data.sql" ]; then
    echo "❌ Error: Seed data file not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

echo "📋 Seed data file found: supabase/migrations/20251111_comprehensive_seed_data.sql"
echo ""

# Method 1: Using Supabase CLI (requires auth)
echo "Method 1: Supabase CLI"
echo "----------------------"
echo "Attempting to run via Supabase CLI..."
echo ""

if command -v supabase &> /dev/null; then
    echo "✅ Supabase CLI is installed"

    # Check if linked to project
    if supabase db remote list &> /dev/null; then
        echo "✅ Project is linked"
        echo ""
        echo "Executing seed data..."
        supabase db execute --file supabase/migrations/20251111_comprehensive_seed_data.sql

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Seed data successfully loaded!"
            echo ""
            echo "Verifying data..."
            supabase db execute --query "
                SELECT
                    'Clients' as table_name, COUNT(*) as count
                FROM clients
                WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
                UNION ALL
                SELECT 'Products', COUNT(*) FROM products
                WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
                UNION ALL
                SELECT 'Quotes', COUNT(*) FROM quotes
                WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
                UNION ALL
                SELECT 'Invoices', COUNT(*) FROM invoices
                WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971'
                UNION ALL
                SELECT 'Job Sites', COUNT(*) FROM job_sites
                WHERE user_id = '6b1d26bf-40d7-46c0-9b07-89a120191971';
            "
            exit 0
        else
            echo "❌ Failed to execute seed data via CLI"
            echo "Trying alternative methods..."
        fi
    else
        echo "⚠️  Project not linked to Supabase CLI"
        echo ""
        echo "To link your project, run:"
        echo "  supabase link --project-ref itugqculhbghypclhyfb"
    fi
else
    echo "⚠️  Supabase CLI not found"
fi

echo ""
echo "========================================="
echo "Method 2: Manual Execution via Dashboard"
echo "========================================="
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Open your Supabase Dashboard:"
echo "   https://supabase.com/dashboard/project/itugqculhbghypclhyfb"
echo ""
echo "2. Navigate to: SQL Editor"
echo ""
echo "3. Click 'New Query'"
echo ""
echo "4. Copy the content of:"
echo "   supabase/migrations/20251111_comprehensive_seed_data.sql"
echo ""
echo "5. Paste it into the SQL Editor"
echo ""
echo "6. Click 'Run' (or press Cmd+Enter)"
echo ""
echo "7. Wait for success message"
echo ""
echo "The seed data file is located at:"
echo "$(pwd)/supabase/migrations/20251111_comprehensive_seed_data.sql"
echo ""
echo "Expected results after execution:"
echo "  - 15 Clients"
echo "  - 30 Products"
echo "  - 15 Quotes"
echo "  - 12 Invoices"
echo "  - 10 Job Sites"
echo "  - 8 Appointments"
echo "  - 5 Payments"
echo ""
echo "========================================="
echo "Done!"
echo "========================================="
