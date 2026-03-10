import 'package:equatable/equatable.dart';
import 'guest_reservation.dart';

class GuestDetail extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? nationality;
  final String? idNumber;
  final String? notes;
  final int totalStays;
  final int totalNights;
  final int totalRevenue;
  final List<GuestReservation> reservations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GuestDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.nationality,
    this.idNumber,
    this.notes,
    required this.totalStays,
    required this.totalNights,
    required this.totalRevenue,
    required this.reservations,
    required this.createdAt,
    required this.updatedAt,
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
        nationality,
        idNumber,
        notes,
        totalStays,
        totalNights,
        totalRevenue,
        reservations,
        createdAt,
        updatedAt,
      ];
}
