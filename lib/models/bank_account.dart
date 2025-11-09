class BankAccount {
  final String? id;
  final String userId;
  final String accountName;
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  final String? bic;
  final double currentBalance;
  final double? lastReconciledBalance;
  final DateTime? lastReconciledAt;
  final bool isActive;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BankAccount({
    this.id,
    required this.userId,
    required this.accountName,
    this.bankName,
    this.accountNumber,
    this.iban,
    this.bic,
    this.currentBalance = 0,
    this.lastReconciledBalance,
    this.lastReconciledAt,
    this.isActive = true,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['user_id'],
      accountName: json['account_name'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      iban: json['iban'],
      bic: json['bic'],
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0,
      lastReconciledBalance: (json['last_reconciled_balance'] as num?)?.toDouble(),
      lastReconciledAt: json['last_reconciled_at'] != null
          ? DateTime.parse(json['last_reconciled_at'])
          : null,
      isActive: json['is_active'] ?? true,
      isDefault: json['is_default'] ?? false,
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
      'account_name': accountName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'iban': iban,
      'bic': bic,
      'current_balance': currentBalance,
      'last_reconciled_balance': lastReconciledBalance,
      'last_reconciled_at': lastReconciledAt?.toIso8601String(),
      'is_active': isActive,
      'is_default': isDefault,
    };
  }

  /// Format IBAN for display (with spaces every 4 characters)
  String? get formattedIban {
    if (iban == null) return null;
    final cleaned = iban!.replaceAll(' ', '');
    final chunks = <String>[];
    for (var i = 0; i < cleaned.length; i += 4) {
      final end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
      chunks.add(cleaned.substring(i, end));
    }
    return chunks.join(' ');
  }

  /// Get masked account number for security
  String? get maskedAccountNumber {
    if (accountNumber == null || accountNumber!.length < 4) {
      return accountNumber;
    }
    final lastFour = accountNumber!.substring(accountNumber!.length - 4);
    return '****$lastFour';
  }
}

class BankTransaction {
  final String? id;
  final String userId;
  final String bankAccountId;
  final DateTime transactionDate;
  final DateTime? valueDate;
  final String description;
  final String? reference;
  final double amount; // Negative for debits, positive for credits
  final double? balanceAfter;
  final String? category;
  final String? notes;
  final bool isReconciled;
  final DateTime? reconciledAt;
  final String? reconciledWithType; // 'invoice', 'expense', 'manual'
  final String? reconciledWithId;
  final String? importBatchId;
  final DateTime? importedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BankTransaction({
    this.id,
    required this.userId,
    required this.bankAccountId,
    required this.transactionDate,
    this.valueDate,
    required this.description,
    this.reference,
    required this.amount,
    this.balanceAfter,
    this.category,
    this.notes,
    this.isReconciled = false,
    this.reconciledAt,
    this.reconciledWithType,
    this.reconciledWithId,
    this.importBatchId,
    this.importedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'],
      userId: json['user_id'],
      bankAccountId: json['bank_account_id'],
      transactionDate: DateTime.parse(json['transaction_date']),
      valueDate: json['value_date'] != null
          ? DateTime.parse(json['value_date'])
          : null,
      description: json['description'],
      reference: json['reference'],
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      category: json['category'],
      notes: json['notes'],
      isReconciled: json['is_reconciled'] ?? false,
      reconciledAt: json['reconciled_at'] != null
          ? DateTime.parse(json['reconciled_at'])
          : null,
      reconciledWithType: json['reconciled_with_type'],
      reconciledWithId: json['reconciled_with_id'],
      importBatchId: json['import_batch_id'],
      importedAt: json['imported_at'] != null
          ? DateTime.parse(json['imported_at'])
          : null,
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
      'bank_account_id': bankAccountId,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'value_date': valueDate?.toIso8601String().split('T')[0],
      'description': description,
      'reference': reference,
      'amount': amount,
      'balance_after': balanceAfter,
      'category': category,
      'notes': notes,
      'is_reconciled': isReconciled,
      'reconciled_at': reconciledAt?.toIso8601String(),
      'reconciled_with_type': reconciledWithType,
      'reconciled_with_id': reconciledWithId,
      'import_batch_id': importBatchId,
      'imported_at': importedAt?.toIso8601String(),
    };
  }

  /// Whether this is a debit (outgoing payment)
  bool get isDebit => amount < 0;

  /// Whether this is a credit (incoming payment)
  bool get isCredit => amount > 0;

  /// Get absolute amount
  double get absoluteAmount => amount.abs();

  /// Get transaction type in French
  String get typeLabel {
    if (isDebit) return 'Débit';
    if (isCredit) return 'Crédit';
    return 'Neutre';
  }
}

class ReconciliationRule {
  final String? id;
  final String userId;
  final String ruleName;
  final String? description;
  final String? matchDescriptionPattern;
  final double? matchAmountMin;
  final double? matchAmountMax;
  final String? autoCategorizeAs;
  final bool autoReconcile;
  final bool isActive;
  final int priority;

  ReconciliationRule({
    this.id,
    required this.userId,
    required this.ruleName,
    this.description,
    this.matchDescriptionPattern,
    this.matchAmountMin,
    this.matchAmountMax,
    this.autoCategorizeAs,
    this.autoReconcile = false,
    this.isActive = true,
    this.priority = 0,
  });

  factory ReconciliationRule.fromJson(Map<String, dynamic> json) {
    return ReconciliationRule(
      id: json['id'],
      userId: json['user_id'],
      ruleName: json['rule_name'],
      description: json['description'],
      matchDescriptionPattern: json['match_description_pattern'],
      matchAmountMin: (json['match_amount_min'] as num?)?.toDouble(),
      matchAmountMax: (json['match_amount_max'] as num?)?.toDouble(),
      autoCategorizeAs: json['auto_categorize_as'],
      autoReconcile: json['auto_reconcile'] ?? false,
      isActive: json['is_active'] ?? true,
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'rule_name': ruleName,
      'description': description,
      'match_description_pattern': matchDescriptionPattern,
      'match_amount_min': matchAmountMin,
      'match_amount_max': matchAmountMax,
      'auto_categorize_as': autoCategorizeAs,
      'auto_reconcile': autoReconcile,
      'is_active': isActive,
      'priority': priority,
    };
  }

  /// Check if a transaction matches this rule
  bool matches(BankTransaction transaction) {
    // Check amount range
    if (matchAmountMin != null && transaction.absoluteAmount < matchAmountMin!) {
      return false;
    }
    if (matchAmountMax != null && transaction.absoluteAmount > matchAmountMax!) {
      return false;
    }

    // Check description pattern
    if (matchDescriptionPattern != null && matchDescriptionPattern!.isNotEmpty) {
      final pattern = RegExp(matchDescriptionPattern!, caseSensitive: false);
      if (!pattern.hasMatch(transaction.description)) {
        return false;
      }
    }

    return true;
  }
}
