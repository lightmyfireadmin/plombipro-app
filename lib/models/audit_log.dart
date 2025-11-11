/// Model class for audit logs
class AuditLog {
  final int id;
  final String? userId;
  final String tableName;
  final String operation; // 'INSERT', 'UPDATE', 'DELETE'
  final String recordId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final List<String>? changedFields;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    this.userId,
    required this.tableName,
    required this.operation,
    required this.recordId,
    this.oldData,
    this.newData,
    this.changedFields,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      tableName: json['table_name'] as String,
      operation: json['operation'] as String,
      recordId: json['record_id'] as String,
      oldData: json['old_data'] as Map<String, dynamic>?,
      newData: json['new_data'] as Map<String, dynamic>?,
      changedFields: json['changed_fields'] != null
          ? List<String>.from(json['changed_fields'] as List)
          : null,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'table_name': tableName,
      'operation': operation,
      'record_id': recordId,
      'old_data': oldData,
      'new_data': newData,
      'changed_fields': changedFields,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get operation text in French
  String get operationText {
    switch (operation) {
      case 'INSERT':
        return 'Création';
      case 'UPDATE':
        return 'Modification';
      case 'DELETE':
        return 'Suppression';
      default:
        return operation;
    }
  }

  /// Get table name in French
  String get tableNameText {
    const tableMap = {
      'clients': 'Client',
      'quotes': 'Devis',
      'invoices': 'Facture',
      'products': 'Produit',
      'payments': 'Paiement',
      'job_sites': 'Chantier',
      'appointments': 'Rendez-vous',
    };
    return tableMap[tableName] ?? tableName;
  }

  /// Get summary text
  String get summary {
    return '$operationText de $tableNameText';
  }
}
