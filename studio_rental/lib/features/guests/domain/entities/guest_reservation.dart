import 'package:equatable/equatable.dart';

class GuestReservation extends Equatable {
  final String id;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numNights;
  final int totalPrice;
  final String status;

  const GuestReservation({
    required this.id,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numNights,
    required this.totalPrice,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        checkInDate,
        checkOutDate,
        numNights,
        totalPrice,
        status,
      ];
}
