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
    final checkIn = DateTime.parse(json['check_in'] as String);
    final checkOut = DateTime.parse(json['check_out'] as String);
    final numNights = checkOut.difference(checkIn).inDays;

    return GuestReservationModel(
      id: json['id'] as String,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      numNights: numNights,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String,
    );
  }
}
