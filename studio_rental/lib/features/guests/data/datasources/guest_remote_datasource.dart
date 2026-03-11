import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';

class GuestRemoteDatasource {
  final ApiClient apiClient;

  GuestRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getGuests({
    String? search,
    String? filter,
    String? sort,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (filter != null && filter.isNotEmpty) {
      queryParams['filter'] = filter;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await apiClient.dio.get(
      ApiEndpoints.guests,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchGuests(String query) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.guestSearch,
      queryParameters: {'q': query},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getGuest(String id) async {
    final response = await apiClient.dio.get(ApiEndpoints.guestById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createGuest({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.guests,
      data: {
        'full_name': '$firstName $lastName'.trim(),
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (nationality != null && nationality.isNotEmpty)
          'country': nationality,
        if (idNumber != null && idNumber.isNotEmpty) 'id_number': idNumber,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateGuest(
    String id, {
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  }) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.guestById(id),
      data: {
        'full_name': '$firstName $lastName'.trim(),
        'phone': phone,
        'email': email,
        'country': nationality,
        'id_number': idNumber,
        'notes': notes,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteGuest(String id) async {
    await apiClient.dio.delete(ApiEndpoints.guestById(id));
  }
}
