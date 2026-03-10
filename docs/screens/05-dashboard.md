# Screen 05 — Home / Dashboard Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Home / Dashboard Screen
- **Number:** 05
- **Purpose:** Quick overview of the studio's current status. First screen after login.
- **Navigation source:** Successful login/registration; Bottom navigation "Home" tab
- **Navigates to:**
  - Settings (Screen 17) — via avatar/profile icon
  - Notifications (Screen 18) — via bell icon
  - Reservation Detail (Screen 10) — via tapping an upcoming reservation
  - Add Reservation (Screen 08) — via "+ New Reservation" button
  - Calendar (Screen 06) — via "Open Calendar" button
  - Analytics (Screen 16) — via "Analytics" button
  - Guest List (Screen 11) — via "See All" link on upcoming reservations

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Studio name:** Left-aligned text
- **Profile/avatar icon:** Right side, taps to Settings
- **Notification bell icon:** Right side (before avatar), with unread badge count

### Summary Cards (horizontal scrollable row)
- **Card 1 — "Tonight":** Shows guest name if occupied, "Free" if not
- **Card 2 — "This Month":** X nights booked / Y total nights
- **Card 3 — "This Month's Revenue":** Total income from confirmed reservations (formatted with currency)
- **Card 4 — "Occupancy Rate":** Percentage of current month booked

### Upcoming Reservations Section
- **Section title:** "Upcoming Reservations"
- **List of up to 5 items**, each showing:
  - Guest name
  - Check-in and check-out dates
  - Number of nights
  - Total price (formatted with currency)
  - Status badge (Confirmed / Pending / Cancelled)
- **"See All" link** at top right of section
- **Empty state:** "No upcoming reservations." with "+ Add Reservation" CTA

### Quick Action Buttons (row of 3)
- **"+ New Reservation"** — navigates to Add Reservation Screen
- **"Open Calendar"** — navigates to Calendar Screen
- **"Analytics"** — navigates to Analytics Screen

### Current Month Mini-Stats
- Total revenue this month
- Total expenses this month
- Net profit this month (green if positive, red if negative)

### Loading States
- Skeleton cards for summary section
- Skeleton list items for upcoming reservations

### Error States
- Error banner with retry button if data fails to load

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- None (all data comes from global state or API)

### Global State (Read)
- `currentUser: User` — for studio name and settings
- `dashboardData: DashboardData` — aggregated dashboard metrics

### Global State (Write)
- `dashboardData: DashboardData` — populated on load

### Loading States
- `isDashboardLoading: bool` — initial data fetch
- `isRefreshing: bool` — pull-to-refresh

### Error States
- `dashboardError: String?` — error from API

### Form Validation
- No forms on this screen

---

## SECTION 4 — DATA MODELS

```
DashboardData {
  tonight_guest: String?        // guest name if occupied tonight, null if free
  month_nights_booked: Int      // number of nights booked this month
  month_total_nights: Int       // total nights in the current month
  month_revenue: Int            // total revenue in cents for confirmed reservations
  occupancy_rate: Float         // 0.0 - 1.0
  month_expenses: Int           // total expenses in cents
  month_net_profit: Int         // revenue - expenses in cents
  upcoming_reservations: List<ReservationSummary>
  unread_notification_count: Int
}

ReservationSummary {
  id: UUID
  guest_name: String
  check_in_date: String         // ISO 8601 date
  check_out_date: String        // ISO 8601 date
  num_nights: Int
  total_price: Int              // in cents
  status: ReservationStatus     // confirmed, pending, cancelled
}

enum ReservationStatus {
  confirmed
  pending
  cancelled
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/dashboard
Purpose: Fetch aggregated dashboard data for the current month
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: none
Success response (200): {
  data: DashboardData
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on screen mount, on pull-to-refresh, on returning from other screens
```

```
GET /api/v1/notifications/unread-count
Purpose: Get count of unread notifications for bell badge
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: none
Success response (200): {
  data: { count: Int }
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on screen mount (can be combined with dashboard call)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/dashboard
Controller: dashboardController.getDashboard
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT token
2. Get current date and compute month start/end
3. Query reservations for current month (user_id match, status != cancelled):
   a. Count booked nights
   b. Sum total_price for confirmed reservations
   c. Check if today has a reservation (for "tonight" card)
4. Query upcoming reservations (check_in >= today, status != cancelled, limit 5, order by check_in ASC)
5. Query expenses for current month (user_id match), sum amounts
6. Compute occupancy rate and net profit
7. Get unread notification count
8. Return aggregated DashboardData

Database table(s) touched: reservations, guests, expenses, notifications
Type of operation: SELECT (multiple aggregation queries)

Business rules:
- "Tonight" checks if today falls within any reservation's check_in <= today < check_out
- Revenue only counts confirmed reservations
- Occupancy rate = booked_nights / total_nights_in_month
- Upcoming reservations exclude cancelled status
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- reservations table (primary table for dashboard)
CREATE TABLE reservations (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  guest_id          UUID NOT NULL REFERENCES guests(id) ON DELETE RESTRICT,
  check_in_date     DATE NOT NULL,
  check_out_date    DATE NOT NULL,
  num_nights        INTEGER NOT NULL,
  price_per_night   INTEGER NOT NULL,       -- in cents/stotinki
  total_price       INTEGER NOT NULL,       -- in cents/stotinki
  deposit_amount    INTEGER DEFAULT 0,      -- in cents/stotinki
  deposit_received  BOOLEAN DEFAULT FALSE,
  status            VARCHAR(20) NOT NULL DEFAULT 'pending',  -- confirmed, pending, cancelled
  payment_status    VARCHAR(20) NOT NULL DEFAULT 'unpaid',   -- unpaid, partially_paid, paid
  amount_paid       INTEGER DEFAULT 0,      -- in cents/stotinki
  notes             TEXT,
  created_at        TIMESTAMP DEFAULT NOW(),
  updated_at        TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_reservations_user_id ON reservations(user_id);
  CREATE INDEX idx_reservations_check_in ON reservations(check_in_date);
  CREATE INDEX idx_reservations_check_out ON reservations(check_out_date);
  CREATE INDEX idx_reservations_guest_id ON reservations(guest_id);
  CREATE INDEX idx_reservations_status ON reservations(status);

-- guests table (referenced by reservations)
CREATE TABLE guests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  first_name      VARCHAR(255) NOT NULL,
  last_name       VARCHAR(255) NOT NULL,
  phone           VARCHAR(50),
  email           VARCHAR(255),
  nationality     VARCHAR(100),
  id_number       VARCHAR(100),       -- passport/ID number
  notes           TEXT,
  created_at      TIMESTAMP DEFAULT NOW(),
  updated_at      TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_guests_user_id ON guests(user_id);
  CREATE INDEX idx_guests_name ON guests(first_name, last_name);

-- expenses table (for monthly stats)
CREATE TABLE expenses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title           VARCHAR(255) NOT NULL,
  amount          INTEGER NOT NULL,        -- in cents/stotinki
  date            DATE NOT NULL,
  category        VARCHAR(50) NOT NULL,    -- maintenance, renovation, utilities, cleaning, supplies, taxes_fees, other
  notes           TEXT,
  is_recurring    BOOLEAN DEFAULT FALSE,
  recurrence_freq VARCHAR(20),             -- monthly, yearly (null if not recurring)
  created_at      TIMESTAMP DEFAULT NOW(),
  updated_at      TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_expenses_user_id ON expenses(user_id);
  CREATE INDEX idx_expenses_date ON expenses(date);
  CREATE INDEX idx_expenses_category ON expenses(category);

Relationships:
  reservations.user_id → users.id (many-to-one)
  reservations.guest_id → guests.id (many-to-one)
  guests.user_id → users.id (many-to-one)
  expenses.user_id → users.id (many-to-one)
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/dashboard`
- **Route path:** `/` (main tab)
- **Route parameters:** none
- **Navigation trigger:** Successful login/register (replace), bottom tab tap
- **Navigation type:** Bottom navigation tab (index 0)
- **Deep link path:** `/dashboard`

---

## SECTION 9 — LOCALIZATION STRINGS

```
dashboard_tonight: "Тази вечер" / "Tonight"
dashboard_tonight_free: "Свободно" / "Free"
dashboard_this_month: "Този месец" / "This Month"
dashboard_month_revenue: "Приход този месец" / "This Month's Revenue"
dashboard_occupancy_rate: "Заетост" / "Occupancy Rate"
dashboard_upcoming: "Предстоящи резервации" / "Upcoming Reservations"
dashboard_see_all: "Виж всички" / "See All"
dashboard_new_reservation: "+ Нова резервация" / "+ New Reservation"
dashboard_open_calendar: "Календар" / "Open Calendar"
dashboard_analytics: "Анализи" / "Analytics"
dashboard_total_revenue: "Общ приход" / "Total Revenue"
dashboard_total_expenses: "Общи разходи" / "Total Expenses"
dashboard_net_profit: "Нетна печалба" / "Net Profit"
dashboard_nights_booked: "{booked} / {total} нощувки" / "{booked} / {total} nights"
dashboard_no_upcoming: "Няма предстоящи резервации." / "No upcoming reservations."
dashboard_add_first: "Добавете първата си резервация" / "Add your first reservation"
dashboard_error_load: "Грешка при зареждане на данните" / "Error loading data"
dashboard_retry: "Опитай отново" / "Retry"
status_confirmed: "Потвърдена" / "Confirmed"
status_pending: "Чакаща" / "Pending"
status_cancelled: "Отменена" / "Cancelled"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    dashboard/
      presentation/
        screens/
          dashboard_screen.dart         -- main dashboard screen
        widgets/
          summary_cards_row.dart        -- horizontal scrollable summary cards
          summary_card.dart             -- individual summary card widget
          upcoming_reservations_list.dart -- upcoming reservations section
          reservation_list_item.dart    -- single reservation row
          quick_actions_row.dart        -- row of 3 quick action buttons
          monthly_mini_stats.dart       -- revenue/expenses/profit section
          status_badge.dart             -- reusable status badge widget
        bloc/
          dashboard_bloc.dart           -- dashboard data loading
          dashboard_event.dart          -- LoadDashboard, RefreshDashboard
          dashboard_state.dart          -- DashboardLoading, DashboardLoaded, DashboardError
      data/
        models/
          dashboard_data.dart           -- DashboardData model + fromJson
          reservation_summary.dart      -- ReservationSummary model + fromJson
        repositories/
          dashboard_repository.dart     -- dashboard API calls
        datasources/
          dashboard_remote_datasource.dart
      domain/
        entities/
          dashboard_data.dart
          reservation_summary.dart
        usecases/
          get_dashboard.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached data if available; show error state with retry if no cache
- **No reservations at all:** Show empty state with CTA to add first reservation
- **No expenses:** Show 0 for expenses and full revenue as net profit
- **Currency display:** Always use user's configured currency from settings
- **Month boundary:** "Tonight" correctly handles midnight — check_in <= today < check_out
- **Pull-to-refresh:** Refreshes all dashboard data
- **Returning from other screens:** Dashboard should refresh to reflect changes

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting
  shimmer: ^3.0.0                 // skeleton loading effect

Node.js / Backend:
  (no additional packages beyond core setup)
```
