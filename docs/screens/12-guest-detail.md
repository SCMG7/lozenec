# Screen 12 — Guest Detail Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Guest Detail Screen
- **Number:** 12
- **Purpose:** Full profile of a single guest and their reservation history.
- **Navigation source:** Guest List (Screen 11) — tap on guest row
- **Navigates to:**
  - Add/Edit Guest (Screen 13) — via "Edit" button
  - Reservation Detail (Screen 10) — tap on a reservation in history list

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button:** Top left
- **Guest name:** Title
- **Edit button:** Top right, navigates to Edit Guest

### Profile Header
- **Avatar circle:** Large, centered, with initials
- **Full name:** Large text below avatar

### Contact Info Section
- **Phone number:** Tappable → opens dialer (with phone icon)
- **Email:** Tappable → opens email client (with email icon)
- **Nationality:** Text display (with flag or globe icon)

### Stats Row (horizontal, 3 items)
- **Total stays:** Number
- **Total nights:** Number
- **Total revenue:** Formatted with currency

### Notes Section
- Guest notes text (e.g. "Prefers early check-in", "Repeat guest")
- "No notes" placeholder if empty

### Divider

### Reservation History Section
- **Section title:** "Reservation History"
- List of all past and future reservations for this guest, each showing:
  - Check-in → Check-out dates
  - Number of nights
  - Total price (formatted)
  - Status badge (Confirmed / Pending / Cancelled)
- Tapping any reservation → Reservation Detail Screen
- **Empty state:** "No reservations for this guest."

### Delete Button
- **"Delete Guest":** Destructive red text button at bottom
- Confirmation dialog: "Are you sure? This will also remove all associated reservations." with Cancel / Delete

### Loading States
- Skeleton layout during data fetch

### Error States
- Error with retry
- 404: "Guest not found"

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `guestId: UUID` — from route parameter
- `showDeleteDialog: bool`

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- Triggers guest list refresh on delete

### Loading States
- `isLoading: bool`
- `isDeleting: bool`

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
GuestDetail {
  id: UUID
  first_name: String
  last_name: String
  phone: String?
  email: String?
  nationality: String?
  id_number: String?
  notes: String?
  total_stays: Int
  total_nights: Int
  total_revenue: Int            // in cents
  reservations: List<GuestReservation>
  created_at: DateTime
  updated_at: DateTime
}

GuestReservation {
  id: UUID
  check_in_date: String         // ISO 8601 date
  check_out_date: String        // ISO 8601 date
  num_nights: Int
  total_price: Int              // in cents
  status: ReservationStatus     // confirmed, pending, cancelled
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/guests/:id
Purpose: Fetch full guest profile with reservation history and stats
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params: ?include=reservations,stats
Success response (200): {
  data: {
    guest: GuestDetail
  }
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Guest not found" }
  500: { error: "Internal server error" }
When called: on screen mount
```

```
DELETE /api/v1/guests/:id
Purpose: Delete a guest and optionally their reservations
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Success response (200): {
  data: null,
  message: "Guest deleted successfully"
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Guest not found" }
  409: { error: "Guest has upcoming reservations. Cancel or delete them first." }
  500: { error: "Internal server error" }
When called: on delete confirmation
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/guests/:id
Controller: guestsController.getGuest
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse guest ID
3. Query guest by ID, verify belongs to user
4. Query reservations for this guest, ordered by check_in_date DESC
5. Compute stats:
   - total_stays: COUNT of non-cancelled reservations
   - total_nights: SUM of num_nights for non-cancelled reservations
   - total_revenue: SUM of total_price for confirmed reservations
6. Return guest detail with reservations and stats

Database table(s) touched: guests, reservations
Type of operation: SELECT with aggregation

Business rules:
- Only owner can view their guest
- Stats exclude cancelled reservations
- Revenue only from confirmed reservations
```

```
ENDPOINT: DELETE /api/v1/guests/:id
Controller: guestsController.deleteGuest
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse guest ID
3. Verify guest exists and belongs to user
4. Check for upcoming non-cancelled reservations
5. If upcoming reservations exist, return 409 with message
6. Delete guest (cascade deletes related data)
7. Return success

Database table(s) touched: guests (DELETE), reservations (CASCADE or check)
Type of operation: SELECT + DELETE

Business rules:
- Cannot delete guest with upcoming active reservations (must cancel/delete them first)
- Past reservations are cascade deleted with the guest
- Alternative: soft delete (mark inactive) — but spec says hard delete with confirmation
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses guests and reservations tables (defined previously)
-- No new tables needed

-- Guest deletion cascading:
-- reservations.guest_id → guests.id (ON DELETE RESTRICT — enforced by business logic check)
-- After check passes, delete guest and cascade
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/guest/:id`
- **Route parameters:**
  - `id: UUID` — required, guest ID
- **Navigation trigger:** Guest List row tap
- **Navigation type:** `push`
- **"Edit" tap:** `push` to `/guest/:id/edit`
- **Reservation tap:** `push` to `/reservation/:id`
- **Back button:** `pop`
- **After delete:** `pop` to guest list
- **Deep link path:** `/guest/:id`

---

## SECTION 9 — LOCALIZATION STRINGS

```
guest_detail_title: "Детайли на госта" / "Guest Details"
guest_detail_phone: "Телефон" / "Phone"
guest_detail_email: "Имейл" / "Email"
guest_detail_nationality: "Националност" / "Nationality"
guest_detail_total_stays: "Посещения" / "Total stays"
guest_detail_total_nights: "Нощувки" / "Total nights"
guest_detail_total_revenue: "Общ приход" / "Total revenue"
guest_detail_notes: "Бележки" / "Notes"
guest_detail_no_notes: "Няма бележки" / "No notes"
guest_detail_reservations: "История на резервациите" / "Reservation History"
guest_detail_no_reservations: "Няма резервации за този гост." / "No reservations for this guest."
guest_detail_edit: "Редактирай" / "Edit"
guest_detail_delete: "Изтрий гост" / "Delete Guest"
guest_detail_delete_confirm_title: "Изтриване на гост" / "Delete Guest"
guest_detail_delete_confirm_message: "Сигурни ли сте? Това ще премахне и всички свързани резервации." / "Are you sure? This will also remove all associated reservations."
guest_detail_delete_confirm_cancel: "Отказ" / "Cancel"
guest_detail_delete_confirm_delete: "Изтрий" / "Delete"
guest_detail_deleted: "Гостът е изтрит" / "Guest deleted successfully"
guest_detail_not_found: "Гостът не е намерен" / "Guest not found"
guest_detail_error_load: "Грешка при зареждане" / "Error loading guest"
guest_detail_has_upcoming: "Гостът има предстоящи резервации. Първо ги отменете или изтрийте." / "Guest has upcoming reservations. Cancel or delete them first."
guest_detail_not_provided: "Не е посочено" / "Not provided"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    guests/
      presentation/
        screens/
          guest_detail_screen.dart          -- main guest detail screen
        widgets/
          guest_profile_header.dart         -- avatar + name
          guest_contact_info.dart           -- phone, email, nationality
          guest_stats_row.dart              -- stays, nights, revenue
          guest_notes_section.dart          -- notes display
          guest_reservation_history.dart    -- reservation list
          guest_reservation_tile.dart       -- single reservation row in history
          delete_guest_dialog.dart          -- confirmation dialog
        bloc/
          guest_detail_bloc.dart            -- load guest, delete
          guest_detail_event.dart           -- LoadGuest, DeleteGuest
          guest_detail_state.dart           -- Loading, Loaded, Deleting, Error
      data/
        models/
          guest_detail.dart                 -- GuestDetail + fromJson
          guest_reservation.dart            -- GuestReservation + fromJson
        repositories/
          guest_repository.dart             -- add getGuest, deleteGuest methods
        datasources/
          guest_remote_datasource.dart      -- add endpoints
      domain/
        usecases/
          get_guest_detail.dart
          delete_guest.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached data if available; error with retry if not
- **Guest not found (404):** Show error message with back button
- **Guest with no reservations:** Show empty reservation history, stats all 0
- **Delete guest with upcoming reservations:** 409 error — show message to cancel reservations first
- **Delete guest with only past reservations:** Allowed — cascade deletes everything
- **Phone/email not provided:** Show "Not provided" or hide row
- **Very long name:** Truncate with ellipsis
- **Return from edit:** Refresh to show updated data
- **Return from reservation detail:** Refresh if reservation was modified
- **Nationality not set:** Hide nationality row

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  url_launcher: ^6.2.0            // phone dialer, email client
  intl: ^0.19.0                   // date/currency formatting

Node.js / Backend:
  (no additional packages)
```
