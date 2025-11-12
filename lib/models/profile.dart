class Profile {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? siret;
  final String? phone;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? vatNumber;
  final String? logoUrl;
  final String? iban;
  final String? bic;
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final DateTime? trialEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? stripeConnectId;

  Profile({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.companyName,
    this.siret,
    this.phone,
    this.address,
    this.postalCode,
    this.city,
    this.country,
    this.vatNumber,
    this.logoUrl,
    this.iban,
    this.bic,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.trialEndDate,
    this.createdAt,
    this.updatedAt,
    this.stripeConnectId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      companyName: json['company_name'],
      siret: json['siret'],
      phone: json['phone'],
      address: json['address'],
      postalCode: json['postal_code'],
      city: json['city'],
      country: json['country'],
      vatNumber: json['tva_number'],
      logoUrl: json['logo_url'],
      iban: json['iban'],
      bic: json['bic'],
      subscriptionPlan: json['subscription_plan'],
      subscriptionStatus: json['subscription_status'],
      trialEndDate: json['trial_end_date'] != null ? DateTime.parse(json['trial_end_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      stripeConnectId: json['stripe_connect_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'company_name': companyName,
        'siret': siret,
        'phone': phone,
        'address': address,
        'postal_code': postalCode,
        'city': city,
        'country': country,
        'tva_number': vatNumber,
        'logo_url': logoUrl,
        'iban': iban,
        'bic': bic,
        'subscription_plan': subscriptionPlan,
        'subscription_status': subscriptionStatus,
        'trial_end_date': trialEndDate?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'stripe_connect_id': stripeConnectId,
      };

  Profile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? companyName,
    String? siret,
    String? phone,
    String? address,
    String? postalCode,
    String? city,
    String? country,
    String? vatNumber,
    String? logoUrl,
    String? iban,
    String? bic,
    String? subscriptionPlan,
    String? subscriptionStatus,
    DateTime? trialEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stripeConnectId,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      siret: siret ?? this.siret,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
      vatNumber: vatNumber ?? this.vatNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      iban: iban ?? this.iban,
      bic: bic ?? this.bic,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stripeConnectId: stripeConnectId ?? this.stripeConnectId,
    );
  }
}
