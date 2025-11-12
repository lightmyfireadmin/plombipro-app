import 'package:json_annotation/json_annotation.dart';

part 'job_site.g.dart';

@JsonSerializable()
class JobSite {
  final String id;
  final String userId;
  final String clientId;
  final String jobName;
  final String? referenceNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? contactPerson;
  final String? contactPhone;
  final String? description;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final String? status;
  final int progressPercentage;
  final String? relatedQuoteId;
  final double? estimatedBudget;
  final double? actualCost;
  final double? profitMargin;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobSite({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.jobName,
    this.referenceNumber,
    this.address,
    this.city,
    this.postalCode,
    this.contactPerson,
    this.contactPhone,
    this.description,
    this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    this.status,
    this.progressPercentage = 0,
    this.relatedQuoteId,
    this.estimatedBudget,
    this.actualCost,
    this.profitMargin,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobSite.fromJson(Map<String, dynamic> json) => _$JobSiteFromJson(json);
  Map<String, dynamic> toJson() => _$JobSiteToJson(this);

  JobSite copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? jobName,
    String? referenceNumber,
    String? address,
    String? city,
    String? postalCode,
    String? contactPerson,
    String? contactPhone,
    String? description,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    String? status,
    int? progressPercentage,
    String? relatedQuoteId,
    double? estimatedBudget,
    double? actualCost,
    double? profitMargin,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobSite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      jobName: jobName ?? this.jobName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      relatedQuoteId: relatedQuoteId ?? this.relatedQuoteId,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualCost: actualCost ?? this.actualCost,
      profitMargin: profitMargin ?? this.profitMargin,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
