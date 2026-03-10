import '../../domain/entities/guest_detail.dart';
import 'guest_reservation_model.dart';

class GuestDetailModel extends GuestDetail {
  const GuestDetailModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.email,
    super.nationality,
    super.idNumber,
    super.notes,
    required super.totalStays,
    required super.totalNights,
    required super.totalRevenue,
    required super.reservations,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GuestDetailModel.fromJson(Map<String, dynamic> json) {
    final reservationsJson = json['reservations'] as List<dynamic>? ?? [];
    final reservations = reservationsJson
        .map((r) => GuestReservationModel.fromJson(r as Map<String, dynamic>))
        .toList();

    return GuestDetailModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      nationality: json['nationality'] as String?,
      idNumber: json['idNumber'] as String?,
      notes: json['notes'] as String?,
      totalStays: json['totalStays'] as int? ?? 0,
      totalNights: json['totalNights'] as int? ?? 0,
      totalRevenue: json['totalRevenue'] as int? ?? 0,
      reservations: reservations,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
