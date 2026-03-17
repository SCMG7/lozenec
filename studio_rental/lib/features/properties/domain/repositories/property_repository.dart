import '../entities/property.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties();

  Future<Property> getProperty(String id);

  Future<Property> createProperty({
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  });

  Future<Property> updateProperty(
    String id, {
    required String name,
    String? address,
    required String propertyType,
    required int defaultPricePerNight,
    required String checkInTime,
    required String checkOutTime,
    String currency = 'EUR',
  });

  Future<void> deleteProperty(String id);
}
