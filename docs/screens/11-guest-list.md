# Screen 11 — Guest List Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Guest List Screen
- **Number:** 11
- **Purpose:** View all guests who have ever stayed or are scheduled to stay.
- **Navigation source:** Bottom navigation "Guests" tab; Dashboard "See All" link
- **Navigates to:**
  - Guest Detail (Screen 12) — tap on a guest row
  - Add/Edit Guest (Screen 13) — via floating "+" button

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Screen title:** "Guests"

### Search Bar
- Text input at top: search by name, phone, email
- Clear button when text is present

### Filter Tabs (horizontal)
- All | Upcoming | Past | Cancelled
- Highlighted/selected tab indicator

### Sort Options
- Dropdown or icon button: Name A–Z / Most Recent / Most Nights Stayed

### Guest List
Each row shows:
- **Avatar circle** with initials (first letter of first + last name)
- **Full name** (first + last)
- **Last stay date** or upcoming stay date (whichever is most relevant)
- **Total number of stays** (badge/count)
- **Arrow icon** (chevron right, taps to Guest Detail)

### Empty State
- Message: "No guests yet. Add your first reservation."
- CTA button: "+ Add Guest"

### Floating Action Button
- "+" button (bottom right) — Add new guest directly

### Loading States
- Skeleton list rows during initial load
- Pull-to-refresh spinner

### Error States
- Error message with retry

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `searchQuery: String`
- `activeFilter: GuestFilter` — all, upcoming, past, cancelled
- `sortBy: GuestSortOption` — nameAsc, mostRecent, mostNights
- `guests: List<GuestListItem>`

### Global State (Read)
- None specifically

### Global State (Write)
- None (read-only list)

### Loading States
- `isLoading: bool`
- `isRefreshing: bool`
- `isSearching: bool`

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
GuestListItem {
  id: UUID
  first_name: String
  last_name: String
  phone: String?
  email: String?
  last_stay_date: String?       // ISO date of most recent or upcoming stay
  total_stays: Int
  has_upcoming: Bool
}

enum GuestFilter {
  all
  upcoming       // has a reservation with check_in >= today
  past           // all reservations are in the past
  cancelled      // has cancelled reservations
}

enum GuestSortOption {
  nameAsc        // alphabetical A-Z by last_name, first_name
  mostRecent     // most recent stay first
  mostNights     // most total nights first
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/guests
Purpose: Fetch paginated guest list with filters and sorting
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params:
  ?search=query        // optional, search term
  &filter=all          // all, upcoming, past, cancelled
  &sort=name_asc       // name_asc, most_recent, most_nights
  &page=1              // pagination page
  &limit=20            // items per page
Success response (200): {
  data: {
    guests: List<GuestListItem>,
    total: Int,
    page: Int,
    total_pages: Int
  }
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on screen mount, on filter/sort change, on search, on pull-to-refresh, on scroll (pagination)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/guests
Controller: guestsController.getGuests
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse query params: search, filter, sort, page, limit
3. Build base query: SELECT guests + aggregated reservation data WHERE user_id = userId
4. Apply search filter: WHERE (first_name ILIKE %q% OR last_name ILIKE %q% OR phone ILIKE %q% OR email ILIKE %q%)
5. Apply category filter:
   - all: no additional filter
   - upcoming: guest has at least one reservation with check_in_date >= today AND status != cancelled
   - past: guest has no reservations with check_in_date >= today
   - cancelled: guest has at least one reservation with status = cancelled
6. Compute aggregations:
   - total_stays: COUNT of non-cancelled reservations
   - last_stay_date: MAX(check_in_date) from all reservations
   - has_upcoming: EXISTS reservation with check_in >= today
7. Apply sort:
   - name_asc: ORDER BY last_name ASC, first_name ASC
   - most_recent: ORDER BY last_stay_date DESC NULLS LAST
   - most_nights: ORDER BY total_nights_stayed DESC
8. Apply pagination (offset/limit)
9. Return guest list with total count

Database table(s) touched: guests, reservations (for aggregations)
Type of operation: SELECT with LEFT JOIN and GROUP BY

Business rules:
- Only guests belonging to the authenticated user
- Aggregations exclude cancelled reservations
- Guests with no reservations still appear (total_stays = 0)
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses guests and reservations tables (defined previously)
-- No new tables needed

-- Key query pattern:
-- SELECT g.*,
--   COUNT(r.id) FILTER (WHERE r.status != 'cancelled') as total_stays,
--   MAX(r.check_in_date) as last_stay_date,
--   EXISTS(SELECT 1 FROM reservations r2 WHERE r2.guest_id = g.id AND r2.check_in_date >= CURRENT_DATE AND r2.status != 'cancelled') as has_upcoming
-- FROM guests g
-- LEFT JOIN reservations r ON r.guest_id = g.id
-- WHERE g.user_id = $1
-- GROUP BY g.id
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/guests`
- **Route parameters:** none
- **Navigation trigger:** Bottom nav "Guests" tab, Dashboard "See All" link
- **Navigation type:** Bottom navigation tab (index 2)
- **Tap guest row:** `push` to `/guest/:id`
- **FAB tap:** `push` to `/add-guest`
- **Deep link path:** `/guests`

---

## SECTION 9 — LOCALIZATION STRINGS

```
guest_list_title: "Гости" / "Guests"
guest_list_search_hint: "Търси по име, телефон, имейл..." / "Search by name, phone, email..."
guest_list_filter_all: "Всички" / "All"
guest_list_filter_upcoming: "Предстоящи" / "Upcoming"
guest_list_filter_past: "Минали" / "Past"
guest_list_filter_cancelled: "Отменени" / "Cancelled"
guest_list_sort_name: "Име А–Я" / "Name A–Z"
guest_list_sort_recent: "Последно посещение" / "Most Recent"
guest_list_sort_nights: "Най-много нощувки" / "Most Nights Stayed"
guest_list_stays: "{count} посещения" / "{count} stays"
guest_list_stay_single: "1 посещение" / "1 stay"
guest_list_no_stays: "Няма посещения" / "No stays"
guest_list_last_stay: "Последно: {date}" / "Last: {date}"
guest_list_upcoming_stay: "Предстои: {date}" / "Upcoming: {date}"
guest_list_empty: "Все още няма гости. Добавете първата си резервация." / "No guests yet. Add your first reservation."
guest_list_empty_search: "Няма намерени гости" / "No guests found"
guest_list_add_guest: "Добави гост" / "Add Guest"
guest_list_error_load: "Грешка при зареждане на гостите" / "Error loading guests"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    guests/
      presentation/
        screens/
          guest_list_screen.dart            -- main guest list screen
        widgets/
          guest_search_bar.dart             -- search input
          guest_filter_tabs.dart            -- filter tab bar
          guest_sort_dropdown.dart          -- sort selector
          guest_list_tile.dart              -- individual guest row
          guest_avatar.dart                 -- avatar circle with initials
          guest_empty_state.dart            -- empty state message + CTA
        bloc/
          guest_list_bloc.dart             -- list loading, filtering, sorting, search
          guest_list_event.dart            -- LoadGuests, SearchGuests, ChangeFilter, ChangeSort
          guest_list_state.dart            -- Loading, Loaded, Error
      data/
        models/
          guest_list_item.dart             -- GuestListItem + fromJson
        repositories/
          guest_repository.dart            -- guest list API call
        datasources/
          guest_remote_datasource.dart
      domain/
        entities/
          guest_list_item.dart
        usecases/
          get_guest_list.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached list if available; error state if not
- **No guests at all:** Show empty state with "Add your first reservation" message
- **Search with no results:** Show "No guests found" with clear search option
- **Guest with no reservations:** Shows in "All" filter with 0 stays
- **Pagination:** Load more guests on scroll (infinite scroll)
- **Filter returns empty:** Show appropriate empty state per filter
- **Pull-to-refresh:** Resets to page 1 and reloads
- **Deleted guest:** Removed from list on next refresh

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date formatting

Node.js / Backend:
  (no additional packages)
```
