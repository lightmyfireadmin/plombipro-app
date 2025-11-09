-- ============================================================================
-- PLOMBIPRO - COMPLETE DATABASE SETUP FROM ZERO
-- Copy this entire script and run in Supabase SQL Editor
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Run existing migration files in this order:
-- ============================================================================

-- 1. First, run: supabase/migrations/20251109_create_appointments_table.sql
-- 2. Then run: supabase/migrations/20251109_create_supplier_products_table.sql
-- 3. Finally run: supabase/migrations/20251109_phase3_critical_features.sql

-- ============================================================================
-- After running migrations, verify with these queries:
-- ============================================================================

-- Check all tables exist
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name NOT LIKE 'pg_%'
ORDER BY table_name;

-- Expected tables:
-- appointments, bank_accounts, bank_transactions, client_portal_activity,
-- client_portal_tokens, clients, invoices, job_sites, line_items, payments,
-- products, progress_invoice_schedule, quotes, reconciliation_rules,
-- recurring_invoice_history, recurring_invoice_items, recurring_invoices,
-- signatures, supplier_products

-- Verify RLS is enabled on all tables
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT LIKE 'pg_%'
ORDER BY tablename;

-- All should show rowsecurity = true

-- Check policies exist
SELECT count(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public';

-- Should be 25+ policies

-- ============================================================================
-- Insert sample supplier products (Optional - for testing)
-- ============================================================================

INSERT INTO supplier_products (supplier, reference, name, description, category, price, price_unit, vat_rate)
VALUES
-- Point P Products
('point_p', 'TUB-CU-12', 'Tube cuivre 12mm', 'Tube cuivre écroui 12mm au mètre', 'Tubes et raccords', 8.50, 'mètre', 20.0),
('point_p', 'TUB-CU-14', 'Tube cuivre 14mm', 'Tube cuivre écroui 14mm au mètre', 'Tubes et raccords', 10.20, 'mètre', 20.0),
('point_p', 'TUB-CU-16', 'Tube cuivre 16mm', 'Tube cuivre écroui 16mm au mètre', 'Tubes et raccords', 12.80, 'mètre', 20.0),
('point_p', 'RAC-90-12', 'Coude 90° Ø12mm', 'Raccord coudé 90° à souder Ø12mm', 'Tubes et raccords', 2.30, 'unité', 20.0),
('point_p', 'RAC-90-14', 'Coude 90° Ø14mm', 'Raccord coudé 90° à souder Ø14mm', 'Tubes et raccords', 2.80, 'unité', 20.0),
('point_p', 'WC-SUS', 'WC suspendu', 'Pack WC suspendu complet blanc', 'Sanitaires', 189.00, 'unité', 20.0),
('point_p', 'LAV-60', 'Lavabo 60cm', 'Lavabo céramique blanc 60cm', 'Sanitaires', 79.00, 'unité', 20.0),
('point_p', 'ROB-LAV', 'Mitigeur lavabo', 'Mitigeur lavabo chromé standard', 'Robinetterie', 45.00, 'unité', 20.0),

-- Cedeo Products  
('cedeo', 'PVC-100', 'Tube PVC Ø100mm', 'Tube PVC évacuation Ø100mm 3m', 'Évacuation', 15.90, 'barre', 20.0),
('cedeo', 'SIPHON-LAV', 'Siphon lavabo', 'Siphon lavabo 1"1/4 chromé', 'Sanitaires', 12.50, 'unité', 20.0),
('cedeo', 'COLL-PVC-100', 'Collier PVC Ø100', 'Collier de fixation PVC Ø100mm', 'Évacuation', 3.20, 'unité', 20.0),

-- Leroy Merlin Products
('leroy_merlin', 'FLEX-INOX', 'Flexible inox', 'Flexible inox 1m pour robinetterie', 'Robinetterie', 8.90, 'unité', 20.0),
('leroy_merlin', 'JOINT-FIB', 'Joint fibre', 'Joint fibre 12/17 - lot de 10', 'Joints et étanchéité', 3.50, 'lot', 20.0),

-- Castorama Products
('castorama', 'TEFLON-ROL', 'Téflon rouleau', 'Ruban téflon 12m x 12mm', 'Joints et étanchéité', 2.80, 'rouleau', 20.0),
('castorama', 'CLE-MOLETTE', 'Clé à molette', 'Clé à molette 250mm', 'Outillage', 18.90, 'unité', 20.0)
ON CONFLICT (supplier, reference) DO NOTHING;

-- ============================================================================
-- Setup complete! Your database is ready.
-- ============================================================================
