# Screen 09 — Edit Reservation Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Edit Reservation Screen
- **Number:** 09
- **Purpose:** Modify an existing reservation.
- **Navigation source:** Reservation Bottom Sheet (Screen 07) "Edit" button; Reservation Detail (Screen 10) "Edit" button
- **Navigates to:**
  - Previous screen — on save success or cancel (pop)
  - Add/Edit Guest (Screen 13) — via "+ Create New Guest" button

---

## SECTION 2 — UI COMPONENTS

### Layout
- Identical to Add Reservation Screen (Screen 08) with these differences:
- **Screen title:** "Edit Reservation"
- **All fields pre-filled** with existing reservation data
- **Save button text:** "Save Changes"
- **Delete section at bottom:**
  - "Delete Reservation" button — destructive, red text
  - Confirmation dialog: "Are you sure? This cannot be undone." with Cancel / Delete buttons

### All other components identical to Screen 08:
- Guest section (search/select, chip display)
- Dates section (mode toggle, date pickers)
- Pricing section (mode toggle, inputs)
- Status section (segmented control)
- Payment section (dropdown + amount paid)
- Notes section (text area)

### Loading States
- Initial load: skeleton form while fetching reservation data
- Save: button spinner "Saving..."
- Delete: dialog shows spinner during deletion

### Error States
- Field-level validation inline
- Server error: toast/banner
- 404: "Reservation not found" (if deleted by another session)

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- Same as Screen 08 (Add Reservation), plus:
- `reservationId: UUID` — the reservation being edited
- `isLoadingReservation: bool` — fetching existing data
- `isDeleting: bool` — during deletion
- `showDeleteDialog: bool`

### Global State (Read)
- `currentUser.currency: String`
- `currentUser.default_price_per_night: Int?`

### Global State (Write)
- Triggers dashboard and calendar refresh on save/delete

### Loading States
- `isLoadingReservation`, `isSubmitting`, `isDeleting`

### Error States
- `fieldErrors`, `serverError`, `hasConflict`

### Form Validation
- Same as Screen 08

---

## SECTION 4 — DATA MODELS

```
UpdateReservationRequest {
  guest_id: UUID            // required
  check_in_date: String     // ISO 8601 date
  check_out_date: String    // ISO 8601 date
  num_nights: Int
  price_per_night: Int      // in cents
  total_price: Int          // in cents
  deposit_amount: Int       // in cents
  deposit_received: Bool
  status: String            // "confirmed", "pending", "cancelled"
  payment_status: String    // "unpaid", "partially_paid", "paid"
  amount_paid: Int          // in cents
  notes: String?
}

Reservation {
  id: UUID
  user_id: UUID
  guest_id: UUID
  guest: Guest              // populated from join
  check_in_date: String
  check_out_date: String
  num_nights: Int
  price_per_night: Int
  total_price: Int
  deposit_amount: Int
  deposit_received: Bool
  status: ReservationStatus
  payment_status: PaymentStatus
  amount_paid: Int
  notes: String?
  created_at: DateTime
  updated_at: DateTime
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/reservations/:id
Purpose: Fetch full reservation data for editing
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: none
Success response (200): {
  data: { reservation: Reservation }
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  500: { error: "Internal server error" }
When called: on screen mount
```

```
PUT /api/v1/reservations/:id
Purpose: Update an existing reservation
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: UpdateReservationRequest
Success response (200): {
  data: { reservation: Reservation },
  message: "Reservation updated successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error" } }
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  409: { error: "Dates conflict with existing reservation" }
  500: { error: "Internal server error" }
When called: on "Save Changes" tap
```

```
DELETE /api/v1/reservations/:id
Purpose: Delete a reservation permanently
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Success response (200): {
  data: null,
  message: "Reservation deleted successfully"
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  500: { error: "Internal server error" }
When called: on delete confirmation
```

```
GET /api/v1/reservations/check-conflict
(Same as Screen 08, but with exclude_id param set to current reservation ID)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/reservations/:id
Controller: reservationsController.getReservation
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID from URL
3. Query reservation by ID with guest join
4. Verify reservation belongs to user (user_id match)
5. If not found or wrong user, return 404
6. Return full reservation with guest data

Database table(s) touched: reservations, guests
Type of operation: SELECT with JOIN
```

```
ENDPOINT: PUT /api/v1/reservations/:id
Controller: reservationsController.updateReservation
Middleware: [authMiddleware, validateBody(updateReservationSchema)]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID from URL
3. Validate request body
4. Verify reservation exists and belongs to user
5. If dates changed, run overlap check (excluding this reservation's ID)
6. If conflict found, return 409
7. Verify guest_id belongs to user
8. Update reservation in database
9. Log change in reservation_activity_log
10. Update/create notifications if dates changed
11. Return updated reservation

Database table(s) touched: reservations (UPDATE), guests (SELECT), reservation_activity_log (INSERT), notifications (INSERT/UPDATE)
Type of operation: SELECT + UPDATE + INSERT

Business rules:
- Overlap check excludes the reservation being edited
- Activity log records what changed (status, dates, price, etc.)
- If status changed to cancelled, no overlap check needed
- Notifications updated if check-in date changed
```

```
ENDPOINT: DELETE /api/v1/reservations/:id
Controller: reservationsController.deleteReservation
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID from URL
3. Verify reservation exists and belongs to user
4. Delete reservation (cascading deletes notifications and activity log entries)
5. Return success

Database table(s) touched: reservations (DELETE), notifications (CASCADE DELETE), reservation_activity_log (CASCADE DELETE)
Type of operation: DELETE

Business rules:
- Hard delete — reservation is permanently removed
- Related notifications and activity log entries cascade deleted
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations, guests, notifications tables (defined previously)

-- Activity log for tracking changes
CREATE TABLE reservation_activity_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id  UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action          VARCHAR(50) NOT NULL,     -- created, updated, status_changed, deleted
  description     TEXT NOT NULL,            -- human-readable description
  changes         JSONB,                    -- { field: { old: value, new: value } }
  created_at      TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_activity_log_reservation_id ON reservation_activity_log(reservation_id);
  CREATE INDEX idx_activity_log_created_at ON reservation_activity_log(created_at);
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/reservation/:id/edit`
- **Route parameters:**
  - `id: UUID` — required, reservation ID
- **Navigation trigger:** Reservation Bottom Sheet "Edit" button, Reservation Detail "Edit" button
- **Navigation type:** `push`
- **On save:** `pop` with result (triggers refresh)
- **On delete:** `pop` to root of navigation stack or calendar/dashboard (skip detail screen)
- **"Cancel":** `pop` without result
- **Deep link path:** `/reservation/:id/edit`

---

## SECTION 9 — LOCALIZATION STRINGS

```
edit_reservation_title: "Редактирай резервация" / "Edit Reservation"
edit_reservation_save: "Запази промени" / "Save Changes"
edit_reservation_saving: "Запазване..." / "Saving..."
edit_reservation_delete: "Изтрий резервация" / "Delete Reservation"
edit_reservation_delete_confirm_title: "Изтриване на резервация" / "Delete Reservation"
edit_reservation_delete_confirm_message: "Сигурни ли сте? Това не може да бъде отменено." / "Are you sure? This cannot be undone."
edit_reservation_delete_confirm_cancel: "Отказ" / "Cancel"
edit_reservation_delete_confirm_delete: "Изтрий" / "Delete"
edit_reservation_deleting: "Изтриване..." / "Deleting..."
edit_reservation_success: "Резервацията е обновена" / "Reservation updated successfully"
edit_reservation_deleted: "Резервацията е изтрита" / "Reservation deleted successfully"
edit_reservation_not_found: "Резервацията не е намерена" / "Reservation not found"
edit_reservation_error_load: "Грешка при зареждане на резервацията" / "Error loading reservation"
```

(All other field labels reuse the add_reservation_* keys from Screen 08)

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    reservations/
      presentation/
        screens/
          edit_reservation_screen.dart      -- edit reservation screen (extends/reuses add form)
        widgets/
          reservation_form.dart             -- shared form widget used by both add and edit screens
          delete_reservation_dialog.dart    -- confirmation dialog for deletion
        bloc/
          edit_reservation_bloc.dart        -- edit logic (load existing, update, delete)
          edit_reservation_event.dart       -- LoadReservation, UpdateReservation, DeleteReservation
          edit_reservation_state.dart       -- Loading, Loaded, Saving, Deleting, Success, Error
      data/
        models/
          update_reservation_request.dart   -- request model + toJson
        repositories/
          reservation_repository.dart       -- add updateReservation, deleteReservation methods
        datasources/
          reservation_remote_datasource.dart -- add PUT, DELETE endpoints
      domain/
        usecases/
          update_reservation.dart
          delete_reservation.dart
          get_reservation.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **All edge cases from Screen 08 apply**, plus:
- **Reservation deleted by another session:** 404 on load or save — show error, pop back
- **Concurrent edit:** If data changed since load, PUT may return stale data warning (optimistic concurrency with updated_at)
- **Deleting reservation with upcoming notifications:** Cascade delete handles cleanup
- **Changing guest on existing reservation:** Allowed — updates guest_id
- **Changing dates to conflict:** Backend enforces overlap check, returns 409
- **Changing status to cancelled:** No overlap check needed, reservation still visible in history
- **Network offline during save:** Show error, preserve form state
- **Network offline during delete:** Show error in dialog

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting

Node.js / Backend:
  zod: ^3.22.0                    // request validation
  date-fns: ^3.6.0               // date arithmetic
```
