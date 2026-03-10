import '../../domain/entities/guest_list_item.dart';
import '../../domain/entities/guest_detail.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasources/guest_remote_datasource.dart';
import '../models/guest_list_item_model.dart';
import '../models/guest_detail_model.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDatasource remoteDatasource;

  GuestRepositoryImpl({required this.remoteDatasource});

  String _filterToString(GuestFilter filter) {
    switch (filter) {
      case GuestFilter.all:
        return 'all';
      case GuestFilter.upcoming:
        return 'upcoming';
      case GuestFilter.past:
        return 'past';
      case GuestFilter.cancelled:
        return 'cancelled';
    }
  }

  String _sortToString(GuestSort sort) {
    switch (sort) {
      case GuestSort.nameAsc:
        return 'name_asc';
      case GuestSort.mostRecent:
        return 'most_recent';
      case GuestSort.mostNights:
        return 'most_nights';
    }
  }

  @override
  Future<List<GuestListItem>> getGuests({
    String? search,
    GuestFilter filter = GuestFilter.all,
    GuestSort sort = GuestSort.nameAsc,
    int page = 1,
  }) async {
    final response = await remoteDatasource.getGuests(
      search: search,
      filter: _filterToString(filter),
      sort: _sortToString(sort),
      page: page,
    );
    final data = response['data'] as Map<String, dynamic>;
    final guestsJson = data['guests'] as List<dynamic>;
    return guestsJson
        .map((g) => GuestListItemModel.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GuestListItem>> searchGuests(String query) async {
    final response = await remoteDatasource.searchGuests(query);
    final data = response['data'] as Map<String, dynamic>;
    final guestsJson = data['guests'] as List<dynamic>;
    return guestsJson
        .map((g) => GuestListItemModel.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GuestDetail> getGuest(String id) async {
    final response = await remoteDatasource.getGuest(id);
    final data = response['data'] as Map<String, dynamic>;
    return GuestDetailModel.fromJson(data['guest'] as Map<String, dynamic>);
  }

  @override
  Future<GuestDetail> createGuest({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  }) async {
    final response = await remoteDatasource.createGuest(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      nationality: nationality,
      idNumber: idNumber,
      notes: notes,
    );
    final data = response['data'] as Map<String, dynamic>;
    return GuestDetailModel.fromJson(data['guest'] as Map<String, dynamic>);
  }

  @override
  Future<GuestDetail> updateGuest(
    String id, {
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  }) async {
    final response = await remoteDatasource.updateGuest(
      id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      nationality: nationality,
      idNumber: idNumber,
      notes: notes,
    );
    final data = response['data'] as Map<String, dynamic>;
    return GuestDetailModel.fromJson(data['guest'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGuest(String id) async {
    await remoteDatasource.deleteGuest(id);
  }
}
