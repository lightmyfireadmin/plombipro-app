// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  invoiceId: json['invoiceId'] as String,
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String?,
  transactionReference: json['transactionReference'] as String?,
  stripePaymentId: json['stripePaymentId'] as String?,
  notes: json['notes'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  isReconciled: json['isReconciled'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'invoiceId': instance.invoiceId,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'transactionReference': instance.transactionReference,
  'stripePaymentId': instance.stripePaymentId,
  'notes': instance.notes,
  'receiptUrl': instance.receiptUrl,
  'isReconciled': instance.isReconciled,
  'createdAt': instance.createdAt.toIso8601String(),
};
