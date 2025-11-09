import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/result.dart';
import '../models/quote.dart';
import '../models/line_item.dart';
import '../services/supabase_service.dart';

part 'quote_repository.g.dart';

/// Repository for quote data operations
class QuoteRepository extends BaseRepository {
  /// Fetch all quotes for the current user
  Future<Result<List<Quote>>> getQuotes() async {
    return execute(
      () => SupabaseService.fetchQuotes(),
      errorMessage: 'Impossible de récupérer les devis',
    );
  }

  /// Get a specific quote by ID
  Future<Result<Quote>> getQuoteById(String quoteId) async {
    return execute(
      () async {
        final quote = await SupabaseService.fetchQuoteById(quoteId);
        if (quote == null) {
          throw Exception('Quote not found');
        }
        return quote;
      },
      errorMessage: 'Impossible de récupérer le devis',
    );
  }

  /// Get quotes for a specific client
  Future<Result<List<Quote>>> getQuotesByClient(String clientId) async {
    return execute(
      () => SupabaseService.fetchQuotesByClient(clientId),
      errorMessage: 'Impossible de récupérer les devis du client',
    );
  }

  /// Create a new quote
  Future<Result<String>> createQuote(Quote quote) async {
    return execute(
      () => SupabaseService.createQuote(quote),
      errorMessage: 'Impossible de créer le devis',
    );
  }

  /// Update an existing quote
  Future<Result<void>> updateQuote(String quoteId, Quote quote) async {
    return execute(
      () => SupabaseService.updateQuote(quoteId, quote),
      errorMessage: 'Impossible de mettre à jour le devis',
    );
  }

  /// Delete a quote
  Future<Result<void>> deleteQuote(String quoteId) async {
    return execute(
      () => SupabaseService.deleteQuote(quoteId),
      errorMessage: 'Impossible de supprimer le devis',
    );
  }

  /// Create line items for a quote
  Future<Result<void>> createLineItems(
    String quoteId,
    List<LineItem> items,
  ) async {
    return execute(
      () => SupabaseService.createLineItems(quoteId, items),
      errorMessage: 'Impossible de créer les lignes du devis',
    );
  }

  /// Get quotes by status
  Future<Result<List<Quote>>> getQuotesByStatus(String status) async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        return quotes.where((quote) => quote.status == status).toList();
      },
      errorMessage: 'Impossible de filtrer les devis par statut',
    );
  }

  /// Get pending quotes (draft or sent)
  Future<Result<List<Quote>>> getPendingQuotes() async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        return quotes
            .where((quote) =>
                quote.status == 'draft' || quote.status == 'sent')
            .toList();
      },
      errorMessage: 'Impossible de récupérer les devis en attente',
    );
  }

  /// Get accepted quotes
  Future<Result<List<Quote>>> getAcceptedQuotes() async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        return quotes.where((quote) => quote.status == 'accepted').toList();
      },
      errorMessage: 'Impossible de récupérer les devis acceptés',
    );
  }

  /// Get quotes within a date range
  Future<Result<List<Quote>>> getQuotesByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        return quotes.where((quote) {
          final quoteDate = quote.quoteDate;
          return quoteDate.isAfter(start) && quoteDate.isBefore(end);
        }).toList();
      },
      errorMessage: 'Impossible de récupérer les devis par période',
    );
  }

  /// Search quotes by quote number or client name
  Future<Result<List<Quote>>> searchQuotes(String query) async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        final lowerQuery = query.toLowerCase();
        return quotes.where((quote) {
          final quoteNumber = quote.quoteNumber.toLowerCase();
          return quoteNumber.contains(lowerQuery);
        }).toList();
      },
      errorMessage: 'Impossible de rechercher les devis',
    );
  }

  /// Calculate total amount for quotes
  Future<Result<double>> getTotalQuotesAmount() async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        return quotes.fold<double>(
          0,
          (sum, quote) => sum + quote.totalTTC,
        );
      },
      errorMessage: 'Impossible de calculer le montant total',
    );
  }

  /// Get conversion rate (accepted / total quotes)
  Future<Result<double>> getConversionRate() async {
    return execute(
      () async {
        final quotes = await SupabaseService.fetchQuotes();
        if (quotes.isEmpty) return 0.0;

        final acceptedCount =
            quotes.where((q) => q.status == 'accepted').length;
        return (acceptedCount / quotes.length) * 100;
      },
      errorMessage: 'Impossible de calculer le taux de conversion',
    );
  }
}

/// Provider for QuoteRepository
@riverpod
QuoteRepository quoteRepository(QuoteRepositoryRef ref) {
  return QuoteRepository();
}

/// Provider for quotes list
@riverpod
class QuotesNotifier extends _$QuotesNotifier {
  @override
  Future<List<Quote>> build() async {
    final repository = ref.watch(quoteRepositoryProvider);
    final result = await repository.getQuotes();
    return result.getOrElse(() => []);
  }

  /// Refresh quotes list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(quoteRepositoryProvider);
    final result = await repository.getQuotes();
    state = result.fold(
      onSuccess: (quotes) => AsyncValue.data(quotes),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Add a new quote
  Future<Result<String>> addQuote(Quote quote) async {
    final repository = ref.read(quoteRepositoryProvider);
    final result = await repository.createQuote(quote);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Update a quote
  Future<Result<void>> updateQuote(String quoteId, Quote quote) async {
    final repository = ref.read(quoteRepositoryProvider);
    final result = await repository.updateQuote(quoteId, quote);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Delete a quote
  Future<Result<void>> deleteQuote(String quoteId) async {
    final repository = ref.read(quoteRepositoryProvider);
    final result = await repository.deleteQuote(quoteId);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }
}

/// Provider for quotes by status
@riverpod
Future<List<Quote>> quotesByStatus(
  QuotesByStatusRef ref,
  String status,
) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getQuotesByStatus(status);
  return result.getOrElse(() => []);
}

/// Provider for pending quotes
@riverpod
Future<List<Quote>> pendingQuotes(PendingQuotesRef ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getPendingQuotes();
  return result.getOrElse(() => []);
}

/// Provider for accepted quotes
@riverpod
Future<List<Quote>> acceptedQuotes(AcceptedQuotesRef ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getAcceptedQuotes();
  return result.getOrElse(() => []);
}

/// Provider for a specific quote
@riverpod
Future<Quote?> quote(QuoteRef ref, String quoteId) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getQuoteById(quoteId);
  return result.dataOrNull;
}

/// Provider for quotes by client
@riverpod
Future<List<Quote>> quotesByClient(
  QuotesByClientRef ref,
  String clientId,
) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getQuotesByClient(clientId);
  return result.getOrElse(() => []);
}

/// Provider for conversion rate
@riverpod
Future<double> quoteConversionRate(QuoteConversionRateRef ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  final result = await repository.getConversionRate();
  return result.getOrElse(() => 0.0);
}
