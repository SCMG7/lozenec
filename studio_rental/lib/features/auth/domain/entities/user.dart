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
        notificationsEnabled,
        notifyCheckIn,
        notifyCheckOut,
        notifyPaymentDue,
        createdAt,
      ];
}
