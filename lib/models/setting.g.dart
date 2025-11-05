// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
  id: json['id'] as String,
  userId: json['userId'] as String,
  invoicePrefix: json['invoicePrefix'] as String? ?? 'FACT-',
  quotePrefix: json['quotePrefix'] as String? ?? 'DEV-',
  invoiceStartingNumber: (json['invoiceStartingNumber'] as num?)?.toInt() ?? 1,
  quoteStartingNumber: (json['quoteStartingNumber'] as num?)?.toInt() ?? 1,
  resetNumberingAnnually: json['resetNumberingAnnually'] as bool? ?? false,
  defaultPaymentTermsDays:
      (json['defaultPaymentTermsDays'] as num?)?.toInt() ?? 30,
  defaultQuoteValidityDays:
      (json['defaultQuoteValidityDays'] as num?)?.toInt() ?? 30,
  defaultVatRate: (json['defaultVatRate'] as num?)?.toDouble() ?? 20.0,
  latePaymentInterestRate: (json['latePaymentInterestRate'] as num?)
      ?.toDouble(),
  defaultQuoteFooter: json['defaultQuoteFooter'] as String?,
  defaultInvoiceFooter: json['defaultInvoiceFooter'] as String?,
  enableFacturx: json['enableFacturx'] as bool? ?? false,
  chorusProEnabled: json['chorusProEnabled'] as bool? ?? false,
  chorusProCredentials: json['chorusProCredentials'] as Map<String, dynamic>?,
  emailNotifications: json['emailNotifications'] as Map<String, dynamic>?,
  smsNotifications: json['smsNotifications'] as Map<String, dynamic>?,
  theme: json['theme'] as String? ?? 'light',
  language: json['language'] as String? ?? 'fr',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'invoicePrefix': instance.invoicePrefix,
  'quotePrefix': instance.quotePrefix,
  'invoiceStartingNumber': instance.invoiceStartingNumber,
  'quoteStartingNumber': instance.quoteStartingNumber,
  'resetNumberingAnnually': instance.resetNumberingAnnually,
  'defaultPaymentTermsDays': instance.defaultPaymentTermsDays,
  'defaultQuoteValidityDays': instance.defaultQuoteValidityDays,
  'defaultVatRate': instance.defaultVatRate,
  'latePaymentInterestRate': instance.latePaymentInterestRate,
  'defaultQuoteFooter': instance.defaultQuoteFooter,
  'defaultInvoiceFooter': instance.defaultInvoiceFooter,
  'enableFacturx': instance.enableFacturx,
  'chorusProEnabled': instance.chorusProEnabled,
  'chorusProCredentials': instance.chorusProCredentials,
  'emailNotifications': instance.emailNotifications,
  'smsNotifications': instance.smsNotifications,
  'theme': instance.theme,
  'language': instance.language,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
