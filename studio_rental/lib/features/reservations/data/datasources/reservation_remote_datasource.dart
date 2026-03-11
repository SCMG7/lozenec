import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';

class ReservationRemoteDatasource {
  final ApiClient apiClient;

  ReservationRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getReservation(String id) async {
    final response =
        await apiClient.dio.get(ApiEndpoints.reservationById(id));
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createReservation(
      Map<String, dynamic> data) async {
    final response =
        await apiClient.dio.post(ApiEndpoints.reservations, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateReservation(
      String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.dio.put(ApiEndpoints.reservationById(id), data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteReservation(String id) async {
    await apiClient.dio.delete(ApiEndpoints.reservationById(id));
  }

  Future<bool> checkConflict({
    required String checkInDate,
    required String checkOutDate,
    String? excludeId,
  }) async {
    final queryParams = <String, dynamic>{
      'check_in': checkInDate,
      'check_out': checkOutDate,
    };
    if (excludeId != null) {
      queryParams['exclude_id'] = excludeId;
    }
    final response = await apiClient.dio.get(
      ApiEndpoints.reservationCheckConflict,
      queryParameters: queryParams,
    );
    return response.data['data']['has_conflict'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> markAsPaid(String id) async {
    final response =
        await apiClient.dio.patch(ApiEndpoints.reservationMarkPaid(id));
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getByDate(String date) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.reservationByDate,
      queryParameters: {'date': date},
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> searchGuests(String query) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.guestSearch,
      queryParameters: {'q': query},
    );
    final list = response.data['data'] as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
