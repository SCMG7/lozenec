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
    super.propertyName,
    super.propertyAddress,
    super.propertyType,
    super.onboardingCompleted,
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
      propertyName: json['property_name'] as String?,
      propertyAddress: json['property_address'] as String?,
      propertyType: json['property_type'] as String?,
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
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
      'property_name': propertyName,
      'property_address': propertyAddress,
      'property_type': propertyType,
      'onboarding_completed': onboardingCompleted,
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
      propertyName: user.propertyName,
      propertyAddress: user.propertyAddress,
      propertyType: user.propertyType,
      onboardingCompleted: user.onboardingCompleted,
      notificationsEnabled: user.notificationsEnabled,
      notifyCheckIn: user.notifyCheckIn,
      notifyCheckOut: user.notifyCheckOut,
      notifyPaymentDue: user.notifyPaymentDue,
      createdAt: user.createdAt,
    );
  }
}
