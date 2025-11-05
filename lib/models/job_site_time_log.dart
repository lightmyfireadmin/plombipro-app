import 'package:json_annotation/json_annotation.dart';

part 'job_site_time_log.g.dart';

@JsonSerializable()
class JobSiteTimeLog {
  final String id;
  final String jobSiteId;
  final String userId;
  final DateTime? logDate;
  final double? hoursWorked;
  final String? description;
  final double? hourlyRate;
  final double? laborCost;
  final DateTime createdAt;

  JobSiteTimeLog({
    required this.id,
    required this.jobSiteId,
    required this.userId,
    this.logDate,
    this.hoursWorked,
    this.description,
    this.hourlyRate,
    this.laborCost,
    required this.createdAt,
  });

  factory JobSiteTimeLog.fromJson(Map<String, dynamic> json) => _$JobSiteTimeLogFromJson(json);
  Map<String, dynamic> toJson() => _$JobSiteTimeLogToJson(this);

  JobSiteTimeLog copyWith({
    String? id,
    String? jobSiteId,
    String? userId,
    DateTime? logDate,
    double? hoursWorked,
    String? description,
    double? hourlyRate,
    double? laborCost,
    DateTime? createdAt,
  }) {
    return JobSiteTimeLog(
      id: id ?? this.id,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      laborCost: laborCost ?? this.laborCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
