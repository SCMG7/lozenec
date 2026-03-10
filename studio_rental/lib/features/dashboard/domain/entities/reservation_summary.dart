import 'package:equatable/equatable.dart';

class ReservationSummary extends Equatable {
  final String id;
  final String guestName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numNights;
  final int totalPrice;
  final String status;

  const ReservationSummary({
    required this.id,
    required this.guestName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numNights,
    required this.totalPrice,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        guestName,
        checkInDate,
        checkOutDate,
        numNights,
        totalPrice,
        status,
      ];
}
