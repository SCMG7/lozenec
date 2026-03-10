# Screen 06 — Calendar Screen (Monthly View)

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Calendar Screen (Monthly View)
- **Number:** 06
- **Purpose:** Visual overview of the whole month showing which days are booked, available, or in transition.
- **Navigation source:** Bottom navigation "Calendar" tab; Dashboard quick action "Open Calendar"
- **Navigates to:**
  - Reservation Bottom Sheet (Screen 07) — tap a booked day
  - Add Reservation (Screen 08) — tap a free day "+" prompt or FAB

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Left arrow button:** Navigate to previous month
- **Right arrow button:** Navigate to next month
- **Center text:** Month name + Year (e.g. "June 2025")
- **"Today" button:** Snap back to current month

### Calendar Grid
- Standard 7-column grid (Mon–Sun or Sun–Sat, configurable via Settings)
- **Day cell contents:**
  - Day number
  - Color fill based on status:
    - **Green** = Available (no reservation)
    - **Blue/teal** = Reserved (booked that day)
    - **Orange** = Check-in day
    - **Red** = Check-out day
    - **Grey** = Past date
  - Guest first name (abbreviated) if booked
  - Multi-night reservations shown as continuous colored bar
- **Today indicator:** Distinct ring or dot
- **Tap booked day:** Opens Reservation Bottom Sheet
- **Tap free day:** Shows mini-prompt "Add Reservation?" with "+" button

### Legend (below calendar)
- Color key: Available / Reserved / Check-in / Check-out / Past

### Bottom Section
- **Monthly summary strip:**
  - Nights booked: X / Y
  - Revenue: formatted amount with currency
- **FAB (floating action button):** "+ Add Reservation" (bottom right)

### Loading States
- Skeleton calendar grid during initial load

### Error States
- Error message with retry button

### Empty State
- Calendar shows all days as green/available when no reservations exist

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `currentMonth: DateTime` — currently displayed month
- `selectedDay: DateTime?` — day the user tapped (for showing prompt)

### Global State (Read)
- `currentUser.week_starts_on: String` — "sunday" or "monday"
- `currentUser.currency: String`

### Global State (Write)
- `calendarReservations: List<CalendarReservation>` — reservations for displayed month

### Loading States
- `isCalendarLoading: bool`
- `isRefreshing: bool`

### Error States
- `calendarError: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
CalendarReservation {
  id: UUID
  guest_first_name: String
  check_in_date: String       // ISO 8601 date
  check_out_date: String      // ISO 8601 date
  status: ReservationStatus   // confirmed, pending, cancelled
  total_price: Int            // in cents
  payment_status: String      // unpaid, partially_paid, paid
}

CalendarDayCellData {
  date: DateTime
  type: DayCellType           // available, reserved, check_in, check_out, past
  reservation_id: UUID?
  guest_name: String?
}

enum DayCellType {
  available
  reserved
  check_in
  check_out
  past
}

MonthSummary {
  nights_booked: Int
  total_nights: Int
  revenue: Int                // in cents
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/reservations/calendar
Purpose: Fetch all reservations that overlap with the given month
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: ?month=2025-06 (YYYY-MM format)
Success response (200): {
  data: {
    reservations: List<CalendarReservation>,
    summary: MonthSummary
  }
}
Error responses:
  401: { error: "Unauthorized" }
  400: { error: "Invalid month format" }
  500: { error: "Internal server error" }
When called: on screen mount, on month change, on pull-to-refresh
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/reservations/calendar
Controller: reservationsController.getCalendar
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse month param (YYYY-MM), compute first day and last day of month
3. Query reservations where:
   user_id = userId AND
   status != 'cancelled' AND
   check_in_date <= last_day_of_month AND
   check_out_date >= first_day_of_month
4. Join with guests table to get guest first names
5. Compute summary:
   a. Count booked nights (sum of days each reservation covers within the month)
   b. Total nights = days in month
   c. Revenue = sum of total_price for confirmed reservations overlapping this month
6. Return reservations list + summary

Database table(s) touched: reservations, guests
Type of operation: SELECT with JOIN

Business rules:
- Include reservations that partially overlap the month (started before or end after)
- Cancelled reservations excluded from calendar view
- Revenue counts full reservation price even if reservation spans multiple months
- A day where one guest checks out and another checks in shows both (dual status)
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations and guests tables (defined in Screen 05)
-- No new tables needed

-- Key query for calendar:
-- SELECT r.*, g.first_name FROM reservations r
-- JOIN guests g ON r.guest_id = g.id
-- WHERE r.user_id = $1
--   AND r.status != 'cancelled'
--   AND r.check_in_date <= $lastDay
--   AND r.check_out_date >= $firstDay
-- ORDER BY r.check_in_date ASC
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/calendar`
- **Route parameters:** none (month controlled internally)
- **Navigation trigger:** Bottom nav "Calendar" tab, Dashboard "Open Calendar" button
- **Navigation type:** Bottom navigation tab (index 1)
- **Tap booked day:** `modal` open Reservation Bottom Sheet
- **Tap free day "+":** `push` to `/add-reservation` with pre-selected date
- **FAB tap:** `push` to `/add-reservation`
- **Deep link path:** `/calendar`

---

## SECTION 9 — LOCALIZATION STRINGS

```
calendar_title: "Календар" / "Calendar"
calendar_today: "Днес" / "Today"
calendar_add_reservation_prompt: "Добави резервация?" / "Add Reservation?"
calendar_nights_booked: "Нощувки: {booked} / {total}" / "Nights booked: {booked} / {total}"
calendar_revenue: "Приход: {amount}" / "Revenue: {amount}"
calendar_add_reservation: "+ Добави резервация" / "+ Add Reservation"
calendar_legend_available: "Свободен" / "Available"
calendar_legend_reserved: "Резервиран" / "Reserved"
calendar_legend_check_in: "Настаняване" / "Check-in"
calendar_legend_check_out: "Напускане" / "Check-out"
calendar_legend_past: "Минал" / "Past"
calendar_error_load: "Грешка при зареждане на календара" / "Error loading calendar"
calendar_no_reservations: "Няма резервации за този месец" / "No reservations this month"
calendar_mon: "Пн" / "Mon"
calendar_tue: "Вт" / "Tue"
calendar_wed: "Ср" / "Wed"
calendar_thu: "Чт" / "Thu"
calendar_fri: "Пт" / "Fri"
calendar_sat: "Сб" / "Sat"
calendar_sun: "Нд" / "Sun"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    calendar/
      presentation/
        screens/
          calendar_screen.dart          -- main calendar screen
        widgets/
          calendar_header.dart          -- month nav + today button
          calendar_grid.dart            -- 7-column date grid
          calendar_day_cell.dart        -- individual day cell with color/text
          calendar_legend.dart          -- color legend below calendar
          calendar_summary_strip.dart   -- nights booked + revenue at bottom
          free_day_prompt.dart          -- "Add Reservation?" mini popup
        bloc/
          calendar_bloc.dart            -- calendar data loading/month navigation
          calendar_event.dart           -- LoadMonth, ChangeMonth, SelectDay
          calendar_state.dart           -- CalendarLoading, CalendarLoaded, CalendarError
      data/
        models/
          calendar_reservation.dart     -- CalendarReservation + fromJson
          month_summary.dart            -- MonthSummary + fromJson
        repositories/
          calendar_repository.dart      -- calendar API calls
        datasources/
          calendar_remote_datasource.dart
      domain/
        entities/
          calendar_reservation.dart
          calendar_day_cell_data.dart
        usecases/
          get_calendar_month.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached calendar data if available; error state if not
- **No reservations for month:** All days shown as available (green) or past (grey)
- **Reservation spans month boundary:** Still shown for both months
- **Same day check-in and check-out (different guests):** Day shows dual status — both orange and red, or shows tab selector in bottom sheet
- **Very long guest name:** Abbreviate to fit cell (e.g. "Ale..." or first name only)
- **Month with no days booked:** Summary shows 0 / N nights, 0 revenue
- **Today indicator:** Always visible regardless of booking status
- **Week start setting:** Calendar reflows columns based on user preference

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  table_calendar: ^3.1.0          // calendar grid widget (or custom implementation)
  intl: ^0.19.0                   // date formatting

Node.js / Backend:
  (no additional packages)
```
