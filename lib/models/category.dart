import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String userId;
  final String categoryName;
  final String? parentCategoryId;
  final int? orderIndex;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.categoryName,
    this.parentCategoryId,
    this.orderIndex,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category copyWith({
    String? id,
    String? userId,
    String? categoryName,
    String? parentCategoryId,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryName: categoryName ?? this.categoryName,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
