import '../../domain/entities/calendar_reservation.dart';

class CalendarReservationModel extends CalendarReservation {
  const CalendarReservationModel({
    required super.id,
    required super.guestFirstName,
    required super.checkInDate,
    required super.checkOutDate,
    required super.status,
    required super.totalPrice,
    required super.paymentStatus,
  });

  factory CalendarReservationModel.fromJson(Map<String, dynamic> json) {
    return CalendarReservationModel(
      id: json['id'] as String,
      guestFirstName: (json['guest_name'] ?? json['guest_first_name'] ?? '') as String,
      checkInDate: DateTime.parse((json['check_in'] ?? json['check_in_date']) as String),
      checkOutDate: DateTime.parse((json['check_out'] ?? json['check_out_date']) as String),
      status: json['status'] as String,
      totalPrice: json['total_price'] as int,
      paymentStatus: (json['payment_status'] ?? 'unknown') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestFirstName,
      'check_in': checkInDate.toIso8601String(),
      'check_out': checkOutDate.toIso8601String(),
      'status': status,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
    };
  }
}
