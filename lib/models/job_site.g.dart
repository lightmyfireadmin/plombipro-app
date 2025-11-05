// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobSite _$JobSiteFromJson(Map<String, dynamic> json) => JobSite(
  id: json['id'] as String,
  userId: json['userId'] as String,
  clientId: json['clientId'] as String,
  jobName: json['jobName'] as String,
  referenceNumber: json['referenceNumber'] as String?,
  address: json['address'] as String?,
  contactPerson: json['contactPerson'] as String?,
  contactPhone: json['contactPhone'] as String?,
  description: json['description'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  estimatedEndDate: json['estimatedEndDate'] == null
      ? null
      : DateTime.parse(json['estimatedEndDate'] as String),
  actualEndDate: json['actualEndDate'] == null
      ? null
      : DateTime.parse(json['actualEndDate'] as String),
  status: json['status'] as String?,
  progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
  relatedQuoteId: json['relatedQuoteId'] as String?,
  estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble(),
  actualCost: (json['actualCost'] as num?)?.toDouble(),
  profitMargin: (json['profitMargin'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JobSiteToJson(JobSite instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'clientId': instance.clientId,
  'jobName': instance.jobName,
  'referenceNumber': instance.referenceNumber,
  'address': instance.address,
  'contactPerson': instance.contactPerson,
  'contactPhone': instance.contactPhone,
  'description': instance.description,
  'startDate': instance.startDate?.toIso8601String(),
  'estimatedEndDate': instance.estimatedEndDate?.toIso8601String(),
  'actualEndDate': instance.actualEndDate?.toIso8601String(),
  'status': instance.status,
  'progressPercentage': instance.progressPercentage,
  'relatedQuoteId': instance.relatedQuoteId,
  'estimatedBudget': instance.estimatedBudget,
  'actualCost': instance.actualCost,
  'profitMargin': instance.profitMargin,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
