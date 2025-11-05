import 'package:json_annotation/json_annotation.dart';

part 'purchase.g.dart';

@JsonSerializable()
class Purchase {
  final String id;
  final String userId;
  final String? supplierName;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final Map<String, dynamic>? lineItems; // jsonb
  final double? subtotalHt;
  final double? totalVat;
  final double? totalTtc;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? jobSiteId;
  final String? scanId;
  final String? invoiceImageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Purchase({
    required this.id,
    required this.userId,
    this.supplierName,
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.lineItems,
    this.subtotalHt,
    this.totalVat,
    this.totalTtc,
    this.paymentStatus,
    this.paymentMethod,
    this.jobSiteId,
    this.scanId,
    this.invoiceImageUrl,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseToJson(this);

  Purchase copyWith({
    String? id,
    String? userId,
    String? supplierName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    Map<String, dynamic>? lineItems,
    double? subtotalHt,
    double? totalVat,
    double? totalTtc,
    String? paymentStatus,
    String? paymentMethod,
    String? jobSiteId,
    String? scanId,
    String? invoiceImageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      supplierName: supplierName ?? this.supplierName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      lineItems: lineItems ?? this.lineItems,
      subtotalHt: subtotalHt ?? this.subtotalHt,
      totalVat: totalVat ?? this.totalVat,
      totalTtc: totalTtc ?? this.totalTtc,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      jobSiteId: jobSiteId ?? this.jobSiteId,
      scanId: scanId ?? this.scanId,
      invoiceImageUrl: invoiceImageUrl ?? this.invoiceImageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
