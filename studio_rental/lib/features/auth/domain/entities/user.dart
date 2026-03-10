import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String studioName;
  final String? studioAddress;
  final int? defaultPricePerNight;
  final String currency;
  final String? defaultCheckInTime;
  final String? defaultCheckOutTime;
  final String weekStartsOn;
  final bool notifyBeforeCheckin;
  final bool notifyOnCheckout;
  final bool notifyUnpaid;
  final bool pushNotificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studioName,
    this.studioAddress,
    this.defaultPricePerNight,
    this.currency = 'BGN',
    this.defaultCheckInTime,
    this.defaultCheckOutTime,
    this.weekStartsOn = 'monday',
    this.notifyBeforeCheckin = true,
    this.notifyOnCheckout = true,
    this.notifyUnpaid = true,
    this.pushNotificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? studioName,
    String? studioAddress,
    int? defaultPricePerNight,
    String? currency,
    String? defaultCheckInTime,
    String? defaultCheckOutTime,
    String? weekStartsOn,
    bool? notifyBeforeCheckin,
    bool? notifyOnCheckout,
    bool? notifyUnpaid,
    bool? pushNotificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      studioName: studioName ?? this.studioName,
      studioAddress: studioAddress ?? this.studioAddress,
      defaultPricePerNight: defaultPricePerNight ?? this.defaultPricePerNight,
      currency: currency ?? this.currency,
      defaultCheckInTime: defaultCheckInTime ?? this.defaultCheckInTime,
      defaultCheckOutTime: defaultCheckOutTime ?? this.defaultCheckOutTime,
      weekStartsOn: weekStartsOn ?? this.weekStartsOn,
      notifyBeforeCheckin: notifyBeforeCheckin ?? this.notifyBeforeCheckin,
      notifyOnCheckout: notifyOnCheckout ?? this.notifyOnCheckout,
      notifyUnpaid: notifyUnpaid ?? this.notifyUnpaid,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        studioName,
        studioAddress,
        defaultPricePerNight,
        currency,
        defaultCheckInTime,
        defaultCheckOutTime,
        weekStartsOn,
        notifyBeforeCheckin,
        notifyOnCheckout,
        notifyUnpaid,
        pushNotificationsEnabled,
        createdAt,
        updatedAt,
      ];
}
