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

    // Backend sends full_name as a single field; split into first/last
    final fullName = json['full_name'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Stats come nested from the backend
    final stats = json['stats'] as Map<String, dynamic>?;

    return GuestDetailModel(
      id: json['id'] as String,
      firstName: firstName,
      lastName: lastName,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      nationality: json['country'] as String?,
      idNumber: json['id_number'] as String?,
      notes: json['notes'] as String?,
      totalStays: stats?['total_reservations'] as int? ?? 0,
      totalNights: stats?['total_nights'] as int? ?? 0,
      totalRevenue: stats?['total_spent'] as int? ?? 0,
      reservations: reservations,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
