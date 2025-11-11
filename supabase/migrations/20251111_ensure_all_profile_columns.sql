-- =====================================================
-- ENSURE ALL PROFILE COLUMNS EXIST
-- Adds any missing columns from the Profile model to the profiles table
-- =====================================================

-- Add columns if they don't exist
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS first_name TEXT,
ADD COLUMN IF NOT EXISTS last_name TEXT,
ADD COLUMN IF NOT EXISTS company_name TEXT,
ADD COLUMN IF NOT EXISTS siret TEXT,
ADD COLUMN IF NOT EXISTS vat_number TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS postal_code TEXT,
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'France',
ADD COLUMN IF NOT EXISTS iban TEXT,
ADD COLUMN IF NOT EXISTS bic TEXT,
ADD COLUMN IF NOT EXISTS logo_url TEXT,
ADD COLUMN IF NOT EXISTS subscription_plan TEXT,
ADD COLUMN IF NOT EXISTS subscription_status TEXT,
ADD COLUMN IF NOT EXISTS trial_end_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS stripe_connect_id TEXT,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Add comments for documentation
COMMENT ON COLUMN profiles.company_name IS 'Company or business name';
COMMENT ON COLUMN profiles.siret IS 'French SIRET business identification number';
COMMENT ON COLUMN profiles.vat_number IS 'VAT (TVA) number for the company';
COMMENT ON COLUMN profiles.iban IS 'International Bank Account Number for payments';
COMMENT ON COLUMN profiles.bic IS 'Bank Identifier Code (SWIFT code)';
COMMENT ON COLUMN profiles.subscription_plan IS 'Current subscription plan (free, pro, premium)';
COMMENT ON COLUMN profiles.subscription_status IS 'Subscription status (active, cancelled, expired)';
COMMENT ON COLUMN profiles.stripe_connect_id IS 'Stripe Connect account ID for payment processing';

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_profiles_updated_at ON profiles;
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_profiles_updated_at();
