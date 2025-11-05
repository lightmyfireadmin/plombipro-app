// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
  id: json['id'] as String,
  userId: json['userId'] as String,
  supplierName: json['supplierName'] as String?,
  invoiceNumber: json['invoiceNumber'] as String?,
  invoiceDate: json['invoiceDate'] == null
      ? null
      : DateTime.parse(json['invoiceDate'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  lineItems: json['lineItems'] as Map<String, dynamic>?,
  subtotalHt: (json['subtotalHt'] as num?)?.toDouble(),
  totalVat: (json['totalVat'] as num?)?.toDouble(),
  totalTtc: (json['totalTtc'] as num?)?.toDouble(),
  paymentStatus: json['paymentStatus'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  jobSiteId: json['jobSiteId'] as String?,
  scanId: json['scanId'] as String?,
  invoiceImageUrl: json['invoiceImageUrl'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'supplierName': instance.supplierName,
  'invoiceNumber': instance.invoiceNumber,
  'invoiceDate': instance.invoiceDate?.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'lineItems': instance.lineItems,
  'subtotalHt': instance.subtotalHt,
  'totalVat': instance.totalVat,
  'totalTtc': instance.totalTtc,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'jobSiteId': instance.jobSiteId,
  'scanId': instance.scanId,
  'invoiceImageUrl': instance.invoiceImageUrl,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
