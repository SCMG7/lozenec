import '../entities/guest_list_item.dart';
import '../entities/guest_detail.dart';

enum GuestFilter { all, upcoming, past, cancelled }

enum GuestSort { nameAsc, mostRecent, mostNights }

abstract class GuestRepository {
  Future<List<GuestListItem>> getGuests({
    String? search,
    GuestFilter filter = GuestFilter.all,
    GuestSort sort = GuestSort.nameAsc,
    int page = 1,
  });

  Future<List<GuestListItem>> searchGuests(String query);

  Future<GuestDetail> getGuest(String id);

  Future<GuestDetail> createGuest({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  });

  Future<GuestDetail> updateGuest(
    String id, {
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
  });

  Future<void> deleteGuest(String id);
}
