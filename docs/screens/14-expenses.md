# Screen 14 — Expenses Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Expenses Screen
- **Number:** 14
- **Purpose:** Track all money spent on the studio (maintenance, renovation, cleaning, bills, etc.)
- **Navigation source:** Dashboard quick links; Analytics screen; Settings
- **Navigates to:**
  - Add/Edit Expense (Screen 15) — via FAB or tapping an expense row

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Screen title:** "Expenses"
- **Back button:** If navigated from another screen (not a tab)

### Month Selector
- Left/right arrow buttons or dropdown
- Displays: "June 2025" format
- Changes displayed expenses to selected month

### Summary Card
- **Total expenses for selected month:** Large formatted amount
- **Largest single expense:** Amount + title
- **Number of expense entries:** Count

### Category Filter (horizontal scrollable chips)
- All | Maintenance | Renovation | Utilities | Cleaning | Supplies | Taxes/Fees | Other
- Active chip highlighted

### Expense List
Each row shows:
- **Category icon:** Visual icon per category
- **Title/description:** Expense name
- **Date:** Formatted date
- **Amount:** In red, formatted with currency
- **Arrow:** Taps to edit (Add/Edit Expense screen)

### Bottom Total
- Total sum of displayed expenses (filtered)

### Floating Action Button
- "+" button — Add new expense

### Empty State
- Message: "No expenses recorded for this month."
- CTA: "+ Add Expense"

### Loading States
- Skeleton rows during load

### Error States
- Error with retry

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `selectedMonth: DateTime` — currently displayed month
- `selectedCategory: ExpenseCategory?` — active filter (null = All)
- `expenses: List<Expense>`
- `summary: ExpenseSummary`

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- None (read-only list)

### Loading States
- `isLoading: bool`
- `isRefreshing: bool`

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
Expense {
  id: UUID
  user_id: UUID
  title: String
  amount: Int                   // in cents
  date: String                  // ISO 8601 date
  category: ExpenseCategory
  notes: String?
  is_recurring: Bool
  recurrence_freq: String?      // "monthly", "yearly"
  created_at: DateTime
  updated_at: DateTime
}

ExpenseSummary {
  total_amount: Int             // in cents
  largest_expense: Expense?
  entry_count: Int
}

enum ExpenseCategory {
  maintenance
  renovation
  utilities
  cleaning
  supplies
  taxes_fees
  other
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/expenses
Purpose: Fetch expenses for a given month with optional category filter
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params:
  ?month=2025-06         // YYYY-MM format
  &category=maintenance  // optional filter
Success response (200): {
  data: {
    expenses: List<Expense>,
    summary: ExpenseSummary
  }
}
Error responses:
  401: { error: "Unauthorized" }
  400: { error: "Invalid month format" }
  500: { error: "Internal server error" }
When called: on screen mount, on month change, on category change, on pull-to-refresh
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/expenses
Controller: expensesController.getExpenses
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse month param (YYYY-MM), compute first/last day
3. Build query: SELECT * FROM expenses WHERE user_id = userId AND date >= firstDay AND date <= lastDay
4. Apply optional category filter
5. Compute summary:
   a. total_amount: SUM(amount)
   b. largest_expense: MAX(amount) with full expense data
   c. entry_count: COUNT(*)
6. Order by date DESC
7. Return expenses + summary

Database table(s) touched: expenses
Type of operation: SELECT

Business rules:
- Only expenses belonging to authenticated user
- Filter by month (date range)
- Optional category filter
- Summary computed from filtered results
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses expenses table (defined in Screen 05)
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/expenses`
- **Route parameters:** none
- **Navigation trigger:** Dashboard link, Analytics link, Settings
- **Navigation type:** `push`
- **Tap expense row:** `push` to `/expense/:id/edit`
- **FAB tap:** `push` to `/add-expense`
- **Deep link path:** `/expenses`

---

## SECTION 9 — LOCALIZATION STRINGS

```
expenses_title: "Разходи" / "Expenses"
expenses_month_summary: "Обобщение за месеца" / "Monthly Summary"
expenses_total: "Общо разходи" / "Total Expenses"
expenses_largest: "Най-голям разход" / "Largest Expense"
expenses_count: "{count} записа" / "{count} entries"
expenses_count_single: "1 запис" / "1 entry"
expenses_filter_all: "Всички" / "All"
expenses_filter_maintenance: "Поддръжка" / "Maintenance"
expenses_filter_renovation: "Ремонт" / "Renovation"
expenses_filter_utilities: "Сметки" / "Utilities"
expenses_filter_cleaning: "Почистване" / "Cleaning"
expenses_filter_supplies: "Консумативи" / "Supplies"
expenses_filter_taxes: "Данъци / Такси" / "Taxes / Fees"
expenses_filter_other: "Други" / "Other"
expenses_add: "+ Добави разход" / "+ Add Expense"
expenses_empty: "Няма записани разходи за този месец." / "No expenses recorded for this month."
expenses_error_load: "Грешка при зареждане на разходите" / "Error loading expenses"
expenses_bottom_total: "Общо: {amount}" / "Total: {amount}"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    expenses/
      presentation/
        screens/
          expenses_screen.dart              -- main expenses screen
        widgets/
          expense_month_selector.dart       -- month navigation arrows
          expense_summary_card.dart         -- monthly summary card
          expense_category_chips.dart       -- horizontal category filter
          expense_list_tile.dart            -- individual expense row
          expense_category_icon.dart        -- icon per category
          expense_empty_state.dart          -- empty state widget
        bloc/
          expenses_bloc.dart               -- list loading, filtering
          expenses_event.dart              -- LoadExpenses, ChangeMonth, ChangeCategory
          expenses_state.dart              -- Loading, Loaded, Error
      data/
        models/
          expense.dart                     -- Expense model + fromJson/toJson
          expense_summary.dart             -- ExpenseSummary + fromJson
        repositories/
          expense_repository.dart          -- expense list API call
        datasources/
          expense_remote_datasource.dart
      domain/
        entities/
          expense.dart
        usecases/
          get_expenses.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached data if available; error state if not
- **No expenses for month:** Show empty state with "+ Add Expense" CTA
- **Category filter with no results:** Show empty state specific to filter
- **Recurring expenses:** Display with recurring icon/badge
- **Currency display:** Always use user's currency setting
- **Month navigation:** No limit on past/future months
- **Large number of expenses:** Consider pagination (50+ items)
- **Return from add/edit:** Refresh list to reflect changes

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting

Node.js / Backend:
  (no additional packages)
```
