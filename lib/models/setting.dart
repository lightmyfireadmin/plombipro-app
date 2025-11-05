import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable()
class Setting {
  final String id;
  final String userId;
  final String invoicePrefix;
  final String quotePrefix;
  final int invoiceStartingNumber;
  final int quoteStartingNumber;
  final bool resetNumberingAnnually;
  final int defaultPaymentTermsDays;
  final int defaultQuoteValidityDays;
  final double defaultVatRate;
  final double? latePaymentInterestRate;
  final String? defaultQuoteFooter;
  final String? defaultInvoiceFooter;
  final bool enableFacturx;
  final bool chorusProEnabled;
  final Map<String, dynamic>? chorusProCredentials; // jsonb
  final Map<String, dynamic>? emailNotifications; // jsonb
  final Map<String, dynamic>? smsNotifications; // jsonb
  final String theme;
  final String language;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Setting({
    required this.id,
    required this.userId,
    this.invoicePrefix = 'FACT-',
    this.quotePrefix = 'DEV-',
    this.invoiceStartingNumber = 1,
    this.quoteStartingNumber = 1,
    this.resetNumberingAnnually = false,
    this.defaultPaymentTermsDays = 30,
    this.defaultQuoteValidityDays = 30,
    this.defaultVatRate = 20.0,
    this.latePaymentInterestRate,
    this.defaultQuoteFooter,
    this.defaultInvoiceFooter,
    this.enableFacturx = false,
    this.chorusProEnabled = false,
    this.chorusProCredentials,
    this.emailNotifications,
    this.smsNotifications,
    this.theme = 'light',
    this.language = 'fr',
    required this.createdAt,
    this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);
  Map<String, dynamic> toJson() => _$SettingToJson(this);

  Setting copyWith({
    String? id,
    String? userId,
    String? invoicePrefix,
    String? quotePrefix,
    int? invoiceStartingNumber,
    int? quoteStartingNumber,
    bool? resetNumberingAnnually,
    int? defaultPaymentTermsDays,
    int? defaultQuoteValidityDays,
    double? defaultVatRate,
    double? latePaymentInterestRate,
    String? defaultQuoteFooter,
    String? defaultInvoiceFooter,
    bool? enableFacturx,
    bool? chorusProEnabled,
    Map<String, dynamic>? chorusProCredentials,
    Map<String, dynamic>? emailNotifications,
    Map<String, dynamic>? smsNotifications,
    String? theme,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Setting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      quotePrefix: quotePrefix ?? this.quotePrefix,
      invoiceStartingNumber: invoiceStartingNumber ?? this.invoiceStartingNumber,
      quoteStartingNumber: quoteStartingNumber ?? this.quoteStartingNumber,
      resetNumberingAnnually: resetNumberingAnnually ?? this.resetNumberingAnnually,
      defaultPaymentTermsDays: defaultPaymentTermsDays ?? this.defaultPaymentTermsDays,
      defaultQuoteValidityDays: defaultQuoteValidityDays ?? this.defaultQuoteValidityDays,
      defaultVatRate: defaultVatRate ?? this.defaultVatRate,
      latePaymentInterestRate: latePaymentInterestRate ?? this.latePaymentInterestRate,
      defaultQuoteFooter: defaultQuoteFooter ?? this.defaultQuoteFooter,
      defaultInvoiceFooter: defaultInvoiceFooter ?? this.defaultInvoiceFooter,
      enableFacturx: enableFacturx ?? this.enableFacturx,
      chorusProEnabled: chorusProEnabled ?? this.chorusProEnabled,
      chorusProCredentials: chorusProCredentials ?? this.chorusProCredentials,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
