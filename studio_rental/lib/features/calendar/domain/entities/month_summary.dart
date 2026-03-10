import 'package:equatable/equatable.dart';

class MonthSummary extends Equatable {
  final int nightsBooked;
  final int totalNights;
  final int revenue;

  const MonthSummary({
    required this.nightsBooked,
    required this.totalNights,
    required this.revenue,
  });

  @override
  List<Object?> get props => [nightsBooked, totalNights, revenue];
}
