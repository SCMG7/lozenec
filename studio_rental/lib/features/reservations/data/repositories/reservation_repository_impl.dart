import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';
import '../models/reservation_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDatasource remoteDatasource;

  ReservationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Reservation> getReservation(String id) async {
    final json = await remoteDatasource.getReservation(id);
    return ReservationModel.fromJson(json);
  }

  @override
  Future<Reservation> createReservation(Map<String, dynamic> data) async {
    final json = await remoteDatasource.createReservation(data);
    return ReservationModel.fromJson(json);
  }

  @override
  Future<Reservation> updateReservation(
      String id, Map<String, dynamic> data) async {
    final json = await remoteDatasource.updateReservation(id, data);
    return ReservationModel.fromJson(json);
  }

  @override
  Future<void> deleteReservation(String id) async {
    await remoteDatasource.deleteReservation(id);
  }

  @override
  Future<bool> checkConflict({
    required String checkInDate,
    required String checkOutDate,
    String? excludeId,
  }) async {
    return await remoteDatasource.checkConflict(
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      excludeId: excludeId,
    );
  }

  @override
  Future<Reservation> markAsPaid(String id) async {
    final json = await remoteDatasource.markAsPaid(id);
    return ReservationModel.fromJson(json);
  }

  @override
  Future<List<Reservation>> getByDate(String date) async {
    final jsonList = await remoteDatasource.getByDate(date);
    return jsonList.map((e) => ReservationModel.fromJson(e)).toList();
  }
}
