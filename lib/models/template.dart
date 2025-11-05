import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable()
class Template {
  final String id;
  final String userId;
  final String templateName;
  final String? templateType;
  final String? category;
  final Map<String, dynamic>? lineItems; // jsonb
  final String? termsConditions;
  final bool isSystemTemplate;
  final int timesUsed;
  final DateTime? lastUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Template({
    required this.id,
    required this.userId,
    required this.templateName,
    this.templateType,
    this.category,
    this.lineItems,
    this.termsConditions,
    this.isSystemTemplate = false,
    this.timesUsed = 0,
    this.lastUsed,
    required this.createdAt,
    this.updatedAt,
  });

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);

  Template copyWith({
    String? id,
    String? userId,
    String? templateName,
    String? templateType,
    String? category,
    Map<String, dynamic>? lineItems,
    String? termsConditions,
    bool? isSystemTemplate,
    int? timesUsed,
    DateTime? lastUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      templateName: templateName ?? this.templateName,
      templateType: templateType ?? this.templateType,
      category: category ?? this.category,
      lineItems: lineItems ?? this.lineItems,
      termsConditions: termsConditions ?? this.termsConditions,
      isSystemTemplate: isSystemTemplate ?? this.isSystemTemplate,
      timesUsed: timesUsed ?? this.timesUsed,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
