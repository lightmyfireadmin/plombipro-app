class Client {
  final String? id;
  final String userId;
  final String clientType;
  final String? salutation;
  final String? firstName;
  final String name; // Corresponds to company_name or last_name
  final String? email;
  final String? phone;
  final String? mobilePhone;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? billingAddress;
  final String? siret;
  final String? vatNumber;
  final int? defaultPaymentTerms;
  final double? defaultDiscount;
  final List<String>? tags;
  final bool isFavorite;
  final String? notes;

  Client({
    this.id,
    required this.userId,
    this.clientType = 'individual',
    this.salutation,
    this.firstName,
    required this.name,
    this.email,
    this.phone,
    this.mobilePhone,
    this.address,
    this.postalCode,
    this.city,
    this.country = 'France',
    this.billingAddress,
    this.siret,
    this.vatNumber,
    this.defaultPaymentTerms,
    this.defaultDiscount,
    this.tags,
    this.isFavorite = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_type': clientType,
        'salutation': salutation,
        'first_name': firstName,
        'company_name': name, // Using name for company_name for simplicity
        'last_name': name, // Or handle based on clientType
        'email': email,
        'phone': phone,
        'mobile_phone': mobilePhone,
        'address': address,
        'postal_code': postalCode,
        'city': city,
        'country': country,
        'billing_address': billingAddress,
        'siret': siret,
        'vat_number': vatNumber,
        'default_payment_terms': defaultPaymentTerms,
        'default_discount': defaultDiscount,
        'tags': tags,
        'is_favorite': isFavorite,
        'notes': notes,
      };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      userId: json['user_id'],
      clientType: json['client_type'] ?? 'individual',
      salutation: json['salutation'],
      firstName: json['first_name'],
      name: json['company_name'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobilePhone: json['mobile_phone'],
      address: json['address'],
      postalCode: json['postal_code'],
      city: json['city'],
      country: json['country'],
      billingAddress: json['billing_address'],
      siret: json['siret'],
      vatNumber: json['vat_number'],
      defaultPaymentTerms: json['default_payment_terms'],
      defaultDiscount: (json['default_discount'] as num?)?.toDouble(),
      tags: (json['tags'] as List?)?.cast<String>(),
      isFavorite: json['is_favorite'] ?? false,
      notes: json['notes'],
    );
  }
}
