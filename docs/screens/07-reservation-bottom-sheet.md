# Screen 07 — Reservation Bottom Sheet (Half-Screen Popup)

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Reservation Bottom Sheet
- **Number:** 07
- **Purpose:** Quick-glance reservation info when tapping a booked date on the calendar.
- **Navigation source:** Calendar Screen (Screen 06) — tap on a booked day
- **Navigates to:**
  - Reservation Detail (Screen 10) — via "View Full Details" button
  - Edit Reservation (Screen 09) — via "Edit" button

---

## SECTION 2 — UI COMPONENTS

### Sheet Structure
- **Drag handle:** Pill-shaped indicator at top for drag gesture
- **Background:** Dimmed semi-transparent overlay behind the sheet
- **Height:** ~50% of screen, expandable by dragging up

### Content
- **Guest name:** Large, bold text
- **Status badge:** Confirmed / Pending / Cancelled (colored)
- **Info rows:**
  - Check-in date — Check-out date
  - Number of nights
  - Price per night | Total price (formatted with currency)
  - Payment status: Paid / Partially Paid / Unpaid (colored badge)
- **Notes preview:** First line of notes (truncated with ellipsis if longer)

### Tab Selector (conditional)
- Shown only when a day has both a check-out and check-in (different reservations)
- Tabs: "Check-out" | "Check-in" — switches between the two reservation summaries

### Action Buttons (side by side)
- **"View Full Details":** Secondary/outlined style, navigates to Reservation Detail
- **"Edit":** Primary style, navigates to Edit Reservation

### Interactions
- Drag down or tap overlay → dismiss sheet
- Drag up → expand to full screen (transitions to Reservation Detail Screen)

### Loading States
- Skeleton content while fetching reservation details

### Error States
- Error text with retry if reservation data fails to load

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `selectedReservationId: UUID` — passed in from calendar tap
- `activeTabIndex: int` — 0 or 1 if dual-reservation day (check-out/check-in)

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- None

### Loading States
- `isLoading: bool` — fetching reservation details

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
ReservationBottomSheetData {
  id: UUID
  guest_name: String
  status: ReservationStatus       // confirmed, pending, cancelled
  check_in_date: String           // ISO 8601 date
  check_out_date: String          // ISO 8601 date
  num_nights: Int
  price_per_night: Int            // in cents
  total_price: Int                // in cents
  payment_status: PaymentStatus   // unpaid, partially_paid, paid
  notes: String?                  // first line or full text
}

enum PaymentStatus {
  unpaid
  partially_paid
  paid
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/reservations/:id/summary
Purpose: Fetch summary data for the bottom sheet view
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: none
Success response (200): {
  data: ReservationBottomSheetData
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Reservation not found" }
  500: { error: "Internal server error" }
When called: when bottom sheet opens (calendar day tap)
```

```
GET /api/v1/reservations/by-date
Purpose: Fetch all reservations for a specific date (handles dual check-in/check-out)
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: ?date=2025-06-15 (ISO date)
Success response (200): {
  data: {
    reservations: List<ReservationBottomSheetData>
  }
}
Error responses:
  401: { error: "Unauthorized" }
  400: { error: "Invalid date format" }
  500: { error: "Internal server error" }
When called: when tapping a calendar day (alternative to by-id, used when day might have multiple reservations)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/reservations/:id/summary
Controller: reservationsController.getReservationSummary
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse reservation ID from URL params
3. Query reservation by ID, join with guest for name
4. Verify reservation belongs to authenticated user
5. Return summary data

Database table(s) touched: reservations, guests
Type of operation: SELECT with JOIN

Business rules:
- Only owner can view their reservation
- Returns condensed data (no full history/activity log)
```

```
ENDPOINT: GET /api/v1/reservations/by-date
Controller: reservationsController.getByDate
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse date from query params
3. Query reservations where:
   user_id = userId AND
   (check_in_date <= date AND check_out_date >= date) AND
   status != 'cancelled'
4. Also include reservations where check_out_date = date (check-out day)
5. Join with guests for names
6. Return list of matching reservations

Database table(s) touched: reservations, guests
Type of operation: SELECT with JOIN

Business rules:
- A date can have up to 2 reservations (one checking out, one checking in)
- Check-out day: check_out_date = date
- Active stay: check_in_date <= date < check_out_date
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations and guests tables (defined in Screen 05)
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** N/A (modal bottom sheet, not a named route)
- **Route parameters:** `reservationId: UUID` or `date: String` passed programmatically
- **Navigation trigger:** Tap on a booked day in Calendar Grid
- **Navigation type:** `modal` bottom sheet (showModalBottomSheet)
- **"View Full Details" tap:** `push` to `/reservation/:id`
- **"Edit" tap:** `push` to `/reservation/:id/edit`
- **Drag up to expand:** transition to `/reservation/:id` (full screen)
- **Deep link path:** none (not directly linkable)

---

## SECTION 9 — LOCALIZATION STRINGS

```
bottom_sheet_check_in: "Настаняване" / "Check-in"
bottom_sheet_check_out: "Напускане" / "Check-out"
bottom_sheet_nights: "{count} нощувки" / "{count} nights"
bottom_sheet_night_single: "1 нощувка" / "1 night"
bottom_sheet_price_per_night: "на нощ" / "per night"
bottom_sheet_total: "Общо" / "Total"
bottom_sheet_view_details: "Виж детайли" / "View Full Details"
bottom_sheet_edit: "Редактирай" / "Edit"
bottom_sheet_notes: "Бележки" / "Notes"
payment_unpaid: "Неплатена" / "Unpaid"
payment_partially_paid: "Частично платена" / "Partially Paid"
payment_paid: "Платена" / "Paid"
bottom_sheet_tab_checkout: "Напускане" / "Check-out"
bottom_sheet_tab_checkin: "Настаняване" / "Check-in"
bottom_sheet_error: "Грешка при зареждане" / "Error loading data"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    calendar/
      presentation/
        widgets/
          reservation_bottom_sheet.dart     -- bottom sheet container with drag handle
          reservation_sheet_content.dart    -- content layout (guest, dates, price, etc.)
          reservation_sheet_tab_bar.dart    -- tab selector for dual check-in/out day
          reservation_sheet_actions.dart    -- View Details + Edit buttons
```

Note: This is part of the calendar feature, not its own feature folder, since it's triggered exclusively from the calendar.

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Dual reservations on same day:** Show tab selector to switch between check-out guest and check-in guest
- **Network offline:** If reservation data was cached from calendar load, show cached; otherwise show error
- **Reservation deleted while sheet is open:** Handle 404 gracefully, dismiss sheet with toast
- **Very long guest name:** Truncate with ellipsis
- **Very long notes:** Show first line only, truncated
- **No notes:** Hide notes row entirely
- **Cancelled reservation:** Should not normally appear (filtered from calendar), but if accessed, show cancelled badge
- **Drag to expand:** Smooth transition animation to full Reservation Detail screen

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  // Uses built-in showModalBottomSheet — no extra packages

Node.js / Backend:
  (no additional packages)
```
