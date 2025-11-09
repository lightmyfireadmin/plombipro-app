-- Phase 3: Critical Missing Features - Database Schema
-- This migration adds support for:
-- 1. E-signatures for quotes and invoices
-- 2. Recurring invoices with automated generation
-- 3. Progress invoices (acomptes) with parent-child relationships
-- 4. Client portal access and tokens
-- 5. Bank reconciliation and transaction matching

-- ============================================================================
-- 1. E-SIGNATURE SYSTEM
-- ============================================================================

-- Signatures table for storing client signatures on quotes/invoices
CREATE TABLE IF NOT EXISTS signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- What was signed
  document_type TEXT NOT NULL CHECK (document_type IN ('quote', 'invoice')),
  document_id UUID NOT NULL,

  -- Signature data
  signature_data TEXT NOT NULL, -- Base64 encoded signature image
  signature_method TEXT DEFAULT 'drawn' CHECK (signature_method IN ('drawn', 'uploaded', 'typed')),

  -- Signer information
  signer_name TEXT NOT NULL,
  signer_email TEXT,
  signer_ip_address TEXT,

  -- Metadata
  signed_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  device_info TEXT, -- Browser/device information for audit trail
  location_data JSONB, -- Optional geolocation data

  -- Validation
  is_valid BOOLEAN DEFAULT true,
  invalidated_at TIMESTAMP WITH TIME ZONE,
  invalidation_reason TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

  -- Ensure one signature per document
  UNIQUE(document_type, document_id)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_signatures_document ON signatures(document_type, document_id);
CREATE INDEX IF NOT EXISTS idx_signatures_user ON signatures(user_id);
CREATE INDEX IF NOT EXISTS idx_signatures_signed_at ON signatures(signed_at);

-- RLS policies
ALTER TABLE signatures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own signatures"
  ON signatures FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create signatures for their documents"
  ON signatures FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own signatures"
  ON signatures FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 2. RECURRING INVOICES SYSTEM
-- ============================================================================

-- Recurring invoice templates
CREATE TABLE IF NOT EXISTS recurring_invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE NOT NULL,

  -- Template information
  template_name TEXT NOT NULL,
  description TEXT,

  -- Invoice details (template)
  invoice_prefix TEXT DEFAULT 'REC',
  payment_terms INTEGER DEFAULT 30,
  notes TEXT,
  terms_and_conditions TEXT,

  -- Recurrence settings
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'yearly')),
  interval_count INTEGER DEFAULT 1, -- e.g., every 2 months
  start_date DATE NOT NULL,
  end_date DATE, -- NULL for indefinite

  -- Generation settings
  generate_days_before INTEGER DEFAULT 5, -- Generate invoice X days before due date
  auto_send BOOLEAN DEFAULT false,
  auto_remind BOOLEAN DEFAULT true,

  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
  last_generated_at TIMESTAMP WITH TIME ZONE,
  next_generation_date DATE,

  -- Totals (for template)
  subtotal_ht NUMERIC(10, 2) DEFAULT 0,
  total_tax NUMERIC(10, 2) DEFAULT 0,
  total_ttc NUMERIC(10, 2) DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Recurring invoice line items (template)
CREATE TABLE IF NOT EXISTS recurring_invoice_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recurring_invoice_id UUID REFERENCES recurring_invoices(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,

  description TEXT NOT NULL,
  quantity NUMERIC(10, 2) NOT NULL DEFAULT 1,
  unit_price NUMERIC(10, 2) NOT NULL,
  tax_rate NUMERIC(5, 2) DEFAULT 20.0,
  discount_percentage NUMERIC(5, 2) DEFAULT 0,

  total_ht NUMERIC(10, 2) GENERATED ALWAYS AS (
    quantity * unit_price * (1 - discount_percentage / 100)
  ) STORED,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Track generated invoices from recurring templates
CREATE TABLE IF NOT EXISTS recurring_invoice_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recurring_invoice_id UUID REFERENCES recurring_invoices(id) ON DELETE CASCADE NOT NULL,
  invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL NOT NULL,
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  period_start DATE,
  period_end DATE,
  status TEXT DEFAULT 'generated' CHECK (status IN ('generated', 'sent', 'paid', 'failed'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_user ON recurring_invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_client ON recurring_invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_status ON recurring_invoices(status);
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_next_date ON recurring_invoices(next_generation_date);

-- RLS policies
ALTER TABLE recurring_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_invoice_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their recurring invoices"
  ON recurring_invoices FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their recurring invoice items"
  ON recurring_invoice_items FOR ALL
  USING (
    recurring_invoice_id IN (
      SELECT id FROM recurring_invoices WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their recurring invoice history"
  ON recurring_invoice_history FOR SELECT
  USING (
    recurring_invoice_id IN (
      SELECT id FROM recurring_invoices WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- 3. PROGRESS INVOICES (ACOMPTES) SYSTEM
-- ============================================================================

-- Add progress invoice fields to invoices table
ALTER TABLE invoices
  ADD COLUMN IF NOT EXISTS is_progress_invoice BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS parent_quote_id UUID REFERENCES quotes(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS progress_percentage NUMERIC(5, 2) CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  ADD COLUMN IF NOT EXISTS payment_number INTEGER, -- e.g., 1 of 3
  ADD COLUMN IF NOT EXISTS total_payments INTEGER, -- Total number of payments
  ADD COLUMN IF NOT EXISTS is_final_payment BOOLEAN DEFAULT false;

-- Progress invoice schedule (defines payment milestones)
CREATE TABLE IF NOT EXISTS progress_invoice_schedule (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE NOT NULL,

  -- Schedule details
  schedule_name TEXT,
  total_amount NUMERIC(10, 2) NOT NULL,

  -- Milestones
  milestones JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Example: [
  --   {"name": "Acompte à la commande", "percentage": 30, "invoice_id": null, "due_date": "2024-01-15"},
  --   {"name": "Paiement intermédiaire", "percentage": 40, "invoice_id": null, "due_date": "2024-02-15"},
  --   {"name": "Solde", "percentage": 30, "invoice_id": null, "due_date": "2024-03-15"}
  -- ]

  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

  -- One schedule per quote
  UNIQUE(quote_id)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_progress_schedule_quote ON progress_invoice_schedule(quote_id);
CREATE INDEX IF NOT EXISTS idx_progress_schedule_user ON progress_invoice_schedule(user_id);

-- RLS policies
ALTER TABLE progress_invoice_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their progress schedules"
  ON progress_invoice_schedule FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- 4. CLIENT PORTAL ACCESS
-- ============================================================================

-- Client portal access tokens
CREATE TABLE IF NOT EXISTS client_portal_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE NOT NULL,

  -- Token
  token TEXT UNIQUE NOT NULL,

  -- Access control
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  access_count INTEGER DEFAULT 0,

  -- Permissions
  can_view_quotes BOOLEAN DEFAULT true,
  can_view_invoices BOOLEAN DEFAULT true,
  can_download_documents BOOLEAN DEFAULT true,
  can_pay_invoices BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Client portal activity log
CREATE TABLE IF NOT EXISTS client_portal_activity (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  token_id UUID REFERENCES client_portal_tokens(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE NOT NULL,

  -- Activity details
  activity_type TEXT NOT NULL CHECK (activity_type IN ('login', 'view_quote', 'view_invoice', 'download_document', 'payment')),
  document_type TEXT CHECK (document_type IN ('quote', 'invoice')),
  document_id UUID,

  -- Metadata
  ip_address TEXT,
  user_agent TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_portal_tokens_client ON client_portal_tokens(client_id);
CREATE INDEX IF NOT EXISTS idx_portal_tokens_token ON client_portal_tokens(token);
CREATE INDEX IF NOT EXISTS idx_portal_activity_token ON client_portal_activity(token_id);
CREATE INDEX IF NOT EXISTS idx_portal_activity_created ON client_portal_activity(created_at);

-- RLS policies
ALTER TABLE client_portal_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_portal_activity ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their client portal tokens"
  ON client_portal_tokens FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view their client portal activity"
  ON client_portal_activity FOR SELECT
  USING (
    token_id IN (
      SELECT id FROM client_portal_tokens WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- 5. BANK RECONCILIATION SYSTEM
-- ============================================================================

-- Bank accounts
CREATE TABLE IF NOT EXISTS bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- Account details
  account_name TEXT NOT NULL,
  bank_name TEXT,
  account_number TEXT,
  iban TEXT,
  bic TEXT,

  -- Balance tracking
  current_balance NUMERIC(12, 2) DEFAULT 0,
  last_reconciled_balance NUMERIC(12, 2),
  last_reconciled_at TIMESTAMP WITH TIME ZONE,

  -- Settings
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Bank transactions (imported from bank statements)
CREATE TABLE IF NOT EXISTS bank_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  bank_account_id UUID REFERENCES bank_accounts(id) ON DELETE CASCADE NOT NULL,

  -- Transaction details
  transaction_date DATE NOT NULL,
  value_date DATE,
  description TEXT NOT NULL,
  reference TEXT,
  amount NUMERIC(12, 2) NOT NULL, -- Negative for debits, positive for credits
  balance_after NUMERIC(12, 2),

  -- Categorization
  category TEXT,
  notes TEXT,

  -- Reconciliation
  is_reconciled BOOLEAN DEFAULT false,
  reconciled_at TIMESTAMP WITH TIME ZONE,
  reconciled_with_type TEXT CHECK (reconciled_with_type IN ('invoice', 'expense', 'manual')),
  reconciled_with_id UUID,

  -- Import tracking
  import_batch_id UUID,
  imported_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

  -- Prevent duplicate imports
  UNIQUE(bank_account_id, transaction_date, amount, description)
);

-- Reconciliation rules (for automatic matching)
CREATE TABLE IF NOT EXISTS reconciliation_rules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- Rule details
  rule_name TEXT NOT NULL,
  description TEXT,

  -- Matching criteria
  match_description_pattern TEXT, -- Regex pattern
  match_amount_min NUMERIC(12, 2),
  match_amount_max NUMERIC(12, 2),

  -- Action
  auto_categorize_as TEXT,
  auto_reconcile BOOLEAN DEFAULT false,

  -- Status
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0, -- Higher priority rules are evaluated first

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_bank_accounts_user ON bank_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_bank_transactions_account ON bank_transactions(bank_account_id);
CREATE INDEX IF NOT EXISTS idx_bank_transactions_date ON bank_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_bank_transactions_reconciled ON bank_transactions(is_reconciled);
CREATE INDEX IF NOT EXISTS idx_reconciliation_rules_user ON reconciliation_rules(user_id);

-- RLS policies
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reconciliation_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their bank accounts"
  ON bank_accounts FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their bank transactions"
  ON bank_transactions FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their reconciliation rules"
  ON reconciliation_rules FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update next_generation_date for recurring invoices
CREATE OR REPLACE FUNCTION update_next_generation_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.next_generation_date :=
    CASE NEW.frequency
      WHEN 'daily' THEN NEW.start_date + (NEW.interval_count || ' days')::interval
      WHEN 'weekly' THEN NEW.start_date + (NEW.interval_count || ' weeks')::interval
      WHEN 'biweekly' THEN NEW.start_date + (NEW.interval_count * 2 || ' weeks')::interval
      WHEN 'monthly' THEN NEW.start_date + (NEW.interval_count || ' months')::interval
      WHEN 'quarterly' THEN NEW.start_date + (NEW.interval_count * 3 || ' months')::interval
      WHEN 'yearly' THEN NEW.start_date + (NEW.interval_count || ' years')::interval
    END::date;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate next generation date
CREATE TRIGGER set_next_generation_date
  BEFORE INSERT OR UPDATE OF frequency, interval_count, start_date
  ON recurring_invoices
  FOR EACH ROW
  EXECUTE FUNCTION update_next_generation_date();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_signatures_updated_at BEFORE UPDATE ON signatures FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recurring_invoices_updated_at BEFORE UPDATE ON recurring_invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recurring_invoice_items_updated_at BEFORE UPDATE ON recurring_invoice_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_progress_invoice_schedule_updated_at BEFORE UPDATE ON progress_invoice_schedule FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_client_portal_tokens_updated_at BEFORE UPDATE ON client_portal_tokens FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bank_accounts_updated_at BEFORE UPDATE ON bank_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bank_transactions_updated_at BEFORE UPDATE ON bank_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reconciliation_rules_updated_at BEFORE UPDATE ON reconciliation_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE signatures IS 'Stores e-signatures for quotes and invoices with full audit trail';
COMMENT ON TABLE recurring_invoices IS 'Templates for automatically generating recurring invoices';
COMMENT ON TABLE recurring_invoice_items IS 'Line items for recurring invoice templates';
COMMENT ON TABLE recurring_invoice_history IS 'Tracks all invoices generated from recurring templates';
COMMENT ON TABLE progress_invoice_schedule IS 'Defines payment milestones for progress invoicing';
COMMENT ON TABLE client_portal_tokens IS 'Secure access tokens for client portal';
COMMENT ON TABLE client_portal_activity IS 'Audit log of all client portal activity';
COMMENT ON TABLE bank_accounts IS 'User bank accounts for reconciliation';
COMMENT ON TABLE bank_transactions IS 'Imported bank transactions for reconciliation';
COMMENT ON TABLE reconciliation_rules IS 'Automatic matching rules for bank reconciliation';
