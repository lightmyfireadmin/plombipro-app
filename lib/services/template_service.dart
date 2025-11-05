import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/line_item.dart';

class QuoteTemplate {
  final String templateName;
  final String templateType;
  final String category;
  final List<LineItem> lineItems;
  final String? termsConditions;
  final bool isSystemTemplate;

  QuoteTemplate({
    required this.templateName,
    required this.templateType,
    required this.category,
    required this.lineItems,
    this.termsConditions,
    required this.isSystemTemplate,
  });

  factory QuoteTemplate.fromJson(Map<String, dynamic> json) {
    return QuoteTemplate(
      templateName: json['template_name'] as String,
      templateType: json['template_type'] as String,
      category: json['category'] as String,
      lineItems: (json['line_items'] as List<dynamic>)
          .map((item) => LineItem(
                description: item['description'] as String,
                quantity: (item['quantity'] as num).toDouble(),
                unitPrice: (item['unit_price'] as num).toDouble(),
                discountPercent: item['discount_percent'] as int? ?? 0,
                taxRate: (item['tax_rate'] as num?)?.toDouble() ?? 20.0,
              ))
          .toList(),
      termsConditions: json['terms_conditions'] as String?,
      isSystemTemplate: json['is_system_template'] as bool? ?? false,
    );
  }
}

class TemplateInfo {
  final String file;
  final String name;
  final String category;
  final String estimatedPriceRange;
  final int itemsCount;

  TemplateInfo({
    required this.file,
    required this.name,
    required this.category,
    required this.estimatedPriceRange,
    required this.itemsCount,
  });

  factory TemplateInfo.fromJson(Map<String, dynamic> json) {
    return TemplateInfo(
      file: json['file'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      estimatedPriceRange: json['estimated_price_range'] as String,
      itemsCount: json['items_count'] as int,
    );
  }
}

class TemplateService {
  static Future<List<TemplateInfo>> getTemplatesList() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/templates/templates_index.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> templates = data['templates'] as List<dynamic>;
      return templates
          .map((item) => TemplateInfo.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading templates index: $e');
      return [];
    }
  }

  static Future<QuoteTemplate?> loadTemplate(String fileName) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/templates/$fileName');
      final Map<String, dynamic> data = json.decode(jsonString);
      return QuoteTemplate.fromJson(data);
    } catch (e) {
      print('Error loading template $fileName: $e');
      return null;
    }
  }

  static Map<String, List<TemplateInfo>> groupByCategory(
      List<TemplateInfo> templates) {
    final Map<String, List<TemplateInfo>> grouped = {};
    for (var template in templates) {
      if (!grouped.containsKey(template.category)) {
        grouped[template.category] = [];
      }
      grouped[template.category]!.add(template);
    }
    return grouped;
  }
}
