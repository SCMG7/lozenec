`# Screen 01 — Welcome / Splash Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Welcome / Splash Screen
- **Number:** 01
- **Purpose:** App entry point shown briefly on launch; directs user to authentication or main app.
- **Navigation source:** App launch (cold start or resume)
- **Navigates to:**
  - Dashboard (Screen 05) — if user is already authenticated
  - Register (Screen 02) — via "Get Started" button
  - Login (Screen 03) — via "I already have an account" link

---

## SECTION 2 — UI COMPONENTS

### Visual Elements
- **App Logo / Icon:** Centered on screen, large, decorative
- **App Name Text:** "My Studio" — centered below logo, large bold font
- **Tagline Text:** "Your rental, organized." — centered below app name, smaller muted font

### Buttons
- **"Get Started" button:** Primary style, full-width, navigates to Register Screen
- **"I already have an account" link:** Text link, secondary style, navigates to Login Screen

### Loading States
- **Authentication check spinner:** Brief loading indicator shown while checking stored JWT token validity
- If token is valid → auto-redirect to Dashboard (no buttons shown)
- If token is invalid/missing → show Get Started button and Login link

### Error States
- No explicit error states — if token check fails, treat as unauthenticated

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `isCheckingAuth: bool` — true while verifying stored JWT token
- `isAuthenticated: bool` — result of token check

### Global State (Read)
- `authToken: String?` — stored JWT token from secure storage
- `currentUser: User?` — user profile if authenticated

### Global State (Write)
- None (read-only on this screen)

### Loading States
- Initial load: checking authentication status (brief spinner)

### Error States
- None — failed auth check simply shows the unauthenticated view

### Form Validation
- No forms on this screen

---

## SECTION 4 — DATA MODELS

```
User {
  id: UUID                  // unique user identifier
  full_name: String         // user's display name
  email: String             // user's email address
  studio_name: String       // name of the studio
  studio_address: String?   // optional studio address
  default_price_per_night: Int?  // default price in cents/stotinki
  currency: String          // currency code (BGN, EUR, USD, GBP)
  default_check_in_time: String?  // HH:mm format
  default_check_out_time: String? // HH:mm format
  week_starts_on: String    // "sunday" or "monday"
  notify_before_checkin: Bool
  notify_on_checkout: Bool
  notify_unpaid: Bool
  push_notifications_enabled: Bool
  created_at: DateTime
  updated_at: DateTime
}

AuthToken {
  access_token: String      // JWT access token
  refresh_token: String     // JWT refresh token
  expires_at: DateTime      // token expiry timestamp
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
POST /api/v1/auth/verify-token
Purpose: Verify if the stored JWT token is still valid
Auth required: yes (sends stored token)
Request headers: { Authorization: "Bearer <token>" }
Request body: none
Query params: none
Success response (200): { data: { user: User } }
Error responses:
  401: { error: "Token expired or invalid" }
  500: { error: "Internal server error" }
When called: on app mount (splash screen load)
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: POST /api/v1/auth/verify-token
Controller: authController.verifyToken
Middleware: [authMiddleware]

Steps:
1. Extract JWT token from Authorization header
2. Verify token signature and expiry using JWT_SECRET
3. Decode user ID from token payload
4. Query database for user by ID
5. If user exists and is active, return user data
6. If user not found, return 401

Database table(s) touched: users
Type of operation: SELECT

Business rules:
- Token must not be expired
- User must exist in the database
- Returns full user profile for hydrating client state
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
  default_price_per_night INTEGER,          -- in cents/stotinki
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

Relationships:
  users.id → reservations.user_id (one-to-many)
  users.id → guests.user_id (one-to-many)
  users.id → expenses.user_id (one-to-many)
  users.id → notifications.user_id (one-to-many)
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/splash`
- **Route path:** `/`
- **Route parameters:** none
- **Navigation trigger:** App launch
- **Navigation type:**
  - If authenticated → `replace` to `/dashboard`
  - "Get Started" tap → `push` to `/register`
  - "I already have an account" tap → `push` to `/login`
- **Deep link path:** none (root route)

---

## SECTION 9 — LOCALIZATION STRINGS

```
// lib/l10n/
splash_app_name: "My Studio" / "My Studio"
splash_tagline: "Вашето наемане, организирано." / "Your rental, organized."
splash_get_started: "Започнете" / "Get Started"
splash_already_have_account: "Вече имам акаунт" / "I already have an account"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    splash/
      presentation/
        screens/
          splash_screen.dart            -- main splash/welcome screen widget
        widgets/
          app_logo.dart                 -- logo + name + tagline widget
          auth_action_buttons.dart      -- Get Started + Login link
        bloc/
          splash_bloc.dart              -- auth check logic
          splash_event.dart             -- CheckAuthStatus event
          splash_state.dart             -- SplashInitial, SplashLoading, Authenticated, Unauthenticated
      data/
        repositories/
          auth_repository.dart          -- token verification API call
        datasources/
          auth_remote_datasource.dart   -- raw HTTP call for verify-token
      domain/
        entities/
          user.dart                     -- User entity
        usecases/
          verify_token.dart             -- verify stored token use case
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show unauthenticated view (Get Started / Login) — don't block the user
- **Token expired:** Show unauthenticated view, clear stored token
- **Token valid but user deleted on server:** 401 response, show unauthenticated view, clear stored token
- **No token stored:** Immediately show unauthenticated view (skip API call)
- **Slow network:** Show loading spinner with a 5-second timeout; if timeout, show unauthenticated view
- **App resumed from background:** Do not re-show splash; only shown on cold start

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_secure_storage: ^9.0.0  // storing JWT tokens securely
  flutter_bloc: ^8.1.0            // state management for auth check

Node.js / Backend:
  jsonwebtoken: ^9.0.0            // JWT verification
```
