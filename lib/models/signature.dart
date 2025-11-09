class Signature {
  final String? id;
  final String userId;
  final String documentType; // 'quote' or 'invoice'
  final String documentId;
  final String signatureData; // Base64 encoded image
  final String signatureMethod; // 'drawn', 'uploaded', 'typed'
  final String signerName;
  final String? signerEmail;
  final String? signerIpAddress;
  final DateTime signedAt;
  final String? deviceInfo;
  final Map<String, dynamic>? locationData;
  final bool isValid;
  final DateTime? invalidatedAt;
  final String? invalidationReason;

  Signature({
    this.id,
    required this.userId,
    required this.documentType,
    required this.documentId,
    required this.signatureData,
    this.signatureMethod = 'drawn',
    required this.signerName,
    this.signerEmail,
    this.signerIpAddress,
    required this.signedAt,
    this.deviceInfo,
    this.locationData,
    this.isValid = true,
    this.invalidatedAt,
    this.invalidationReason,
  });

  factory Signature.fromJson(Map<String, dynamic> json) {
    return Signature(
      id: json['id'],
      userId: json['user_id'],
      documentType: json['document_type'],
      documentId: json['document_id'],
      signatureData: json['signature_data'],
      signatureMethod: json['signature_method'] ?? 'drawn',
      signerName: json['signer_name'],
      signerEmail: json['signer_email'],
      signerIpAddress: json['signer_ip_address'],
      signedAt: DateTime.parse(json['signed_at']),
      deviceInfo: json['device_info'],
      locationData: json['location_data'],
      isValid: json['is_valid'] ?? true,
      invalidatedAt: json['invalidated_at'] != null
          ? DateTime.parse(json['invalidated_at'])
          : null,
      invalidationReason: json['invalidation_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'document_type': documentType,
      'document_id': documentId,
      'signature_data': signatureData,
      'signature_method': signatureMethod,
      'signer_name': signerName,
      'signer_email': signerEmail,
      'signer_ip_address': signerIpAddress,
      'signed_at': signedAt.toIso8601String(),
      'device_info': deviceInfo,
      'location_data': locationData,
      'is_valid': isValid,
      'invalidated_at': invalidatedAt?.toIso8601String(),
      'invalidation_reason': invalidationReason,
    };
  }
}
