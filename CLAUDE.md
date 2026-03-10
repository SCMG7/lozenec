# MASTER PROMPT — Beach Studio Rental App
# Paste this entire file as your first message to Claude CLI (claude --prompt or in CLAUDE.md)

---

You are a senior full-stack mobile developer. Your job is to fully design and implement a personal beach studio rental management app from a specification file.

The project folder already contains: `studio-app-spec.md`

You will execute this work in **three sequential phases**. Do NOT skip phases. Do NOT start a phase until the previous one is fully complete.

---

## PHASE 1 — GENERATE 18 SCREEN SPECIFICATION FILES

Read `studio-app-spec.md` in full before doing anything else.

Then generate **18 separate Markdown files**, one per screen listed in the spec. Name them exactly:

```
docs/screens/01-splash-welcome.md
docs/screens/02-register.md
docs/screens/03-login.md
docs/screens/04-forgot-password.md
docs/screens/05-dashboard.md
docs/screens/06-calendar.md
docs/screens/07-reservation-bottom-sheet.md
docs/screens/08-add-reservation.md
docs/screens/09-edit-reservation.md
docs/screens/10-reservation-detail.md
docs/screens/11-guest-list.md
docs/screens/12-guest-detail.md
docs/screens/13-add-edit-guest.md
docs/screens/14-expenses.md
docs/screens/15-add-edit-expense.md
docs/screens/16-analytics.md
docs/screens/17-settings.md
docs/screens/18-notifications.md
```

### Each screen MD file MUST contain ALL of the following sections:

---

#### SECTION 1 — SCREEN OVERVIEW
- Screen name and number
- Purpose in one sentence
- Who triggers navigation to this screen and from where
- What screen this screen can navigate to

#### SECTION 2 — UI COMPONENTS
List every single UI element on the screen:
- Input fields (type, label, placeholder, validation rules, keyboard type)
- Buttons (label, action, primary/secondary/destructive style)
- Text labels and headings
- Lists / cards / rows (every field shown per item)
- Bottom sheets, modals, dialogs (content and triggers)
- Icons, badges, status indicators
- Charts or visual elements (type, data source)
- Empty states (message + CTA)
- Loading states (skeleton / spinner placement)
- Error states (inline vs toast vs dialog)

#### SECTION 3 — STATE MANAGEMENT
- List every piece of local state this screen owns
- List every piece of global state this screen reads or writes
- Loading states (initial load, submit, refresh)
- Error states
- Form validation state (field-level + form-level)

#### SECTION 4 — DATA MODELS
Define every data model used on this screen as a typed schema:

```
ModelName {
  field_name: Type  // description, constraints
}
```

Include:
- All models read on this screen
- All models written or mutated on this screen
- Enums and their allowed values

#### SECTION 5 — API CALLS (FRONTEND → BACKEND)

For every API call this screen makes, document:

```
METHOD /api/v1/endpoint
Purpose: what this call does
Auth required: yes/no
Request headers: { key: value }
Request body: { field: type // description }
Query params: ?param=type
Success response (200/201): { field: type }
Error responses:
  400: { error: "message" } // when
  401: { error: "Unauthorized" } // when
  404: { error: "Not found" } // when
  409: { error: "Conflict" } // when (e.g. overlapping reservations)
  500: { error: "Internal server error" }
When called: (on mount / on submit / on user action)
```

#### SECTION 6 — BACKEND IMPLEMENTATION

For every API endpoint used by this screen, describe the full backend implementation:

```
ENDPOINT: METHOD /api/v1/path
Controller: controllerName.functionName
Middleware: [authMiddleware, validateBody(schema), ...]

Steps:
1. Validate JWT token from Authorization header
2. Parse and validate request body/params
3. [describe every business logic step]
4. Query database (describe exact query logic)
5. Return response

Database table(s) touched: table_name
Type of operation: SELECT / INSERT / UPDATE / DELETE

Business rules:
- Rule 1 (e.g. "Check for overlapping reservations before insert")
- Rule 2
- Rule 3
```

#### SECTION 7 — DATABASE SCHEMA

List every database table touched by this screen:

```sql
CREATE TABLE table_name (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_name    TYPE NOT NULL,     -- description
  ...
  created_at    TIMESTAMP DEFAULT NOW(),
  updated_at    TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_table_field ON table_name(field_name);

Relationships:
  table_name.foreign_key → other_table.id (type: many-to-one)
```

#### SECTION 8 — NAVIGATION & ROUTING

- Route name / path (Flutter named route)
- Route parameters passed in (name, type, required/optional)
- Navigation trigger (button tap / swipe / auto-redirect)
- Navigation type (push / replace / pop / modal)
- Deep link path if applicable (e.g. `/reservation/:id`)

#### SECTION 9 — LOCALIZATION STRINGS

List every user-facing string on this screen that needs translation, as key-value pairs:

```
// lib/l10n/
screen_title: "Резервации" / "Reservations"
button_save: "Запази" / "Save"
error_required: "Полето е задължително" / "Field is required"
... (every string, BG first, EN second)
```

#### SECTION 10 — FLUTTER FILE STRUCTURE

List every file that should be created for this screen:

```
lib/
  features/
    screen_name/
      presentation/
        screens/
          screen_name_screen.dart       -- main screen widget
        widgets/
          widget_one.dart               -- describe purpose
          widget_two.dart               -- describe purpose
        bloc/ (or provider/riverpod)
          screen_bloc.dart              -- events, states
          screen_event.dart
          screen_state.dart
      data/
        models/
          model_name.dart               -- data model + fromJson/toJson
        repositories/
          screen_repository.dart        -- API call implementations
        datasources/
          screen_remote_datasource.dart -- raw HTTP calls
      domain/
        entities/
          entity_name.dart
        usecases/
          use_case_name.dart
```

#### SECTION 11 — EDGE CASES & VALIDATION RULES

List every edge case that must be handled:
- What happens if the network is offline?
- What happens if the user submits an empty form?
- What happens with overlapping reservation dates?
- What happens if a guest has no reservations yet?
- What happens if data fails to load?
- Any other screen-specific edge cases

#### SECTION 12 — DEPENDENCIES & PACKAGES

List any Flutter packages or Node.js packages specifically needed for this screen (beyond the global setup). Format:

```
Flutter:
  package_name: ^version  // why it's needed

Node.js / Backend:
  package_name: ^version  // why it's needed
```

---

After generating all 18 files, write a summary file at:
`docs/screens/00-CROSS-CHECK.md`

This file must:
- List all shared data models and confirm they are defined consistently across all screen files
- List all API endpoints across all 18 screens and flag any duplicates or conflicts
- Confirm navigation graph is complete and consistent (no screens that can't be reached, no dead ends)
- List the full database schema by combining all tables from all screen files, deduplicated and merged
- Flag any inconsistencies found and propose resolutions
- Confirm localization key naming is consistent across all files
- Give a green light ✅ or flag ⚠️ for each screen file before Phase 3 begins

Do NOT proceed to Phase 2 until all 19 files (18 screens + 00-CROSS-CHECK.md) are written.

---

## PHASE 2 — PROJECT SETUP

Only begin Phase 2 after all Phase 1 files are written and 00-CROSS-CHECK.md shows no unresolved ⚠️ flags.

### 2A — Flutter Project Initialization

Run the following setup steps:

1. Create Flutter project: `flutter create studio_rental --org com.studioapp --platforms android,ios`
2. Set up folder structure under `lib/` following the feature-first architecture described in the screen files
3. Add all required packages to `pubspec.yaml` (consolidate from all screen dependency sections)
4. Set up `flutter_localizations` and `intl` for i18n
5. Create `lib/l10n/app_bg.arb` (Bulgarian — **default locale**) and `lib/l10n/app_en.arb` (English)
6. Populate both ARB files with ALL localization keys collected from all 18 screen files
7. Set `bg` as the default and fallback locale in `MaterialApp`
8. Create `lib/core/` with:
   - `constants/app_colors.dart` — color palette
   - `constants/app_text_styles.dart` — typography
   - `constants/app_routes.dart` — all named routes
   - `constants/app_strings.dart` — non-translatable constants
   - `network/api_client.dart` — base HTTP client with auth header injection
   - `network/api_endpoints.dart` — all endpoint constants
   - `network/interceptors/auth_interceptor.dart` — JWT attach + 401 refresh
   - `storage/secure_storage.dart` — wrapper for JWT and user prefs
   - `theme/app_theme.dart` — light theme definition
   - `widgets/` — shared widgets used across screens (loading spinner, error state, empty state, custom bottom sheet, status badge)
9. Set up global state management (BLoC or Riverpod — pick one and use it consistently across all screens)
10. Set up the main navigation shell with bottom navigation bar (5 tabs: Home, Calendar, Guests, Analytics, Settings)
11. Set up dependency injection (get_it + injectable recommended)
12. Create `lib/main.dart` wiring everything together

### 2B — Backend Project Initialization

In a folder `backend/` at the root of the project:

1. Initialize Node.js project: `npm init -y`
2. Set up Express.js with TypeScript
3. Add all required packages to `package.json` (consolidate from all screen dependency sections)
4. Create folder structure:
```
backend/
  src/
    config/
      db.ts           -- PostgreSQL connection (pg or Prisma)
      env.ts          -- environment variable validation
    middleware/
      auth.ts         -- JWT verification middleware
      validate.ts     -- request body validation middleware
      errorHandler.ts -- global error handler
    modules/
      auth/
        auth.controller.ts
        auth.routes.ts
        auth.service.ts
      reservations/
        reservations.controller.ts
        reservations.routes.ts
        reservations.service.ts
      guests/
        guests.controller.ts
        guests.routes.ts
        guests.service.ts
      expenses/
        expenses.controller.ts
        expenses.routes.ts
        expenses.service.ts
      analytics/
        analytics.controller.ts
        analytics.routes.ts
        analytics.service.ts
      notifications/
        notifications.controller.ts
        notifications.routes.ts
        notifications.service.ts
    utils/
      asyncHandler.ts
      ApiError.ts
      dateHelpers.ts
    app.ts
    server.ts
  prisma/
    schema.prisma     -- full schema from 00-CROSS-CHECK.md consolidated tables
  .env.example
  railway.toml        -- Railway deployment config
  Dockerfile          -- optional but include
```
5. Create `prisma/schema.prisma` using the full merged database schema from `00-CROSS-CHECK.md`
6. Run `npx prisma generate`
7. Create `.env.example` with all required env vars:
```
DATABASE_URL=
JWT_SECRET=
JWT_EXPIRES_IN=7d
PORT=3000
NODE_ENV=development
```
8. Create `railway.toml`:
```toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "npx prisma migrate deploy && node dist/server.js"
restartPolicyType = "on-failure"
restartPolicyMaxRetries = 3
```
9. Add npm scripts: `dev`, `build`, `start`, `migrate`, `studio`
10. Confirm the backend runs locally with `npm run dev` before proceeding

Do NOT proceed to Phase 3 until both Flutter and backend projects initialize without errors.

---

## PHASE 3 — SCREEN-BY-SCREEN IMPLEMENTATION

Only begin Phase 3 after Phase 2 is fully complete with no errors.

### Rules for Phase 3:

- Work through screens **strictly in order**: 01 → 02 → 03 → ... → 18
- For each screen, implement **both the Flutter frontend AND the backend endpoints** for that screen before moving to the next
- After completing each screen, run a **self-check**:
  - All UI components from the screen spec are present
  - All API calls are implemented and connected
  - All localization strings are in both ARB files
  - All edge cases from the spec are handled
  - Navigation to/from this screen works
  - No hardcoded strings (use l10n keys)
  - No hardcoded colors or text styles (use theme/constants)
  - Only when self-check passes: move to the next screen
- Never touch a screen that hasn't been reached yet in the sequence
- Never refactor a completed screen unless a later screen reveals a genuine conflict

### For each screen, the implementation order is:
1. Backend: Prisma migration (if new table needed)
2. Backend: Service layer (business logic)
3. Backend: Controller (request/response handling)
4. Backend: Routes (register endpoints)
5. Flutter: Data model (fromJson/toJson)
6. Flutter: Remote datasource (raw API calls)
7. Flutter: Repository (interface + implementation)
8. Flutter: Use cases
9. Flutter: BLoC/Provider (events, states, logic)
10. Flutter: UI widgets (bottom-up: small widgets first)
11. Flutter: Screen widget (compose widgets, wire BLoC)
12. Flutter: Register route in `app_routes.dart`
13. Flutter: Add/verify all l10n strings in both ARB files
14. Self-check → proceed to next screen

---

## GLOBAL RULES (apply to all phases)

- **No placeholder code.** Every file must be fully implemented, not stubbed.
- **No TODO comments** left in final code unless they are explicitly listed in the screen spec as out-of-scope.
- **No hardcoded credentials, URLs, or secrets.** Use `.env` on the backend and `flutter_dotenv` or `--dart-define` on Flutter.
- **JWT authentication** must be enforced on every backend endpoint except: POST /api/v1/auth/register and POST /api/v1/auth/login.
- **Error handling** must be consistent: backend always returns `{ error: string, details?: any }` on failure; Flutter always shows user-facing error messages using l10n strings.
- **Date handling**: always store dates as UTC ISO 8601 strings in the database and API; convert to local time only in the Flutter UI layer.
- **Currency**: store all monetary values as integers (cents/stotinki) in the database; divide by 100 only in the display layer.
- **Overlapping reservation check**: always enforce on the backend, not just the frontend.
- The backend API base path is `/api/v1/`
- All backend responses use consistent envelope: `{ data: T, message?: string }` for success and `{ error: string }` for failure.
- Flutter minimum SDK: 3.x (null-safe, no legacy code)
- Backend Node.js minimum: 20.x

---

## HOW TO START

Run this command to begin:

```
Read the file studio-app-spec.md in full, then begin Phase 1.
Create the docs/screens/ folder and generate all 18 screen MD files followed by 00-CROSS-CHECK.md.
Confirm completion of all 19 files before asking me anything.
```