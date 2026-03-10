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
    return GuestListItemModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      lastStayDate: json['lastStayDate'] != null
          ? DateTime.parse(json['lastStayDate'] as String)
          : null,
      totalStays: json['totalStays'] as int? ?? 0,
      hasUpcoming: json['hasUpcoming'] as bool? ?? false,
    );
  }
}
