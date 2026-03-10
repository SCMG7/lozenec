class Reservation {
  final String id;
  final String userId;
  final String guestId;
  final String? guestName;
  final String? guestPhone;
  final String? guestEmail;
  final String checkInDate;
  final String checkOutDate;
  final int numNights;
  final int pricePerNight;
  final int totalPrice;
  final int depositAmount;
  final bool depositReceived;
  final String status;
  final String paymentStatus;
  final int amountPaid;
  final String? notes;
  final List<ActivityLogEntry>? activityLog;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.userId,
    required this.guestId,
    this.guestName,
    this.guestPhone,
    this.guestEmail,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numNights,
    required this.pricePerNight,
    required this.totalPrice,
    this.depositAmount = 0,
    this.depositReceived = false,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.amountPaid = 0,
    this.notes,
    this.activityLog,
    required this.createdAt,
    required this.updatedAt,
  });

  int get amountRemaining => totalPrice - amountPaid;

  bool get isFullyPaid => amountPaid >= totalPrice;

  bool get isUpcoming =>
      DateTime.tryParse(checkInDate)?.isAfter(DateTime.now()) ?? false;

  bool get isActive {
    final now = DateTime.now();
    final checkIn = DateTime.tryParse(checkInDate);
    final checkOut = DateTime.tryParse(checkOutDate);
    if (checkIn == null || checkOut == null) return false;
    return now.isAfter(checkIn) && now.isBefore(checkOut);
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      guestId:
          json['guest_id'] as String? ?? json['guestId'] as String? ?? '',
      guestName:
          json['guest_name'] as String? ?? json['guestName'] as String?,
      guestPhone:
          json['guest_phone'] as String? ?? json['guestPhone'] as String?,
      guestEmail:
          json['guest_email'] as String? ?? json['guestEmail'] as String?,
      checkInDate: json['check_in_date'] as String? ??
          json['checkInDate'] as String? ??
          '',
      checkOutDate: json['check_out_date'] as String? ??
          json['checkOutDate'] as String? ??
          '',
      numNights: json['num_nights'] as int? ??
          json['numNights'] as int? ??
          0,
      pricePerNight: json['price_per_night'] as int? ??
          json['pricePerNight'] as int? ??
          0,
      totalPrice: json['total_price'] as int? ??
          json['totalPrice'] as int? ??
          0,
      depositAmount: json['deposit_amount'] as int? ??
          json['depositAmount'] as int? ??
          0,
      depositReceived: json['deposit_received'] as bool? ??
          json['depositReceived'] as bool? ??
          false,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ??
          json['paymentStatus'] as String? ??
          'unpaid',
      amountPaid: json['amount_paid'] as int? ??
          json['amountPaid'] as int? ??
          0,
      notes: json['notes'] as String?,
      activityLog: json['activity_log'] != null
          ? (json['activity_log'] as List)
              .map((e) =>
                  ActivityLogEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : json['activityLog'] != null
              ? (json['activityLog'] as List)
                  .map((e) =>
                      ActivityLogEntry.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
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
      'guest_id': guestId,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'guest_email': guestEmail,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'num_nights': numNights,
      'price_per_night': pricePerNight,
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'deposit_received': depositReceived,
      'status': status,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'guest_id': guestId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'num_nights': numNights,
      'price_per_night': pricePerNight,
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'deposit_received': depositReceived,
      'status': status,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'notes': notes,
    };
  }

  Reservation copyWith({
    String? id,
    String? userId,
    String? guestId,
    String? guestName,
    String? guestPhone,
    String? guestEmail,
    String? checkInDate,
    String? checkOutDate,
    int? numNights,
    int? pricePerNight,
    int? totalPrice,
    int? depositAmount,
    bool? depositReceived,
    String? status,
    String? paymentStatus,
    int? amountPaid,
    String? notes,
    List<ActivityLogEntry>? activityLog,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      guestEmail: guestEmail ?? this.guestEmail,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numNights: numNights ?? this.numNights,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      totalPrice: totalPrice ?? this.totalPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      depositReceived: depositReceived ?? this.depositReceived,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
      activityLog: activityLog ?? this.activityLog,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Reservation(id: $id, guest: $guestName, $checkInDate - $checkOutDate)';
}

class ActivityLogEntry {
  final String id;
  final String action;
  final String description;
  final DateTime createdAt;

  const ActivityLogEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'ActivityLogEntry(id: $id, action: $action, description: $description)';
}
