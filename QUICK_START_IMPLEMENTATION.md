# PlombiPro - Quick Start Implementation Guide
## Priority 1 Critical Fixes - Code Examples

**Date:** 2025-11-07
**Target:** Immediate deployment (Week 1)

---

## Fix 1: Duplicated Burger Menu Icon (CRITICAL)

### Problem Location
`lib/screens/home/home_page.dart`

### Current Issue
```dart
// home_page.dart lines 141-154
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('PlombiPro'),
      actions: [...]
    ),
    drawer: _buildAppDrawer(),  // ← Creates first hamburger icon
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchDashboardData,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),  // ← This contains SliverAppBar with duplicate icon!
                ...
              ],
            ),
          ),
  );
}

// home_page.dart lines 213-235 (PROBLEM!)
Widget _buildHeader() {
  return SliverAppBar(
    pinned: true,  // ← Creates a SECOND persistent app bar
    expandedHeight: 120.0,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    flexibleSpace: FlexibleSpaceBar(...),
  );
}

// home_page.dart lines 192-210 (INCONSISTENCY!)
Widget _buildAppDrawer() {
  return Drawer(
    child: ListView(...),  // ← Local drawer implementation
  );
}
```

### Solution 1: Remove SliverAppBar (Immediate Fix)

**Replace `_buildHeader()` with a simple header widget:**

```dart
// REMOVE the entire _buildHeader() method (lines 212-236)

// REPLACE the CustomScrollView slivers with:
child: CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting header (no longer in SliverAppBar)
            Text(
              'Bonjour, Utilisateur!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              InvoiceCalculator.formatDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Statistiques Rapides'),
            _buildQuickStatsGrid(),
            // ... rest of the content
          ],
        ),
      ),
    ),
  ],
),
```

### Solution 2: Use Canonical AppDrawer Widget

**Remove the local `_buildAppDrawer()` method and import the canonical widget:**

```dart
// At the top of home_page.dart, ADD:
import '../../widgets/app_drawer.dart';

// REMOVE the entire _buildAppDrawer() method (lines 192-210)

// UPDATE the Scaffold to use the canonical widget:
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('PlombiPro'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage())
            );
          },
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings),
        ),
      ],
    ),
    drawer: const AppDrawer(),  // ← Use canonical widget
    body: _isLoading ? const Center(child: CircularProgressIndicator()) : ...,
  );
}
```

### Complete Fixed Code for HomePage

```dart
// lib/screens/home/home_page.dart (FIXED VERSION)

import 'package:flutter/material.dart';
import '../notifications/notifications_page.dart';
import 'package:go_router/go_router.dart';

import '../../models/activity.dart';
import '../../models/appointment.dart';
import '../../models/invoice.dart';
import '../../models/job_site.dart';
import '../../models/payment.dart';
import '../../models/quote.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../widgets/section_header.dart';
import '../../widgets/app_drawer.dart';  // ← ADD THIS
import '../clients/client_form_page.dart';
import '../quotes/quote_form_page.dart';
import '../quotes/quotes_list_page.dart';
import './widgets/revenue_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<Quote> _quotes = [];
  List<Invoice> _invoices = [];
  List<JobSite> _jobSites = [];
  List<Payment> _payments = [];
  List<Activity> _activityFeed = [];
  List<Appointment> _upcomingAppointments = [];

  double _monthlyRevenue = 0;
  int _pendingQuotesCount = 0;
  double _unpaidInvoicesAmount = 0;
  int _activeJobSitesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final quotes = await SupabaseService.fetchQuotes();
      final invoices = await SupabaseService.fetchInvoices();
      final jobSites = await SupabaseService.getJobSites();
      final payments = await SupabaseService.getPayments();
      final appointments = await SupabaseService.fetchUpcomingAppointments();
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _invoices = invoices;
          _jobSites = jobSites;
          _payments = payments;
          _upcomingAppointments = appointments;
          _calculateStats();
          _prepareActivityFeed();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du tableau de bord: ${e.toString()}")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _prepareActivityFeed() {
    List<Activity> feed = [];
    for (var quote in _quotes) {
      feed.add(Activity(item: quote, date: quote.date, type: ActivityType.quote));
    }
    for (var invoice in _invoices) {
      feed.add(Activity(item: invoice, date: invoice.date, type: ActivityType.invoice));
    }
    for (var payment in _payments) {
      feed.add(Activity(item: payment, date: payment.paymentDate, type: ActivityType.payment));
    }

    feed.sort((a, b) => b.date.compareTo(a.date));
    _activityFeed = feed.take(5).toList();
  }

  void _calculateStats() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    double monthlyRev = 0;
    int pendingCount = 0;
    double unpaidAmount = 0;
    int activeJobSites = 0;

    for (final quote in _quotes) {
      if (quote.status == 'accepted' && quote.date.month == currentMonth && quote.date.year == currentYear) {
        monthlyRev += quote.totalTtc;
      }
      if (quote.status == 'sent') {
        pendingCount++;
      }
    }

    for (final invoice in _invoices) {
      if (invoice.paymentStatus != 'paid') {
        unpaidAmount += invoice.balanceDue;
      }
    }

    for (final jobSite in _jobSites) {
      if (jobSite.status == 'in_progress') {
        activeJobSites++;
      }
    }

    setState(() {
      _monthlyRevenue = monthlyRev;
      _pendingQuotesCount = pendingCount;
      _unpaidInvoicesAmount = unpaidAmount;
      _activeJobSitesCount = activeJobSites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlombiPro'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
            },
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      drawer: const AppDrawer(),  // ← FIXED: Use canonical drawer
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(  // ← FIXED: Removed CustomScrollView
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ← FIXED: Header as regular widget, not SliverAppBar
                    Text(
                      'Bonjour, Utilisateur!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      InvoiceCalculator.formatDate(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Statistiques Rapides'),
                    _buildQuickStatsGrid(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Revenus des 12 derniers mois'),
                    RevenueChart(quotes: _quotes),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Activité Récente'),
                    _buildRecentActivityList(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Rendez-vous à venir'),
                    _buildUpcomingAppointments(),
                    const Divider(height: 32),
                    const SectionHeader(title: 'Actions Rapides'),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  // REMOVED: _buildAppDrawer() method
  // REMOVED: _buildHeader() method

  // Rest of the methods remain the same...
  Widget _buildQuickStatsGrid() { /* ... */ }
  Widget _buildRecentActivityList() { /* ... */ }
  Widget _buildUpcomingAppointments() { /* ... */ }
  Widget _buildQuickActions() { /* ... */ }
}

// Helper widgets (_StatCard, _ActivityCard, _ActionButton) remain the same
```

---

## Fix 2: Add Consistent Back Navigation

### Problem
Users report being "trapped" on pages with no way to go back.

### Solution: Add Custom AppBar Widget

**Create new file: `lib/widgets/custom_app_bar.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we can pop (has previous route in stack)
    final canPop = GoRouter.of(context).canPop();

    return AppBar(
      title: Text(title),
      leading: automaticallyImplyLeading && canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
```

### Usage Example

**Update any page that might not have a back button:**

```dart
// BEFORE
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Mes Devis'),
    ),
    body: ...,
  );
}

// AFTER
import '../../widgets/custom_app_bar.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: 'Mes Devis',
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
      ],
    ),
    body: ...,
  );
}
```

### Alternative: Add WillPopScope for Android Back Button

```dart
@override
Widget build(BuildContext context) {
  return PopScope(  // Replaces deprecated WillPopScope in Flutter 3.12+
    canPop: true,
    onPopInvoked: (didPop) {
      if (didPop) {
        // Handle any cleanup before popping
        print('User navigated back');
      }
    },
    child: Scaffold(
      appBar: CustomAppBar(title: 'Page Title'),
      body: ...,
    ),
  );
}
```

---

## Fix 3: Biometric Authentication

### Add Dependencies

**Update `pubspec.yaml`:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing dependencies...
  supabase_flutter: ^2.0.0
  go_router: 14.1.4

  # NEW: Add these for biometric auth
  local_auth: ^2.1.7
  flutter_secure_storage: ^9.0.0
```

### Create Biometric Auth Service

**Create new file: `lib/services/biometric_auth_service.dart`**

```dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types (fingerprint, face, iris, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à PlombiPro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Store credentials securely (encrypted)
  static Future<void> storeCredentials(String email, String password) async {
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_password', value: password);
  }

  // Retrieve stored credentials
  static Future<Map<String, String?>> getStoredCredentials() async {
    final email = await _secureStorage.read(key: 'user_email');
    final password = await _secureStorage.read(key: 'user_password');
    return {'email': email, 'password': password};
  }

  // Clear stored credentials
  static Future<void> clearStoredCredentials() async {
    await _secureStorage.delete(key: 'user_email');
    await _secureStorage.delete(key: 'user_password');
  }

  // Check if biometric login is enabled
  static Future<bool> isBiometricLoginEnabled() async {
    final credentials = await getStoredCredentials();
    return credentials['email'] != null && credentials['password'] != null;
  }
}
```

### Update Login Page

**Update `lib/screens/auth/login_page.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/biometric_auth_service.dart';  // ← ADD THIS

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricAuthService.isBiometricAvailable();
    final enabled = await BiometricAuthService.isBiometricLoginEnabled();
    setState(() {
      _biometricAvailable = available;
      _biometricLoginEnabled = enabled;
    });

    // If biometric is available and enabled, prompt immediately
    if (_biometricAvailable && _biometricLoginEnabled) {
      _signInWithBiometric();
    }
  }

  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authenticated = await BiometricAuthService.authenticateWithBiometrics();
      if (authenticated) {
        final credentials = await BiometricAuthService.getStoredCredentials();
        if (credentials['email'] != null && credentials['password'] != null) {
          await SupabaseService.signIn(
            email: credentials['email']!,
            password: credentials['password']!,
          );
          if (mounted) {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentification biométrique échouée: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Ask if user wants to enable biometric login
      if (_biometricAvailable && mounted) {
        final enableBiometric = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Activer l\'authentification biométrique?'),
            content: const Text('Souhaitez-vous utiliser l\'authentification biométrique pour vos prochaines connexions?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Non merci'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Oui'),
              ),
            ],
          ),
        );

        if (enableBiometric == true) {
          await BiometricAuthService.storeCredentials(
            _emailController.text,
            _passwordController.text,
          );
        }
      }

      if (mounted) {
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue: ${e.toString()}')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or branding here
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Main login button
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Se connecter'),
                        ),
                      ),

                const SizedBox(height: 16),

                // Biometric login button (if available)
                if (_biometricAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Connexion biométrique'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: const Text('Pas encore de compte? Inscrivez-vous'),
                ),

                TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: const Text('Mot de passe oublié?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Fix 4: Centralized Error Handling

### Create Error Handler Service

**Create new file: `lib/services/error_handler.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  serverError,
  notFound,
  unknown,
}

class ErrorHandler {
  static ErrorType _categorizeError(dynamic error) {
    if (error is AuthException) {
      return ErrorType.authentication;
    } else if (error is PostgrestException) {
      if (error.code == 'PGRST116') {
        return ErrorType.notFound;
      }
      return ErrorType.serverError;
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return ErrorType.network;
    } else {
      return ErrorType.unknown;
    }
  }

  static String _getUserFriendlyMessage(ErrorType errorType, dynamic error) {
    switch (errorType) {
      case ErrorType.network:
        return 'Problème de connexion. Veuillez vérifier votre connexion Internet.';
      case ErrorType.authentication:
        return 'Erreur d\'authentification. Veuillez vérifier vos identifiants.';
      case ErrorType.validation:
        return 'Les données saisies sont invalides. Veuillez vérifier les champs.';
      case ErrorType.serverError:
        return 'Une erreur serveur s\'est produite. Veuillez réessayer plus tard.';
      case ErrorType.notFound:
        return 'Élément non trouvé.';
      case ErrorType.unknown:
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }

  static void _logError(dynamic error, StackTrace? stackTrace) {
    // TODO: Integrate with Sentry or Firebase Crashlytics
    print('ERROR: $error');
    if (stackTrace != null) {
      print('STACK TRACE: $stackTrace');
    }
  }

  static void handle(BuildContext context, dynamic error, {StackTrace? stackTrace}) {
    final errorType = _categorizeError(error);
    final message = _getUserFriendlyMessage(errorType, error);
    _logError(error, stackTrace);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getErrorColor(errorType),
        action: errorType == ErrorType.network
            ? SnackBarAction(
                label: 'Réessayer',
                onPressed: () {
                  // Retry logic here
                },
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Color _getErrorColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.serverError:
      case ErrorType.notFound:
      case ErrorType.unknown:
        return Colors.red[700]!;
    }
  }

  static void showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

### Usage Example

**Update any page to use ErrorHandler:**

```dart
// BEFORE
try {
  final quotes = await SupabaseService.fetchQuotes();
  // ...
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur de chargement des devis: ${e.toString()}")),
    );
  }
}

// AFTER
import '../../services/error_handler.dart';

try {
  final quotes = await SupabaseService.fetchQuotes();
  // ...
} catch (e, stackTrace) {
  if (mounted) {
    ErrorHandler.handle(context, e, stackTrace: stackTrace);
  }
}

// For success messages
ErrorHandler.showSuccessMessage(context, 'Devis créé avec succès!');
```

---

## Testing Checklist

After implementing these fixes, test the following:

### Navigation Tests
- [ ] HomePage displays only ONE hamburger menu icon
- [ ] Drawer opens correctly from HomePage
- [ ] All other pages use the same AppDrawer widget
- [ ] Back button appears on all detail/form pages
- [ ] Back button works correctly (pops to previous screen)
- [ ] Android back button works on all pages

### Authentication Tests
- [ ] Standard email/password login works
- [ ] Biometric authentication prompt appears (if available)
- [ ] Biometric login works after enabling
- [ ] User can decline biometric authentication
- [ ] Stored credentials are secure (test by restarting app)
- [ ] Logout clears biometric credentials

### Error Handling Tests
- [ ] Disconnect Wi-Fi and try to load data (network error)
- [ ] Try to login with wrong credentials (auth error)
- [ ] User-friendly messages appear (not raw error strings)
- [ ] Errors are logged (check console)
- [ ] Retry button works for network errors

---

## Deployment Steps

1. **Create a new branch for these fixes:**
   ```bash
   git checkout -b fix/critical-navigation-and-auth
   ```

2. **Implement the fixes one by one:**
   - Fix duplicated burger menu
   - Add CustomAppBar widget
   - Add biometric authentication
   - Implement centralized error handling

3. **Test thoroughly on both iOS and Android**

4. **Run Flutter analyze and fix any issues:**
   ```bash
   flutter analyze
   flutter test
   ```

5. **Commit and push:**
   ```bash
   git add .
   git commit -m "Fix critical navigation and authentication issues

   - Remove duplicated burger menu icon in HomePage
   - Standardize AppDrawer usage across all screens
   - Add CustomAppBar with consistent back button logic
   - Implement biometric authentication support
   - Add centralized error handling with user-friendly messages"

   git push -u origin fix/critical-navigation-and-auth
   ```

6. **Create a pull request and merge after review**

---

## Estimated Time

- Fix 1 (Duplicated Menu): 1 hour
- Fix 2 (Back Navigation): 2 hours
- Fix 3 (Biometric Auth): 3-4 hours
- Fix 4 (Error Handling): 2-3 hours

**Total: 1-2 days for all critical fixes**

---

## Next Steps After These Fixes

1. Begin Phase 2: Visual Identity (see `APP_DESIGN_STRATEGIC_PLAN.md`)
2. Implement bottom navigation bar
3. Add glassmorphism design system
4. Create onboarding flow

---

**Ready to implement. Start with Fix 1 (duplicated menu) as it's the quickest win.**
