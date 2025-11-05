// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String,
  userId: json['userId'] as String,
  notificationType: json['notificationType'] as String?,
  title: json['title'] as String?,
  message: json['message'] as String?,
  linkUrl: json['linkUrl'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'notificationType': instance.notificationType,
      'title': instance.title,
      'message': instance.message,
      'linkUrl': instance.linkUrl,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
