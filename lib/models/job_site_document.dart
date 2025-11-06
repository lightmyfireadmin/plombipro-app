/// Job Site Document Model
///
/// Represents a document (PDF, image, invoice, etc.) associated with a job site
class JobSiteDocument {
  final String id;
  final String jobSiteId;
  final String documentName;
  final String documentUrl;
  final String documentType; // 'invoice', 'quote', 'contract', 'photo', 'other'
  final int? fileSize; // in bytes
  final DateTime? uploadedAt;
  final DateTime? createdAt;

  JobSiteDocument({
    required this.id,
    required this.jobSiteId,
    required this.documentName,
    required this.documentUrl,
    required this.documentType,
    this.fileSize,
    this.uploadedAt,
    this.createdAt,
  });

  factory JobSiteDocument.fromJson(Map<String, dynamic> json) {
    return JobSiteDocument(
      id: json['id'] as String,
      jobSiteId: json['job_site_id'] as String,
      documentName: json['document_name'] as String,
      documentUrl: json['document_url'] as String,
      documentType: json['document_type'] as String,
      fileSize: json['file_size'] as int?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_site_id': jobSiteId,
      'document_name': documentName,
      'document_url': documentUrl,
      'document_type': documentType,
      if (fileSize != null) 'file_size': fileSize,
      if (uploadedAt != null) 'uploaded_at': uploadedAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Get a human-readable file size
  String get formattedFileSize {
    if (fileSize == null) return 'Taille inconnue';

    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get icon for document type
  static String getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return '📄';
      case 'quote':
        return '📋';
      case 'contract':
        return '📜';
      case 'photo':
        return '📷';
      case 'pdf':
        return '📕';
      default:
        return '📎';
    }
  }
}
