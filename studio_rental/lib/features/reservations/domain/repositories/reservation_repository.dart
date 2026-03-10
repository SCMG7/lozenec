import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<Reservation> getReservation(String id);

  Future<Reservation> createReservation(Map<String, dynamic> data);

  Future<Reservation> updateReservation(String id, Map<String, dynamic> data);

  Future<void> deleteReservation(String id);

  Future<bool> checkConflict({
    required String checkInDate,
    required String checkOutDate,
    String? excludeId,
  });

  Future<Reservation> markAsPaid(String id);

  Future<List<Reservation>> getByDate(String date);
}
