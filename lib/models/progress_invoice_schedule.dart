class ProgressInvoiceSchedule {
  final String? id;
  final String userId;
  final String quoteId;
  final String? scheduleName;
  final double totalAmount;
  final List<ProgressMilestone> milestones;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgressInvoiceSchedule({
    this.id,
    required this.userId,
    required this.quoteId,
    this.scheduleName,
    required this.totalAmount,
    required this.milestones,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory ProgressInvoiceSchedule.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'] as List<dynamic>? ?? [];
    final milestones = milestonesJson
        .map((m) => ProgressMilestone.fromJson(m as Map<String, dynamic>))
        .toList();

    return ProgressInvoiceSchedule(
      id: json['id'],
      userId: json['user_id'],
      quoteId: json['quote_id'],
      scheduleName: json['schedule_name'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      milestones: milestones,
      status: json['status'] ?? 'active',
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
      'quote_id': quoteId,
      'schedule_name': scheduleName,
      'total_amount': totalAmount,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'status': status,
    };
  }

  /// Get total percentage covered by all milestones
  double get totalPercentage {
    return milestones.fold(0.0, (sum, m) => sum + m.percentage);
  }

  /// Check if the schedule is valid (percentages add up to 100%)
  bool get isValid {
    return (totalPercentage - 100.0).abs() < 0.01; // Allow small floating point errors
  }

  /// Get number of completed milestones
  int get completedMilestonesCount {
    return milestones.where((m) => m.invoiceId != null).length;
  }

  /// Get number of pending milestones
  int get pendingMilestonesCount {
    return milestones.where((m) => m.invoiceId == null).length;
  }

  /// Check if all milestones are completed
  bool get isCompleted {
    return milestones.every((m) => m.invoiceId != null);
  }

  /// Get total amount paid so far
  double get totalPaid {
    return milestones
        .where((m) => m.invoiceId != null)
        .fold(0.0, (sum, m) => sum + (totalAmount * m.percentage / 100));
  }

  /// Get remaining amount to be paid
  double get remainingAmount {
    return totalAmount - totalPaid;
  }

  /// Get status label in French
  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class ProgressMilestone {
  final String name;
  final double percentage;
  final String? invoiceId;
  final DateTime? dueDate;

  ProgressMilestone({
    required this.name,
    required this.percentage,
    this.invoiceId,
    this.dueDate,
  });

  factory ProgressMilestone.fromJson(Map<String, dynamic> json) {
    return ProgressMilestone(
      name: json['name'],
      percentage: (json['percentage'] as num).toDouble(),
      invoiceId: json['invoice_id'],
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'invoice_id': invoiceId,
      'due_date': dueDate?.toIso8601String().split('T')[0],
    };
  }

  /// Whether this milestone has been invoiced
  bool get isInvoiced => invoiceId != null;

  /// Whether this milestone is pending
  bool get isPending => invoiceId == null;

  /// Whether this milestone is overdue (not invoiced and past due date)
  bool get isOverdue {
    if (isInvoiced || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Calculate milestone amount for a given total
  double getAmount(double totalAmount) {
    return totalAmount * (percentage / 100);
  }
}

/// Utility class for creating common progress invoice schedules
class ProgressScheduleTemplates {
  /// Two payments: 50% deposit, 50% final
  static List<ProgressMilestone> twoPayments() {
    return [
      ProgressMilestone(
        name: 'Acompte à la commande',
        percentage: 50.0,
      ),
      ProgressMilestone(
        name: 'Solde',
        percentage: 50.0,
      ),
    ];
  }

  /// Three payments: 30% deposit, 40% mid, 30% final
  static List<ProgressMilestone> threePayments() {
    return [
      ProgressMilestone(
        name: 'Acompte à la commande',
        percentage: 30.0,
      ),
      ProgressMilestone(
        name: 'Paiement intermédiaire',
        percentage: 40.0,
      ),
      ProgressMilestone(
        name: 'Solde',
        percentage: 30.0,
      ),
    ];
  }

  /// Four payments: 25% each
  static List<ProgressMilestone> fourPayments() {
    return [
      ProgressMilestone(
        name: 'Acompte à la commande',
        percentage: 25.0,
      ),
      ProgressMilestone(
        name: 'Premier paiement intermédiaire',
        percentage: 25.0,
      ),
      ProgressMilestone(
        name: 'Deuxième paiement intermédiaire',
        percentage: 25.0,
      ),
      ProgressMilestone(
        name: 'Solde',
        percentage: 25.0,
      ),
    ];
  }

  /// Custom percentage split
  static List<ProgressMilestone> custom(List<double> percentages, List<String> names) {
    if (percentages.length != names.length) {
      throw ArgumentError('Percentages and names must have the same length');
    }

    final milestones = <ProgressMilestone>[];
    for (var i = 0; i < percentages.length; i++) {
      milestones.add(ProgressMilestone(
        name: names[i],
        percentage: percentages[i],
      ));
    }

    return milestones;
  }

  /// Legal French construction milestone schedule (article 1799-1 Code Civil)
  /// Maximum 30% deposit for work > €3,000
  static List<ProgressMilestone> frenchConstructionLegal({
    bool includeDeposit = true,
  }) {
    if (includeDeposit) {
      return [
        ProgressMilestone(
          name: 'Acompte à la commande (max 30%)',
          percentage: 30.0,
        ),
        ProgressMilestone(
          name: 'À la livraison',
          percentage: 70.0,
        ),
      ];
    } else {
      return [
        ProgressMilestone(
          name: 'À la livraison',
          percentage: 100.0,
        ),
      ];
    }
  }
}
