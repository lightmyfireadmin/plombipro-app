// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
  id: json['id'] as String,
  userId: json['userId'] as String,
  templateName: json['templateName'] as String,
  templateType: json['templateType'] as String?,
  category: json['category'] as String?,
  lineItems: json['lineItems'] as Map<String, dynamic>?,
  termsConditions: json['termsConditions'] as String?,
  isSystemTemplate: json['isSystemTemplate'] as bool? ?? false,
  timesUsed: (json['timesUsed'] as num?)?.toInt() ?? 0,
  lastUsed: json['lastUsed'] == null
      ? null
      : DateTime.parse(json['lastUsed'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'templateName': instance.templateName,
  'templateType': instance.templateType,
  'category': instance.category,
  'lineItems': instance.lineItems,
  'termsConditions': instance.termsConditions,
  'isSystemTemplate': instance.isSystemTemplate,
  'timesUsed': instance.timesUsed,
  'lastUsed': instance.lastUsed?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
