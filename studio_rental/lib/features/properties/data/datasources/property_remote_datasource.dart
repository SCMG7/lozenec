import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';

class PropertyRemoteDatasource {
  final ApiClient apiClient;

  PropertyRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getProperties() async {
    final response = await apiClient.dio.get(ApiEndpoints.properties);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProperty(String id) async {
    final response = await apiClient.dio.get(ApiEndpoints.propertyById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProperty({
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.properties,
      data: {
        'name': name,
        if (address != null && address.isNotEmpty) 'address': address,
        'property_type': propertyType,
        'default_price_per_night': defaultPricePerNight,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'currency': currency,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProperty(
    String id, {
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  }) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.propertyById(id),
      data: {
        'name': name,
        'address': address,
        'property_type': propertyType,
        'default_price_per_night': defaultPricePerNight,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'currency': currency,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProperty(String id) async {
    await apiClient.dio.delete(ApiEndpoints.propertyById(id));
  }
}
