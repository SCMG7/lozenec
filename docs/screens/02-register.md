# Screen 02 — Register Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Register Screen
- **Number:** 02
- **Purpose:** One-time account creation for the studio owner.
- **Navigation source:** Splash Screen (Screen 01) via "Get Started" button
- **Navigates to:**
  - Dashboard (Screen 05) — on successful registration
  - Login (Screen 03) — via "Already have an account? Log In" link

---

## SECTION 2 — UI COMPONENTS

### Text & Labels
- **Screen title:** "Create Account" — top center or app bar
- **Bottom link text:** "Already have an account? Log In"

### Input Fields
| Field | Type | Label | Placeholder | Validation | Keyboard |
|-------|------|-------|-------------|------------|----------|
| Full Name | text | "Full Name" | "Enter your full name" | Required, min 2 chars | text |
| Email | email | "Email Address" | "you@example.com" | Required, valid email format | emailAddress |
| Password | password | "Password" | "Create a password" | Required, min 8 chars, 1 uppercase, 1 number | text |
| Confirm Password | password | "Confirm Password" | "Repeat your password" | Required, must match Password | text |
| Studio Name | text | "Studio Name" | "e.g. Sunset Studio" | Required, min 2 chars | text |
| Studio Location | text | "Studio Location" | "Address (optional)" | Optional | text |

- Each password field has a show/hide toggle icon (eye icon)
- Validation messages shown inline below each field in red

### Buttons
- **"Create Account":** Primary style, full-width, disabled until form is valid
- **"Already have an account? Log In":** Text link, navigates to Login Screen

### Loading States
- Button shows spinner and "Creating Account..." text while submitting
- All fields disabled during submission

### Error States
- Inline field errors: shown below each field on blur or submit attempt
- Server error (e.g. email already exists): shown as a banner above the form or inline under email field
- Network error: toast notification "Network error. Please try again."

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `fullName: String` — current value of full name input
- `email: String` — current value of email input
- `password: String` — current value of password input
- `confirmPassword: String` — current value of confirm password input
- `studioName: String` — current value of studio name input
- `studioAddress: String` — current value of studio address input
- `passwordVisible: bool` — toggle for password field visibility
- `confirmPasswordVisible: bool` — toggle for confirm password field visibility
- `fieldErrors: Map<String, String?>` — per-field validation errors
- `isSubmitting: bool` — true during API call

### Global State (Read)
- None

### Global State (Write)
- `authToken: AuthToken` — stored on successful registration
- `currentUser: User` — user profile returned from registration

### Loading States
- `isSubmitting` — disables form, shows spinner on button

### Error States
- `serverError: String?` — error message from backend (e.g. "Email already registered")
- `fieldErrors` — map of field-level validation errors

### Form Validation
- **Field-level:** Validated on blur and on submit
- **Form-level:** All required fields must be filled and valid; passwords must match

---

## SECTION 4 — DATA MODELS

```
RegisterRequest {
  full_name: String       // required, min 2 chars
  email: String           // required, valid email
  password: String        // required, min 8 chars, 1 uppercase, 1 number
  studio_name: String     // required, min 2 chars
  studio_address: String? // optional
}

RegisterResponse {
  user: User              // created user profile
  access_token: String    // JWT access token
  refresh_token: String   // JWT refresh token
}

User {
  id: UUID
  full_name: String
  email: String
  studio_name: String
  studio_address: String?
  default_price_per_night: Int?
  currency: String
  default_check_in_time: String?
  default_check_out_time: String?
  week_starts_on: String
  notify_before_checkin: Bool
  notify_on_checkout: Bool
  notify_unpaid: Bool
  push_notifications_enabled: Bool
  created_at: DateTime
  updated_at: DateTime
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
POST /api/v1/auth/register
Purpose: Create a new user account
Auth required: no
Request headers: { Content-Type: "application/json" }
Request body: {
  full_name: String       // required
  email: String           // required
  password: String        // required
  studio_name: String     // required
  studio_address: String? // optional
}
Query params: none
Success response (201): {
  data: {
    user: User,
    access_token: String,
    refresh_token: String
  },
  message: "Account created successfully"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error message" } }
  409: { error: "Email already registered" }
  500: { error: "Internal server error" }
When called: on "Create Account" button tap (after client-side validation passes)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/auth/register
Controller: authController.register
Middleware: [validateBody(registerSchema)]

Steps:
1. Parse and validate request body against registerSchema
2. Check if email already exists in users table
3. If email exists, return 409 "Email already registered"
4. Hash password using bcrypt with salt rounds = 12
5. Insert new user into users table with default settings
6. Generate JWT access token (payload: { userId, email }, expires: 7d)
7. Generate JWT refresh token (payload: { userId }, expires: 30d)
8. Return user object (excluding password_hash) + tokens

Database table(s) touched: users
Type of operation: SELECT (email check) + INSERT (create user)

Business rules:
- Email must be unique across all users
- Password is never stored in plain text
- Default settings applied: currency=BGN, week_starts_on=monday, check_in=14:00, check_out=11:00
- Tokens issued immediately (user is logged in after registration)
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
CREATE TABLE users (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name               VARCHAR(255) NOT NULL,
  email                   VARCHAR(255) NOT NULL UNIQUE,
  password_hash           VARCHAR(255) NOT NULL,
  studio_name             VARCHAR(255) NOT NULL,
  studio_address          TEXT,
  default_price_per_night INTEGER,
  currency                VARCHAR(3) DEFAULT 'BGN',
  default_check_in_time   VARCHAR(5) DEFAULT '14:00',
  default_check_out_time  VARCHAR(5) DEFAULT '11:00',
  week_starts_on          VARCHAR(10) DEFAULT 'monday',
  notify_before_checkin   BOOLEAN DEFAULT TRUE,
  notify_on_checkout      BOOLEAN DEFAULT TRUE,
  notify_unpaid           BOOLEAN DEFAULT TRUE,
  push_notifications_enabled BOOLEAN DEFAULT TRUE,
  created_at              TIMESTAMP DEFAULT NOW(),
  updated_at              TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE UNIQUE INDEX idx_users_email ON users(email);
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/register`
- **Route parameters:** none
- **Navigation trigger:** "Get Started" button on Splash Screen
- **Navigation type:** `push` from Splash
- **On success:** `replace` to `/dashboard` (clear auth stack)
- **Deep link path:** none

---

## SECTION 9 — LOCALIZATION STRINGS

```
register_title: "Създай акаунт" / "Create Account"
register_full_name_label: "Пълно име" / "Full Name"
register_full_name_hint: "Въведете пълното си име" / "Enter your full name"
register_email_label: "Имейл адрес" / "Email Address"
register_email_hint: "you@example.com" / "you@example.com"
register_password_label: "Парола" / "Password"
register_password_hint: "Създайте парола" / "Create a password"
register_confirm_password_label: "Потвърди парола" / "Confirm Password"
register_confirm_password_hint: "Повторете паролата" / "Repeat your password"
register_studio_name_label: "Име на студиото" / "Studio Name"
register_studio_name_hint: "напр. Sunset Studio" / "e.g. Sunset Studio"
register_studio_location_label: "Локация на студиото" / "Studio Location"
register_studio_location_hint: "Адрес (по избор)" / "Address (optional)"
register_button: "Създай акаунт" / "Create Account"
register_button_loading: "Създаване на акаунт..." / "Creating Account..."
register_already_have_account: "Вече имате акаунт? Вход" / "Already have an account? Log In"
register_error_name_required: "Името е задължително" / "Name is required"
register_error_name_min: "Името трябва да е поне 2 символа" / "Name must be at least 2 characters"
register_error_email_required: "Имейлът е задължителен" / "Email is required"
register_error_email_invalid: "Невалиден имейл адрес" / "Invalid email address"
register_error_password_required: "Паролата е задължителна" / "Password is required"
register_error_password_min: "Паролата трябва да е поне 8 символа" / "Password must be at least 8 characters"
register_error_password_format: "Паролата трябва да съдържа главна буква и цифра" / "Password must contain an uppercase letter and a number"
register_error_confirm_required: "Потвърдете паролата" / "Please confirm your password"
register_error_confirm_mismatch: "Паролите не съвпадат" / "Passwords do not match"
register_error_studio_required: "Името на студиото е задължително" / "Studio name is required"
register_error_email_exists: "Този имейл вече е регистриран" / "This email is already registered"
register_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    auth/
      presentation/
        screens/
          register_screen.dart          -- main register screen widget
        widgets/
          register_form.dart            -- form with all input fields
          password_field.dart           -- reusable password field with show/hide toggle
        bloc/
          register_bloc.dart            -- registration logic
          register_event.dart           -- SubmitRegistration, ValidateField events
          register_state.dart           -- RegisterInitial, RegisterLoading, RegisterSuccess, RegisterFailure
      data/
        models/
          register_request.dart         -- RegisterRequest model + toJson
          register_response.dart        -- RegisterResponse model + fromJson
        repositories/
          auth_repository.dart          -- register API call (shared with login)
        datasources/
          auth_remote_datasource.dart   -- raw HTTP calls (shared with login)
      domain/
        entities/
          user.dart                     -- User entity (shared)
        usecases/
          register_user.dart            -- register use case
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show toast "Network error. Please try again." — don't clear form
- **Email already registered:** Show inline error under email field "This email is already registered"
- **Empty form submission:** Show all required field errors simultaneously
- **Password mismatch:** Show error under Confirm Password field
- **Weak password:** Show specific guidance (min 8 chars, 1 uppercase, 1 number)
- **Very long input:** Limit Full Name to 255 chars, email to 255 chars, studio name to 255 chars
- **Server error (500):** Show generic error banner "Something went wrong. Please try again."
- **Double-tap submit:** Prevent duplicate submissions by disabling button during loading

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  flutter_secure_storage: ^9.0.0  // store tokens after registration
  email_validator: ^3.0.0         // email format validation

Node.js / Backend:
  bcrypt: ^5.1.0                  // password hashing
  jsonwebtoken: ^9.0.0            // JWT generation
  zod: ^3.22.0                    // request body validation
```
