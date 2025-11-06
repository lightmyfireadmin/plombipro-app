// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      jobSiteId: json['job_site_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 60,
      actualStartTime: json['actual_start_time'] == null
          ? null
          : DateTime.parse(json['actual_start_time'] as String),
      actualEndTime: json['actual_end_time'] == null
          ? null
          : DateTime.parse(json['actual_end_time'] as String),
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      postalCode: json['postal_code'] as String,
      city: json['city'] as String,
      country: json['country'] as String? ?? 'FR',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      plannedEta: DateTime.parse(json['planned_eta'] as String),
      currentEta: json['current_eta'] == null
          ? null
          : DateTime.parse(json['current_eta'] as String),
      lastEtaUpdate: json['last_eta_update'] == null
          ? null
          : DateTime.parse(json['last_eta_update'] as String),
      etaUpdateIntervalMinutes: json['eta_update_interval_minutes'] as int? ?? 15,
      dailySequence: json['daily_sequence'] as int?,
      routeDistanceMeters: json['route_distance_meters'] as int?,
      routeDurationMinutes: json['route_duration_minutes'] as int?,
      status: $enumDecodeNullable(_$AppointmentStatusEnumMap, json['status']) ??
          AppointmentStatus.scheduled,
      smsNotificationsEnabled: json['sms_notifications_enabled'] as bool? ?? true,
      lastSmsSentAt: json['last_sms_sent_at'] == null
          ? null
          : DateTime.parse(json['last_sms_sent_at'] as String),
      smsCount: json['sms_count'] as int? ?? 0,
      internalNotes: json['internal_notes'] as String?,
      customerNotes: json['customer_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'client_id': instance.clientId,
      'job_site_id': instance.jobSiteId,
      'title': instance.title,
      'description': instance.description,
      'appointment_date': instance.appointmentDate.toIso8601String(),
      'appointment_time': instance.appointmentTime,
      'estimated_duration_minutes': instance.estimatedDurationMinutes,
      'actual_start_time': instance.actualStartTime?.toIso8601String(),
      'actual_end_time': instance.actualEndTime?.toIso8601String(),
      'address_line1': instance.addressLine1,
      'address_line2': instance.addressLine2,
      'postal_code': instance.postalCode,
      'city': instance.city,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'planned_eta': instance.plannedEta.toIso8601String(),
      'current_eta': instance.currentEta?.toIso8601String(),
      'last_eta_update': instance.lastEtaUpdate?.toIso8601String(),
      'eta_update_interval_minutes': instance.etaUpdateIntervalMinutes,
      'daily_sequence': instance.dailySequence,
      'route_distance_meters': instance.routeDistanceMeters,
      'route_duration_minutes': instance.routeDurationMinutes,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'sms_notifications_enabled': instance.smsNotificationsEnabled,
      'last_sms_sent_at': instance.lastSmsSentAt?.toIso8601String(),
      'sms_count': instance.smsCount,
      'internal_notes': instance.internalNotes,
      'customer_notes': instance.customerNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.inTransit: 'in_transit',
  AppointmentStatus.arrived: 'arrived',
  AppointmentStatus.inProgress: 'in_progress',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.noShow: 'no_show',
};

DailyRoute _$DailyRouteFromJson(Map<String, dynamic> json) => DailyRoute(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      routeDate: DateTime.parse(json['route_date'] as String),
      startAddress: json['start_address'] as String?,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      startTime: json['start_time'] as String?,
      isOptimized: json['is_optimized'] as bool? ?? false,
      optimizationDate: json['optimization_date'] == null
          ? null
          : DateTime.parse(json['optimization_date'] as String),
      totalDistanceMeters: json['total_distance_meters'] as int?,
      totalDurationMinutes: json['total_duration_minutes'] as int?,
      routeStartedAt: json['route_started_at'] == null
          ? null
          : DateTime.parse(json['route_started_at'] as String),
      routeCompletedAt: json['route_completed_at'] == null
          ? null
          : DateTime.parse(json['route_completed_at'] as String),
      status: $enumDecodeNullable(_$RouteStatusEnumMap, json['status']) ??
          RouteStatus.planned,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DailyRouteToJson(DailyRoute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'route_date': instance.routeDate.toIso8601String(),
      'start_address': instance.startAddress,
      'start_latitude': instance.startLatitude,
      'start_longitude': instance.startLongitude,
      'start_time': instance.startTime,
      'is_optimized': instance.isOptimized,
      'optimization_date': instance.optimizationDate?.toIso8601String(),
      'total_distance_meters': instance.totalDistanceMeters,
      'total_duration_minutes': instance.totalDurationMinutes,
      'route_started_at': instance.routeStartedAt?.toIso8601String(),
      'route_completed_at': instance.routeCompletedAt?.toIso8601String(),
      'status': _$RouteStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RouteStatusEnumMap = {
  RouteStatus.planned: 'planned',
  RouteStatus.active: 'active',
  RouteStatus.completed: 'completed',
  RouteStatus.cancelled: 'cancelled',
};

AppointmentEtaHistory _$AppointmentEtaHistoryFromJson(
        Map<String, dynamic> json) =>
    AppointmentEtaHistory(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      eta: DateTime.parse(json['eta'] as String),
      delayMinutes: json['delay_minutes'] as int?,
      updateReason: $enumDecode(_$EtaUpdateReasonEnumMap, json['update_reason']),
      smsSent: json['sms_sent'] as bool? ?? false,
      smsSentAt: json['sms_sent_at'] == null
          ? null
          : DateTime.parse(json['sms_sent_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppointmentEtaHistoryToJson(
        AppointmentEtaHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'eta': instance.eta.toIso8601String(),
      'delay_minutes': instance.delayMinutes,
      'update_reason': _$EtaUpdateReasonEnumMap[instance.updateReason]!,
      'sms_sent': instance.smsSent,
      'sms_sent_at': instance.smsSentAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$EtaUpdateReasonEnumMap = {
  EtaUpdateReason.manual: 'manual',
  EtaUpdateReason.automatic: 'automatic',
  EtaUpdateReason.traffic: 'traffic',
  EtaUpdateReason.previousDelay: 'previous_delay',
  EtaUpdateReason.routeOptimization: 'route_optimization',
};

AppointmentSmsLog _$AppointmentSmsLogFromJson(Map<String, dynamic> json) =>
    AppointmentSmsLog(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      recipientPhone: json['recipient_phone'] as String,
      messageContent: json['message_content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      deliveryStatus:
          $enumDecodeNullable(_$SmsDeliveryStatusEnumMap, json['delivery_status']) ??
              SmsDeliveryStatus.pending,
      errorMessage: json['error_message'] as String?,
      providerMessageSid: json['provider_message_sid'] as String?,
      provider: json['provider'] as String? ?? 'twilio',
      costEur: (json['cost_eur'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppointmentSmsLogToJson(AppointmentSmsLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'recipient_phone': instance.recipientPhone,
      'message_content': instance.messageContent,
      'sent_at': instance.sentAt.toIso8601String(),
      'delivery_status': _$SmsDeliveryStatusEnumMap[instance.deliveryStatus]!,
      'error_message': instance.errorMessage,
      'provider_message_sid': instance.providerMessageSid,
      'provider': instance.provider,
      'cost_eur': instance.costEur,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$SmsDeliveryStatusEnumMap = {
  SmsDeliveryStatus.pending: 'pending',
  SmsDeliveryStatus.sent: 'sent',
  SmsDeliveryStatus.delivered: 'delivered',
  SmsDeliveryStatus.failed: 'failed',
  SmsDeliveryStatus.queued: 'queued',
};

T $enumDecode<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

T? $enumDecodeNullable<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return $enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}
