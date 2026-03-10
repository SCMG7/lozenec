# Screen 13 — Add / Edit Guest Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Add / Edit Guest Screen
- **Number:** 13
- **Purpose:** Create a new guest profile or edit an existing one.
- **Navigation source:** Guest List FAB (Screen 11); Guest Detail "Edit" button (Screen 12); Add Reservation "+ Create New Guest" (Screen 08)
- **Navigates to:**
  - Previous screen — on save success or cancel (pop)

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button / Cancel:** Top left
- **Screen title:** "New Guest" (add mode) or "Edit Guest" (edit mode)

### Input Fields
| Field | Type | Label | Placeholder | Validation | Keyboard |
|-------|------|-------|-------------|------------|----------|
| First Name | text | "First Name" | "Enter first name" | Required, min 2 chars | text |
| Last Name | text | "Last Name" | "Enter last name" | Required, min 2 chars | text |
| Phone Number | phone | "Phone Number" | "+359..." | Optional, valid phone format | phone |
| Email Address | email | "Email Address" | "guest@email.com" | Optional, valid email if provided | emailAddress |
| Nationality | text/picker | "Nationality" | "Select country" | Optional | text |
| ID / Passport Number | text | "ID / Passport Number" | "Enter ID number" | Optional | text |

- Phone field has country code selector/prefix

### Notes Section
- **Text area:** "Guest notes" — multiline, optional
- Placeholder: "e.g. Quiet guest, Has a dog"

### Action Buttons
- **"Save Guest":** Primary, full-width
- **"Cancel":** Text link

### Loading States
- Save: button spinner "Saving..."
- Edit mode: skeleton form while loading existing data

### Error States
- Inline field validation errors
- Server error: toast/banner

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `isEditMode: bool` — determined by presence of guestId parameter
- `guestId: UUID?` — null for add, set for edit
- `firstName: String`
- `lastName: String`
- `phone: String`
- `email: String`
- `nationality: String`
- `idNumber: String`
- `notes: String`
- `fieldErrors: Map<String, String?>`
- `isSubmitting: bool`
- `isLoadingGuest: bool` (edit mode only)

### Global State (Read)
- None

### Global State (Write)
- Triggers guest list refresh after save

### Loading States
- `isLoadingGuest` (edit), `isSubmitting`

### Error States
- `fieldErrors`, `serverError: String?`

### Form Validation
- **Field-level:** First name required (min 2), last name required (min 2), email valid if provided, phone valid format if provided
- **Form-level:** First and last name must be filled

---

## SECTION 4 — DATA MODELS

```
CreateGuestRequest {
  first_name: String        // required, min 2
  last_name: String         // required, min 2
  phone: String?            // optional
  email: String?            // optional, valid email if provided
  nationality: String?      // optional
  id_number: String?        // optional
  notes: String?            // optional
}

UpdateGuestRequest {
  first_name: String        // required
  last_name: String         // required
  phone: String?
  email: String?
  nationality: String?
  id_number: String?
  notes: String?
}

Guest {
  id: UUID
  user_id: UUID
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
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
POST /api/v1/guests
Purpose: Create a new guest profile
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: CreateGuestRequest
Success response (201): {
  data: { guest: Guest },
  message: "Guest created successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error" } }
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on "Save Guest" tap (add mode)
```

```
GET /api/v1/guests/:id
Purpose: Fetch guest data for editing (same as Screen 12 but without reservations)
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: { guest: Guest }
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Guest not found" }
  500: { error: "Internal server error" }
When called: on screen mount (edit mode)
```

```
PUT /api/v1/guests/:id
Purpose: Update an existing guest profile
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: UpdateGuestRequest
Success response (200): {
  data: { guest: Guest },
  message: "Guest updated successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error" } }
  401: { error: "Unauthorized" }
  404: { error: "Guest not found" }
  500: { error: "Internal server error" }
When called: on "Save Guest" tap (edit mode)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/guests
Controller: guestsController.createGuest
Middleware: [authMiddleware, validateBody(createGuestSchema)]

Steps:
1. Extract user ID from JWT
2. Validate request body
3. Insert new guest with user_id
4. Return created guest

Database table(s) touched: guests (INSERT)
Type of operation: INSERT

Business rules:
- Guest belongs to authenticated user
- Duplicate guest names allowed (different guests can have the same name)
- Phone and email are optional
```

```
ENDPOINT: PUT /api/v1/guests/:id
Controller: guestsController.updateGuest
Middleware: [authMiddleware, validateBody(updateGuestSchema)]

Steps:
1. Extract user ID from JWT
2. Parse guest ID
3. Verify guest exists and belongs to user
4. Validate request body
5. Update guest fields
6. Return updated guest

Database table(s) touched: guests (SELECT + UPDATE)
Type of operation: SELECT + UPDATE

Business rules:
- Only owner can edit their guest
- All fields can be updated
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses guests table (defined in Screen 05)
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/add-guest` (add mode) or `/guest/:id/edit` (edit mode)
- **Route parameters:**
  - `id: UUID?` — optional, present for edit mode
- **Navigation trigger:** Guest List FAB, Guest Detail "Edit" button, Add Reservation "+ Create New Guest"
- **Navigation type:** `push` (or `modal` from Add Reservation)
- **On save:** `pop` with result (the created/updated Guest object, for Add Reservation to use)
- **"Cancel":** `pop` without result
- **Deep link path:** `/add-guest`, `/guest/:id/edit`

---

## SECTION 9 — LOCALIZATION STRINGS

```
add_guest_title: "Нов гост" / "New Guest"
edit_guest_title: "Редактирай гост" / "Edit Guest"
guest_form_first_name: "Име" / "First Name"
guest_form_first_name_hint: "Въведете име" / "Enter first name"
guest_form_last_name: "Фамилия" / "Last Name"
guest_form_last_name_hint: "Въведете фамилия" / "Enter last name"
guest_form_phone: "Телефонен номер" / "Phone Number"
guest_form_phone_hint: "+359..." / "+359..."
guest_form_email: "Имейл адрес" / "Email Address"
guest_form_email_hint: "guest@email.com" / "guest@email.com"
guest_form_nationality: "Националност" / "Nationality"
guest_form_nationality_hint: "Изберете страна" / "Select country"
guest_form_id_number: "ЕГН / Номер на паспорт" / "ID / Passport Number"
guest_form_id_number_hint: "Въведете номер" / "Enter ID number"
guest_form_notes: "Бележки за госта" / "Guest notes"
guest_form_notes_hint: "напр. Тих гост, Има куче" / "e.g. Quiet guest, Has a dog"
guest_form_save: "Запази гост" / "Save Guest"
guest_form_cancel: "Отказ" / "Cancel"
guest_form_saving: "Запазване..." / "Saving..."
guest_form_error_first_name_required: "Името е задължително" / "First name is required"
guest_form_error_first_name_min: "Името трябва да е поне 2 символа" / "First name must be at least 2 characters"
guest_form_error_last_name_required: "Фамилията е задължителна" / "Last name is required"
guest_form_error_last_name_min: "Фамилията трябва да е поне 2 символа" / "Last name must be at least 2 characters"
guest_form_error_email_invalid: "Невалиден имейл адрес" / "Invalid email address"
guest_form_error_phone_invalid: "Невалиден телефонен номер" / "Invalid phone number"
guest_form_created: "Гостът е създаден" / "Guest created successfully"
guest_form_updated: "Гостът е обновен" / "Guest updated successfully"
guest_form_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    guests/
      presentation/
        screens/
          add_edit_guest_screen.dart        -- shared add/edit guest screen
        widgets/
          guest_form.dart                   -- form with all fields
          country_picker_field.dart         -- nationality picker
          phone_input_field.dart            -- phone with country code
        bloc/
          add_edit_guest_bloc.dart          -- form logic (add + edit)
          add_edit_guest_event.dart         -- LoadGuest, SaveGuest, ValidateField
          add_edit_guest_state.dart         -- Initial, Loading, Saving, Success, Error
      data/
        models/
          create_guest_request.dart         -- toJson
          update_guest_request.dart         -- toJson
          guest.dart                        -- Guest model (shared)
        repositories/
          guest_repository.dart             -- add createGuest, updateGuest methods
        datasources/
          guest_remote_datasource.dart      -- add POST, PUT endpoints
      domain/
        usecases/
          create_guest.dart
          update_guest.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show error toast, preserve form state
- **Empty required fields:** Show inline errors for first name and last name
- **Email provided but invalid:** Show inline error
- **Phone with invalid format:** Show inline error (allow various international formats)
- **Duplicate guest name:** Allowed — different people can share names
- **Very long input:** Limit first/last name to 255 chars
- **Edit mode - guest not found:** Show error, pop back
- **Opened from Add Reservation:** On save, return created Guest object so reservation form can select it
- **Cancel with unsaved changes:** Pop without saving (no confirmation dialog — data is not critical)
- **Double-tap save:** Prevent duplicate submissions

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  intl_phone_field: ^3.2.0        // phone number input with country code
  country_picker: ^2.0.0          // nationality selection (optional, can use text field)

Node.js / Backend:
  zod: ^3.22.0                    // request validation
```
