import 'package:equatable/equatable.dart';

class GuestListItem extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final DateTime? lastStayDate;
  final int totalStays;
  final bool hasUpcoming;

  const GuestListItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.lastStayDate,
    required this.totalStays,
    required this.hasUpcoming,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        email,
        lastStayDate,
        totalStays,
        hasUpcoming,
      ];
}
