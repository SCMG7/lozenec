# Screen 08 — Add Reservation Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Add Reservation Screen
- **Number:** 08
- **Purpose:** Create a new reservation for the studio.
- **Navigation source:** Dashboard "+ New Reservation" button; Calendar FAB or free day "+" prompt
- **Navigates to:**
  - Add/Edit Guest (Screen 13) — via "+ Create New Guest" button
  - Previous screen — via "Cancel" or back button (pop)
  - Reservation Detail (Screen 10) — on successful save (optional, or pop back)

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button:** Top left, pops screen
- **Screen title:** "New Reservation"

### Guest Section
- **Guest search field:** Autocomplete text input, searches saved guests by name/phone/email
- **"+ Create New Guest" button:** Opens Add Guest screen/modal
- **Selected guest chip:** Card showing guest name + initial avatar, with "x" to deselect

### Dates Section
- **Mode toggle:** "Number of Nights" / "Date Range" segmented control
- **Nights mode:**
  - Date picker: Check-in date (defaults to today or pre-selected from calendar)
  - Number input: How many nights (spinner or text field, min 1)
  - Check-out date: Auto-calculated, displayed read-only
- **Date Range mode:**
  - Date range picker: Check-in → Check-out (calendar selector)
  - Nights count: Auto-calculated, displayed read-only
- **Conflict warning:** Red text/banner if selected dates overlap an existing reservation

### Pricing Section
- **Mode toggle:** "Price per Night" / "Custom Total Price" segmented control
- **Per Night mode:**
  - Input: Price per night (numeric, shows currency symbol, defaults to user's default price)
  - Total: Auto-calculated, read-only
- **Custom Total mode:**
  - Input: Total price (numeric, shows currency symbol)
  - Per-night equivalent: Auto-calculated, read-only
- **Deposit amount input:** Optional, numeric with currency symbol
- **Deposit received toggle:** Yes / No switch

### Status Section
- **Reservation status:** Segmented control — Confirmed / Pending / Cancelled (defaults to Pending)

### Payment Section
- **Payment status dropdown:** Unpaid / Partially Paid / Paid in Full (defaults to Unpaid)
- **Amount received input:** Numeric, shown only when "Partially Paid" is selected

### Notes Section
- **Text area:** Internal notes, multiline, optional

### Action Buttons
- **"Save Reservation":** Primary, full-width
- **"Cancel":** Secondary text link

### Loading States
- Guest search: spinner in search field while querying
- Save: button shows spinner "Saving..."

### Error States
- Field-level validation errors inline
- Conflict warning for overlapping dates
- Server error: toast or banner

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `selectedGuest: Guest?` — currently selected guest
- `guestSearchQuery: String` — text in guest search field
- `guestSearchResults: List<Guest>` — autocomplete results
- `dateMode: DateInputMode` — nights or dateRange
- `checkInDate: DateTime?`
- `checkOutDate: DateTime?`
- `numNights: Int`
- `pricingMode: PricingMode` — perNight or customTotal
- `pricePerNight: Int` — in cents
- `totalPrice: Int` — in cents
- `depositAmount: Int` — in cents
- `depositReceived: bool`
- `status: ReservationStatus` — defaults to pending
- `paymentStatus: PaymentStatus` — defaults to unpaid
- `amountPaid: Int` — in cents
- `notes: String`
- `hasConflict: bool` — true if dates overlap existing reservation
- `fieldErrors: Map<String, String?>`
- `isSubmitting: bool`
- `isSearchingGuests: bool`

### Global State (Read)
- `currentUser.default_price_per_night: Int?` — for price default
- `currentUser.currency: String`

### Global State (Write)
- Triggers dashboard and calendar refresh after successful save

### Loading States
- `isSearchingGuests`, `isSubmitting`, `isCheckingConflicts`

### Error States
- `fieldErrors`, `serverError: String?`, `hasConflict`

### Form Validation
- **Field-level:** Guest required, check-in required, nights >= 1, price > 0
- **Form-level:** All required fields filled, no date conflict

---

## SECTION 4 — DATA MODELS

```
CreateReservationRequest {
  guest_id: UUID            // required
  check_in_date: String     // ISO 8601 date, required
  check_out_date: String    // ISO 8601 date, required
  num_nights: Int           // required, >= 1
  price_per_night: Int      // in cents, required
  total_price: Int          // in cents, required
  deposit_amount: Int       // in cents, default 0
  deposit_received: Bool    // default false
  status: String            // "confirmed", "pending", "cancelled"
  payment_status: String    // "unpaid", "partially_paid", "paid"
  amount_paid: Int          // in cents, default 0
  notes: String?            // optional
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
  created_at: DateTime
  updated_at: DateTime
}

Reservation {
  id: UUID
  user_id: UUID
  guest_id: UUID
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

enum DateInputMode { nights, dateRange }
enum PricingMode { perNight, customTotal }
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/guests/search
Purpose: Search guests by name, phone, or email for autocomplete
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params: ?q=searchterm (min 2 chars)
Success response (200): {
  data: { guests: List<Guest> }
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: as user types in guest search field (debounced, 300ms)
```

```
GET /api/v1/reservations/check-conflict
Purpose: Check if proposed dates conflict with existing reservations
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params: ?check_in=2025-06-01&check_out=2025-06-05&exclude_id=UUID (exclude_id optional, for edit)
Success response (200): {
  data: { has_conflict: Bool, conflicting_reservation: ReservationSummary? }
}
Error responses:
  401: { error: "Unauthorized" }
  400: { error: "Invalid date format" }
  500: { error: "Internal server error" }
When called: when dates change (debounced, 500ms)
```

```
POST /api/v1/reservations
Purpose: Create a new reservation
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: CreateReservationRequest
Success response (201): {
  data: { reservation: Reservation },
  message: "Reservation created successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error" } }
  401: { error: "Unauthorized" }
  409: { error: "Dates conflict with existing reservation" }
  500: { error: "Internal server error" }
When called: on "Save Reservation" tap
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/guests/search
Controller: guestsController.searchGuests
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse query param q (min 2 chars)
3. Search guests where user_id = userId AND (first_name ILIKE %q% OR last_name ILIKE %q% OR phone ILIKE %q% OR email ILIKE %q%)
4. Limit results to 10
5. Return list of matching guests

Database table(s) touched: guests
Type of operation: SELECT
```

```
ENDPOINT: GET /api/v1/reservations/check-conflict
Controller: reservationsController.checkConflict
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse check_in, check_out, and optional exclude_id from query params
3. Query reservations where:
   user_id = userId AND
   status != 'cancelled' AND
   id != exclude_id (if provided) AND
   check_in_date < check_out_param AND
   check_out_date > check_in_param
4. If any result, return has_conflict: true with conflicting reservation summary
5. Otherwise return has_conflict: false

Database table(s) touched: reservations
Type of operation: SELECT

Business rules:
- Overlap check: new.check_in < existing.check_out AND new.check_out > existing.check_in
- Exclude cancelled reservations
- Exclude the reservation being edited (if exclude_id provided)
```

```
ENDPOINT: POST /api/v1/reservations
Controller: reservationsController.createReservation
Middleware: [authMiddleware, validateBody(createReservationSchema)]

Steps:
1. Extract user ID from JWT
2. Validate request body
3. Verify guest_id exists and belongs to this user
4. Run overlap check (same logic as check-conflict)
5. If conflict found, return 409
6. Insert new reservation into reservations table
7. Create notification entry for check-in reminder (if notifications enabled)
8. Return created reservation

Database table(s) touched: reservations (INSERT), guests (SELECT for validation), notifications (INSERT)
Type of operation: SELECT + INSERT

Business rules:
- Guest must belong to the same user
- Date overlap check enforced on backend (not just frontend)
- num_nights must equal difference between check_out and check_in
- total_price must be consistent with price_per_night * num_nights (or custom total)
- If status is "cancelled", no overlap check needed
- Notification created for day before check_in (if user has notify_before_checkin enabled)
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations table (defined in Screen 05)
-- Uses guests table (defined in Screen 05)

-- notifications table (for auto-generated reminders)
CREATE TABLE notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reservation_id  UUID REFERENCES reservations(id) ON DELETE CASCADE,
  type            VARCHAR(50) NOT NULL,    -- check_in_reminder, check_out_reminder, unpaid_reminder
  title           VARCHAR(255) NOT NULL,
  body            TEXT NOT NULL,
  is_read         BOOLEAN DEFAULT FALSE,
  scheduled_at    TIMESTAMP,               -- when to show the notification
  created_at      TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_notifications_user_id ON notifications(user_id);
  CREATE INDEX idx_notifications_reservation_id ON notifications(reservation_id);
  CREATE INDEX idx_notifications_is_read ON notifications(is_read);
  CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at);
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/add-reservation`
- **Route parameters:**
  - `preselectedDate: String?` — optional, ISO date from calendar tap (pre-fills check-in date)
  - `preselectedGuestId: UUID?` — optional, pre-selects guest (from guest detail screen)
- **Navigation trigger:** Dashboard "+ New Reservation", Calendar FAB, Calendar free day "+"
- **Navigation type:** `push`
- **On save success:** `pop` with result (triggers refresh on previous screen)
- **"Cancel":** `pop` without result
- **Deep link path:** `/add-reservation`

---

## SECTION 9 — LOCALIZATION STRINGS

```
add_reservation_title: "Нова резервация" / "New Reservation"
add_reservation_guest_section: "Гост" / "Guest"
add_reservation_search_guest: "Търси гост..." / "Search guest..."
add_reservation_create_guest: "+ Създай нов гост" / "+ Create New Guest"
add_reservation_dates_section: "Дати" / "Dates"
add_reservation_mode_nights: "Брой нощувки" / "Number of Nights"
add_reservation_mode_range: "Период" / "Date Range"
add_reservation_check_in: "Настаняване" / "Check-in"
add_reservation_check_out: "Напускане" / "Check-out"
add_reservation_nights: "Нощувки" / "Nights"
add_reservation_pricing_section: "Цена" / "Pricing"
add_reservation_mode_per_night: "Цена на нощ" / "Price per Night"
add_reservation_mode_custom_total: "Обща цена" / "Custom Total Price"
add_reservation_price_per_night: "Цена на нощ" / "Price per night"
add_reservation_total_price: "Обща цена" / "Total price"
add_reservation_deposit: "Депозит" / "Deposit"
add_reservation_deposit_received: "Депозитът получен?" / "Deposit received?"
add_reservation_status_section: "Статус" / "Status"
add_reservation_payment_section: "Плащане" / "Payment"
add_reservation_amount_paid: "Платена сума" / "Amount paid"
add_reservation_notes_section: "Бележки" / "Notes"
add_reservation_notes_hint: "Вътрешни бележки..." / "Internal notes..."
add_reservation_save: "Запази резервация" / "Save Reservation"
add_reservation_cancel: "Отказ" / "Cancel"
add_reservation_saving: "Запазване..." / "Saving..."
add_reservation_conflict: "Избраните дати се припокриват с друга резервация" / "Selected dates overlap with an existing reservation"
add_reservation_error_guest_required: "Изберете гост" / "Please select a guest"
add_reservation_error_date_required: "Изберете дата за настаняване" / "Please select a check-in date"
add_reservation_error_nights_min: "Минимум 1 нощувка" / "Minimum 1 night"
add_reservation_error_price_required: "Въведете цена" / "Please enter a price"
add_reservation_error_price_positive: "Цената трябва да е положителна" / "Price must be positive"
add_reservation_success: "Резервацията е създадена" / "Reservation created successfully"
add_reservation_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    reservations/
      presentation/
        screens/
          add_reservation_screen.dart       -- main add reservation screen
        widgets/
          guest_search_field.dart           -- autocomplete guest search
          guest_chip.dart                   -- selected guest display chip
          date_input_section.dart           -- dates with mode toggle
          pricing_section.dart             -- pricing with mode toggle
          status_selector.dart             -- reservation status segmented control
          payment_section.dart             -- payment status + amount paid
          notes_input.dart                 -- multiline notes text area
          conflict_warning.dart            -- date conflict warning banner
        bloc/
          add_reservation_bloc.dart        -- form logic, validation, submission
          add_reservation_event.dart       -- SelectGuest, SetDates, SetPricing, Submit, etc.
          add_reservation_state.dart       -- form state with all fields, validation, loading
      data/
        models/
          reservation.dart                 -- Reservation model + fromJson/toJson
          create_reservation_request.dart  -- request model + toJson
          guest.dart                       -- Guest model + fromJson (shared)
        repositories/
          reservation_repository.dart      -- create, check-conflict API calls
        datasources/
          reservation_remote_datasource.dart
      domain/
        entities/
          reservation.dart
        usecases/
          create_reservation.dart
          check_date_conflict.dart
          search_guests.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Disable save button, show offline indicator
- **Empty form submission:** Show all required field errors: guest, check-in date, price
- **Overlapping dates:** Show red conflict warning; backend enforces overlap check and returns 409
- **Guest not yet created:** User can create guest inline via "+ Create New Guest"
- **Pre-selected date from calendar:** Auto-fill check-in date, focus on nights/checkout input
- **Price calculation:** Auto-calculate total from per-night * nights, or per-night equivalent from total / nights
- **Zero or negative price:** Show error "Price must be positive"
- **Deposit > total price:** Show warning (allowed but flagged)
- **Amount paid > total price:** Show warning
- **Check-out before check-in:** Prevent — date picker enforces min date
- **Same day check-in and check-out (0 nights):** Not allowed, minimum 1 night
- **Double-tap save:** Prevent duplicate submissions
- **Guest search with < 2 chars:** Don't trigger search, show hint
- **No matching guests:** Show "No guests found" with "+ Create New Guest" option

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting
  flutter_typeahead: ^5.2.0       // guest search autocomplete

Node.js / Backend:
  zod: ^3.22.0                    // request validation
  date-fns: ^3.6.0               // date arithmetic for overlap checks
```
