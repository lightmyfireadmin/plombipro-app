import 'package:json_annotation/json_annotation.dart';

part 'job_site_note.g.dart';

@JsonSerializable()
class JobSiteNote {
  final String id;
  final String jobSiteId;
  final String userId;
  final String? noteText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobSiteNote({
    required this.id,
    required this.jobSiteId,
    required this.userId,
    this.noteText,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobSiteNote.fromJson(Map<String, dynamic> json) => _$JobSiteNoteFromJson(json);
  Map<String, dynamic> toJson() => _$JobSiteNoteToJson(this);

  JobSiteNote copyWith({
    String? id,
    String? jobSiteId,
    String? userId,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobSiteNote(
      id: id ?? this.id,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      userId: userId ?? this.userId,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
