# Database Migrations

This directory contains SQL migration scripts for the PlombiPro database.

## Applying Migrations

### Using Supabase CLI

1. Make sure you have the Supabase CLI installed
2. Run the migration:
```bash
supabase db push --include-all migrations/003_auto_number_generation.sql
```

### Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of the migration file
4. Execute the SQL

### Using psql (if you have direct database access)

```bash
psql -h <your-db-host> -U postgres -d postgres -f migrations/003_auto_number_generation.sql
```

## Migration History

### 003_auto_number_generation.sql (2025-11-05)
- Implements automatic sequential numbering for quotes and invoices
- Creates `generate_quote_number()` and `generate_invoice_number()` functions
- Creates triggers to auto-generate numbers on insert
- Supports custom prefixes and annual reset from user settings
- Adds indexes for better performance

**Features:**
- Sequential numbering with no gaps (French legal requirement)
- Custom prefix per user (from settings table)
- Optional annual reset (e.g., FACT-2025-0001)
- Automatic on insert (when quote_number/invoice_number is NULL or 'DRAFT')
- Thread-safe and handles concurrent inserts

**Format Examples:**
- Without annual reset: `DEV-000001`, `DEV-000002`, ...
- With annual reset: `DEV-2025-0001`, `DEV-2025-0002`, ...

## Testing Migrations

After applying the migration, test it with:

```sql
-- Test quote number generation
SELECT generate_quote_number('<your-user-id>');

-- Test invoice number generation
SELECT generate_invoice_number('<your-user-id>');

-- Test trigger by inserting a quote
INSERT INTO quotes (user_id, client_id, quote_number, quote_date)
VALUES ('<your-user-id>', '<client-id>', 'DRAFT', CURRENT_DATE)
RETURNING quote_number;
```

## Rollback

To rollback this migration:

```sql
-- Drop triggers
DROP TRIGGER IF EXISTS trigger_auto_generate_quote_number ON quotes;
DROP TRIGGER IF EXISTS trigger_auto_generate_invoice_number ON invoices;

-- Drop functions
DROP FUNCTION IF EXISTS auto_generate_quote_number();
DROP FUNCTION IF EXISTS auto_generate_invoice_number();
DROP FUNCTION IF EXISTS generate_quote_number(uuid);
DROP FUNCTION IF EXISTS generate_invoice_number(uuid);

-- Drop indexes
DROP INDEX IF EXISTS idx_quotes_user_number;
DROP INDEX IF EXISTS idx_invoices_user_number;
```
