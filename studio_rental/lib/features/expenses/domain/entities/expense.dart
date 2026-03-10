class Expense {
  final String id;
  final String userId;
  final String title;
  final int amount;
  final String date;
  final String category;
  final String? notes;
  final bool isRecurring;
  final String? recurrenceFreq;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.isRecurring = false,
    this.recurrenceFreq,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      notes: json['notes'] as String?,
      isRecurring: json['is_recurring'] as bool? ??
          json['isRecurring'] as bool? ??
          false,
      recurrenceFreq: json['recurrence_freq'] as String? ??
          json['recurrenceFreq'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
      'notes': notes,
      'is_recurring': isRecurring,
      'recurrence_freq': recurrenceFreq,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
      'notes': notes,
      'is_recurring': isRecurring,
      'recurrence_freq': recurrenceFreq,
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    int? amount,
    String? date,
    String? category,
    String? notes,
    bool? isRecurring,
    String? recurrenceFreq,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFreq: recurrenceFreq ?? this.recurrenceFreq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount)';
}

class ExpenseSummary {
  final int totalAmount;
  final Expense? largestExpense;
  final int entryCount;

  const ExpenseSummary({
    required this.totalAmount,
    this.largestExpense,
    required this.entryCount,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      totalAmount: json['totalAmount'] as int? ??
          json['total_amount'] as int? ??
          0,
      largestExpense: json['largestExpense'] != null
          ? Expense.fromJson(json['largestExpense'] as Map<String, dynamic>)
          : json['largest_expense'] != null
              ? Expense.fromJson(
                  json['largest_expense'] as Map<String, dynamic>)
              : null,
      entryCount: json['entryCount'] as int? ??
          json['entry_count'] as int? ??
          0,
    );
  }

  @override
  String toString() =>
      'ExpenseSummary(total: $totalAmount, count: $entryCount)';
}
