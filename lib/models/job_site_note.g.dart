// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_site_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobSiteNote _$JobSiteNoteFromJson(Map<String, dynamic> json) => JobSiteNote(
  id: json['id'] as String,
  jobSiteId: json['jobSiteId'] as String,
  userId: json['userId'] as String,
  noteText: json['noteText'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JobSiteNoteToJson(JobSiteNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSiteId': instance.jobSiteId,
      'userId': instance.userId,
      'noteText': instance.noteText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
