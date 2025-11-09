import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/result.dart';
import '../models/invoice.dart';
import '../models/line_item.dart';
import '../models/payment.dart';
import '../services/supabase_service.dart';

part 'invoice_repository.g.dart';

/// Repository for invoice data operations
class InvoiceRepository extends BaseRepository {
  /// Fetch all invoices for the current user
  Future<Result<List<Invoice>>> getInvoices() async {
    return execute(
      () => SupabaseService.fetchInvoices(),
      errorMessage: 'Impossible de récupérer les factures',
    );
  }

  /// Get a specific invoice by ID
  Future<Result<Invoice>> getInvoiceById(String invoiceId) async {
    return execute(
      () async {
        final invoice = await SupabaseService.getInvoiceById(invoiceId);
        if (invoice == null) {
          throw Exception('Invoice not found');
        }
        return invoice;
      },
      errorMessage: 'Impossible de récupérer la facture',
    );
  }

  /// Get invoices for a specific client
  Future<Result<List<Invoice>>> getInvoicesByClient(String clientId) async {
    return execute(
      () => SupabaseService.fetchInvoicesByClient(clientId),
      errorMessage: 'Impossible de récupérer les factures du client',
    );
  }

  /// Create a new invoice
  Future<Result<String>> createInvoice(Invoice invoice) async {
    return execute(
      () => SupabaseService.createInvoice(invoice),
      errorMessage: 'Impossible de créer la facture',
    );
  }

  /// Update an existing invoice
  Future<Result<void>> updateInvoice(String invoiceId, Invoice invoice) async {
    return execute(
      () => SupabaseService.updateInvoice(invoiceId, invoice),
      errorMessage: 'Impossible de mettre à jour la facture',
    );
  }

  /// Delete an invoice
  Future<Result<void>> deleteInvoice(String invoiceId) async {
    return execute(
      () => SupabaseService.deleteInvoice(invoiceId),
      errorMessage: 'Impossible de supprimer la facture',
    );
  }

  /// Create line items for an invoice
  Future<Result<void>> createLineItems(
    String invoiceId,
    List<LineItem> items,
  ) async {
    return execute(
      () => SupabaseService.createInvoiceLineItems(invoiceId, items),
      errorMessage: 'Impossible de créer les lignes de facture',
    );
  }

  /// Get payments for an invoice
  Future<Result<List<Payment>>> getPaymentsForInvoice(String invoiceId) async {
    return execute(
      () => SupabaseService.getPaymentsForInvoice(invoiceId),
      errorMessage: 'Impossible de récupérer les paiements',
    );
  }

  /// Get invoices by status
  Future<Result<List<Invoice>>> getInvoicesByStatus(String status) async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices.where((invoice) => invoice.status == status).toList();
      },
      errorMessage: 'Impossible de filtrer les factures par statut',
    );
  }

  /// Get unpaid invoices
  Future<Result<List<Invoice>>> getUnpaidInvoices() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices
            .where((invoice) =>
                invoice.status == 'draft' || invoice.status == 'sent')
            .toList();
      },
      errorMessage: 'Impossible de récupérer les factures impayées',
    );
  }

  /// Get paid invoices
  Future<Result<List<Invoice>>> getPaidInvoices() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices.where((invoice) => invoice.status == 'paid').toList();
      },
      errorMessage: 'Impossible de récupérer les factures payées',
    );
  }

  /// Get overdue invoices
  Future<Result<List<Invoice>>> getOverdueInvoices() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        final now = DateTime.now();
        return invoices.where((invoice) {
          final isPaid = invoice.status == 'paid';
          final isOverdue = invoice.dueDate.isBefore(now);
          return !isPaid && isOverdue;
        }).toList();
      },
      errorMessage: 'Impossible de récupérer les factures en retard',
    );
  }

  /// Get invoices within a date range
  Future<Result<List<Invoice>>> getInvoicesByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices.where((invoice) {
          final invoiceDate = invoice.invoiceDate;
          return invoiceDate.isAfter(start) && invoiceDate.isBefore(end);
        }).toList();
      },
      errorMessage: 'Impossible de récupérer les factures par période',
    );
  }

  /// Calculate total revenue
  Future<Result<double>> getTotalRevenue() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices
            .where((invoice) => invoice.status == 'paid')
            .fold<double>(
              0,
              (sum, invoice) => sum + invoice.totalTTC,
            );
      },
      errorMessage: 'Impossible de calculer le chiffre d\'affaires',
    );
  }

  /// Calculate outstanding amount (unpaid invoices)
  Future<Result<double>> getOutstandingAmount() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        return invoices
            .where((invoice) => invoice.status != 'paid')
            .fold<double>(
              0,
              (sum, invoice) => sum + invoice.totalTTC,
            );
      },
      errorMessage: 'Impossible de calculer le montant en attente',
    );
  }

  /// Get average invoice amount
  Future<Result<double>> getAverageInvoiceAmount() async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        if (invoices.isEmpty) return 0.0;

        final total = invoices.fold<double>(
          0,
          (sum, invoice) => sum + invoice.totalTTC,
        );
        return total / invoices.length;
      },
      errorMessage: 'Impossible de calculer le montant moyen',
    );
  }

  /// Search invoices by invoice number
  Future<Result<List<Invoice>>> searchInvoices(String query) async {
    return execute(
      () async {
        final invoices = await SupabaseService.fetchInvoices();
        final lowerQuery = query.toLowerCase();
        return invoices.where((invoice) {
          final invoiceNumber = invoice.invoiceNumber.toLowerCase();
          return invoiceNumber.contains(lowerQuery);
        }).toList();
      },
      errorMessage: 'Impossible de rechercher les factures',
    );
  }
}

/// Provider for InvoiceRepository
@riverpod
InvoiceRepository invoiceRepository(InvoiceRepositoryRef ref) {
  return InvoiceRepository();
}

/// Provider for invoices list
@riverpod
class InvoicesNotifier extends _$InvoicesNotifier {
  @override
  Future<List<Invoice>> build() async {
    final repository = ref.watch(invoiceRepositoryProvider);
    final result = await repository.getInvoices();
    return result.getOrElse(() => []);
  }

  /// Refresh invoices list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(invoiceRepositoryProvider);
    final result = await repository.getInvoices();
    state = result.fold(
      onSuccess: (invoices) => AsyncValue.data(invoices),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Add a new invoice
  Future<Result<String>> addInvoice(Invoice invoice) async {
    final repository = ref.read(invoiceRepositoryProvider);
    final result = await repository.createInvoice(invoice);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Update an invoice
  Future<Result<void>> updateInvoice(String invoiceId, Invoice invoice) async {
    final repository = ref.read(invoiceRepositoryProvider);
    final result = await repository.updateInvoice(invoiceId, invoice);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Delete an invoice
  Future<Result<void>> deleteInvoice(String invoiceId) async {
    final repository = ref.read(invoiceRepositoryProvider);
    final result = await repository.deleteInvoice(invoiceId);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }
}

/// Provider for invoices by status
@riverpod
Future<List<Invoice>> invoicesByStatus(
  InvoicesByStatusRef ref,
  String status,
) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoicesByStatus(status);
  return result.getOrElse(() => []);
}

/// Provider for unpaid invoices
@riverpod
Future<List<Invoice>> unpaidInvoices(UnpaidInvoicesRef ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getUnpaidInvoices();
  return result.getOrElse(() => []);
}

/// Provider for paid invoices
@riverpod
Future<List<Invoice>> paidInvoices(PaidInvoicesRef ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getPaidInvoices();
  return result.getOrElse(() => []);
}

/// Provider for overdue invoices
@riverpod
Future<List<Invoice>> overdueInvoices(OverdueInvoicesRef ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getOverdueInvoices();
  return result.getOrElse(() => []);
}

/// Provider for a specific invoice
@riverpod
Future<Invoice?> invoice(InvoiceRef ref, String invoiceId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoiceById(invoiceId);
  return result.dataOrNull;
}

/// Provider for invoices by client
@riverpod
Future<List<Invoice>> invoicesByClient(
  InvoicesByClientRef ref,
  String clientId,
) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoicesByClient(clientId);
  return result.getOrElse(() => []);
}

/// Provider for total revenue
@riverpod
Future<double> totalRevenue(TotalRevenueRef ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getTotalRevenue();
  return result.getOrElse(() => 0.0);
}

/// Provider for outstanding amount
@riverpod
Future<double> outstandingAmount(OutstandingAmountRef ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getOutstandingAmount();
  return result.getOrElse(() => 0.0);
}
