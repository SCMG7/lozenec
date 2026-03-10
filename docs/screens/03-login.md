# Screen 03 — Login Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Login Screen
- **Number:** 03
- **Purpose:** Authenticate the owner on return visits.
- **Navigation source:** Splash Screen (Screen 01) via "I already have an account" link; Register Screen (Screen 02) via "Already have an account? Log In" link
- **Navigates to:**
  - Dashboard (Screen 05) — on successful login
  - Forgot Password (Screen 04) — via "Forgot Password?" link
  - Register (Screen 02) — via "Don't have an account? Register" link

---

## SECTION 2 — UI COMPONENTS

### Text & Labels
- **Screen title:** "Welcome Back"
- **Studio name or logo:** Displayed above the form
- **Bottom link:** "Don't have an account? Register"

### Input Fields
| Field | Type | Label | Placeholder | Validation | Keyboard |
|-------|------|-------|-------------|------------|----------|
| Email | email | "Email Address" | "you@example.com" | Required, valid email | emailAddress |
| Password | password | "Password" | "Enter your password" | Required | text |

- Password field has show/hide toggle icon

### Interactive Elements
- **"Remember me" checkbox:** Keeps session alive (stores refresh token permanently vs. session-only)
- **"Forgot Password?" link:** Text link, navigates to Forgot Password Screen
- **"Log In" button:** Primary style, full-width

### Error States
- **Invalid credentials:** Error message shown above the button: "Invalid email or password"
- **Field errors:** Inline below each field
- **Network error:** Toast notification

### Loading States
- Button shows spinner and "Logging in..." during API call
- All fields disabled during submission

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `email: String`
- `password: String`
- `passwordVisible: bool`
- `rememberMe: bool` — defaults to false
- `fieldErrors: Map<String, String?>`
- `isSubmitting: bool`
- `serverError: String?`

### Global State (Read)
- None

### Global State (Write)
- `authToken: AuthToken` — stored on successful login
- `currentUser: User` — user profile from login response

### Loading States
- `isSubmitting` — disables form, shows spinner

### Error States
- `serverError` — "Invalid email or password" or network error

### Form Validation
- **Field-level:** email required + valid format, password required
- **Form-level:** Both fields must be filled

---

## SECTION 4 — DATA MODELS

```
LoginRequest {
  email: String           // required, valid email
  password: String        // required
  remember_me: Bool       // optional, defaults to false
}

LoginResponse {
  user: User              // user profile
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
POST /api/v1/auth/login
Purpose: Authenticate user and return tokens
Auth required: no
Request headers: { Content-Type: "application/json" }
Request body: {
  email: String       // required
  password: String    // required
}
Query params: none
Success response (200): {
  data: {
    user: User,
    access_token: String,
    refresh_token: String
  },
  message: "Login successful"
}
Error responses:
  400: { error: "Validation failed", details: { field: "error message" } }
  401: { error: "Invalid email or password" }
  500: { error: "Internal server error" }
When called: on "Log In" button tap
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/auth/login
Controller: authController.login
Middleware: [validateBody(loginSchema)]

Steps:
1. Parse and validate request body
2. Query users table for user with matching email
3. If no user found, return 401 "Invalid email or password"
4. Compare provided password with stored password_hash using bcrypt
5. If password doesn't match, return 401 "Invalid email or password"
6. Generate JWT access token (payload: { userId, email }, expires: 7d)
7. Generate JWT refresh token (payload: { userId }, expires: 30d)
8. Return user object (excluding password_hash) + tokens

Database table(s) touched: users
Type of operation: SELECT

Business rules:
- Same error message for "email not found" and "wrong password" (prevents email enumeration)
- Tokens issued with configurable expiry from env JWT_EXPIRES_IN
- Password comparison uses constant-time bcrypt.compare
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses the same users table as Screen 01/02
-- No additional tables needed for login

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

- **Route name:** `/login`
- **Route parameters:** none
- **Navigation trigger:** "I already have an account" on Splash, "Already have an account?" on Register
- **Navigation type:** `push` from Splash/Register
- **On success:** `replace` to `/dashboard` (clear auth stack)
- **Deep link path:** none

---

## SECTION 9 — LOCALIZATION STRINGS

```
login_title: "Добре дошли отново" / "Welcome Back"
login_email_label: "Имейл адрес" / "Email Address"
login_email_hint: "you@example.com" / "you@example.com"
login_password_label: "Парола" / "Password"
login_password_hint: "Въведете паролата си" / "Enter your password"
login_remember_me: "Запомни ме" / "Remember me"
login_button: "Вход" / "Log In"
login_button_loading: "Влизане..." / "Logging in..."
login_forgot_password: "Забравена парола?" / "Forgot Password?"
login_no_account: "Нямате акаунт? Регистрация" / "Don't have an account? Register"
login_error_email_required: "Имейлът е задължителен" / "Email is required"
login_error_email_invalid: "Невалиден имейл адрес" / "Invalid email address"
login_error_password_required: "Паролата е задължителна" / "Password is required"
login_error_invalid_credentials: "Невалиден имейл или парола" / "Invalid email or password"
login_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    auth/
      presentation/
        screens/
          login_screen.dart             -- main login screen widget
        widgets/
          login_form.dart               -- form with email/password fields
        bloc/
          login_bloc.dart               -- login logic
          login_event.dart              -- SubmitLogin, ValidateField events
          login_state.dart              -- LoginInitial, LoginLoading, LoginSuccess, LoginFailure
      data/
        models/
          login_request.dart            -- LoginRequest model + toJson
          login_response.dart           -- LoginResponse model + fromJson
        repositories/
          auth_repository.dart          -- login API call (shared with register)
        datasources/
          auth_remote_datasource.dart   -- raw HTTP calls (shared)
      domain/
        usecases/
          login_user.dart               -- login use case
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show toast "Network error. Please try again."
- **Invalid credentials:** Generic message "Invalid email or password" (no distinction between wrong email and wrong password)
- **Empty form submission:** Show inline errors for all required fields
- **Remember me unchecked:** Token stored only in memory (lost on app kill)
- **Remember me checked:** Token stored in secure storage (persists across restarts)
- **Account not found:** Same 401 message as wrong password
- **Server error (500):** Show generic error banner
- **Double-tap submit:** Prevent duplicate submissions

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  flutter_secure_storage: ^9.0.0  // token persistence
  email_validator: ^3.0.0         // email validation

Node.js / Backend:
  bcrypt: ^5.1.0                  // password comparison
  jsonwebtoken: ^9.0.0            // JWT generation
  zod: ^3.22.0                    // request validation
```
