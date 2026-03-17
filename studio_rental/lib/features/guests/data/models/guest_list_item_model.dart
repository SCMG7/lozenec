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
    // Prefer first_name/last_name; fall back to splitting full_name
    String firstName = json['first_name'] as String? ?? '';
    String lastName = json['last_name'] as String? ?? '';
    if (firstName.isEmpty && json['full_name'] != null) {
      final fullName = json['full_name'] as String;
      final nameParts = fullName.split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

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
