// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_site_time_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobSiteTimeLog _$JobSiteTimeLogFromJson(Map<String, dynamic> json) =>
    JobSiteTimeLog(
      id: json['id'] as String,
      jobSiteId: json['jobSiteId'] as String,
      userId: json['userId'] as String,
      logDate: json['logDate'] == null
          ? null
          : DateTime.parse(json['logDate'] as String),
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
      description: json['description'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      laborCost: (json['laborCost'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$JobSiteTimeLogToJson(JobSiteTimeLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSiteId': instance.jobSiteId,
      'userId': instance.userId,
      'logDate': instance.logDate?.toIso8601String(),
      'hoursWorked': instance.hoursWorked,
      'description': instance.description,
      'hourlyRate': instance.hourlyRate,
      'laborCost': instance.laborCost,
      'createdAt': instance.createdAt.toIso8601String(),
    };
