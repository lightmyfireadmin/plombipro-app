import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/result.dart';
import '../models/client.dart';
import '../services/supabase_service.dart';

part 'client_repository.g.dart';

/// Repository for client data operations
/// Provides clean separation between data layer and business logic
class ClientRepository extends BaseRepository {
  /// Fetch all clients for the current user
  Future<Result<List<Client>>> getClients() async {
    return execute(
      () => SupabaseService.fetchClients(),
      errorMessage: 'Impossible de récupérer les clients',
    );
  }

  /// Get a specific client by ID
  Future<Result<Client>> getClientById(String clientId) async {
    return execute(
      () async {
        final client = await SupabaseService.getClientById(clientId);
        if (client == null) {
          throw Exception('Client not found');
        }
        return client;
      },
      errorMessage: 'Impossible de récupérer le client',
    );
  }

  /// Create a new client
  Future<Result<String>> createClient(Client client) async {
    return execute(
      () => SupabaseService.createClient(client),
      errorMessage: 'Impossible de créer le client',
    );
  }

  /// Update an existing client
  Future<Result<void>> updateClient(String clientId, Client client) async {
    return execute(
      () => SupabaseService.updateClient(clientId, client),
      errorMessage: 'Impossible de mettre à jour le client',
    );
  }

  /// Delete a client
  Future<Result<void>> deleteClient(String clientId) async {
    return execute(
      () => SupabaseService.deleteClient(clientId),
      errorMessage: 'Impossible de supprimer le client',
    );
  }

  /// Get appointments for a specific client
  Future<Result<List<Map<String, dynamic>>>> getClientAppointments(
    String clientId,
  ) async {
    return execute(
      () => SupabaseService.getClientAppointments(clientId),
      errorMessage: 'Impossible de récupérer les rendez-vous du client',
    );
  }

  /// Search clients by name or email
  Future<Result<List<Client>>> searchClients(String query) async {
    return execute(
      () async {
        final clients = await SupabaseService.fetchClients();
        final lowerQuery = query.toLowerCase();
        return clients.where((client) {
          final name = client.name.toLowerCase();
          final email = client.email.toLowerCase();
          final phone = client.phone.toLowerCase();
          return name.contains(lowerQuery) ||
              email.contains(lowerQuery) ||
              phone.contains(lowerQuery);
        }).toList();
      },
      errorMessage: 'Impossible de rechercher les clients',
    );
  }

  /// Get favorite clients
  Future<Result<List<Client>>> getFavoriteClients() async {
    return execute(
      () async {
        final clients = await SupabaseService.fetchClients();
        return clients.where((client) => client.isFavorite).toList();
      },
      errorMessage: 'Impossible de récupérer les clients favoris',
    );
  }

  /// Filter clients by type (individual/company)
  Future<Result<List<Client>>> getClientsByType(String type) async {
    return execute(
      () async {
        final clients = await SupabaseService.fetchClients();
        return clients.where((client) => client.clientType == type).toList();
      },
      errorMessage: 'Impossible de filtrer les clients par type',
    );
  }

  /// Toggle favorite status for a client
  Future<Result<void>> toggleFavorite(String clientId, Client client) async {
    final updatedClient = Client(
      id: client.id,
      userId: client.userId,
      clientType: client.clientType,
      salutation: client.salutation,
      firstName: client.firstName,
      name: client.name,
      email: client.email,
      phone: client.phone,
      mobilePhone: client.mobilePhone,
      address: client.address,
      postalCode: client.postalCode,
      city: client.city,
      country: client.country,
      billingAddress: client.billingAddress,
      siret: client.siret,
      vatNumber: client.vatNumber,
      defaultPaymentTerms: client.defaultPaymentTerms,
      defaultDiscount: client.defaultDiscount,
      tags: client.tags,
      isFavorite: !client.isFavorite,
      notes: client.notes,
    );

    return execute(
      () => SupabaseService.updateClient(clientId, updatedClient),
      errorMessage: 'Impossible de mettre à jour les favoris',
    );
  }
}

/// Provider for ClientRepository
@riverpod
ClientRepository clientRepository(ClientRepositoryRef ref) {
  return ClientRepository();
}

/// Provider for clients list
@riverpod
class ClientsNotifier extends _$ClientsNotifier {
  @override
  Future<List<Client>> build() async {
    final repository = ref.watch(clientRepositoryProvider);
    final result = await repository.getClients();
    return result.getOrElse(() => []);
  }

  /// Refresh clients list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(clientRepositoryProvider);
    final result = await repository.getClients();
    state = result.fold(
      onSuccess: (clients) => AsyncValue.data(clients),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Add a new client
  Future<Result<String>> addClient(Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    final result = await repository.createClient(client);

    // Refresh list if successful
    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Update a client
  Future<Result<void>> updateClient(String clientId, Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    final result = await repository.updateClient(clientId, client);

    // Refresh list if successful
    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Delete a client
  Future<Result<void>> deleteClient(String clientId) async {
    final repository = ref.read(clientRepositoryProvider);
    final result = await repository.deleteClient(clientId);

    // Refresh list if successful
    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Toggle favorite status
  Future<Result<void>> toggleFavorite(String clientId, Client client) async {
    final repository = ref.read(clientRepositoryProvider);
    final result = await repository.toggleFavorite(clientId, client);

    // Refresh list if successful
    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }
}

/// Provider for searching clients
@riverpod
class ClientSearchNotifier extends _$ClientSearchNotifier {
  @override
  Future<List<Client>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final repository = ref.watch(clientRepositoryProvider);
    final result = await repository.searchClients(query);
    return result.getOrElse(() => []);
  }
}

/// Provider for favorite clients
@riverpod
Future<List<Client>> favoriteClients(FavoriteClientsRef ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  final result = await repository.getFavoriteClients();
  return result.getOrElse(() => []);
}

/// Provider for a specific client
@riverpod
Future<Client?> client(ClientRef ref, String clientId) async {
  final repository = ref.watch(clientRepositoryProvider);
  final result = await repository.getClientById(clientId);
  return result.dataOrNull;
}
