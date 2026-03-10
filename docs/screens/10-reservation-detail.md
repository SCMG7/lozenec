# Screen 10 — Reservation Detail Screen (Full)

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Reservation Detail Screen
- **Number:** 10
- **Purpose:** Complete view of a single reservation with all information.
- **Navigation source:** Reservation Bottom Sheet (Screen 07) "View Full Details"; Upcoming reservations on Dashboard (Screen 05); Guest Detail reservation history (Screen 12)
- **Navigates to:**
  - Edit Reservation (Screen 09) — via "Edit Reservation" button
  - Previous screen — via back button (pop)

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button:** Top left
- **Title:** "Reservation Details"
- **Edit button:** Top right, navigates to Edit Reservation

### Guest Info Section
- **Guest name:** Large, bold
- **Guest contact:** Phone (tappable → dialer), email (tappable → email client)
- **Status badge:** Confirmed / Pending / Cancelled

### Divider

### Dates & Duration Section
- Check-in date (formatted with day of week)
- Check-out date (formatted with day of week)
- Total nights

### Financial Section
- Price per night (formatted with currency)
- Total price
- Deposit amount
- Amount paid
- **Amount remaining:** Auto-calculated (total_price - amount_paid), shown in red if > 0
- **Payment status badge:** Paid / Partially Paid / Unpaid

### Notes Section
- Full notes text (or "No notes" placeholder)

### Activity Log Section (optional)
- List of timestamped changes:
  - "Reservation created — Jun 1, 2025"
  - "Status changed to Confirmed — Jun 3, 2025"
  - Each entry: icon + description + relative timestamp

### Action Buttons
- **"Edit Reservation":** Primary button
- **"Mark as Paid":** Secondary button, shown only if payment_status != "paid"
- **"Delete Reservation":** Destructive red text button at bottom, with confirmation dialog

### Loading States
- Skeleton layout while fetching data

### Error States
- Error message with retry if data fails to load
- 404: "Reservation not found"

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `reservationId: UUID` — from route parameter
- `showDeleteDialog: bool`

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- Triggers refresh on previous screens after "Mark as Paid" or delete

### Loading States
- `isLoading: bool` — fetching reservation
- `isMarkingPaid: bool` — during "Mark as Paid"
- `isDeleting: bool`

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
ReservationDetail {
  id: UUID
  user_id: UUID
  guest: Guest
  check_in_date: String
  check_out_date: String
  num_nights: Int
  price_per_night: Int          // cents
  total_price: Int              // cents
  deposit_amount: Int           // cents
  deposit_received: Bool
  amount_paid: Int              // cents
  amount_remaining: Int         // cents (computed: total_price - amount_paid)
  status: ReservationStatus
  payment_status: PaymentStatus
  notes: String?
  activity_log: List<ActivityLogEntry>
  created_at: DateTime
  updated_at: DateTime
}

ActivityLogEntry {
  id: UUID
  action: String               // created, updated, status_changed
  description: String          // human-readable
  created_at: DateTime
}

Guest {
  id: UUID
  first_name: String
  last_name: String
  phone: String?
  email: String?
  nationality: String?
  id_number: String?
  notes: String?
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/reservations/:id
Purpose: Fetch full reservation details including guest and activity log
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params: ?include=guest,activity_log
Success response (200): {
  data: {
    reservation: ReservationDetail
  }
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  500: { error: "Internal server error" }
When called: on screen mount
```

```
PATCH /api/v1/reservations/:id/mark-paid
Purpose: Quick action to mark reservation as fully paid
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Success response (200): {
  data: { reservation: ReservationDetail },
  message: "Reservation marked as paid"
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  500: { error: "Internal server error" }
When called: on "Mark as Paid" button tap
```

```
DELETE /api/v1/reservations/:id
(Same as Screen 09)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/reservations/:id
Controller: reservationsController.getReservation
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID
3. Query reservation with:
   - JOIN guests on guest_id
   - LEFT JOIN reservation_activity_log ordered by created_at DESC
4. Verify reservation belongs to user
5. Compute amount_remaining = total_price - amount_paid
6. Return full reservation detail

Database table(s) touched: reservations, guests, reservation_activity_log
Type of operation: SELECT with JOINs
```

```
ENDPOINT: PATCH /api/v1/reservations/:id/mark-paid
Controller: reservationsController.markAsPaid
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID
3. Verify reservation exists and belongs to user
4. Update reservation: payment_status = 'paid', amount_paid = total_price
5. Log activity: "Payment marked as paid in full"
6. Return updated reservation

Database table(s) touched: reservations (UPDATE), reservation_activity_log (INSERT)
Type of operation: UPDATE + INSERT

Business rules:
- Sets amount_paid equal to total_price
- Changes payment_status to 'paid'
- Creates activity log entry
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations, guests, reservation_activity_log, notifications tables (all defined previously)
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/reservation/:id`
- **Route parameters:**
  - `id: UUID` — required, reservation ID
- **Navigation trigger:** Bottom Sheet "View Full Details", Dashboard reservation tap, Guest Detail reservation tap
- **Navigation type:** `push`
- **"Edit" tap:** `push` to `/reservation/:id/edit`
- **Back button:** `pop`
- **After delete:** `pop` to previous screen (dashboard/calendar/guest detail)
- **Deep link path:** `/reservation/:id`

---

## SECTION 9 — LOCALIZATION STRINGS

```
reservation_detail_title: "Детайли на резервацията" / "Reservation Details"
reservation_detail_dates: "Дати и продължителност" / "Dates & Duration"
reservation_detail_check_in: "Настаняване" / "Check-in"
reservation_detail_check_out: "Напускане" / "Check-out"
reservation_detail_nights: "Общо нощувки" / "Total nights"
reservation_detail_financial: "Финансова информация" / "Financial"
reservation_detail_price_per_night: "Цена на нощ" / "Price per night"
reservation_detail_total_price: "Обща цена" / "Total price"
reservation_detail_deposit: "Депозит" / "Deposit"
reservation_detail_amount_paid: "Платена сума" / "Amount paid"
reservation_detail_amount_remaining: "Оставащо" / "Amount remaining"
reservation_detail_notes: "Бележки" / "Notes"
reservation_detail_no_notes: "Няма бележки" / "No notes"
reservation_detail_activity: "Активност" / "Activity Log"
reservation_detail_edit: "Редактирай резервация" / "Edit Reservation"
reservation_detail_mark_paid: "Маркирай като платена" / "Mark as Paid"
reservation_detail_delete: "Изтрий резервация" / "Delete Reservation"
reservation_detail_not_found: "Резервацията не е намерена" / "Reservation not found"
reservation_detail_error_load: "Грешка при зареждане" / "Error loading reservation"
reservation_detail_marked_paid: "Резервацията е маркирана като платена" / "Reservation marked as paid"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    reservations/
      presentation/
        screens/
          reservation_detail_screen.dart    -- main detail screen
        widgets/
          reservation_guest_header.dart     -- guest name + contact + status
          reservation_dates_section.dart    -- dates & duration display
          reservation_financial_section.dart -- financial breakdown
          reservation_notes_section.dart    -- notes display
          reservation_activity_log.dart     -- activity log list
          reservation_detail_actions.dart   -- action buttons row
        bloc/
          reservation_detail_bloc.dart      -- load detail, mark paid, delete
          reservation_detail_event.dart     -- LoadDetail, MarkAsPaid, Delete
          reservation_detail_state.dart     -- Loading, Loaded, Error
      data/
        models/
          reservation_detail.dart           -- ReservationDetail model + fromJson
          activity_log_entry.dart           -- ActivityLogEntry model + fromJson
      domain/
        usecases/
          get_reservation_detail.dart
          mark_reservation_paid.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached data if available; error with retry if not
- **Reservation not found (404):** Show "Reservation not found" message with back button
- **Already paid:** Hide "Mark as Paid" button
- **Amount remaining is 0 but status not "paid":** Still show "Mark as Paid" to update status
- **Activity log empty:** Show "No activity" placeholder
- **Deleted while viewing:** If attempting action after deletion, show toast and pop back
- **Phone/email not provided:** Don't show contact row or show "Not provided"
- **Return from edit:** Refresh data to reflect changes
- **Delete cascade:** Notifications and activity log cleaned up automatically

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting
  url_launcher: ^6.2.0            // opening phone dialer and email client

Node.js / Backend:
  (no additional packages)
```
