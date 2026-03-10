# Screen 17 — Settings Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Settings Screen
- **Number:** 17
- **Purpose:** App-wide configuration and account management.
- **Navigation source:** Bottom navigation "Settings" tab; Dashboard avatar/profile icon
- **Navigates to:**
  - Change Password sub-screen (inline or modal)
  - Expenses (Screen 14) — via quick link
  - Login (Screen 03) — after logout (replace entire stack)

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Screen title:** "Settings"

### Profile Section
- **Avatar:** Circle with initials, edit button overlay (for future photo upload)
- **Display name:** Tappable to edit (inline edit or modal)
- **Email address:** Tappable to edit
- **"Change Password" row:** Chevron, opens sub-screen with:
  - Current Password input
  - New Password input (with show/hide toggle)
  - Confirm New Password input (with show/hide toggle)
  - "Update Password" button

### Studio Settings Section
- **Studio Name:** Editable text field
- **Studio Address:** Editable text field
- **Default price per night:** Numeric input with currency symbol
- **Currency selector:** Dropdown — BGN, EUR, USD, GBP
- **Default check-in time:** Time picker (defaults to 14:00)
- **Default check-out time:** Time picker (defaults to 11:00)

### Calendar Settings Section
- **Week starts on:** Toggle/segmented — Sunday / Monday
- **Color theme for reserved days:** Color picker with presets (blue, teal, purple, green)

### Notifications Section
- **Toggle:** Enable push notifications (master toggle)
- **Toggle:** Notify me 1 day before check-in
- **Toggle:** Notify me on check-out day
- **Toggle:** Notify me for upcoming unpaid reservations

### Data Section
- **"Export Data" button:** Exports all reservations + expenses as CSV or PDF
- **"Clear All Data" button:** Destructive, red — requires typed confirmation ("DELETE" typed in a text field)

### About Section
- **App version:** e.g. "v1.0.0"
- **"Rate the App" link:** Opens app store listing
- **"Privacy Policy" link:** Opens web URL
- **"Terms of Use" link:** Opens web URL

### Logout Button
- Full-width at bottom, neutral/warning color
- Confirmation: "Are you sure you want to log out?"

### Loading States
- Save indicator when settings change (auto-save or explicit save)
- Export: progress indicator

### Error States
- Toast for failed save
- Error for failed export

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `isEditingName: bool`
- `isEditingEmail: bool`
- `showChangePassword: bool`
- `currentPassword: String`
- `newPassword: String`
- `confirmNewPassword: String`
- `showClearDataDialog: bool`
- `clearDataConfirmText: String`
- `isExporting: bool`
- `isSaving: bool`

### Global State (Read + Write)
- `currentUser: User` — all profile and settings fields

### Loading States
- `isSaving`, `isExporting`, `isChangingPassword`

### Error States
- `saveError: String?`, `passwordError: String?`, `exportError: String?`

### Form Validation
- Change password: current password required, new password min 8 chars with requirements, confirm must match
- Studio settings: studio name required, default price >= 0

---

## SECTION 4 — DATA MODELS

```
UpdateProfileRequest {
  full_name: String?
  email: String?
}

UpdateSettingsRequest {
  studio_name: String?
  studio_address: String?
  default_price_per_night: Int?   // cents
  currency: String?               // BGN, EUR, USD, GBP
  default_check_in_time: String?  // HH:mm
  default_check_out_time: String? // HH:mm
  week_starts_on: String?         // "sunday" or "monday"
  notify_before_checkin: Bool?
  notify_on_checkout: Bool?
  notify_unpaid: Bool?
  push_notifications_enabled: Bool?
}

ChangePasswordRequest {
  current_password: String
  new_password: String
}

ExportFormat {
  csv
  pdf
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
PUT /api/v1/auth/profile
Purpose: Update user profile (name, email)
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: UpdateProfileRequest
Success response (200): {
  data: { user: User },
  message: "Profile updated successfully"
}
Error responses:
  400: { error: "Validation failed" }
  401: { error: "Unauthorized" }
  409: { error: "Email already in use" }
  500: { error: "Internal server error" }
When called: on profile field save
```

```
PUT /api/v1/auth/settings
Purpose: Update app/studio settings
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: UpdateSettingsRequest
Success response (200): {
  data: { user: User },
  message: "Settings updated successfully"
}
Error responses:
  400: { error: "Validation failed" }
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on settings toggle/change (debounced auto-save or explicit save)
```

```
POST /api/v1/auth/change-password
Purpose: Change the user's password
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: {
  current_password: String,
  new_password: String
}
Success response (200): {
  data: null,
  message: "Password changed successfully"
}
Error responses:
  400: { error: "Validation failed" }
  401: { error: "Current password is incorrect" }
  500: { error: "Internal server error" }
When called: on "Update Password" tap
```

```
POST /api/v1/data/export
Purpose: Export all user data as CSV or PDF
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: { format: "csv" | "pdf" }
Success response (200): binary file download (Content-Type: text/csv or application/pdf)
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on "Export Data" tap
```

```
DELETE /api/v1/data/clear
Purpose: Clear all user data (reservations, guests, expenses, notifications)
Auth required: yes
Request headers: { Authorization: "Bearer <token>", Content-Type: "application/json" }
Request body: { confirmation: "DELETE" }
Success response (200): {
  data: null,
  message: "All data cleared successfully"
}
Error responses:
  400: { error: "Invalid confirmation" }
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on clear data confirmation
```

```
POST /api/v1/auth/logout
Purpose: Invalidate the current session/token
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: null,
  message: "Logged out successfully"
}
Error responses:
  500: { error: "Internal server error" }
When called: on logout confirmation
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: PUT /api/v1/auth/profile
Controller: authController.updateProfile
Middleware: [authMiddleware, validateBody(updateProfileSchema)]

Steps:
1. Extract user ID from JWT
2. Validate request body
3. If email changed, check uniqueness
4. Update user profile fields
5. Return updated user

Database table(s) touched: users (SELECT + UPDATE)
Type of operation: UPDATE
```

```
ENDPOINT: PUT /api/v1/auth/settings
Controller: authController.updateSettings
Middleware: [authMiddleware, validateBody(updateSettingsSchema)]

Steps:
1. Extract user ID from JWT
2. Validate request body (currency must be valid enum, times must be HH:mm format)
3. Update user settings fields
4. Return updated user

Database table(s) touched: users (UPDATE)
Type of operation: UPDATE
```

```
ENDPOINT: POST /api/v1/auth/change-password
Controller: authController.changePassword
Middleware: [authMiddleware, validateBody(changePasswordSchema)]

Steps:
1. Extract user ID from JWT
2. Fetch user from database
3. Compare current_password with stored hash using bcrypt
4. If mismatch, return 401 "Current password is incorrect"
5. Hash new password with bcrypt
6. Update password_hash in database
7. Return success

Database table(s) touched: users (SELECT + UPDATE)
Type of operation: SELECT + UPDATE

Business rules:
- Current password must be verified before allowing change
- New password must meet same requirements as registration (min 8, uppercase, number)
```

```
ENDPOINT: POST /api/v1/data/export
Controller: dataController.exportData
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Query all reservations with guest names
3. Query all expenses
4. Format as CSV or PDF based on request
5. Return file as download

Database table(s) touched: reservations, guests, expenses
Type of operation: SELECT (bulk)
```

```
ENDPOINT: DELETE /api/v1/data/clear
Controller: dataController.clearData
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Verify confirmation = "DELETE"
3. Delete all notifications for user
4. Delete all reservation_activity_log entries for user's reservations
5. Delete all reservations for user
6. Delete all guests for user
7. Delete all expenses for user
8. Return success

Database table(s) touched: notifications, reservation_activity_log, reservations, guests, expenses
Type of operation: DELETE (bulk, in correct order for FK constraints)

Business rules:
- Delete in order to respect foreign key constraints
- User account itself is NOT deleted — only data
- This action is irreversible
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses users table (defined in Screens 01/02)
-- All data operations are on existing tables
-- No new tables needed
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/settings`
- **Route parameters:** none
- **Navigation trigger:** Bottom nav "Settings" tab, Dashboard avatar icon
- **Navigation type:** Bottom navigation tab (index 4)
- **Change password:** Inline sub-screen or `push` to `/settings/change-password`
- **Logout:** `replace` entire stack with `/login`
- **Deep link path:** `/settings`

---

## SECTION 9 — LOCALIZATION STRINGS

```
settings_title: "Настройки" / "Settings"
settings_profile: "Профил" / "Profile"
settings_display_name: "Име" / "Display Name"
settings_email: "Имейл" / "Email"
settings_change_password: "Промяна на парола" / "Change Password"
settings_current_password: "Текуща парола" / "Current Password"
settings_new_password: "Нова парола" / "New Password"
settings_confirm_new_password: "Потвърди нова парола" / "Confirm New Password"
settings_update_password: "Обнови парола" / "Update Password"
settings_studio: "Настройки на студиото" / "Studio Settings"
settings_studio_name: "Име на студиото" / "Studio Name"
settings_studio_address: "Адрес на студиото" / "Studio Address"
settings_default_price: "Цена на нощ по подразбиране" / "Default Price per Night"
settings_currency: "Валута" / "Currency"
settings_check_in_time: "Час на настаняване" / "Default Check-in Time"
settings_check_out_time: "Час на напускане" / "Default Check-out Time"
settings_calendar: "Настройки на календара" / "Calendar Settings"
settings_week_starts: "Седмицата започва от" / "Week starts on"
settings_sunday: "Неделя" / "Sunday"
settings_monday: "Понеделник" / "Monday"
settings_color_theme: "Цветова тема за резервации" / "Color theme for reserved days"
settings_notifications: "Известия" / "Notifications"
settings_push_enabled: "Включи известия" / "Enable push notifications"
settings_notify_checkin: "Известие 1 ден преди настаняване" / "Notify 1 day before check-in"
settings_notify_checkout: "Известие в деня на напускане" / "Notify on check-out day"
settings_notify_unpaid: "Известие за неплатени резервации" / "Notify for unpaid reservations"
settings_data: "Данни" / "Data"
settings_export: "Експорт на данни" / "Export Data"
settings_export_csv: "Експорт като CSV" / "Export as CSV"
settings_export_pdf: "Експорт като PDF" / "Export as PDF"
settings_clear_data: "Изтрий всички данни" / "Clear All Data"
settings_clear_data_confirm: "Въведете DELETE за потвърждение" / "Type DELETE to confirm"
settings_clear_data_warning: "Това действие е необратимо. Всички резервации, гости и разходи ще бъдат изтрити." / "This action is irreversible. All reservations, guests, and expenses will be deleted."
settings_about: "Относно" / "About"
settings_version: "Версия" / "Version"
settings_rate_app: "Оценете приложението" / "Rate the App"
settings_privacy: "Политика за поверителност" / "Privacy Policy"
settings_terms: "Условия за ползване" / "Terms of Use"
settings_logout: "Изход" / "Log Out"
settings_logout_confirm: "Сигурни ли сте, че искате да излезете?" / "Are you sure you want to log out?"
settings_logout_cancel: "Отказ" / "Cancel"
settings_logout_yes: "Изход" / "Log Out"
settings_saved: "Настройките са запазени" / "Settings saved"
settings_password_changed: "Паролата е променена" / "Password changed successfully"
settings_password_error_current: "Текущата парола е грешна" / "Current password is incorrect"
settings_password_error_match: "Паролите не съвпадат" / "Passwords do not match"
settings_export_success: "Данните са експортирани" / "Data exported successfully"
settings_data_cleared: "Всички данни са изтрити" / "All data cleared successfully"
settings_error_save: "Грешка при запазване" / "Error saving settings"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    settings/
      presentation/
        screens/
          settings_screen.dart              -- main settings screen (scrollable)
          change_password_screen.dart       -- change password sub-screen
        widgets/
          profile_section.dart              -- avatar, name, email
          studio_settings_section.dart      -- studio name, address, price, currency, times
          calendar_settings_section.dart    -- week start, color theme
          notifications_section.dart        -- notification toggles
          data_section.dart                 -- export + clear data
          about_section.dart                -- version, links
          logout_button.dart                -- logout with confirmation
          clear_data_dialog.dart            -- confirmation with typed input
          settings_editable_field.dart      -- reusable inline editable field
          currency_selector.dart            -- currency dropdown
          time_picker_field.dart            -- time picker wrapper
          color_theme_picker.dart           -- color preset picker
        bloc/
          settings_bloc.dart               -- load/save settings
          settings_event.dart              -- LoadSettings, UpdateProfile, UpdateSettings, ChangePassword, Export, ClearData, Logout
          settings_state.dart              -- Loading, Loaded, Saving, Error
      data/
        models/
          update_profile_request.dart      -- toJson
          update_settings_request.dart     -- toJson
          change_password_request.dart     -- toJson
        repositories/
          settings_repository.dart         -- settings API calls
        datasources/
          settings_remote_datasource.dart
      domain/
        usecases/
          update_profile.dart
          update_settings.dart
          change_password.dart
          export_data.dart
          clear_data.dart
          logout.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show error for any save action; toggles revert to previous state
- **Change password — wrong current password:** Show inline error
- **Change password — weak new password:** Show requirements
- **Email change to existing email:** Show 409 error
- **Currency change:** Affects all price displays across the app (stored values in cents stay same)
- **Clear data — wrong confirmation text:** Button stays disabled
- **Clear data — success:** Reset all app state, navigate to dashboard (empty)
- **Export — large dataset:** Show progress indicator, handle timeout
- **Export — no data:** Generate empty report with headers
- **Logout:** Clear stored tokens, reset all global state
- **Settings auto-save:** Debounce changes (500ms) to avoid excessive API calls
- **Invalid time format:** Time pickers prevent invalid input
- **Default price = 0:** Allowed (free studio)

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  flutter_secure_storage: ^9.0.0  // clear tokens on logout
  url_launcher: ^6.2.0            // rate app, privacy, terms links
  share_plus: ^9.0.0              // share exported file
  path_provider: ^2.1.0           // save exported file
  file_picker: ^8.0.0             // save file dialog (optional)

Node.js / Backend:
  bcrypt: ^5.1.0                  // password change
  json2csv: ^6.0.0                // CSV export
  pdfkit: ^0.15.0                 // PDF export (or use a simpler library)
  zod: ^3.22.0                    // request validation
```
