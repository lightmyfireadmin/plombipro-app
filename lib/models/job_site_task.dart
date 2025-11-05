import 'package:json_annotation/json_annotation.dart';

part 'job_site_task.g.dart';

@JsonSerializable()
class JobSiteTask {
  final String id;
  final String jobSiteId;
  final String? taskDescription;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  JobSiteTask({
    required this.id,
    required this.jobSiteId,
    this.taskDescription,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  factory JobSiteTask.fromJson(Map<String, dynamic> json) => _$JobSiteTaskFromJson(json);
  Map<String, dynamic> toJson() => _$JobSiteTaskToJson(this);

  JobSiteTask copyWith({
    String? id,
    String? jobSiteId,
    String? taskDescription,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return JobSiteTask(
      id: id ?? this.id,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      taskDescription: taskDescription ?? this.taskDescription,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
