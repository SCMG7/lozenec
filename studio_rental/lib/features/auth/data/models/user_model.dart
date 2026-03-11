import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.defaultPricePerNight,
    super.currency,
    super.language,
    super.checkInTime,
    super.checkOutTime,
    super.notificationsEnabled,
    super.notifyCheckIn,
    super.notifyCheckOut,
    super.notifyPaymentDue,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      defaultPricePerNight: (json['default_price_per_night'] as int?) ?? 0,
      currency: (json['currency'] as String?) ?? 'EUR',
      language: (json['language'] as String?) ?? 'bg',
      checkInTime: (json['check_in_time'] as String?) ?? '14:00',
      checkOutTime: (json['check_out_time'] as String?) ?? '12:00',
      notificationsEnabled: (json['notifications_enabled'] as bool?) ?? true,
      notifyCheckIn: (json['notify_check_in'] as bool?) ?? true,
      notifyCheckOut: (json['notify_check_out'] as bool?) ?? true,
      notifyPaymentDue: (json['notify_payment_due'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'default_price_per_night': defaultPricePerNight,
      'currency': currency,
      'language': language,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'notifications_enabled': notificationsEnabled,
      'notify_check_in': notifyCheckIn,
      'notify_check_out': notifyCheckOut,
      'notify_payment_due': notifyPaymentDue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      defaultPricePerNight: user.defaultPricePerNight,
      currency: user.currency,
      language: user.language,
      checkInTime: user.checkInTime,
      checkOutTime: user.checkOutTime,
      notificationsEnabled: user.notificationsEnabled,
      notifyCheckIn: user.notifyCheckIn,
      notifyCheckOut: user.notifyCheckOut,
      notifyPaymentDue: user.notifyPaymentDue,
      createdAt: user.createdAt,
    );
  }
}
