// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_site_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobSitePhoto _$JobSitePhotoFromJson(Map<String, dynamic> json) => JobSitePhoto(
  id: json['id'] as String,
  jobSiteId: json['jobSiteId'] as String,
  photoUrl: json['photoUrl'] as String?,
  photoType: json['photoType'] as String?,
  caption: json['caption'] as String?,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$JobSitePhotoToJson(JobSitePhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobSiteId': instance.jobSiteId,
      'photoUrl': instance.photoUrl,
      'photoType': instance.photoType,
      'caption': instance.caption,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
    };
