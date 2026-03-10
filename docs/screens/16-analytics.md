# Screen 16 — Analytics Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Analytics Screen
- **Number:** 16
- **Purpose:** Visual summary of the studio's financial performance over time.
- **Navigation source:** Bottom navigation "Analytics" tab; Dashboard "Analytics" quick action
- **Navigates to:**
  - Expenses (Screen 14) — via tapping expenses breakdown section

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Screen title:** "Analytics"

### Period Selector
- Segmented control or dropdown: This Month / Last Month / Last 3 Months / Last 6 Months / This Year / Custom Range
- Custom Range: opens date range picker

### Overview Cards (horizontal row of 3)
- **Total Revenue:** Formatted with currency, for selected period
- **Total Expenses:** Formatted with currency
- **Net Profit:** Revenue - Expenses, green if positive, red if negative

### Occupancy Section
- **Occupancy rate:** Large percentage display
- **Progress bar:** Booked nights vs available nights, filled proportionally
- **Text:** "X booked / Y total nights"

### Revenue Breakdown Chart
- **Bar chart or line chart:** Revenue per month across selected period
- Bars broken down: Confirmed revenue (solid) vs Pending revenue (lighter)
- X-axis: months, Y-axis: amount

### Expenses Breakdown
- **Pie/donut chart:** Expenses split by category
- **Legend list** below chart: category name, total amount, percentage of total

### Reservation Statistics
- **Average length of stay:** X nights
- **Average revenue per reservation:** Formatted amount
- **Longest stay:** X nights (guest name)
- **Most frequent guest:** Name + number of stays

### Monthly Comparison Table
- Columns: Month | Nights Booked | Revenue | Expenses | Net Profit
- Rows: one per month in selected period
- Scrollable if many rows

### Seasonal Trends (conditional)
- Simple bar chart showing historical monthly performance
- Only shown if 6+ months of data exist

### Loading States
- Skeleton cards and chart placeholders

### Error States
- Error with retry

### Empty State
- "Not enough data for analytics. Add reservations to see insights."

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `selectedPeriod: AnalyticsPeriod` — this_month, last_month, last_3_months, etc.
- `customStartDate: DateTime?`
- `customEndDate: DateTime?`

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- None (read-only)

### Loading States
- `isLoading: bool`

### Error States
- `error: String?`

### Form Validation
- No forms (period selector is a filter, not a form)

---

## SECTION 4 — DATA MODELS

```
AnalyticsData {
  total_revenue: Int                    // cents
  total_expenses: Int                   // cents
  net_profit: Int                       // cents
  occupancy: OccupancyData
  revenue_chart: List<RevenueChartPoint>
  expenses_breakdown: List<ExpenseCategoryBreakdown>
  reservation_stats: ReservationStats
  monthly_comparison: List<MonthlyComparisonRow>
  seasonal_trends: List<SeasonalTrendPoint>?
}

OccupancyData {
  rate: Float                           // 0.0 - 1.0
  booked_nights: Int
  total_nights: Int
}

RevenueChartPoint {
  month: String                         // "2025-06"
  confirmed_revenue: Int                // cents
  pending_revenue: Int                  // cents
}

ExpenseCategoryBreakdown {
  category: ExpenseCategory
  total: Int                            // cents
  percentage: Float                     // 0.0 - 1.0
}

ReservationStats {
  avg_length_of_stay: Float             // nights
  avg_revenue_per_reservation: Int      // cents
  longest_stay: Int                     // nights
  longest_stay_guest: String            // guest name
  most_frequent_guest: String           // guest name
  most_frequent_guest_stays: Int        // number of stays
}

MonthlyComparisonRow {
  month: String                         // "June 2025"
  nights_booked: Int
  revenue: Int                          // cents
  expenses: Int                         // cents
  net_profit: Int                       // cents
}

SeasonalTrendPoint {
  month: String                         // "January", "February", etc.
  avg_revenue: Int                      // cents, averaged across years
}

enum AnalyticsPeriod {
  this_month
  last_month
  last_3_months
  last_6_months
  this_year
  custom
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/analytics
Purpose: Fetch all analytics data for the selected period
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params:
  ?period=this_month           // or last_month, last_3_months, last_6_months, this_year, custom
  &start_date=2025-01-01      // only for custom period
  &end_date=2025-06-30        // only for custom period
Success response (200): {
  data: AnalyticsData
}
Error responses:
  401: { error: "Unauthorized" }
  400: { error: "Invalid period or date range" }
  500: { error: "Internal server error" }
When called: on screen mount, on period change
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/analytics
Controller: analyticsController.getAnalytics
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse period param, compute date range (start_date, end_date)
3. Query reservations in date range (user_id match, status != cancelled for most metrics):
   a. Total revenue: SUM(total_price) WHERE status = 'confirmed'
   b. Occupancy: count booked nights within range / total days in range
   c. Revenue chart: GROUP BY month, split by status
   d. Reservation stats: AVG, MAX aggregations
   e. Most frequent guest: GROUP BY guest_id, ORDER BY COUNT DESC, LIMIT 1
4. Query expenses in date range:
   a. Total expenses: SUM(amount)
   b. Expenses breakdown: GROUP BY category
5. Compute net profit, monthly comparison
6. If 6+ months of data: compute seasonal trends from all historical data
7. Return AnalyticsData

Database table(s) touched: reservations, guests, expenses
Type of operation: SELECT with multiple aggregation queries

Business rules:
- Revenue only from confirmed reservations
- Expenses include all categories
- Occupancy counts each day a reservation covers within the range
- Average calculations exclude cancelled reservations
- Seasonal trends use all available data, not just selected period
- If custom period: validate start_date < end_date
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses reservations, guests, expenses tables (all defined previously)
-- No new tables needed
-- Heavy aggregation queries — consider adding database views or materialized views for performance
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/analytics`
- **Route parameters:** none
- **Navigation trigger:** Bottom nav "Analytics" tab, Dashboard "Analytics" button
- **Navigation type:** Bottom navigation tab (index 3)
- **Deep link path:** `/analytics`

---

## SECTION 9 — LOCALIZATION STRINGS

```
analytics_title: "Анализи" / "Analytics"
analytics_period_this_month: "Този месец" / "This Month"
analytics_period_last_month: "Миналия месец" / "Last Month"
analytics_period_last_3: "Последни 3 месеца" / "Last 3 Months"
analytics_period_last_6: "Последни 6 месеца" / "Last 6 Months"
analytics_period_this_year: "Тази година" / "This Year"
analytics_period_custom: "По избор" / "Custom Range"
analytics_total_revenue: "Общ приход" / "Total Revenue"
analytics_total_expenses: "Общи разходи" / "Total Expenses"
analytics_net_profit: "Нетна печалба" / "Net Profit"
analytics_occupancy: "Заетост" / "Occupancy"
analytics_booked_nights: "{booked} от {total} нощувки" / "{booked} of {total} nights"
analytics_revenue_chart: "Приход по месеци" / "Revenue Breakdown"
analytics_confirmed: "Потвърден" / "Confirmed"
analytics_pending: "Чакащ" / "Pending"
analytics_expenses_chart: "Разходи по категории" / "Expenses by Category"
analytics_avg_stay: "Средна продължителност" / "Avg. Length of Stay"
analytics_avg_revenue: "Среден приход на резервация" / "Avg. Revenue per Reservation"
analytics_longest_stay: "Най-дълго посещение" / "Longest Stay"
analytics_most_frequent: "Най-чест гост" / "Most Frequent Guest"
analytics_monthly_table: "Месечно сравнение" / "Monthly Comparison"
analytics_month_col: "Месец" / "Month"
analytics_nights_col: "Нощувки" / "Nights"
analytics_revenue_col: "Приход" / "Revenue"
analytics_expenses_col: "Разходи" / "Expenses"
analytics_profit_col: "Печалба" / "Profit"
analytics_seasonal: "Сезонни тенденции" / "Seasonal Trends"
analytics_nights_unit: "нощувки" / "nights"
analytics_stays_unit: "посещения" / "stays"
analytics_empty: "Няма достатъчно данни за анализ. Добавете резервации, за да видите статистики." / "Not enough data for analytics. Add reservations to see insights."
analytics_error_load: "Грешка при зареждане на анализите" / "Error loading analytics"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    analytics/
      presentation/
        screens/
          analytics_screen.dart             -- main analytics screen (scrollable)
        widgets/
          period_selector.dart              -- period segmented control
          analytics_overview_cards.dart     -- revenue, expenses, profit cards
          occupancy_section.dart            -- occupancy rate + progress bar
          revenue_chart.dart                -- bar/line chart for revenue
          expenses_pie_chart.dart           -- donut chart for expenses
          expenses_legend.dart              -- category list below chart
          reservation_stats_section.dart    -- stats grid
          monthly_comparison_table.dart     -- comparison table
          seasonal_trends_chart.dart        -- seasonal bar chart
          analytics_empty_state.dart        -- empty state widget
        bloc/
          analytics_bloc.dart              -- load analytics, change period
          analytics_event.dart             -- LoadAnalytics, ChangePeriod
          analytics_state.dart             -- Loading, Loaded, Error
      data/
        models/
          analytics_data.dart              -- AnalyticsData + fromJson (and nested models)
        repositories/
          analytics_repository.dart        -- analytics API call
        datasources/
          analytics_remote_datasource.dart
      domain/
        entities/
          analytics_data.dart
        usecases/
          get_analytics.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show error state (analytics requires fresh data, no caching recommended)
- **No data at all:** Show empty state with CTA
- **Partial data:** Show available sections, hide sections with insufficient data (e.g. seasonal trends needs 6+ months)
- **Custom date range:** Validate start < end, max range of 1 year
- **Division by zero:** Handle occupancy rate when total nights = 0
- **No expenses:** Show 0 for expenses, full revenue as profit
- **No confirmed reservations:** Revenue = 0, all metrics based on confirmed bookings show 0
- **Currency formatting:** Use user's currency consistently
- **Large dataset performance:** Backend aggregation queries should be efficient; consider database-level optimizations
- **Most frequent guest tie:** Pick first alphabetically or most recent

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  fl_chart: ^0.68.0               // charts (bar, line, pie/donut)
  intl: ^0.19.0                   // date/currency formatting

Node.js / Backend:
  date-fns: ^3.6.0               // date range calculations
```
