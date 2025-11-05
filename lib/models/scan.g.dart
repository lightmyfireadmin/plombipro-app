// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scan _$ScanFromJson(Map<String, dynamic> json) => Scan(
  id: json['id'] as String,
  userId: json['userId'] as String,
  scanType: json['scanType'] as String?,
  originalImageUrl: json['originalImageUrl'] as String?,
  scanDate: DateTime.parse(json['scanDate'] as String),
  extractionStatus: json['extractionStatus'] as String?,
  extractedData: json['extractedData'] as Map<String, dynamic>?,
  reviewed: json['reviewed'] as bool? ?? false,
  convertedToPurchase: json['convertedToPurchase'] as bool? ?? false,
  purchaseId: json['purchaseId'] as String?,
  generatedQuoteId: json['generatedQuoteId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ScanToJson(Scan instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'scanType': instance.scanType,
  'originalImageUrl': instance.originalImageUrl,
  'scanDate': instance.scanDate.toIso8601String(),
  'extractionStatus': instance.extractionStatus,
  'extractedData': instance.extractedData,
  'reviewed': instance.reviewed,
  'convertedToPurchase': instance.convertedToPurchase,
  'purchaseId': instance.purchaseId,
  'generatedQuoteId': instance.generatedQuoteId,
  'createdAt': instance.createdAt.toIso8601String(),
};
