-- Add missing RLS policies for profiles table
-- This is critical as profiles contain sensitive financial information (IBAN, BIC, SIRET)

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only see their own profile
CREATE POLICY "Users can only see their own profile."
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can only update their own profile."
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Note: INSERT and DELETE policies are not needed for profiles
-- - INSERT is handled by Supabase auth trigger on signup
-- - DELETE should be handled through auth.users deletion cascade
