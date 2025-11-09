class ClientPortalToken {
  final String? id;
  final String userId;
  final String clientId;
  final String token;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime? lastAccessedAt;
  final int accessCount;
  final bool canViewQuotes;
  final bool canViewInvoices;
  final bool canDownloadDocuments;
  final bool canPayInvoices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientPortalToken({
    this.id,
    required this.userId,
    required this.clientId,
    required this.token,
    required this.expiresAt,
    this.isActive = true,
    this.lastAccessedAt,
    this.accessCount = 0,
    this.canViewQuotes = true,
    this.canViewInvoices = true,
    this.canDownloadDocuments = true,
    this.canPayInvoices = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientPortalToken.fromJson(Map<String, dynamic> json) {
    return ClientPortalToken(
      id: json['id'],
      userId: json['user_id'],
      clientId: json['client_id'],
      token: json['token'],
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? true,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'])
          : null,
      accessCount: json['access_count'] ?? 0,
      canViewQuotes: json['can_view_quotes'] ?? true,
      canViewInvoices: json['can_view_invoices'] ?? true,
      canDownloadDocuments: json['can_download_documents'] ?? true,
      canPayInvoices: json['can_pay_invoices'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'client_id': clientId,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'access_count': accessCount,
      'can_view_quotes': canViewQuotes,
      'can_view_invoices': canViewInvoices,
      'can_download_documents': canDownloadDocuments,
      'can_pay_invoices': canPayInvoices,
    };
  }

  /// Whether the token is currently valid
  bool get isValid {
    return isActive && DateTime.now().isBefore(expiresAt);
  }

  /// Whether the token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Days until expiration
  int get daysUntilExpiration {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// Get portal URL for client
  String getPortalUrl(String baseUrl) {
    return '$baseUrl/portal/$token';
  }
}

class ClientPortalActivity {
  final String? id;
  final String tokenId;
  final String clientId;
  final String activityType; // 'login', 'view_quote', 'view_invoice', 'download_document', 'payment'
  final String? documentType; // 'quote', 'invoice'
  final String? documentId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  ClientPortalActivity({
    this.id,
    required this.tokenId,
    required this.clientId,
    required this.activityType,
    this.documentType,
    this.documentId,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory ClientPortalActivity.fromJson(Map<String, dynamic> json) {
    return ClientPortalActivity(
      id: json['id'],
      tokenId: json['token_id'],
      clientId: json['client_id'],
      activityType: json['activity_type'],
      documentType: json['document_type'],
      documentId: json['document_id'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_id': tokenId,
      'client_id': clientId,
      'activity_type': activityType,
      'document_type': documentType,
      'document_id': documentId,
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }

  /// Get activity label in French
  String get activityLabel {
    switch (activityType) {
      case 'login':
        return 'Connexion au portail';
      case 'view_quote':
        return 'Consultation du devis';
      case 'view_invoice':
        return 'Consultation de la facture';
      case 'download_document':
        return 'Téléchargement du document';
      case 'payment':
        return 'Paiement effectué';
      default:
        return activityType;
    }
  }
}
