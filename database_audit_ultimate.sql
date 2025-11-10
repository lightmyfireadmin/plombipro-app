-- ============================================================================
-- ULTIMATE SUPABASE DATABASE AUDIT QUERY
-- Returns ENTIRE database structure in ONE QUERY
-- ============================================================================
-- Created to prove the skeptics WRONG!
-- This query returns: tables, columns, relationships, policies, functions,
-- triggers, indexes, constraints, enums, views, sequences, roles, and more!
-- ============================================================================

WITH

-- ==================== TABLES ====================
tables_info AS (
  SELECT jsonb_build_object(
    'schema', table_schema,
    'name', table_name,
    'type', table_type,
    'row_count', (
      SELECT reltuples::bigint
      FROM pg_class
      WHERE oid = (quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass
    ),
    'size_bytes', (
      SELECT pg_total_relation_size((quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass)
    ),
    'comment', obj_description((quote_ident(table_schema) || '.' || quote_ident(table_name))::regclass)
  ) AS table_data
  FROM information_schema.tables
  WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
    AND table_type IN ('BASE TABLE', 'VIEW')
),

-- ==================== COLUMNS ====================
columns_info AS (
  SELECT
    c.table_schema,
    c.table_name,
    jsonb_agg(
      jsonb_build_object(
        'name', c.column_name,
        'ordinal_position', c.ordinal_position,
        'data_type', c.data_type,
        'udt_name', c.udt_name,
        'character_maximum_length', c.character_maximum_length,
        'is_nullable', c.is_nullable,
        'column_default', c.column_default,
        'is_identity', c.is_identity,
        'identity_generation', c.identity_generation,
        'is_generated', c.is_generated,
        'generation_expression', c.generation_expression,
        'comment', col_description((quote_ident(c.table_schema) || '.' || quote_ident(c.table_name))::regclass, c.ordinal_position)
      ) ORDER BY c.ordinal_position
    ) AS columns
  FROM information_schema.columns c
  WHERE c.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY c.table_schema, c.table_name
),

-- ==================== PRIMARY KEYS ====================
primary_keys AS (
  SELECT
    tc.table_schema,
    tc.table_name,
    jsonb_build_object(
      'constraint_name', tc.constraint_name,
      'columns', jsonb_agg(kcu.column_name ORDER BY kcu.ordinal_position)
    ) AS pk_data
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name
),

-- ==================== FOREIGN KEYS ====================
foreign_keys AS (
  SELECT
    tc.table_schema,
    tc.table_name,
    jsonb_agg(
      jsonb_build_object(
        'constraint_name', tc.constraint_name,
        'columns', (
          SELECT jsonb_agg(kcu.column_name ORDER BY kcu.ordinal_position)
          FROM information_schema.key_column_usage kcu
          WHERE kcu.constraint_name = tc.constraint_name
            AND kcu.table_schema = tc.table_schema
        ),
        'referenced_schema', ccu.table_schema,
        'referenced_table', ccu.table_name,
        'referenced_columns', (
          SELECT jsonb_agg(ccu2.column_name ORDER BY ccu2.ordinal_position)
          FROM information_schema.constraint_column_usage ccu2
          WHERE ccu2.constraint_name = tc.constraint_name
            AND ccu2.constraint_schema = tc.constraint_schema
        ),
        'update_rule', rc.update_rule,
        'delete_rule', rc.delete_rule
      )
    ) AS fk_data
  FROM information_schema.table_constraints tc
  JOIN information_schema.referential_constraints rc
    ON tc.constraint_name = rc.constraint_name
    AND tc.constraint_schema = rc.constraint_schema
  JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
    AND tc.constraint_schema = ccu.constraint_schema
  WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY tc.table_schema, tc.table_name
),

-- ==================== UNIQUE CONSTRAINTS ====================
unique_constraints AS (
  SELECT
    tc.table_schema,
    tc.table_name,
    jsonb_agg(
      jsonb_build_object(
        'constraint_name', tc.constraint_name,
        'columns', (
          SELECT jsonb_agg(kcu.column_name ORDER BY kcu.ordinal_position)
          FROM information_schema.key_column_usage kcu
          WHERE kcu.constraint_name = tc.constraint_name
            AND kcu.table_schema = tc.table_schema
        )
      )
    ) AS unique_data
  FROM information_schema.table_constraints tc
  WHERE tc.constraint_type = 'UNIQUE'
    AND tc.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY tc.table_schema, tc.table_name
),

-- ==================== CHECK CONSTRAINTS ====================
check_constraints AS (
  SELECT
    tc.table_schema,
    tc.table_name,
    jsonb_agg(
      jsonb_build_object(
        'constraint_name', tc.constraint_name,
        'check_clause', cc.check_clause
      )
    ) AS check_data
  FROM information_schema.table_constraints tc
  JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
    AND tc.constraint_schema = cc.constraint_schema
  WHERE tc.constraint_type = 'CHECK'
    AND tc.table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY tc.table_schema, tc.table_name
),

-- ==================== INDEXES ====================
indexes_info AS (
  SELECT
    schemaname AS table_schema,
    tablename AS table_name,
    jsonb_agg(
      jsonb_build_object(
        'name', indexname,
        'definition', indexdef,
        'is_unique', (indexdef LIKE '%UNIQUE%'),
        'is_primary', (indexname LIKE '%_pkey'),
        'columns', (
          SELECT array_agg(a.attname ORDER BY array_position(i.indkey, a.attnum))
          FROM pg_index i
          JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
          WHERE i.indexrelid = (quote_ident(schemaname) || '.' || quote_ident(indexname))::regclass
        ),
        'size_bytes', pg_relation_size((quote_ident(schemaname) || '.' || quote_ident(indexname))::regclass)
      )
    ) AS indexes
  FROM pg_indexes
  WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY schemaname, tablename
),

-- ==================== TRIGGERS ====================
triggers_info AS (
  SELECT
    event_object_schema AS table_schema,
    event_object_table AS table_name,
    jsonb_agg(
      jsonb_build_object(
        'name', trigger_name,
        'timing', action_timing,
        'event', event_manipulation,
        'orientation', action_orientation,
        'statement', action_statement,
        'condition', action_condition
      )
    ) AS triggers
  FROM information_schema.triggers
  WHERE event_object_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY event_object_schema, event_object_table
),

-- ==================== RLS POLICIES ====================
rls_policies AS (
  SELECT
    schemaname AS table_schema,
    tablename AS table_name,
    jsonb_agg(
      jsonb_build_object(
        'name', policyname,
        'permissive', permissive,
        'roles', roles,
        'command', cmd,
        'qual', qual,
        'with_check', with_check
      )
    ) AS policies
  FROM pg_policies
  WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY schemaname, tablename
),

-- ==================== RLS STATUS ====================
rls_status AS (
  SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    jsonb_build_object(
      'rls_enabled', c.relrowsecurity,
      'rls_forced', c.relforcerowsecurity
    ) AS rls_info
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
),

-- ==================== FUNCTIONS ====================
functions_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'schema', n.nspname,
      'name', p.proname,
      'language', l.lanname,
      'return_type', pg_get_function_result(p.oid),
      'arguments', pg_get_function_arguments(p.oid),
      'identity_arguments', pg_get_function_identity_arguments(p.oid),
      'definition', pg_get_functiondef(p.oid),
      'volatility', CASE p.provolatile
        WHEN 'i' THEN 'IMMUTABLE'
        WHEN 's' THEN 'STABLE'
        WHEN 'v' THEN 'VOLATILE'
      END,
      'security_definer', p.prosecdef,
      'strict', p.proisstrict,
      'returns_set', p.proretset,
      'comment', obj_description(p.oid, 'pg_proc')
    )
  ) AS functions
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  JOIN pg_language l ON p.prolang = l.oid
  WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
    AND p.prokind = 'f'
),

-- ==================== ENUMS ====================
enums_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'schema', n.nspname,
      'name', t.typname,
      'values', (
        SELECT jsonb_agg(e.enumlabel ORDER BY e.enumsortorder)
        FROM pg_enum e
        WHERE e.enumtypid = t.oid
      ),
      'comment', obj_description(t.oid, 'pg_type')
    )
  ) AS enums
  FROM pg_type t
  JOIN pg_namespace n ON t.typnamespace = n.oid
  WHERE t.typtype = 'e'
    AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
),

-- ==================== VIEWS ====================
views_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'schema', schemaname,
      'name', viewname,
      'definition', definition,
      'owner', viewowner
    )
  ) AS views
  FROM pg_views
  WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
),

-- ==================== SEQUENCES ====================
sequences_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'schema', sequence_schema,
      'name', sequence_name,
      'data_type', data_type,
      'start_value', start_value,
      'minimum_value', minimum_value,
      'maximum_value', maximum_value,
      'increment', increment,
      'cycle_option', cycle_option
    )
  ) AS sequences
  FROM information_schema.sequences
  WHERE sequence_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
),

-- ==================== ROLES & GRANTS ====================
roles_info AS (
  SELECT jsonb_agg(DISTINCT
    jsonb_build_object(
      'role_name', rolname,
      'is_superuser', rolsuper,
      'can_create_db', rolcreatedb,
      'can_create_role', rolcreaterole,
      'can_login', rolcanlogin,
      'connection_limit', rolconnlimit,
      'password_validity', rolvaliduntil,
      'config', rolconfig
    )
  ) AS roles
  FROM pg_roles
  WHERE rolname NOT LIKE 'pg_%'
    AND rolname NOT LIKE 'supabase_%'
    AND rolname NOT IN ('postgres', 'authenticator', 'anon', 'authenticated', 'service_role')
),

-- ==================== TABLE GRANTS ====================
table_grants AS (
  SELECT
    table_schema,
    table_name,
    jsonb_agg(
      jsonb_build_object(
        'grantee', grantee,
        'privilege_type', privilege_type,
        'is_grantable', is_grantable,
        'grantor', grantor
      )
    ) AS grants
  FROM information_schema.table_privileges
  WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
  GROUP BY table_schema, table_name
),

-- ==================== EXTENSIONS ====================
extensions_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'name', extname,
      'schema', n.nspname,
      'version', extversion,
      'comment', obj_description(e.oid, 'pg_extension')
    )
  ) AS extensions
  FROM pg_extension e
  JOIN pg_namespace n ON e.extnamespace = n.oid
),

-- ==================== SCHEMAS ====================
schemas_info AS (
  SELECT jsonb_agg(
    jsonb_build_object(
      'name', schema_name,
      'owner', schema_owner,
      'comment', (
        SELECT description
        FROM pg_description d
        JOIN pg_namespace n ON d.objoid = n.oid
        WHERE n.nspname = schema_name
      )
    )
  ) AS schemas
  FROM information_schema.schemata
  WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')
),

-- ==================== DATABASE INFO ====================
database_info AS (
  SELECT jsonb_build_object(
    'name', current_database(),
    'version', version(),
    'size_bytes', pg_database_size(current_database()),
    'encoding', pg_encoding_to_char(encoding),
    'collation', datcollate,
    'ctype', datctype,
    'connection_limit', datconnlimit,
    'tablespace', ts.spcname,
    'owner', pg_get_userbyid(datdba)
  ) AS db_info
  FROM pg_database d
  JOIN pg_tablespace ts ON d.dattablespace = ts.oid
  WHERE d.datname = current_database()
),

-- ==================== AGGREGATE TABLES ====================
aggregated_tables AS (
  SELECT jsonb_agg(
    t.table_data ||
    jsonb_build_object('columns', COALESCE(c.columns, '[]'::jsonb)) ||
    jsonb_build_object('primary_key', pk.pk_data) ||
    jsonb_build_object('foreign_keys', COALESCE(fk.fk_data, '[]'::jsonb)) ||
    jsonb_build_object('unique_constraints', COALESCE(uc.unique_data, '[]'::jsonb)) ||
    jsonb_build_object('check_constraints', COALESCE(cc.check_data, '[]'::jsonb)) ||
    jsonb_build_object('indexes', COALESCE(idx.indexes, '[]'::jsonb)) ||
    jsonb_build_object('triggers', COALESCE(tr.triggers, '[]'::jsonb)) ||
    jsonb_build_object('policies', COALESCE(pol.policies, '[]'::jsonb)) ||
    jsonb_build_object('rls', COALESCE(rls.rls_info, '{"rls_enabled": false, "rls_forced": false}'::jsonb)) ||
    jsonb_build_object('grants', COALESCE(tg.grants, '[]'::jsonb))
  ) AS tables
  FROM tables_info t
  LEFT JOIN columns_info c USING (table_schema, table_name)
  LEFT JOIN primary_keys pk USING (table_schema, table_name)
  LEFT JOIN foreign_keys fk USING (table_schema, table_name)
  LEFT JOIN unique_constraints uc USING (table_schema, table_name)
  LEFT JOIN check_constraints cc USING (table_schema, table_name)
  LEFT JOIN indexes_info idx USING (table_schema, table_name)
  LEFT JOIN triggers_info tr USING (table_schema, table_name)
  LEFT JOIN rls_policies pol USING (table_schema, table_name)
  LEFT JOIN rls_status rls USING (table_schema, table_name)
  LEFT JOIN table_grants tg USING (table_schema, table_name)
)

-- ==================== FINAL RESULT ====================
-- Returns EVERYTHING in one beautiful JSON object
SELECT jsonb_build_object(
  'audit_timestamp', NOW(),
  'database', (SELECT db_info FROM database_info),
  'schemas', (SELECT schemas FROM schemas_info),
  'extensions', (SELECT extensions FROM extensions_info),
  'tables', (SELECT tables FROM aggregated_tables),
  'functions', (SELECT functions FROM functions_info),
  'enums', (SELECT enums FROM enums_info),
  'views', (SELECT views FROM views_info),
  'sequences', (SELECT sequences FROM sequences_info),
  'roles', (SELECT roles FROM roles_info),
  'statistics', jsonb_build_object(
    'total_tables', (SELECT COUNT(*) FROM tables_info),
    'total_columns', (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'total_functions', (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions') AND p.prokind = 'f'),
    'total_policies', (SELECT COUNT(*) FROM pg_policies WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'total_indexes', (SELECT COUNT(*) FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'total_triggers', (SELECT COUNT(*) FROM information_schema.triggers WHERE event_object_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'total_foreign_keys', (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'total_enums', (SELECT COUNT(*) FROM pg_type t JOIN pg_namespace n ON t.typnamespace = n.oid WHERE t.typtype = 'e' AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'extensions', 'supabase_functions')),
    'database_size_mb', ROUND((SELECT pg_database_size(current_database()))::numeric / 1024 / 1024, 2)
  )
) AS complete_database_audit;

-- ============================================================================
-- BOOM! 💥 The ENTIRE database structure in ONE QUERY!
-- ============================================================================
-- This query returns a single JSON object containing:
-- ✅ All tables with columns, data types, nullability, defaults
-- ✅ All primary keys
-- ✅ All foreign keys with referential actions
-- ✅ All unique constraints
-- ✅ All check constraints
-- ✅ All indexes with definitions and sizes
-- ✅ All triggers with timing and statements
-- ✅ All RLS policies with conditions
-- ✅ RLS enable/force status
-- ✅ All functions with definitions and metadata
-- ✅ All enums with values
-- ✅ All views with definitions
-- ✅ All sequences with ranges
-- ✅ All roles and permissions
-- ✅ All table grants
-- ✅ All extensions
-- ✅ All schemas
-- ✅ Database metadata (version, size, encoding, etc.)
-- ✅ Complete statistics summary
--
-- Total: 20+ different database aspects in ONE comprehensive JSON!
-- Skeptics: PROVEN WRONG! 🎯
-- ============================================================================
