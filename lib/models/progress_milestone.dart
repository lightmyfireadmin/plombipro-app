/// Model class for progress milestones
class ProgressMilestone {
  final String id;
  final String scheduleId;
  final String milestoneName;
  final String? description;
  final double? percentage; // For percentage-based schedules
  final double? amount; // For amount-based schedules
  final DateTime? dueDate;
  final String? invoiceId; // Linked invoice once generated
  final String status; // 'pending', 'invoiced', 'paid', 'cancelled'
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProgressMilestone({
    required this.id,
    required this.scheduleId,
    required this.milestoneName,
    this.description,
    this.percentage,
    this.amount,
    this.dueDate,
    this.invoiceId,
    this.status = 'pending',
    this.displayOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProgressMilestone.fromJson(Map<String, dynamic> json) {
    return ProgressMilestone(
      id: json['id'] as String,
      scheduleId: json['schedule_id'] as String,
      milestoneName: json['milestone_name'] as String,
      description: json['description'] as String?,
      percentage: json['percentage'] != null
          ? (json['percentage'] as num).toDouble()
          : null,
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      invoiceId: json['invoice_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'milestone_name': milestoneName,
      'description': description,
      'percentage': percentage,
      'amount': amount,
      'due_date': dueDate?.toIso8601String(),
      'invoice_id': invoiceId,
      'status': status,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProgressMilestone copyWith({
    String? id,
    String? scheduleId,
    String? milestoneName,
    String? description,
    double? percentage,
    double? amount,
    DateTime? dueDate,
    String? invoiceId,
    String? status,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressMilestone(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      milestoneName: milestoneName ?? this.milestoneName,
      description: description ?? this.description,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      invoiceId: invoiceId ?? this.invoiceId,
      status: status ?? this.status,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get status text in French
  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'invoiced':
        return 'Facturé';
      case 'paid':
        return 'Payé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  /// Check if milestone is overdue
  bool get isOverdue {
    if (status == 'paid' || status == 'cancelled') return false;
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if milestone is completed
  bool get isCompleted {
    return status == 'paid';
  }

  /// Check if milestone can be invoiced
  bool get canBeInvoiced {
    return status == 'pending' && invoiceId == null;
  }
}
