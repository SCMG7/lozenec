# Screen 15 — Add / Edit Expense Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Add / Edit Expense Screen
- **Number:** 15
- **Purpose:** Log a new expense or edit an existing one.
- **Navigation source:** Expenses Screen (Screen 14) FAB (add mode) or expense row tap (edit mode)
- **Navigates to:**
  - Previous screen — on save success or cancel (pop)

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button:** Top left
- **Screen title:** "New Expense" (add mode) or "Edit Expense" (edit mode)

### Input Fields
| Field | Type | Label | Placeholder | Validation | Keyboard |
|-------|------|-------|-------------|------------|----------|
| Title | text | "Title / Description" | "e.g. Plumber repair" | Required, min 2 chars | text |
| Amount | numeric | "Amount" | "0.00" | Required, > 0 | decimal |
| Date | date picker | "Date" | Today's date | Required | N/A |
| Category | dropdown | "Category" | "Select category" | Required | N/A |
| Notes | textarea | "Notes" | "Additional details..." | Optional | text |

- Amount field shows currency symbol prefix
- Date defaults to today

### Category Dropdown Options
- Maintenance
- Renovation
- Utilities (water, electricity, internet)
- Cleaning
- Supplies
- Taxes / Fees
- Other

### Recurring Section
- **Toggle:** "Recurring expense?" (Yes / No switch)
- If Yes: **Frequency selector:** Monthly / Yearly radio buttons or segmented control

### Action Buttons
- **"Save Expense":** Primary, full-width
- **"Cancel":** Text link
- **"Delete Expense":** Destructive red button (edit mode only), with confirmation dialog

### Loading States
- Save: button spinner "Saving..."
- Edit mode: skeleton form while loading
- Delete: spinner in dialog

### Error States
- Inline field validation errors
- Server error: toast/banner

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `isEditMode: bool`
- `expenseId: UUID?`
- `title: String`
- `amount: Int` — in cents
- `date: DateTime`
- `category: ExpenseCategory?`
- `notes: String`
- `isRecurring: bool`
- `recurrenceFreq: String?` — "monthly" or "yearly"
- `fieldErrors: Map<String, String?>`
- `isSubmitting: bool`
- `isLoadingExpense: bool`
- `isDeleting: bool`
- `showDeleteDialog: bool`

### Global State (Read)
- `currentUser.currency: String`

### Global State (Write)
- Triggers expenses list refresh after save/delete

### Loading States
- `isLoadingExpense`, `isSubmitting`, `isDeleting`

### Error States
- `fieldErrors`, `serverError: String?`

### Form Validation
- Title: required, min 2 chars
- Amount: required, > 0
- Date: required
- Category: required

---

## SECTION 4 — DATA MODELS

```
CreateExpenseRequest {
  title: String              // required
  amount: Int                // in cents, required, > 0
  date: String               // ISO 8601 date, required
  category: String           // required, one of enum values
  notes: String?             // optional
  is_recurring: Bool         // default false
  recurrence_freq: String?   // "monthly" or "yearly", required if is_recurring
}

UpdateExpenseRequest {
  title: String
  amount: Int
  date: String
  category: String
  notes: String?
  is_recurring: Bool
  recurrence_freq: String?
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
POST /api/v1/expenses
Purpose: Create a new expense
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: CreateExpenseRequest
Success response (201): {
  data: { expense: Expense },
  message: "Expense created successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error" } }
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on "Save Expense" tap (add mode)
```

```
GET /api/v1/expenses/:id
Purpose: Fetch expense data for editing
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: { expense: Expense }
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Expense not found" }
  500: { error: "Internal server error" }
When called: on screen mount (edit mode)
```

```
PUT /api/v1/expenses/:id
Purpose: Update an existing expense
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: UpdateExpenseRequest
Success response (200): {
  data: { expense: Expense },
  message: "Expense updated successfully"
}
Error responses:
  400: { error: "Validation failed" }
  401: { error: "Unauthorized" }
  404: { error: "Expense not found" }
  500: { error: "Internal server error" }
When called: on "Save Expense" tap (edit mode)
```

```
DELETE /api/v1/expenses/:id
Purpose: Delete an expense
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: null,
  message: "Expense deleted successfully"
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Expense not found" }
  500: { error: "Internal server error" }
When called: on delete confirmation
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/expenses
Controller: expensesController.createExpense
Middleware: [authMiddleware, validateBody(createExpenseSchema)]

Steps:
1. Extract user ID from JWT
2. Validate request body
3. Convert amount to integer (cents) if needed
4. Insert expense with user_id
5. Return created expense

Database table(s) touched: expenses (INSERT)
Type of operation: INSERT

Business rules:
- Amount stored in cents
- Date stored as ISO date
- Category must be valid enum value
- If is_recurring = true, recurrence_freq is required
```

```
ENDPOINT: PUT /api/v1/expenses/:id
Controller: expensesController.updateExpense
Middleware: [authMiddleware, validateBody(updateExpenseSchema)]

Steps:
1. Extract user ID from JWT
2. Parse expense ID
3. Verify expense exists and belongs to user
4. Validate request body
5. Update expense
6. Return updated expense

Database table(s) touched: expenses (SELECT + UPDATE)
Type of operation: SELECT + UPDATE
```

```
ENDPOINT: DELETE /api/v1/expenses/:id
Controller: expensesController.deleteExpense
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse expense ID
3. Verify expense exists and belongs to user
4. Delete expense
5. Return success

Database table(s) touched: expenses (DELETE)
Type of operation: DELETE
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses expenses table (defined in Screen 05)
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/add-expense` (add mode) or `/expense/:id/edit` (edit mode)
- **Route parameters:**
  - `id: UUID?` — optional, present for edit mode
- **Navigation trigger:** Expenses FAB (add), expense row tap (edit)
- **Navigation type:** `push`
- **On save:** `pop` with result (triggers refresh)
- **On delete:** `pop` with delete result
- **"Cancel":** `pop`
- **Deep link path:** `/add-expense`, `/expense/:id/edit`

---

## SECTION 9 — LOCALIZATION STRINGS

```
add_expense_title: "Нов разход" / "New Expense"
edit_expense_title: "Редактирай разход" / "Edit Expense"
expense_form_title_label: "Заглавие / Описание" / "Title / Description"
expense_form_title_hint: "напр. Ремонт на водопровод" / "e.g. Plumber repair"
expense_form_amount_label: "Сума" / "Amount"
expense_form_amount_hint: "0.00" / "0.00"
expense_form_date_label: "Дата" / "Date"
expense_form_category_label: "Категория" / "Category"
expense_form_category_hint: "Изберете категория" / "Select category"
expense_form_notes_label: "Бележки" / "Notes"
expense_form_notes_hint: "Допълнителни детайли..." / "Additional details..."
expense_form_recurring: "Повтарящ се разход?" / "Recurring expense?"
expense_form_frequency: "Честота" / "Frequency"
expense_form_monthly: "Месечно" / "Monthly"
expense_form_yearly: "Годишно" / "Yearly"
expense_form_save: "Запази разход" / "Save Expense"
expense_form_cancel: "Отказ" / "Cancel"
expense_form_saving: "Запазване..." / "Saving..."
expense_form_delete: "Изтрий разход" / "Delete Expense"
expense_form_delete_confirm: "Сигурни ли сте, че искате да изтриете този разход?" / "Are you sure you want to delete this expense?"
expense_form_error_title_required: "Заглавието е задължително" / "Title is required"
expense_form_error_title_min: "Заглавието трябва да е поне 2 символа" / "Title must be at least 2 characters"
expense_form_error_amount_required: "Сумата е задължителна" / "Amount is required"
expense_form_error_amount_positive: "Сумата трябва да е положителна" / "Amount must be positive"
expense_form_error_date_required: "Датата е задължителна" / "Date is required"
expense_form_error_category_required: "Категорията е задължителна" / "Category is required"
expense_form_created: "Разходът е създаден" / "Expense created successfully"
expense_form_updated: "Разходът е обновен" / "Expense updated successfully"
expense_form_deleted: "Разходът е изтрит" / "Expense deleted successfully"
expense_form_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    expenses/
      presentation/
        screens/
          add_edit_expense_screen.dart      -- shared add/edit expense screen
        widgets/
          expense_form.dart                 -- form with all fields
          category_dropdown.dart            -- category selector
          recurring_toggle.dart             -- recurring switch + frequency
          delete_expense_dialog.dart        -- confirmation dialog
        bloc/
          add_edit_expense_bloc.dart        -- form logic
          add_edit_expense_event.dart       -- LoadExpense, SaveExpense, DeleteExpense
          add_edit_expense_state.dart       -- Initial, Loading, Saving, Deleting, Success, Error
      data/
        models/
          create_expense_request.dart       -- toJson
          update_expense_request.dart       -- toJson
        repositories/
          expense_repository.dart           -- add create, update, delete, getById methods
        datasources/
          expense_remote_datasource.dart    -- add endpoints
      domain/
        usecases/
          create_expense.dart
          update_expense.dart
          delete_expense.dart
          get_expense.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show error toast, preserve form state
- **Empty required fields:** Inline errors for title, amount, category, date
- **Amount = 0 or negative:** Error "Amount must be positive"
- **Very large amount:** Allow (no upper limit) but display with proper formatting
- **Recurring without frequency:** If toggle is on, frequency is required
- **Date in far future:** Allowed
- **Edit mode — expense not found:** Show error, pop back
- **Delete confirmation cancelled:** Return to form
- **Double-tap save:** Prevent duplicate submissions
- **Currency display:** Use user's currency from settings

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl: ^0.19.0                   // date/currency formatting

Node.js / Backend:
  zod: ^3.22.0                    // request validation
```
