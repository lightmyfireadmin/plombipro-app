// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_site_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobSiteTask _$JobSiteTaskFromJson(Map<String, dynamic> json) => JobSiteTask(
  id: json['id'] as String,
  jobSiteId: json['jobSiteId'] as String,
  taskDescription: json['taskDescription'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$JobSiteTaskToJson(JobSiteTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSiteId': instance.jobSiteId,
      'taskDescription': instance.taskDescription,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
