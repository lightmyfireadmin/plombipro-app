import 'package:supabase_flutter/supabase_flutter.dart';

/// Database Diagnostic Tool
/// Use this to diagnose database connection and RLS policy issues
class DatabaseDiagnostic {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Run comprehensive database diagnostics
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    try {
      // 1. Check authentication
      final authCheck = await _checkAuthentication();
      results['authentication'] = authCheck;

      // 2. Check database connection
      final connectionCheck = await _checkDatabaseConnection();
      results['connection'] = connectionCheck;

      // 3. Check RLS policies
      final rlsCheck = await _checkRLSPolicies();
      results['rls_policies'] = rlsCheck;

      // 4. Check data counts
      final dataCheck = await _checkDataCounts();
      results['data_counts'] = dataCheck;

      // 5. Check user_id consistency
      final userIdCheck = await _checkUserIdConsistency();
      results['user_id_check'] = userIdCheck;

      results['status'] = 'success';
      results['timestamp'] = DateTime.now().toIso8601String();
    } catch (e, stackTrace) {
      results['status'] = 'error';
      results['error'] = e.toString();
      results['stack_trace'] = stackTrace.toString();
    }

    return results;
  }

  /// Check if user is authenticated
  static Future<Map<String, dynamic>> _checkAuthentication() async {
    try {
      final user = _client.auth.currentUser;

      return {
        'is_authenticated': user != null,
        'user_id': user?.id,
        'email': user?.email,
        'created_at': user?.createdAt,
      };
    } catch (e) {
      return {
        'is_authenticated': false,
        'error': e.toString(),
      };
    }
  }

  /// Check database connection
  static Future<Map<String, dynamic>> _checkDatabaseConnection() async {
    try {
      // Try a simple query
      final response = await _client
          .from('profiles')
          .select('id')
          .limit(1);

      return {
        'connected': true,
        'response_type': response.runtimeType.toString(),
      };
    } catch (e) {
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  /// Check RLS policies by attempting to query each table
  static Future<Map<String, dynamic>> _checkRLSPolicies() async {
    final results = <String, dynamic>{};
    final user = _client.auth.currentUser;

    if (user == null) {
      return {'error': 'User not authenticated'};
    }

    final tables = [
      'clients',
      'quotes',
      'invoices',
      'products',
      'payments',
      'job_sites',
      'profiles',
    ];

    for (final table in tables) {
      try {
        final response = await _client
            .from(table)
            .select('id')
            .limit(1);

        results[table] = {
          'accessible': true,
          'row_count': (response as List).length,
        };
      } catch (e) {
        results[table] = {
          'accessible': false,
          'error': e.toString(),
        };
      }
    }

    return results;
  }

  /// Check actual data counts in each table
  static Future<Map<String, dynamic>> _checkDataCounts() async {
    final results = <String, dynamic>{};
    final user = _client.auth.currentUser;

    if (user == null) {
      return {'error': 'User not authenticated'};
    }

    // Clients
    try {
      final clientsResponse = await _client
          .from('clients')
          .select('id')
          .eq('user_id', user.id);
      results['clients'] = (clientsResponse as List).length;
    } catch (e) {
      results['clients'] = {'error': e.toString()};
    }

    // Quotes
    try {
      final quotesResponse = await _client
          .from('quotes')
          .select('id')
          .eq('user_id', user.id);
      results['quotes'] = (quotesResponse as List).length;
    } catch (e) {
      results['quotes'] = {'error': e.toString()};
    }

    // Invoices
    try {
      final invoicesResponse = await _client
          .from('invoices')
          .select('id')
          .eq('user_id', user.id);
      results['invoices'] = (invoicesResponse as List).length;
    } catch (e) {
      results['invoices'] = {'error': e.toString()};
    }

    // Products
    try {
      final productsResponse = await _client
          .from('products')
          .select('id')
          .eq('user_id', user.id);
      results['products'] = (productsResponse as List).length;
    } catch (e) {
      results['products'] = {'error': e.toString()};
    }

    // Payments
    try {
      final paymentsResponse = await _client
          .from('payments')
          .select('id')
          .eq('user_id', user.id);
      results['payments'] = (paymentsResponse as List).length;
    } catch (e) {
      results['payments'] = {'error': e.toString()};
    }

    // Job Sites
    try {
      final jobSitesResponse = await _client
          .from('job_sites')
          .select('id')
          .eq('user_id', user.id);
      results['job_sites'] = (jobSitesResponse as List).length;
    } catch (e) {
      results['job_sites'] = {'error': e.toString()};
    }

    return results;
  }

  /// Check if user_id is consistent across tables
  static Future<Map<String, dynamic>> _checkUserIdConsistency() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return {'error': 'User not authenticated'};
    }

    try {
      // Check clients table for any rows without proper user_id
      final clientsWithWrongUserId = await _client
          .from('clients')
          .select('id, user_id')
          .neq('user_id', user.id)
          .limit(5);

      // Check quotes table
      final quotesWithWrongUserId = await _client
          .from('quotes')
          .select('id, user_id')
          .neq('user_id', user.id)
          .limit(5);

      return {
        'current_user_id': user.id,
        'clients_with_wrong_user_id': (clientsWithWrongUserId as List).length,
        'quotes_with_wrong_user_id': (quotesWithWrongUserId as List).length,
        'note': 'If counts are > 0, data belongs to different users (expected in multi-user app)',
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Test creating a client (write operation)
  static Future<Map<String, dynamic>> testClientCreation() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a test client
      final testClient = {
        'user_id': user.id,
        'client_type': 'individual',
        'first_name': 'Test',
        'last_name': 'Diagnostic',
        'email': 'test@diagnostic.local',
        'phone': '0000000000',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('clients')
          .insert(testClient)
          .select()
          .single();

      final insertedId = response['id'];

      // Try to read it back
      final readBack = await _client
          .from('clients')
          .select('*')
          .eq('id', insertedId)
          .eq('user_id', user.id)
          .single();

      // Delete the test client
      await _client
          .from('clients')
          .delete()
          .eq('id', insertedId)
          .eq('user_id', user.id);

      return {
        'success': true,
        'inserted_id': insertedId,
        'read_back': readBack != null,
        'deleted': true,
      };
    } catch (e, stackTrace) {
      return {
        'success': false,
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      };
    }
  }

  /// Format diagnostic results for display
  static String formatResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== DATABASE DIAGNOSTIC REPORT ===');
    buffer.writeln('Timestamp: ${results['timestamp'] ?? DateTime.now()}');
    buffer.writeln('Status: ${results['status']}');
    buffer.writeln('');

    if (results['status'] == 'error') {
      buffer.writeln('ERROR: ${results['error']}');
      buffer.writeln('');
      buffer.writeln('Stack Trace:');
      buffer.writeln(results['stack_trace']);
      return buffer.toString();
    }

    // Authentication
    buffer.writeln('--- AUTHENTICATION ---');
    final auth = results['authentication'] as Map?;
    if (auth != null) {
      buffer.writeln('  Authenticated: ${auth['is_authenticated']}');
      buffer.writeln('  User ID: ${auth['user_id']}');
      buffer.writeln('  Email: ${auth['email']}');
    }
    buffer.writeln('');

    // Connection
    buffer.writeln('--- DATABASE CONNECTION ---');
    final conn = results['connection'] as Map?;
    if (conn != null) {
      buffer.writeln('  Connected: ${conn['connected']}');
      if (conn['error'] != null) {
        buffer.writeln('  Error: ${conn['error']}');
      }
    }
    buffer.writeln('');

    // RLS Policies
    buffer.writeln('--- RLS POLICIES ---');
    final rls = results['rls_policies'] as Map?;
    if (rls != null) {
      rls.forEach((table, status) {
        if (status is Map) {
          buffer.writeln('  $table: ${status['accessible'] ? 'ACCESSIBLE' : 'BLOCKED'}');
          if (status['error'] != null) {
            buffer.writeln('    Error: ${status['error']}');
          }
        }
      });
    }
    buffer.writeln('');

    // Data Counts
    buffer.writeln('--- DATA COUNTS ---');
    final counts = results['data_counts'] as Map?;
    if (counts != null) {
      counts.forEach((table, count) {
        buffer.writeln('  $table: $count');
      });
    }
    buffer.writeln('');

    // User ID Consistency
    buffer.writeln('--- USER ID CONSISTENCY ---');
    final userIdCheck = results['user_id_check'] as Map?;
    if (userIdCheck != null) {
      buffer.writeln('  Current User ID: ${userIdCheck['current_user_id']}');
      buffer.writeln('  Clients with wrong user_id: ${userIdCheck['clients_with_wrong_user_id']}');
      buffer.writeln('  Quotes with wrong user_id: ${userIdCheck['quotes_with_wrong_user_id']}');
    }

    buffer.writeln('');
    buffer.writeln('=== END OF REPORT ===');

    return buffer.toString();
  }
}
