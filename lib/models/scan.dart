import 'package:json_annotation/json_annotation.dart';

part 'scan.g.dart';

@JsonSerializable()
class Scan {
  final String id;
  final String userId;
  final String? scanType;
  final String? originalImageUrl;
  final DateTime scanDate;
  final String? extractionStatus;
  final Map<String, dynamic>? extractedData;
  final bool reviewed;
  final bool convertedToPurchase;
  final String? purchaseId;
  final String? generatedQuoteId;
  final DateTime createdAt;

  Scan({
    required this.id,
    required this.userId,
    this.scanType,
    this.originalImageUrl,
    required this.scanDate,
    this.extractionStatus,
    this.extractedData,
    this.reviewed = false,
    this.convertedToPurchase = false,
    this.purchaseId,
    this.generatedQuoteId,
    required this.createdAt,
  });

  factory Scan.fromJson(Map<String, dynamic> json) => _$ScanFromJson(json);
  Map<String, dynamic> toJson() => _$ScanToJson(this);

  Scan copyWith({
    String? id,
    String? userId,
    String? scanType,
    String? originalImageUrl,
    DateTime? scanDate,
    String? extractionStatus,
    Map<String, dynamic>? extractedData,
    bool? reviewed,
    bool? convertedToPurchase,
    String? purchaseId,
    String? generatedQuoteId,
    DateTime? createdAt,
  }) {
    return Scan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scanType: scanType ?? this.scanType,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      scanDate: scanDate ?? this.scanDate,
      extractionStatus: extractionStatus ?? this.extractionStatus,
      extractedData: extractedData ?? this.extractedData,
      reviewed: reviewed ?? this.reviewed,
      convertedToPurchase: convertedToPurchase ?? this.convertedToPurchase,
      purchaseId: purchaseId ?? this.purchaseId,
      generatedQuoteId: generatedQuoteId ?? this.generatedQuoteId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
