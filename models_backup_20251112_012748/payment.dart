import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final String id;
  final String userId;
  final String invoiceId;
  final DateTime paymentDate;
  final double amount;
  final String? paymentMethod;
  final String? transactionReference;
  final String? stripePaymentId;
  final String? notes;
  final String? receiptUrl;
  final bool isReconciled;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.invoiceId,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod,
    this.transactionReference,
    this.stripePaymentId,
    this.notes,
    this.receiptUrl,
    this.isReconciled = false,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  Payment copyWith({
    String? id,
    String? userId,
    String? invoiceId,
    DateTime? paymentDate,
    double? amount,
    String? paymentMethod,
    String? transactionReference,
    String? stripePaymentId,
    String? notes,
    String? receiptUrl,
    bool? isReconciled,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      stripePaymentId: stripePaymentId ?? this.stripePaymentId,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isReconciled: isReconciled ?? this.isReconciled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
