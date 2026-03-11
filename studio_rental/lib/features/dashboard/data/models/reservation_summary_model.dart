import '../../domain/entities/reservation_summary.dart';

class ReservationSummaryModel extends ReservationSummary {
  const ReservationSummaryModel({
    required super.id,
    required super.guestName,
    required super.checkInDate,
    required super.checkOutDate,
    required super.numNights,
    required super.totalPrice,
    required super.status,
  });

  factory ReservationSummaryModel.fromJson(Map<String, dynamic> json) {
    final checkIn = DateTime.parse(json['check_in'] as String);
    final checkOut = DateTime.parse(json['check_out'] as String);
    final numNights = json['num_nights'] as int? ??
        checkOut.difference(checkIn).inDays;

    return ReservationSummaryModel(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      numNights: numNights,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'check_in': checkInDate.toIso8601String(),
      'check_out': checkOutDate.toIso8601String(),
      'num_nights': numNights,
      'total_price': totalPrice,
      'status': status,
    };
  }
}
