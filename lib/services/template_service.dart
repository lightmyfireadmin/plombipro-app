import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/line_item.dart';

class QuoteTemplate {
  final String id;
  final String templateName;
  final String templateType;
  final String category;
  final List<LineItem> lineItems;
  final String? termsConditions;
  final bool isSystemTemplate;
  final int timesUsed;

  QuoteTemplate({
    required this.id,
    required this.templateName,
    required this.templateType,
    required this.category,
    required this.lineItems,
    this.termsConditions,
    required this.isSystemTemplate,
    this.timesUsed = 0,
  });

  factory QuoteTemplate.fromDatabase(Map<String, dynamic> json) {
    // Parse line_items from database JSONB
    List<LineItem> items = [];
    if (json['line_items'] != null) {
      final lineItemsData = json['line_items'];
      List<dynamic> itemsList;

      // Handle both String (JSON string) and List (already parsed)
      if (lineItemsData is String) {
        itemsList = jsonDecode(lineItemsData) as List<dynamic>;
      } else if (lineItemsData is List) {
        itemsList = lineItemsData;
      } else {
        itemsList = [];
      }

      items = itemsList.map((item) {
        return LineItem(
          description: item['description'] as String,
          quantity: (item['quantity'] as num).toDouble(),
          unitPrice: (item['unit_price'] as num).toDouble(),
          discountPercent: item['discount_percent'] as int? ?? 0,
          taxRate: (item['vat_rate'] as num?)?.toDouble() ?? 20.0,
          unit: item['unit'] as String? ?? 'unité',
        );
      }).toList();
    }

    return QuoteTemplate(
      id: json['id'] as String,
      templateName: json['template_name'] as String,
      templateType: json['template_type'] as String? ?? 'quote',
      category: json['category'] as String? ?? 'Autre',
      lineItems: items,
      termsConditions: json['terms_conditions'] as String?,
      isSystemTemplate: json['is_system_template'] as bool? ?? false,
      timesUsed: json['times_used'] as int? ?? 0,
    );
  }
}

class TemplateInfo {
  final String id; // Template ID from database
  final String name;
  final String category;
  final String estimatedPriceRange;
  final int itemsCount;
  final bool isSystemTemplate;

  TemplateInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedPriceRange,
    required this.itemsCount,
    this.isSystemTemplate = false,
  });

  factory TemplateInfo.fromDatabase(Map<String, dynamic> json) {
    // Calculate price range from line_items
    double totalPrice = 0.0;
    int itemCount = 0;

    if (json['line_items'] != null) {
      final lineItemsData = json['line_items'];
      List<dynamic> itemsList;

      if (lineItemsData is String) {
        itemsList = jsonDecode(lineItemsData) as List<dynamic>;
      } else if (lineItemsData is List) {
        itemsList = lineItemsData;
      } else {
        itemsList = [];
      }

      itemCount = itemsList.length;

      for (var item in itemsList) {
        double quantity = (item['quantity'] as num).toDouble();
        double unitPrice = (item['unit_price'] as num).toDouble();
        totalPrice += quantity * unitPrice;
      }
    }

    // Format price range
    String priceRange;
    if (totalPrice < 500) {
      priceRange = '${totalPrice.toStringAsFixed(0)}';
    } else {
      int rounded = (totalPrice / 100).round() * 100;
      priceRange = '${rounded}+';
    }

    return TemplateInfo(
      id: json['id'] as String,
      name: json['template_name'] as String,
      category: json['category'] as String? ?? 'Autre',
      estimatedPriceRange: priceRange,
      itemsCount: itemCount,
      isSystemTemplate: json['is_system_template'] as bool? ?? false,
    );
  }
}

class TemplateService {
  /// Fetch all system templates from database
  static Future<List<TemplateInfo>> getTemplatesList() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch system templates (is_system_template = true)
      final response = await supabase
          .from('templates')
          .select()
          .eq('is_system_template', true)
          .order('category')
          .order('template_name');

      if (response == null) {
        print('No templates found in database');
        return [];
      }

      final List<dynamic> templatesData = response as List<dynamic>;
      return templatesData
          .map((item) => TemplateInfo.fromDatabase(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading templates from database: $e');
      return [];
    }
  }

  /// Load a specific template by ID
  static Future<QuoteTemplate?> loadTemplate(String templateId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('templates')
          .select()
          .eq('id', templateId)
          .single();

      if (response == null) {
        print('Template not found: $templateId');
        return null;
      }

      // Update times_used counter
      await supabase
          .from('templates')
          .update({
            'times_used': (response['times_used'] as int? ?? 0) + 1,
            'last_used': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);

      return QuoteTemplate.fromDatabase(response);
    } catch (e) {
      print('Error loading template $templateId: $e');
      return null;
    }
  }

  /// Fetch user's custom templates (non-system templates)
  static Future<List<TemplateInfo>> getUserTemplates() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return [];

      final response = await supabase
          .from('templates')
          .select()
          .eq('user_id', userId)
          .eq('is_system_template', false)
          .order('template_name');

      if (response == null) return [];

      final List<dynamic> templatesData = response as List<dynamic>;
      return templatesData
          .map((item) => TemplateInfo.fromDatabase(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading user templates: $e');
      return [];
    }
  }

  /// Group templates by category
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

  /// Create a new custom template
  static Future<String?> createTemplate(QuoteTemplate template) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw Exception('User not authenticated');

      // Convert line items to JSON
      final lineItemsJson = template.lineItems.map((item) => {
        'description': item.description,
        'quantity': item.quantity,
        'unit': item.unit ?? 'unité',
        'unit_price': item.unitPrice,
        'vat_rate': item.taxRate,
        'discount_percent': item.discountPercent,
      }).toList();

      final response = await supabase
          .from('templates')
          .insert({
            'user_id': userId,
            'template_name': template.templateName,
            'template_type': template.templateType,
            'category': template.category,
            'line_items': lineItemsJson,
            'terms_conditions': template.termsConditions,
            'is_system_template': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating template: $e');
      return null;
    }
  }

  /// Delete a user template
  static Future<bool> deleteTemplate(String templateId) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('templates')
          .delete()
          .eq('id', templateId)
          .eq('is_system_template', false); // Safety: can't delete system templates

      return true;
    } catch (e) {
      print('Error deleting template: $e');
      return false;
    }
  }
}
