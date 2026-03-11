import '../../domain/entities/guest_list_item.dart';

class GuestListItemModel extends GuestListItem {
  const GuestListItemModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.email,
    super.lastStayDate,
    required super.totalStays,
    required super.hasUpcoming,
  });

  factory GuestListItemModel.fromJson(Map<String, dynamic> json) {
    // Backend sends full_name as a single field; split into first/last
    final fullName = json['full_name'] as String? ?? '';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return GuestListItemModel(
      id: json['id'] as String,
      firstName: firstName,
      lastName: lastName,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      lastStayDate: json['last_stay'] != null
          ? DateTime.parse(json['last_stay'] as String)
          : null,
      totalStays: json['total_reservations'] as int? ?? 0,
      hasUpcoming: json['upcoming_stay'] != null,
    );
  }
}
