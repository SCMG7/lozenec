import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_remote_datasource.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDatasource remoteDatasource;

  PropertyRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Property>> getProperties() async {
    final response = await remoteDatasource.getProperties();
    final data = response['data'] as List<dynamic>;
    return data
        .map((p) => Property.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Property> getProperty(String id) async {
    final response = await remoteDatasource.getProperty(id);
    final data = response['data'] as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  @override
  Future<Property> createProperty({
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  }) async {
    final response = await remoteDatasource.createProperty(
      name: name,
      address: address,
      propertyType: propertyType,
      defaultPricePerNight: defaultPricePerNight,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      currency: currency,
    );
    final data = response['data'] as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  @override
  Future<Property> updateProperty(
    String id, {
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  }) async {
    final response = await remoteDatasource.updateProperty(
      id,
      name: name,
      address: address,
      propertyType: propertyType,
      defaultPricePerNight: defaultPricePerNight,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      currency: currency,
    );
    final data = response['data'] as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  @override
  Future<void> deleteProperty(String id) async {
    await remoteDatasource.deleteProperty(id);
  }
}
