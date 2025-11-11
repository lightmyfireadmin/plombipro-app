-- ============================================================================
-- QUICK DATABASE AUDIT (Simplified Version)
-- Returns essential database structure for quick checks
-- ============================================================================
-- Use this for faster checks, use database_audit_ultimate.sql for full audit
-- ============================================================================

SELECT jsonb_build_object(
  -- Quick stats
  'stats', jsonb_build_object(
    'tables', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')),
    'columns', (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')),
    'functions', (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')),
    'policies', (SELECT COUNT(*) FROM pg_policies WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')),
    'db_size_mb', ROUND((pg_database_size(current_database()))::numeric / 1024 / 1024, 2)
  ),

  -- Tables with basic info
  'tables', (
    SELECT jsonb_agg(
      jsonb_build_object(
        'name', table_schema || '.' || table_name,
        'columns', (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name),
        'rls_enabled', (SELECT relrowsecurity FROM pg_class WHERE oid = (quote_ident(t.table_schema) || '.' || quote_ident(t.table_name))::regclass),
        'has_pk', (SELECT COUNT(*) > 0 FROM information_schema.table_constraints tc WHERE tc.table_schema = t.table_schema AND tc.table_name = t.table_name AND tc.constraint_type = 'PRIMARY KEY')
      )
    )
    FROM information_schema.tables t
    WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')
      AND t.table_type = 'BASE TABLE'
  ),

  -- Foreign keys count
  'foreign_keys', (
    SELECT jsonb_agg(
      jsonb_build_object(
        'table', table_schema || '.' || table_name,
        'fk_count', (SELECT COUNT(*) FROM information_schema.table_constraints tc WHERE tc.table_schema = t.table_schema AND tc.table_name = t.table_name AND tc.constraint_type = 'FOREIGN KEY')
      )
    )
    FROM (SELECT DISTINCT table_schema, table_name FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY') t
  ),

  -- Security issues
  'security_issues', jsonb_build_object(
    'tables_without_rls', (
      SELECT jsonb_agg(schemaname || '.' || tablename)
      FROM pg_tables
      WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')
        AND (schemaname || '.' || tablename)::regclass NOT IN (
          SELECT oid FROM pg_class WHERE relrowsecurity = true
        )
    ),
    'tables_without_pk', (
      SELECT jsonb_agg(table_schema || '.' || table_name)
      FROM information_schema.tables t
      WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage')
        AND t.table_type = 'BASE TABLE'
        AND NOT EXISTS (
          SELECT 1 FROM information_schema.table_constraints tc
          WHERE tc.table_schema = t.table_schema
            AND tc.table_name = t.table_name
            AND tc.constraint_type = 'PRIMARY KEY'
        )
    )
  )
) AS quick_audit;

-- ============================================================================
-- Returns a simplified view perfect for quick checks!
-- ============================================================================
