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
    return ReservationSummaryModel(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      numNights: json['num_nights'] as int,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'num_nights': numNights,
      'total_price': totalPrice,
      'status': status,
    };
  }
}
