import '../models/quote.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import 'supabase_service.dart';
import 'offline_storage_service.dart';

/// Offline-aware service wrapper (Phase 10)
///
/// Automatically handles online/offline scenarios:
/// - When online: Fetches from Supabase and caches locally
/// - When offline: Returns cached data and queues operations
/// - Automatic sync when connection is restored
class OfflineAwareService {
  // ==================== QUOTES ====================

  /// Fetch quotes with offline fallback
  static Future<List<Quote>> fetchQuotes({int? limit, int? offset}) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        // Online: Fetch from Supabase and cache
        final quotes = await SupabaseService.fetchQuotes(
          limit: limit,
          offset: offset,
        );
        await OfflineStorageService.cacheQuotes(quotes);
        return quotes;
      } else {
        // Offline: Return cached data
        return OfflineStorageService.getCachedQuotes();
      }
    } catch (e) {
      // On error, return cached data as fallback
      return OfflineStorageService.getCachedQuotes();
    }
  }

  /// Get quote by ID with offline fallback
  static Future<Quote?> getQuoteById(String id) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final quote = await SupabaseService.getQuoteById(id);
        if (quote != null) {
          await OfflineStorageService.cacheQuote(quote);
        }
        return quote;
      } else {
        return OfflineStorageService.getCachedQuote(id);
      }
    } catch (e) {
      return OfflineStorageService.getCachedQuote(id);
    }
  }

  /// Create quote (queued if offline)
  static Future<String> createQuote(Quote quote) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final id = await SupabaseService.createQuote(quote);
        final createdQuote = quote.copyWith(id: id);
        await OfflineStorageService.cacheQuote(createdQuote);
        return id;
      } else {
        // Offline: Cache and queue for later sync
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final offlineQuote = quote.copyWith(id: tempId);
        await OfflineStorageService.cacheQuote(offlineQuote);
        await OfflineStorageService.queueOperation(
          type: 'create',
          entity: 'quote',
          id: tempId,
          data: offlineQuote.toJson(),
        );
        return tempId;
      }
    } catch (e) {
      // On error, save offline
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final offlineQuote = quote.copyWith(id: tempId);
      await OfflineStorageService.cacheQuote(offlineQuote);
      await OfflineStorageService.queueOperation(
        type: 'create',
        entity: 'quote',
        id: tempId,
        data: offlineQuote.toJson(),
      );
      rethrow;
    }
  }

  /// Update quote (queued if offline)
  static Future<void> updateQuote(String quoteId, Quote quote) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        await SupabaseService.updateQuote(quoteId, quote);
        await OfflineStorageService.cacheQuote(quote);
      } else {
        // Offline: Cache and queue for later sync
        await OfflineStorageService.cacheQuote(quote);
        await OfflineStorageService.queueOperation(
          type: 'update',
          entity: 'quote',
          id: quoteId,
          data: quote.toJson(),
        );
      }
    } catch (e) {
      // On error, save offline
      await OfflineStorageService.cacheQuote(quote);
      await OfflineStorageService.queueOperation(
        type: 'update',
        entity: 'quote',
        id: quoteId,
        data: quote.toJson(),
      );
      rethrow;
    }
  }

  /// Delete quote (queued if offline)
  static Future<void> deleteQuote(String quoteId) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        await SupabaseService.deleteQuote(quoteId);
        await OfflineStorageService.deleteCachedQuote(quoteId);
      } else {
        // Offline: Delete from cache and queue for later sync
        await OfflineStorageService.deleteCachedQuote(quoteId);
        await OfflineStorageService.queueOperation(
          type: 'delete',
          entity: 'quote',
          id: quoteId,
        );
      }
    } catch (e) {
      // On error, delete from cache
      await OfflineStorageService.deleteCachedQuote(quoteId);
      await OfflineStorageService.queueOperation(
        type: 'delete',
        entity: 'quote',
        id: quoteId,
      );
      rethrow;
    }
  }

  // ==================== INVOICES ====================

  /// Fetch invoices with offline fallback
  static Future<List<Invoice>> fetchInvoices({int? limit, int? offset}) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final invoices = await SupabaseService.fetchInvoices(
          limit: limit,
          offset: offset,
        );
        await OfflineStorageService.cacheInvoices(invoices);
        return invoices;
      } else {
        return OfflineStorageService.getCachedInvoices();
      }
    } catch (e) {
      return OfflineStorageService.getCachedInvoices();
    }
  }

  /// Create invoice (queued if offline)
  static Future<String> createInvoice(Invoice invoice) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final id = await SupabaseService.createInvoice(invoice);
        final createdInvoice = invoice.copyWith(id: id);
        await OfflineStorageService.cacheInvoice(createdInvoice);
        return id;
      } else {
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final offlineInvoice = invoice.copyWith(id: tempId);
        await OfflineStorageService.cacheInvoice(offlineInvoice);
        await OfflineStorageService.queueOperation(
          type: 'create',
          entity: 'invoice',
          id: tempId,
          data: offlineInvoice.toJson(),
        );
        return tempId;
      }
    } catch (e) {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final offlineInvoice = invoice.copyWith(id: tempId);
      await OfflineStorageService.cacheInvoice(offlineInvoice);
      await OfflineStorageService.queueOperation(
        type: 'create',
        entity: 'invoice',
        id: tempId,
        data: offlineInvoice.toJson(),
      );
      rethrow;
    }
  }

  // ==================== CLIENTS ====================

  /// Fetch clients with offline fallback
  static Future<List<Client>> fetchClients({int? limit, int? offset}) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final clients = await SupabaseService.fetchClients(
          limit: limit,
          offset: offset,
        );
        await OfflineStorageService.cacheClients(clients);
        return clients;
      } else {
        return OfflineStorageService.getCachedClients();
      }
    } catch (e) {
      return OfflineStorageService.getCachedClients();
    }
  }

  /// Create client (queued if offline)
  static Future<String> createClient(Client client) async {
    try {
      final isOnline = await OfflineStorageService.isOnline();

      if (isOnline) {
        final id = await SupabaseService.createClient(client);
        final createdClient = client.copyWith(id: id);
        await OfflineStorageService.cacheClient(createdClient);
        return id;
      } else {
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final offlineClient = client.copyWith(id: tempId);
        await OfflineStorageService.cacheClient(offlineClient);
        await OfflineStorageService.queueOperation(
          type: 'create',
          entity: 'client',
          id: tempId,
          data: offlineClient.toJson(),
        );
        return tempId;
      }
    } catch (e) {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final offlineClient = client.copyWith(id: tempId);
      await OfflineStorageService.cacheClient(offlineClient);
      await OfflineStorageService.queueOperation(
        type: 'create',
        entity: 'client',
        id: tempId,
        data: offlineClient.toJson(),
      );
      rethrow;
    }
  }

  // ==================== SYNC ====================

  /// Manually trigger sync
  static Future<SyncResult> sync() async {
    return await OfflineStorageService.syncPendingOperations();
  }

  /// Check if there are pending operations
  static bool hasPendingOperations() {
    return OfflineStorageService.getPendingOperations().isNotEmpty;
  }

  /// Get number of pending operations
  static int getPendingOperationsCount() {
    return OfflineStorageService.getPendingOperations().length;
  }
}

/// Extension for Quote model
extension QuoteCopyWith on Quote {
  Quote copyWith({String? id}) {
    return Quote(
      id: id ?? this.id,
      userId: userId,
      quoteNumber: quoteNumber,
      clientId: clientId,
      date: date,
      expiryDate: expiryDate,
      status: status,
      totalHt: totalHt,
      totalTva: totalTva,
      totalTtc: totalTtc,
      notes: notes,
      items: items,
    );
  }
}

/// Extension for Invoice model
extension InvoiceCopyWith on Invoice {
  Invoice copyWith({String? id}) {
    return Invoice(
      id: id ?? this.id,
      userId: userId,
      number: number,
      clientId: clientId,
      date: date,
      dueDate: dueDate,
      totalHt: totalHt,
      totalTva: totalTva,
      totalTtc: totalTtc,
      notes: notes,
      items: items,
    );
  }
}

/// Extension for Client model
extension ClientCopyWith on Client {
  Client copyWith({String? id}) {
    return Client(
      id: id ?? this.id,
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
    );
  }
}
