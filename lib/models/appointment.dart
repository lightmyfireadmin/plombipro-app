import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;

  // Client and job site relations
  @JsonKey(name: 'client_id')
  final String? clientId;
  @JsonKey(name: 'job_site_id')
  final String? jobSiteId;

  // Appointment details
  final String title;
  final String? description;
  @JsonKey(name: 'appointment_date')
  final DateTime appointmentDate;
  @JsonKey(name: 'appointment_time')
  final String appointmentTime; // TIME type from SQL

  // Duration and timing
  @JsonKey(name: 'estimated_duration_minutes')
  final int estimatedDurationMinutes;
  @JsonKey(name: 'actual_start_time')
  final DateTime? actualStartTime;
  @JsonKey(name: 'actual_end_time')
  final DateTime? actualEndTime;

  // Location details
  @JsonKey(name: 'address_line1')
  final String addressLine1;
  @JsonKey(name: 'address_line2')
  final String? addressLine2;
  @JsonKey(name: 'postal_code')
  final String postalCode;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;

  // ETA tracking
  @JsonKey(name: 'planned_eta')
  final DateTime plannedEta;
  @JsonKey(name: 'current_eta')
  final DateTime? currentEta;
  @JsonKey(name: 'last_eta_update')
  final DateTime? lastEtaUpdate;
  @JsonKey(name: 'eta_update_interval_minutes')
  final int etaUpdateIntervalMinutes;

  // Route and sequence
  @JsonKey(name: 'daily_sequence')
  final int? dailySequence;
  @JsonKey(name: 'route_distance_meters')
  final int? routeDistanceMeters;
  @JsonKey(name: 'route_duration_minutes')
  final int? routeDurationMinutes;

  // Status tracking
  final AppointmentStatus status;

  // SMS notification tracking
  @JsonKey(name: 'sms_notifications_enabled')
  final bool smsNotificationsEnabled;
  @JsonKey(name: 'last_sms_sent_at')
  final DateTime? lastSmsSentAt;
  @JsonKey(name: 'sms_count')
  final int smsCount;

  // Notes
  @JsonKey(name: 'internal_notes')
  final String? internalNotes;
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;

  // Metadata
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    this.clientId,
    this.jobSiteId,
    required this.title,
    this.description,
    required this.appointmentDate,
    required this.appointmentTime,
    this.estimatedDurationMinutes = 60,
    this.actualStartTime,
    this.actualEndTime,
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.city,
    this.country = 'FR',
    this.latitude,
    this.longitude,
    required this.plannedEta,
    this.currentEta,
    this.lastEtaUpdate,
    this.etaUpdateIntervalMinutes = 15,
    this.dailySequence,
    this.routeDistanceMeters,
    this.routeDurationMinutes,
    this.status = AppointmentStatus.scheduled,
    this.smsNotificationsEnabled = true,
    this.lastSmsSentAt,
    this.smsCount = 0,
    this.internalNotes,
    this.customerNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  // Helper methods
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      '$postalCode $city',
    ];
    return parts.join(', ');
  }

  DateTime get effectiveEta => currentEta ?? plannedEta;

  Duration? get etaDelay {
    if (currentEta == null) return null;
    return currentEta!.difference(plannedEta);
  }

  int? get etaDelayMinutes {
    final delay = etaDelay;
    return delay?.inMinutes;
  }

  bool get isDelayed => (etaDelayMinutes ?? 0) > 0;

  bool get isEarly => (etaDelayMinutes ?? 0) < 0;

  bool get isOnTime => !isDelayed && !isEarly;

  String get formattedDelay {
    final delayMinutes = etaDelayMinutes ?? 0;
    if (delayMinutes == 0) return 'À l\'heure';
    if (delayMinutes > 0) {
      return '+${delayMinutes} min de retard';
    }
    return '${delayMinutes.abs()} min d\'avance';
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planifié';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.inTransit:
        return 'En route';
      case AppointmentStatus.arrived:
        return 'Arrivé';
      case AppointmentStatus.inProgress:
        return 'En cours';
      case AppointmentStatus.completed:
        return 'Terminé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.noShow:
        return 'Absent';
    }
  }

  bool get isActive =>
      status != AppointmentStatus.completed &&
      status != AppointmentStatus.cancelled &&
      status != AppointmentStatus.noShow;

  bool get needsEtaUpdate {
    if (lastEtaUpdate == null) return true;
    final timeSinceUpdate = DateTime.now().difference(lastEtaUpdate!);
    return timeSinceUpdate.inMinutes >= etaUpdateIntervalMinutes;
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? jobSiteId,
    String? title,
    String? description,
    DateTime? appointmentDate,
    String? appointmentTime,
    int? estimatedDurationMinutes,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? plannedEta,
    DateTime? currentEta,
    DateTime? lastEtaUpdate,
    int? etaUpdateIntervalMinutes,
    int? dailySequence,
    int? routeDistanceMeters,
    int? routeDurationMinutes,
    AppointmentStatus? status,
    bool? smsNotificationsEnabled,
    DateTime? lastSmsSentAt,
    int? smsCount,
    String? internalNotes,
    String? customerNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      title: title ?? this.title,
      description: description ?? this.description,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      plannedEta: plannedEta ?? this.plannedEta,
      currentEta: currentEta ?? this.currentEta,
      lastEtaUpdate: lastEtaUpdate ?? this.lastEtaUpdate,
      etaUpdateIntervalMinutes:
          etaUpdateIntervalMinutes ?? this.etaUpdateIntervalMinutes,
      dailySequence: dailySequence ?? this.dailySequence,
      routeDistanceMeters: routeDistanceMeters ?? this.routeDistanceMeters,
      routeDurationMinutes: routeDurationMinutes ?? this.routeDurationMinutes,
      status: status ?? this.status,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      lastSmsSentAt: lastSmsSentAt ?? this.lastSmsSentAt,
      smsCount: smsCount ?? this.smsCount,
      internalNotes: internalNotes ?? this.internalNotes,
      customerNotes: customerNotes ?? this.customerNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AppointmentStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('in_transit')
  inTransit,
  @JsonValue('arrived')
  arrived,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
}

@JsonSerializable()
class DailyRoute {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'route_date')
  final DateTime routeDate;

  // Starting point
  @JsonKey(name: 'start_address')
  final String? startAddress;
  @JsonKey(name: 'start_latitude')
  final double? startLatitude;
  @JsonKey(name: 'start_longitude')
  final double? startLongitude;
  @JsonKey(name: 'start_time')
  final String? startTime;

  // Route optimization
  @JsonKey(name: 'is_optimized')
  final bool isOptimized;
  @JsonKey(name: 'optimization_date')
  final DateTime? optimizationDate;
  @JsonKey(name: 'total_distance_meters')
  final int? totalDistanceMeters;
  @JsonKey(name: 'total_duration_minutes')
  final int? totalDurationMinutes;

  // Tracking
  @JsonKey(name: 'route_started_at')
  final DateTime? routeStartedAt;
  @JsonKey(name: 'route_completed_at')
  final DateTime? routeCompletedAt;
  final RouteStatus status;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  DailyRoute({
    required this.id,
    required this.userId,
    required this.routeDate,
    this.startAddress,
    this.startLatitude,
    this.startLongitude,
    this.startTime,
    this.isOptimized = false,
    this.optimizationDate,
    this.totalDistanceMeters,
    this.totalDurationMinutes,
    this.routeStartedAt,
    this.routeCompletedAt,
    this.status = RouteStatus.planned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyRoute.fromJson(Map<String, dynamic> json) =>
      _$DailyRouteFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRouteToJson(this);

  String get formattedDistance {
    if (totalDistanceMeters == null) return '--';
    if (totalDistanceMeters! < 1000) {
      return '$totalDistanceMeters m';
    }
    return '${(totalDistanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (totalDurationMinutes == null) return '--';
    final hours = totalDurationMinutes! ~/ 60;
    final minutes = totalDurationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  DailyRoute copyWith({
    String? id,
    String? userId,
    DateTime? routeDate,
    String? startAddress,
    double? startLatitude,
    double? startLongitude,
    String? startTime,
    bool? isOptimized,
    DateTime? optimizationDate,
    int? totalDistanceMeters,
    int? totalDurationMinutes,
    DateTime? routeStartedAt,
    DateTime? routeCompletedAt,
    RouteStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRoute(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routeDate: routeDate ?? this.routeDate,
      startAddress: startAddress ?? this.startAddress,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      startTime: startTime ?? this.startTime,
      isOptimized: isOptimized ?? this.isOptimized,
      optimizationDate: optimizationDate ?? this.optimizationDate,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      routeStartedAt: routeStartedAt ?? this.routeStartedAt,
      routeCompletedAt: routeCompletedAt ?? this.routeCompletedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum RouteStatus {
  @JsonValue('planned')
  planned,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class AppointmentEtaHistory {
  final String id;
  @JsonKey(name: 'appointment_id')
  final String appointmentId;
  final DateTime eta;
  @JsonKey(name: 'delay_minutes')
  final int? delayMinutes;
  @JsonKey(name: 'update_reason')
  final EtaUpdateReason updateReason;
  @JsonKey(name: 'sms_sent')
  final bool smsSent;
  @JsonKey(name: 'sms_sent_at')
  final DateTime? smsSentAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AppointmentEtaHistory({
    required this.id,
    required this.appointmentId,
    required this.eta,
    this.delayMinutes,
    required this.updateReason,
    this.smsSent = false,
    this.smsSentAt,
    required this.createdAt,
  });

  factory AppointmentEtaHistory.fromJson(Map<String, dynamic> json) =>
      _$AppointmentEtaHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentEtaHistoryToJson(this);
}

enum EtaUpdateReason {
  @JsonValue('manual')
  manual,
  @JsonValue('automatic')
  automatic,
  @JsonValue('traffic')
  traffic,
  @JsonValue('previous_delay')
  previousDelay,
  @JsonValue('route_optimization')
  routeOptimization,
}

@JsonSerializable()
class AppointmentSmsLog {
  final String id;
  @JsonKey(name: 'appointment_id')
  final String appointmentId;
  @JsonKey(name: 'recipient_phone')
  final String recipientPhone;
  @JsonKey(name: 'message_content')
  final String messageContent;
  @JsonKey(name: 'sent_at')
  final DateTime sentAt;
  @JsonKey(name: 'delivery_status')
  final SmsDeliveryStatus deliveryStatus;
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @JsonKey(name: 'provider_message_sid')
  final String? providerMessageSid;
  final String provider;
  @JsonKey(name: 'cost_eur')
  final double? costEur;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AppointmentSmsLog({
    required this.id,
    required this.appointmentId,
    required this.recipientPhone,
    required this.messageContent,
    required this.sentAt,
    this.deliveryStatus = SmsDeliveryStatus.pending,
    this.errorMessage,
    this.providerMessageSid,
    this.provider = 'twilio',
    this.costEur,
    required this.createdAt,
  });

  factory AppointmentSmsLog.fromJson(Map<String, dynamic> json) =>
      _$AppointmentSmsLogFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentSmsLogToJson(this);
}

enum SmsDeliveryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('failed')
  failed,
  @JsonValue('queued')
  queued,
}
