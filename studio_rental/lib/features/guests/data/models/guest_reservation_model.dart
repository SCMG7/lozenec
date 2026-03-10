import '../../domain/entities/guest_reservation.dart';

class GuestReservationModel extends GuestReservation {
  const GuestReservationModel({
    required super.id,
    required super.checkInDate,
    required super.checkOutDate,
    required super.numNights,
    required super.totalPrice,
    required super.status,
  });

  factory GuestReservationModel.fromJson(Map<String, dynamic> json) {
    return GuestReservationModel(
      id: json['id'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      numNights: json['numNights'] as int,
      totalPrice: json['totalPrice'] as int,
      status: json['status'] as String,
    );
  }
}
