// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StripeSubscription _$StripeSubscriptionFromJson(Map<String, dynamic> json) =>
    StripeSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
      planId: json['planId'] as String?,
      status: json['status'] as String?,
      currentPeriodStart: json['currentPeriodStart'] == null
          ? null
          : DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: json['currentPeriodEnd'] == null
          ? null
          : DateTime.parse(json['currentPeriodEnd'] as String),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StripeSubscriptionToJson(StripeSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'stripeCustomerId': instance.stripeCustomerId,
      'stripeSubscriptionId': instance.stripeSubscriptionId,
      'planId': instance.planId,
      'status': instance.status,
      'currentPeriodStart': instance.currentPeriodStart?.toIso8601String(),
      'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
      'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
