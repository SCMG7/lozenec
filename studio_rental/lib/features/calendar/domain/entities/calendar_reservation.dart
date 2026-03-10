import 'package:equatable/equatable.dart';

class CalendarReservation extends Equatable {
  final String id;
  final String guestFirstName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status;
  final int totalPrice;
  final String paymentStatus;

  const CalendarReservation({
    required this.id,
    required this.guestFirstName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
  });

  int get numNights =>
      checkOutDate.difference(checkInDate).inDays;

  @override
  List<Object?> get props => [
        id,
        guestFirstName,
        checkInDate,
        checkOutDate,
        status,
        totalPrice,
        paymentStatus,
      ];
}
