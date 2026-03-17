import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final int defaultPricePerNight;
  final String currency;
  final String language;
  final String checkInTime;
  final String checkOutTime;
  final String? propertyName;
  final String? propertyAddress;
  final String? propertyType;
  final bool onboardingCompleted;
  final bool notificationsEnabled;
  final bool notifyCheckIn;
  final bool notifyCheckOut;
  final bool notifyPaymentDue;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.defaultPricePerNight = 0,
    this.currency = 'EUR',
    this.language = 'bg',
    this.checkInTime = '14:00',
    this.checkOutTime = '12:00',
    this.propertyName,
    this.propertyAddress,
    this.propertyType,
    this.onboardingCompleted = false,
    this.notificationsEnabled = true,
    this.notifyCheckIn = true,
    this.notifyCheckOut = true,
    this.notifyPaymentDue = true,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    int? defaultPricePerNight,
    String? currency,
    String? language,
    String? checkInTime,
    String? checkOutTime,
    String? propertyName,
    String? propertyAddress,
    String? propertyType,
    bool? onboardingCompleted,
    bool? notificationsEnabled,
    bool? notifyCheckIn,
    bool? notifyCheckOut,
    bool? notifyPaymentDue,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      defaultPricePerNight: defaultPricePerNight ?? this.defaultPricePerNight,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      propertyName: propertyName ?? this.propertyName,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      propertyType: propertyType ?? this.propertyType,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyCheckIn: notifyCheckIn ?? this.notifyCheckIn,
      notifyCheckOut: notifyCheckOut ?? this.notifyCheckOut,
      notifyPaymentDue: notifyPaymentDue ?? this.notifyPaymentDue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        defaultPricePerNight,
        currency,
        language,
        checkInTime,
        checkOutTime,
        propertyName,
        propertyAddress,
        propertyType,
        onboardingCompleted,
        notificationsEnabled,
        notifyCheckIn,
        notifyCheckOut,
        notifyPaymentDue,
        createdAt,
      ];
}
