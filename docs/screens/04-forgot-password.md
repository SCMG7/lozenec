# Screen 04 — Forgot Password Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Forgot Password Screen
- **Number:** 04
- **Purpose:** Allow the owner to reset their password via email.
- **Navigation source:** Login Screen (Screen 03) via "Forgot Password?" link
- **Navigates to:**
  - Login (Screen 03) — via "Back to Login" link

---

## SECTION 2 — UI COMPONENTS

### Text & Labels
- **Screen title:** "Reset Password"
- **Description text:** "Enter your email and we'll send you a reset link."
- **Confirmation message:** "If this email exists, a reset link has been sent." — shown after successful submission

### Input Fields
| Field | Type | Label | Placeholder | Validation | Keyboard |
|-------|------|-------|-------------|------------|----------|
| Email | email | "Email Address" | "you@example.com" | Required, valid email | emailAddress |

### Buttons
- **"Send Reset Link":** Primary style, full-width
- **"Back to Login":** Text link

### Loading States
- Button shows spinner during API call

### Error States
- Inline field error for invalid email
- Network error: toast notification

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `email: String`
- `isSubmitting: bool`
- `isSubmitted: bool` — true after successful API call (shows confirmation message)
- `fieldError: String?` — email validation error

### Global State (Read/Write)
- None

### Loading States
- `isSubmitting` — spinner on button

### Error States
- `fieldError` — inline email validation
- Network error — toast

### Form Validation
- Email: required, valid format

---

## SECTION 4 — DATA MODELS

```
ForgotPasswordRequest {
  email: String  // required, valid email
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
POST /api/v1/auth/forgot-password
Purpose: Send a password reset link to the user's email
Auth required: no
Request headers: { Content-Type: "application/json" }
Request body: {
  email: String  // required
}
Query params: none
Success response (200): {
  data: null,
  message: "If this email exists, a reset link has been sent."
}
Error responses:
  400: { error: "Validation failed", details: { email: "Invalid email" } }
  500: { error: "Internal server error" }
When called: on "Send Reset Link" button tap
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/auth/forgot-password
Controller: authController.forgotPassword
Middleware: [validateBody(forgotPasswordSchema)]

Steps:
1. Parse and validate request body
2. Query users table for user with matching email
3. If user found:
   a. Generate a password reset token (random UUID or crypto.randomBytes)
   b. Store token + expiry (1 hour) in password_reset_tokens table
   c. Send reset email with link containing token (e.g., via SendGrid/Nodemailer)
4. If user NOT found: do nothing (don't reveal whether email exists)
5. Always return 200 with same message regardless of whether email was found

Database table(s) touched: users (SELECT), password_reset_tokens (INSERT)
Type of operation: SELECT + INSERT

Business rules:
- Always return success message regardless of email existence (prevents enumeration)
- Reset token expires after 1 hour
- Previous unused tokens for same email are invalidated
- Rate limit: max 3 requests per email per hour
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
CREATE TABLE password_reset_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token       VARCHAR(255) NOT NULL UNIQUE,
  expires_at  TIMESTAMP NOT NULL,
  used        BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_reset_tokens_token ON password_reset_tokens(token);
  CREATE INDEX idx_reset_tokens_user_id ON password_reset_tokens(user_id);
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/forgot-password`
- **Route parameters:** none
- **Navigation trigger:** "Forgot Password?" link on Login Screen
- **Navigation type:** `push` from Login
- **"Back to Login":** `pop` back to Login
- **Deep link path:** none

---

## SECTION 9 — LOCALIZATION STRINGS

```
forgot_title: "Нулиране на парола" / "Reset Password"
forgot_description: "Въведете имейла си и ще ви изпратим линк за нулиране." / "Enter your email and we'll send you a reset link."
forgot_email_label: "Имейл адрес" / "Email Address"
forgot_email_hint: "you@example.com" / "you@example.com"
forgot_button: "Изпрати линк за нулиране" / "Send Reset Link"
forgot_button_loading: "Изпращане..." / "Sending..."
forgot_success: "Ако този имейл съществува, линк за нулиране е изпратен." / "If this email exists, a reset link has been sent."
forgot_back_to_login: "Назад към Вход" / "Back to Login"
forgot_error_email_required: "Имейлът е задължителен" / "Email is required"
forgot_error_email_invalid: "Невалиден имейл адрес" / "Invalid email address"
forgot_error_network: "Мрежова грешка. Опитайте отново." / "Network error. Please try again."
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    auth/
      presentation/
        screens/
          forgot_password_screen.dart   -- main forgot password screen
        bloc/
          forgot_password_bloc.dart     -- forgot password logic
          forgot_password_event.dart    -- SubmitForgotPassword event
          forgot_password_state.dart    -- Initial, Loading, Success, Failure
      data/
        models/
          forgot_password_request.dart  -- request model
        repositories/
          auth_repository.dart          -- shared auth repo (add forgotPassword method)
        datasources/
          auth_remote_datasource.dart   -- shared (add forgotPassword method)
      domain/
        usecases/
          forgot_password.dart          -- forgot password use case
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show toast "Network error. Please try again."
- **Email not registered:** Same success response — no way for attacker to enumerate emails
- **Empty email submission:** Show inline error
- **Repeated submissions:** Rate limit on backend (3/hour/email); frontend disables button after success and shows confirmation
- **Reset token already sent:** Backend invalidates old tokens, sends new one
- **Server error:** Show generic error toast

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  email_validator: ^3.0.0         // email validation

Node.js / Backend:
  nodemailer: ^6.9.0              // sending reset emails
  crypto: (built-in)              // generating reset tokens
  zod: ^3.22.0                    // request validation
```
