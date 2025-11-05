import 'package:json_annotation/json_annotation.dart';

part 'stripe_subscription.g.dart';

@JsonSerializable()
class StripeSubscription {
  final String id;
  final String userId;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? planId;
  final String? status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool? cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StripeSubscription({
    required this.id,
    required this.userId,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.planId,
    this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd,
    required this.createdAt,
    this.updatedAt,
  });

  factory StripeSubscription.fromJson(Map<String, dynamic> json) => _$StripeSubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$StripeSubscriptionToJson(this);

  StripeSubscription copyWith({
    String? id,
    String? userId,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    String? planId,
    String? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    bool? cancelAtPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StripeSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
