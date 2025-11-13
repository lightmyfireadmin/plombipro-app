# Authentication Fix Guide

## ✅ Database Status: WORKING
The Supabase AI confirmed:
- **11 clients exist** for user `6b1d26bf-40d7-46c0-9b07-89a120191971`
- **RLS policies are correct**
- **Data is accessible when authenticated**

## ❌ Problem: Flutter App Not Sending Auth Token

The issue is that `auth.uid()` returns **NULL** when the Flutter app makes requests, meaning:
- The app is making **unauthenticated requests**
- The JWT access token is **not being sent** with API calls
- Session is **not persisting** properly

---

## 🔧 Solution: Enhanced Auth Service

I've created two new files to fix this:

### 1. `lib/services/auth_service.dart`
**Purpose:** Centralized authentication management
**Features:**
- ✅ Check if user is authenticated before API calls
- ✅ Get current user ID safely
- ✅ Refresh expired tokens automatically
- ✅ Debug auth state with detailed logging
- ✅ Throw errors if unauthenticated API calls attempted

### 2. `lib/services/supabase_service_enhanced.dart`
**Purpose:** Wrapper around SupabaseService with auth verification
**Features:**
- ✅ Verifies auth before every database call
- ✅ Logs user ID and token status
- ✅ Auto-refreshes tokens if needed
- ✅ Detailed error logging for auth issues
- ✅ Wraps fetchClients, createClient, fetchQuotes, fetchInvoices

---

## 🚀 How to Apply the Fix

### Step 1: Update Home Page to Use Enhanced Service

**File:** `lib/screens/home/home_page.dart`

**Find this:**
```dart
import '../../services/supabase_service.dart';
```

**Replace with:**
```dart
import '../../services/supabase_service.dart';
import '../../services/supabase_service_enhanced.dart';
import '../../services/auth_service.dart';
```

**Find this in `_fetchDashboardData()` method:**
```dart
final clients = await SupabaseService.fetchClients();
final quotes = await SupabaseService.fetchQuotes();
final invoices = await SupabaseService.fetchInvoices();
```

**Replace with:**
```dart
// Debug: Print auth state
await SupabaseServiceEnhanced.printAuthState();

// Use enhanced service with auth verification
final clients = await SupabaseServiceEnhanced.fetchClients();
final quotes = await SupabaseServiceEnhanced.fetchQuotes();
final invoices = await SupabaseServiceEnhanced.fetchInvoices();
```

### Step 2: Check Auth State on App Start

**File:** `lib/screens/splash/splash_page.dart`

**Replace the `_redirect()` method:**

```dart
Future<void> _redirect() async {
  await Future.delayed(Duration.zero);
  if (!mounted) return;

  print('🔍 Checking auth state...');

  final session = Supabase.instance.client.auth.currentSession;
  final user = Supabase.instance.client.auth.currentUser;

  print('Session: ${session != null}');
  print('User: ${user?.id}');
  print('Access Token: ${session?.accessToken?.substring(0, 20)}...');

  if (session != null && user != null) {
    print('✅ User authenticated, going to home');
    context.go('/home-enhanced');
  } else {
    print('❌ No session, going to login');
    context.go('/login');
  }
}
```

### Step 3: Verify Auth After Login

**File:** `lib/screens/auth/login_page.dart`

**In the `_signIn()` method, after successful login, add:**

```dart
try {
  await SupabaseService.signIn(
    email: _emailController.text,
    password: _passwordController.text,
  );

  // VERIFY AUTH STATE AFTER LOGIN
  print('🔍 Verifying auth after login...');
  final authState = await AuthService.debugAuthState();
  print('Auth state: $authState');

  if (!AuthService.isAuthenticated) {
    throw Exception('Login succeeded but session not established');
  }

  // Save credentials for biometric login if enabled
  if (_enableBiometricLogin && _isBiometricAvailable) {
    await BiometricAuthService.enableBiometricLogin(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  if (mounted) {
    context.showSuccess('Connexion réussie!');
    context.go('/home-enhanced');
  }
} catch (e) {
  // ... error handling
}
```

### Step 4: Add Auth State Listener (Optional but Recommended)

**File:** `lib/main.dart`

**In the `MyApp` widget, add an auth state listener:**

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      print('🔐 Auth state changed: $event');
      print('   Session: ${session != null}');
      print('   User: ${session?.user?.id}');

      if (event == AuthChangeEvent.signedOut) {
        print('👋 User signed out');
      } else if (event == AuthChangeEvent.signedIn) {
        print('👤 User signed in');
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        print('🔄 Token refreshed');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlombiPro',
      // ... rest of config
    );
  }
}
```

---

## 🧪 Testing the Fix

### Test 1: Check Auth on Login

1. Run the app: `flutter run`
2. Log in with credentials
3. Check console output for:
   ```
   🔍 Verifying auth after login...
   Auth state: {is_authenticated: true, user_id: 6b1d26bf-40d7-46c0-9b07-89a120191971, ...}
   ```

### Test 2: Check Dashboard Data Fetch

1. After login, navigate to dashboard
2. Check console for:
   ```
   🔍 === AUTH STATE DEBUG ===
     is_authenticated: true
     user_id: 6b1d26bf-40d7-46c0-9b07-89a120191971
     access_token_exists: true
   🔍 === END AUTH STATE ===

   📥 Fetching clients...
     User ID: 6b1d26bf-40d7-46c0-9b07-89a120191971
     Access Token present: true
     Executing query...
   ✅ Fetched 11 clients
   ```

### Test 3: Verify Dashboard Shows Data

1. Dashboard should now show:
   - **11 clients** (not 0)
   - **5 quotes**
   - **4 invoices**
   - **22 products**
   - **2 payments**
   - **4 job sites**

### Test 4: Test Create Client

1. Try creating a new client
2. Check console for:
   ```
   📤 Creating client...
     User ID: 6b1d26bf-40d7-46c0-9b07-89a120191971
     Client name: Test Client
     Inserting with data: user_id, client_type, first_name, ...
   ✅ Client created: <client-id>
   ```

---

## 🔍 Debugging Tools

### Tool 1: Auth State Diagnostic

Add this button temporarily to your dashboard:

```dart
ElevatedButton(
  onPressed: () async {
    final state = await AuthService.debugAuthState();
    print('=== AUTH STATE ===');
    state.forEach((key, value) {
      print('$key: $value');
    });
  },
  child: Text('Debug Auth'),
)
```

### Tool 2: Check Session Persistence

Add this to check if session persists after app restart:

```dart
@override
void initState() {
  super.initState();
  _checkSessionOnStart();
}

Future<void> _checkSessionOnStart() async {
  print('🔍 Checking session on app start...');
  final session = Supabase.instance.client.auth.currentSession;
  final user = Supabase.instance.client.auth.currentUser;

  print('Session exists: ${session != null}');
  print('User exists: ${user != null}');
  print('User ID: ${user?.id}');

  if (session == null || user == null) {
    print('⚠️ WARNING: Session not restored! User needs to log in again.');
  } else {
    print('✅ Session restored successfully');
  }
}
```

---

## 🚨 Common Issues and Fixes

### Issue 1: "User not authenticated" Error

**Symptoms:** Console shows `❌ FATAL: API call attempted without authentication!`

**Cause:** Session not established or expired

**Fix:**
1. Check if user is logged in: `AuthService.isAuthenticated`
2. Force login again: Log out and back in
3. Check token expiry: Look at console logs for "Token expires in"

### Issue 2: Session Not Persisting After Restart

**Symptoms:** User has to log in every time app restarts

**Cause:** Session storage issue

**Fix:**
1. Check if using correct storage (default is secure storage)
2. Verify no errors during Supabase initialization
3. Check Android/iOS permissions for secure storage

**Add to `main.dart`:**
```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authFlowType: AuthFlowType.pkce, // Add this for better security
  debug: true, // Add this to see detailed logs
);
```

### Issue 3: Still Shows 0 Clients After Fix

**Symptoms:** Dashboard still displays 0 despite auth working

**Cause:** Caching or state not updating

**Fix:**
1. Add `setState(() {})` after fetching data
2. Force refresh with pull-to-refresh
3. Clear app data and reinstall
4. Check console logs for actual data fetched

### Issue 4: Token Expired Error

**Symptoms:** `JWT expired` or `invalid_token` errors

**Cause:** Access token expired and not refreshing

**Fix:** The `AuthService.refreshSessionIfNeeded()` should handle this automatically, but you can force refresh:

```dart
try {
  await Supabase.instance.client.auth.refreshSession();
  print('✅ Token refreshed');
} catch (e) {
  print('❌ Token refresh failed: $e');
  // Force logout and re-login
  await AuthService.signOut();
  context.go('/login');
}
```

---

## ✅ Success Criteria

Mark this as complete when:

- [ ] Console shows `✅ Fetched 11 clients` (not errors)
- [ ] Dashboard displays **11 clients**
- [ ] Dashboard displays **5 quotes**
- [ ] Dashboard displays **4 invoices**
- [ ] Can create new client successfully
- [ ] Console shows auth state with `user_id: 6b1d26bf-40d7-46c0-9b07-89a120191971`
- [ ] No "User not authenticated" errors in console
- [ ] Session persists after app restart

---

## 🔄 Next Steps After Auth Fix

Once authentication is working and dashboard shows data:

1. ✅ Database RLS policies (complete)
2. ✅ Auth token transmission (this fix)
3. ⏳ Fix /home routing error
4. ⏳ Fix white-on-white text fields
5. ⏳ Fix error message positioning
6. ⏳ Implement OCR smart categorization

---

**Created:** 2025-11-12
**Purpose:** Fix auth token not being sent with API requests
**Priority:** P0 - Critical
**Status:** Ready to apply
