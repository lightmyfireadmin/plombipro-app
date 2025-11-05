import 'package:json_annotation/json_annotation.dart';

part 'job_site_photo.g.dart';

@JsonSerializable()
class JobSitePhoto {
  final String id;
  final String jobSiteId;
  final String? photoUrl;
  final String? photoType;
  final String? caption;
  final DateTime uploadedAt;

  JobSitePhoto({
    required this.id,
    required this.jobSiteId,
    this.photoUrl,
    this.photoType,
    this.caption,
    required this.uploadedAt,
  });

  factory JobSitePhoto.fromJson(Map<String, dynamic> json) => _$JobSitePhotoFromJson(json);
  Map<String, dynamic> toJson() => _$JobSitePhotoToJson(this);

  JobSitePhoto copyWith({
    String? id,
    String? jobSiteId,
    String? photoUrl,
    String? photoType,
    String? caption,
    DateTime? uploadedAt,
  }) {
    return JobSitePhoto(
      id: id ?? this.id,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      photoUrl: photoUrl ?? this.photoUrl,
      photoType: photoType ?? this.photoType,
      caption: caption ?? this.caption,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
