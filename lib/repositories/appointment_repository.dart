import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/result.dart';
import '../services/supabase_service.dart';

part 'appointment_repository.g.dart';

/// Repository for appointment data operations
class AppointmentRepository extends BaseRepository {
  /// Fetch upcoming appointments
  Future<Result<List<Map<String, dynamic>>>> getUpcomingAppointments({
    int limit = 5,
  }) async {
    return execute(
      () => SupabaseService.fetchUpcomingAppointments(limit: limit),
      errorMessage: 'Impossible de récupérer les prochains rendez-vous',
    );
  }

  /// Get appointments by date range
  Future<Result<List<Map<String, dynamic>>>> getAppointmentsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    return execute(
      () => SupabaseService.fetchAppointmentsByDateRange(
        start: start,
        end: end,
      ),
      errorMessage: 'Impossible de récupérer les rendez-vous par période',
    );
  }

  /// Get a specific appointment by ID
  Future<Result<Map<String, dynamic>>> getAppointment(String id) async {
    return execute(
      () async {
        final appointment = await SupabaseService.getAppointment(id);
        if (appointment == null) {
          throw Exception('Appointment not found');
        }
        return appointment;
      },
      errorMessage: 'Impossible de récupérer le rendez-vous',
    );
  }

  /// Create a new appointment
  Future<Result<String>> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    return execute(
      () => SupabaseService.createAppointment(appointmentData),
      errorMessage: 'Impossible de créer le rendez-vous',
    );
  }

  /// Update an existing appointment
  Future<Result<bool>> updateAppointment(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return execute(
      () => SupabaseService.updateAppointment(id, updates),
      errorMessage: 'Impossible de mettre à jour le rendez-vous',
    );
  }

  /// Delete an appointment
  Future<Result<bool>> deleteAppointment(String id) async {
    return execute(
      () => SupabaseService.deleteAppointment(id),
      errorMessage: 'Impossible de supprimer le rendez-vous',
    );
  }

  /// Update appointment status
  Future<Result<bool>> updateAppointmentStatus(
    String id,
    String status,
  ) async {
    return execute(
      () => SupabaseService.updateAppointmentStatus(id, status),
      errorMessage: 'Impossible de mettre à jour le statut',
    );
  }

  /// Get today's appointments
  Future<Result<List<Map<String, dynamic>>>> getTodayAppointments() async {
    return execute(
      () => SupabaseService.getTodayAppointments(),
      errorMessage: 'Impossible de récupérer les rendez-vous du jour',
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

  /// Get appointments by status
  Future<Result<List<Map<String, dynamic>>>> getAppointmentsByStatus(
    String status,
  ) async {
    return execute(
      () async {
        final now = DateTime.now();
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        final appointments = await SupabaseService.fetchAppointmentsByDateRange(
          start: now,
          end: endOfMonth,
        );
        return appointments
            .where((apt) => apt['status'] == status)
            .toList();
      },
      errorMessage: 'Impossible de filtrer les rendez-vous par statut',
    );
  }

  /// Get appointments for this week
  Future<Result<List<Map<String, dynamic>>>> getWeekAppointments() async {
    return execute(
      () async {
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return SupabaseService.fetchAppointmentsByDateRange(
          start: startOfWeek,
          end: endOfWeek,
        );
      },
      errorMessage: 'Impossible de récupérer les rendez-vous de la semaine',
    );
  }

  /// Get appointments for this month
  Future<Result<List<Map<String, dynamic>>>> getMonthAppointments() async {
    return execute(
      () async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return SupabaseService.fetchAppointmentsByDateRange(
          start: startOfMonth,
          end: endOfMonth,
        );
      },
      errorMessage: 'Impossible de récupérer les rendez-vous du mois',
    );
  }

  /// Mark appointment as completed
  Future<Result<bool>> completeAppointment(String id) async {
    return updateAppointmentStatus(id, 'completed');
  }

  /// Mark appointment as cancelled
  Future<Result<bool>> cancelAppointment(String id) async {
    return updateAppointmentStatus(id, 'cancelled');
  }

  /// Mark appointment as confirmed
  Future<Result<bool>> confirmAppointment(String id) async {
    return updateAppointmentStatus(id, 'confirmed');
  }

  /// Get appointment statistics
  Future<Result<Map<String, int>>> getAppointmentStats() async {
    return execute(
      () async {
        final appointments = await getTodayAppointments();
        final allAppointments = appointments.getOrElse(() => []);

        final scheduled = allAppointments
            .where((apt) => apt['status'] == 'scheduled')
            .length;
        final confirmed = allAppointments
            .where((apt) => apt['status'] == 'confirmed')
            .length;
        final completed = allAppointments
            .where((apt) => apt['status'] == 'completed')
            .length;
        final cancelled = allAppointments
            .where((apt) => apt['status'] == 'cancelled')
            .length;

        return {
          'total': allAppointments.length,
          'scheduled': scheduled,
          'confirmed': confirmed,
          'completed': completed,
          'cancelled': cancelled,
        };
      },
      errorMessage: 'Impossible de calculer les statistiques',
    );
  }
}

/// Provider for AppointmentRepository
@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepository();
}

/// Provider for upcoming appointments
@riverpod
class UpcomingAppointmentsNotifier extends _$UpcomingAppointmentsNotifier {
  @override
  Future<List<Map<String, dynamic>>> build({int limit = 5}) async {
    final repository = ref.watch(appointmentRepositoryProvider);
    final result = await repository.getUpcomingAppointments(limit: limit);
    return result.getOrElse(() => []);
  }

  /// Refresh appointments list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.getUpcomingAppointments(limit: limit);
    state = result.fold(
      onSuccess: (appointments) => AsyncValue.data(appointments),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Add a new appointment
  Future<Result<String>> addAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.createAppointment(appointmentData);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Update an appointment
  Future<Result<bool>> updateAppointment(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.updateAppointment(id, updates);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Delete an appointment
  Future<Result<bool>> deleteAppointment(String id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.deleteAppointment(id);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Complete an appointment
  Future<Result<bool>> completeAppointment(String id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.completeAppointment(id);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }

  /// Cancel an appointment
  Future<Result<bool>> cancelAppointment(String id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final result = await repository.cancelAppointment(id);

    if (result.isSuccess) {
      await refresh();
    }

    return result;
  }
}

/// Provider for today's appointments
@riverpod
Future<List<Map<String, dynamic>>> todayAppointments(
  TodayAppointmentsRef ref,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getTodayAppointments();
  return result.getOrElse(() => []);
}

/// Provider for this week's appointments
@riverpod
Future<List<Map<String, dynamic>>> weekAppointments(
  WeekAppointmentsRef ref,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getWeekAppointments();
  return result.getOrElse(() => []);
}

/// Provider for this month's appointments
@riverpod
Future<List<Map<String, dynamic>>> monthAppointments(
  MonthAppointmentsRef ref,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getMonthAppointments();
  return result.getOrElse(() => []);
}

/// Provider for appointments by status
@riverpod
Future<List<Map<String, dynamic>>> appointmentsByStatus(
  AppointmentsByStatusRef ref,
  String status,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getAppointmentsByStatus(status);
  return result.getOrElse(() => []);
}

/// Provider for a specific appointment
@riverpod
Future<Map<String, dynamic>?> appointment(
  AppointmentRef ref,
  String id,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getAppointment(id);
  return result.dataOrNull;
}

/// Provider for appointment statistics
@riverpod
Future<Map<String, int>> appointmentStats(AppointmentStatsRef ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  final result = await repository.getAppointmentStats();
  return result.getOrElse(() => {});
}
