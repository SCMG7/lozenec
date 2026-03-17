class Property {
  final String id;
  final String userId;
  final String name;
  final String? address;
  final String propertyType;
  final int defaultPricePerNight;
  final String checkInTime;
  final String checkOutTime;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Property({
    required this.id,
    required this.userId,
    required this.name,
    this.address,
    required this.propertyType,
    required this.defaultPricePerNight,
    required this.checkInTime,
    required this.checkOutTime,
    required this.currency,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      name: json['name'] as String,
      address: json['address'] as String?,
      propertyType: json['property_type'] as String? ??
          json['propertyType'] as String? ??
          'studio',
      defaultPricePerNight: json['default_price_per_night'] as int? ??
          json['defaultPricePerNight'] as int? ??
          0,
      checkInTime: json['check_in_time'] as String? ??
          json['checkInTime'] as String? ??
          '14:00',
      checkOutTime: json['check_out_time'] as String? ??
          json['checkOutTime'] as String? ??
          '10:00',
      currency: json['currency'] as String? ?? 'EUR',
      isActive: json['is_active'] as bool? ??
          json['isActive'] as bool? ??
          true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'property_type': propertyType,
      'default_price_per_night': defaultPricePerNight,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'currency': currency,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Property copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? propertyType,
    int? defaultPricePerNight,
    String? checkInTime,
    String? checkOutTime,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      propertyType: propertyType ?? this.propertyType,
      defaultPricePerNight: defaultPricePerNight ?? this.defaultPricePerNight,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Property(id: $id, name: $name)';
}
