import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.studioName,
    super.studioAddress,
    super.defaultPricePerNight,
    super.currency,
    super.defaultCheckInTime,
    super.defaultCheckOutTime,
    super.weekStartsOn,
    super.notifyBeforeCheckin,
    super.notifyOnCheckout,
    super.notifyUnpaid,
    super.pushNotificationsEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      studioName: json['studioName'] as String,
      studioAddress: json['studioAddress'] as String?,
      defaultPricePerNight: json['defaultPricePerNight'] as int?,
      currency: (json['currency'] as String?) ?? 'BGN',
      defaultCheckInTime: json['defaultCheckInTime'] as String?,
      defaultCheckOutTime: json['defaultCheckOutTime'] as String?,
      weekStartsOn: (json['weekStartsOn'] as String?) ?? 'monday',
      notifyBeforeCheckin: (json['notifyBeforeCheckin'] as bool?) ?? true,
      notifyOnCheckout: (json['notifyOnCheckout'] as bool?) ?? true,
      notifyUnpaid: (json['notifyUnpaid'] as bool?) ?? true,
      pushNotificationsEnabled:
          (json['pushNotificationsEnabled'] as bool?) ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'studioName': studioName,
      'studioAddress': studioAddress,
      'defaultPricePerNight': defaultPricePerNight,
      'currency': currency,
      'defaultCheckInTime': defaultCheckInTime,
      'defaultCheckOutTime': defaultCheckOutTime,
      'weekStartsOn': weekStartsOn,
      'notifyBeforeCheckin': notifyBeforeCheckin,
      'notifyOnCheckout': notifyOnCheckout,
      'notifyUnpaid': notifyUnpaid,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      studioName: user.studioName,
      studioAddress: user.studioAddress,
      defaultPricePerNight: user.defaultPricePerNight,
      currency: user.currency,
      defaultCheckInTime: user.defaultCheckInTime,
      defaultCheckOutTime: user.defaultCheckOutTime,
      weekStartsOn: user.weekStartsOn,
      notifyBeforeCheckin: user.notifyBeforeCheckin,
      notifyOnCheckout: user.notifyOnCheckout,
      notifyUnpaid: user.notifyUnpaid,
      pushNotificationsEnabled: user.pushNotificationsEnabled,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
