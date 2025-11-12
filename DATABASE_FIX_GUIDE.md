# PlombiPro Database Fix Guide

## Problem Summary

The PlombiPro app is experiencing database issues:
1. **Dashboard shows zero clients** despite 11 clients existing
2. **Add client operation fails** completely
3. **CRUD operations not working** for quotes, invoices, etc.

## Root Cause

The most likely cause is **RLS (Row Level Security) policies** that are either:
- Missing
- Too restrictive
- Incorrectly configured

## Solution Components

We've created a comprehensive fix package with 3 components:

### 1. RLS Policy Migration (`supabase/migrations/20251112_fix_rls_policies.sql`)
- Fixes all RLS policies for 8 core tables
- Creates proper SELECT, INSERT, UPDATE, DELETE policies
- Adds performance indexes
- Includes diagnostic function

### 2. Database Diagnostic Tool (`lib/services/database_diagnostic.dart`)
- Tests authentication
- Tests database connection
- Tests RLS policies for each table
- Checks data counts
- Tests CRUD operations

### 3. Diagnostic UI Page (`lib/screens/debug/database_diagnostic_page.dart`)
- Visual diagnostic interface
- One-click testing
- Results display
- Copy to clipboard

---

## Step-by-Step Fix Process

### Step 1: Apply the RLS Migration

There are two ways to apply the migration:

#### Option A: Via Supabase Dashboard (Recommended)

1. Go to your Supabase project: https://app.supabase.com/project/itugqculhbghypclhyfb
2. Click on "SQL Editor" in the left sidebar
3. Click "New Query"
4. Copy the entire contents of `supabase/migrations/20251112_fix_rls_policies.sql`
5. Paste into the SQL editor
6. Click "Run" button
7. Wait for "Success" message

#### Option B: Via Supabase CLI

```bash
# Make sure you're in the project directory
cd /Users/utilisateur/Desktop/plombipro/plombipro-app

# Link to your project (if not already linked)
supabase link --project-ref itugqculhbghypclhyfb

# Apply the migration
supabase db push

# Or apply the specific migration file
supabase db execute-sql -f supabase/migrations/20251112_fix_rls_policies.sql
```

### Step 2: Test with Diagnostic Tool

#### Run from within the app:

1. Build and run the app:
```bash
flutter run
```

2. Navigate to the diagnostic page:
   - **Manual navigation:** Go to `/database-diagnostic` route
   - **Direct test:** Open the app and navigate to Settings → Database Diagnostics

3. Click "Run Full Diagnostics"

4. Review the results:
   - ✅ Authentication should show "User logged in"
   - ✅ Database Connection should be "Connected"
   - ✅ All tables should show "ACCESSIBLE"
   - ✅ Data counts should match expected numbers

5. Click "Test Client CRUD":
   - This will create, read, update, and delete a test client
   - Should show "✅ ALL CRUD OPERATIONS WORKING!"

#### Run from command line (alternative):

```dart
// Add this to any page temporarily:
import '../services/database_diagnostic.dart';

// In a button onPressed:
final results = await DatabaseDiagnostic.runDiagnostics();
print(DatabaseDiagnostic.formatResults(results));

// Test CRUD:
final crudTest = await DatabaseDiagnostic.testClientCreation();
print(crudTest);
```

### Step 3: Verify in Supabase Dashboard

1. Go to Table Editor: https://app.supabase.com/project/itugqculhbghypclhyfb/editor
2. Check "clients" table
3. Verify data is visible
4. Check the RLS policies:
   - Click on table name
   - Click "Policies" tab
   - Should see 4 policies (SELECT, INSERT, UPDATE, DELETE)

### Step 4: Check Data Counts Manually

Run this query in SQL Editor to see actual counts:

```sql
-- Check data for current user
SELECT
  'clients' as table_name,
  COUNT(*) as count
FROM clients
WHERE user_id = auth.uid()

UNION ALL

SELECT
  'quotes',
  COUNT(*)
FROM quotes
WHERE user_id = auth.uid()

UNION ALL

SELECT
  'invoices',
  COUNT(*)
FROM invoices
WHERE user_id = auth.uid();
```

---

## Expected Results After Fix

### Dashboard Should Show:
- ✅ Correct client count (11 or actual number)
- ✅ Correct quote count
- ✅ Correct invoice count
- ✅ All statistics accurate

### CRUD Operations Should Work:
- ✅ Add new client succeeds
- ✅ View clients list shows all data
- ✅ Edit client works
- ✅ Delete client works
- ✅ Same for quotes, invoices, products, etc.

### Diagnostic Results Should Show:
```
=== DATABASE DIAGNOSTIC REPORT ===
Status: success

--- AUTHENTICATION ---
  Authenticated: true
  User ID: [your-user-id]
  Email: [your-email]

--- DATABASE CONNECTION ---
  Connected: true

--- RLS POLICIES ---
  clients: ACCESSIBLE
  quotes: ACCESSIBLE
  invoices: ACCESSIBLE
  products: ACCESSIBLE
  payments: ACCESSIBLE
  job_sites: ACCESSIBLE
  profiles: ACCESSIBLE

--- DATA COUNTS ---
  clients: 11
  quotes: [actual count]
  invoices: [actual count]
  products: [actual count]
```

---

## Troubleshooting

### Issue: Migration fails with "policy already exists"

**Solution:** The migration script includes `DROP POLICY IF EXISTS` statements, but if it still fails:

```sql
-- Run this first to drop all policies manually:
DROP POLICY IF EXISTS "Users can view their own clients" ON clients;
DROP POLICY IF EXISTS "Users can insert their own clients" ON clients;
DROP POLICY IF EXISTS "Users can update their own clients" ON clients;
DROP POLICY IF EXISTS "Users can delete their own clients" ON clients;

-- Then run the full migration again
```

### Issue: Still showing zero clients after migration

**Possible causes:**

1. **Wrong user_id in database:**
```sql
-- Check what user_ids exist in clients table:
SELECT DISTINCT user_id FROM clients;

-- Check your current auth user_id:
SELECT auth.uid();

-- If they don't match, data belongs to different user
```

2. **RLS still not applied:**
```sql
-- Verify RLS is enabled:
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'clients';
-- rowsecurity should be TRUE

-- Check policies exist:
SELECT * FROM pg_policies WHERE tablename = 'clients';
```

3. **User not authenticated in app:**
- Check that user is logged in
- Check auth token hasn't expired
- Try logging out and back in

### Issue: "Not connected" in diagnostic tool

**Solution:**
1. Restart the app
2. Check internet connection
3. Verify Supabase project is not paused
4. Check Supabase credentials in `lib/main.dart`:
   - URL: `https://itugqculhbghypclhyfb.supabase.co`
   - Anon Key: Should be set correctly

### Issue: Create client still fails after RLS fix

**Check the error message:**

1. **"User not authenticated"** → User needs to log in
2. **"duplicate key value violates unique constraint"** → Client already exists
3. **"null value in column 'user_id'"** → Service not passing user_id correctly
4. **"permission denied"** → RLS policies still restrictive

**Debug steps:**
```dart
// Add detailed logging in SupabaseService.createClient:
try {
  final user = _client.auth.currentUser;
  print('🔍 Current user: ${user?.id}');
  print('🔍 User email: ${user?.email}');

  final clientData = {
    ...client.toJson(),
    'user_id': user!.id,
  };
  print('🔍 Inserting client data: $clientData');

  final response = await _client.from('clients').insert(clientData).select().single();

  print('✅ Client created: ${response['id']}');
  return response['id'] as String;
} catch (e, stackTrace) {
  print('❌ Error creating client: $e');
  print('❌ Stack trace: $stackTrace');
  rethrow;
}
```

---

## Additional Optimizations

### Add Better Error Messages

Update `lib/services/error_handler.dart` to show user-friendly messages:

```dart
// Add specific handling for RLS errors
if (error.toString().contains('row-level security policy')) {
  return 'Permission denied. Please contact support.';
}

if (error.toString().contains('not authenticated')) {
  return 'Please log in to continue.';
}
```

### Add Retry Logic

For temporary network issues:

```dart
Future<T> _retryOperation<T>(Future<T> Function() operation, {int maxAttempts = 3}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempt));
    }
  }
  throw Exception('Operation failed after $maxAttempts attempts');
}
```

### Add Data Refresh After Mutations

In `home_page.dart`:

```dart
// After any CRUD operation, refresh data:
Future<void> _refreshData() async {
  await _fetchDashboardData();
  setState(() {}); // Force rebuild
}

// Call this after creating/updating/deleting
await _refreshData();
```

---

## Verification Checklist

Before marking this as complete, verify:

- [ ] Migration applied successfully (no errors)
- [ ] Diagnostic tool shows all tables "ACCESSIBLE"
- [ ] Dashboard displays correct client count
- [ ] Can create new client successfully
- [ ] Can view client list with all clients
- [ ] Can edit existing client
- [ ] Can delete client
- [ ] Same for quotes
- [ ] Same for invoices
- [ ] Same for products
- [ ] No console errors during operations

---

## Next Steps After Database Fix

Once database is working, address these issues (in order):

1. **Fix /home routing error** (router.dart line 387)
2. **Fix white-on-white text fields** (theme issues)
3. **Move error messages to top** (snackbar positioning)
4. **Implement OCR smart categorization**
5. **Add wizard dead-end fixes**

---

## Support

If issues persist after applying all fixes:

1. **Export diagnostic results:**
   - Run diagnostic tool
   - Copy full output
   - Save to file

2. **Export database schema:**
```sql
-- Run in SQL Editor:
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

3. **Check Supabase logs:**
   - Go to Supabase Dashboard
   - Click "Logs" → "Database"
   - Look for errors around CRUD operation times

4. **Share with team:**
   - Diagnostic output
   - Database schema
   - Error logs
   - Console logs from Flutter app

---

**Last Updated:** 2025-11-12
**Migration Version:** 20251112_fix_rls_policies
**Status:** Ready to apply
