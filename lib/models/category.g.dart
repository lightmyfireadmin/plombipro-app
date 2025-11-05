// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  userId: json['userId'] as String,
  categoryName: json['categoryName'] as String,
  parentCategoryId: json['parentCategoryId'] as String?,
  orderIndex: (json['orderIndex'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryName': instance.categoryName,
  'parentCategoryId': instance.parentCategoryId,
  'orderIndex': instance.orderIndex,
  'createdAt': instance.createdAt.toIso8601String(),
};
