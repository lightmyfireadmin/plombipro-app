import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import 'auth_service.dart';

/// Enhanced Supabase Service with proper auth checking
/// This wraps the original SupabaseService with auth verification
class SupabaseServiceEnhanced {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch clients with auth verification
  static Future<List<Client>> fetchClients({int? limit, int? offset}) async {
    print('📥 Fetching clients...');

    // CRITICAL: Verify auth before making request
    AuthService.requireAuth();
    final userId = AuthService.currentUserId!;

    print('  User ID: $userId');
    print('  Access Token present: ${AuthService.accessToken != null}');

    try {
      // Refresh token if needed
      await AuthService.refreshSessionIfNeeded();

      var query = _client
          .from('clients')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      print('  Executing query...');
      final response = await query;

      final clients = (response as List)
          .map((item) => Client.fromJson(item))
          .toList();

      print('✅ Fetched ${clients.length} clients');
      return clients;
    } catch (e, stackTrace) {
      print('❌ Error fetching clients: $e');
      print('Stack trace: $stackTrace');

      // Check if it's an auth error
      if (e.toString().contains('JWT') || e.toString().contains('auth')) {
        print('⚠️ This appears to be an authentication error!');
        print('⚠️ Session state: ${await AuthService.debugAuthState()}');
      }

      rethrow;
    }
  }

  /// Create client with auth verification
  static Future<String> createClient(Client client) async {
    print('📤 Creating client...');

    AuthService.requireAuth();
    final userId = AuthService.currentUserId!;

    print('  User ID: $userId');
    print('  Client name: ${client.name}');

    try {
      await AuthService.refreshSessionIfNeeded();

      final clientData = {
        ...client.toJson(),
        'user_id': userId,
      };

      print('  Inserting with data: ${clientData.keys.join(', ')}');

      final response = await _client
          .from('clients')
          .insert(clientData)
          .select()
          .single();

      final clientId = response['id'] as String;
      print('✅ Client created: $clientId');
      return clientId;
    } catch (e, stackTrace) {
      print('❌ Error creating client: $e');
      print('Stack trace: $stackTrace');

      if (e.toString().contains('JWT') || e.toString().contains('auth')) {
        print('⚠️ Authentication error detected!');
        final authState = await AuthService.debugAuthState();
        print('⚠️ Auth state: $authState');
      }

      rethrow;
    }
  }

  /// Fetch quotes with auth verification
  static Future<List<Quote>> fetchQuotes({int? limit, int? offset}) async {
    print('📥 Fetching quotes...');

    AuthService.requireAuth();
    final userId = AuthService.currentUserId!;

    try {
      await AuthService.refreshSessionIfNeeded();

      var query = _client
          .from('quotes')
          .select('''
            *,
            quote_items(*),
            clients(id, first_name, last_name, company_name, email)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      final quotes = (response as List)
          .map((item) => Quote.fromJson(item))
          .toList();

      print('✅ Fetched ${quotes.length} quotes');
      return quotes;
    } catch (e, stackTrace) {
      print('❌ Error fetching quotes: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch invoices with auth verification
  static Future<List<Invoice>> fetchInvoices({int? limit, int? offset}) async {
    print('📥 Fetching invoices...');

    AuthService.requireAuth();
    final userId = AuthService.currentUserId!;

    try {
      await AuthService.refreshSessionIfNeeded();

      var query = _client
          .from('invoices')
          .select('''
            *,
            invoice_items(*),
            clients(id, first_name, last_name, company_name, email)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      final invoices = (response as List)
          .map((item) => Invoice.fromJson(item))
          .toList();

      print('✅ Fetched ${invoices.length} invoices');
      return invoices;
    } catch (e, stackTrace) {
      print('❌ Error fetching invoices: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Debug: Print current auth state
  static Future<void> printAuthState() async {
    print('🔍 === AUTH STATE DEBUG ===');
    final state = await AuthService.debugAuthState();
    state.forEach((key, value) {
      print('  $key: $value');
    });
    print('🔍 === END AUTH STATE ===');
  }
}
