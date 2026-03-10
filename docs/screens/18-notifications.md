# Screen 18 — Notifications Screen

---

## SECTION 1 — SCREEN OVERVIEW

- **Screen name:** Notifications Screen
- **Number:** 18
- **Purpose:** In-app notification history and reminders related to reservations.
- **Navigation source:** Dashboard (Screen 05) bell icon in top bar
- **Navigates to:**
  - Reservation Detail (Screen 10) — tapping a notification navigates to the relevant reservation

---

## SECTION 2 — UI COMPONENTS

### Top Bar
- **Back button:** Top left
- **Screen title:** "Notifications"
- **"Mark all as read" button:** Top right, text button

### Notification List (newest first)
Each item shows:
- **Icon:** Context-based (calendar icon for check-in, money icon for unpaid, etc.)
- **Notification text:** E.g. "John Doe checks in tomorrow", "Reservation #5 is unpaid"
- **Timestamp:** Relative format ("2 hours ago", "Yesterday", "Jun 5")
- **Unread indicator:** Colored dot on the left (visible only for unread)
- Tapping → navigates to the relevant reservation

### Empty State
- Message: "You're all caught up!"
- Icon: checkmark or bell with line through

### Pull-to-Refresh
- Standard pull-to-refresh gesture

### Loading States
- Skeleton list during initial load

### Error States
- Error with retry

---

## SECTION 3 — STATE MANAGEMENT

### Local State
- `notifications: List<AppNotification>`

### Global State (Read)
- None specifically

### Global State (Write)
- `unreadNotificationCount: Int` — decremented when notifications are read/marked

### Loading States
- `isLoading: bool`
- `isRefreshing: bool`
- `isMarkingAllRead: bool`

### Error States
- `error: String?`

### Form Validation
- No forms

---

## SECTION 4 — DATA MODELS

```
AppNotification {
  id: UUID
  user_id: UUID
  reservation_id: UUID?
  type: NotificationType
  title: String
  body: String
  is_read: Bool
  scheduled_at: DateTime?
  created_at: DateTime
}

enum NotificationType {
  check_in_reminder        // "X checks in tomorrow"
  check_out_reminder       // "X checks out today"
  unpaid_reminder          // "Reservation with X is unpaid"
  status_change            // "Reservation status changed"
  general                  // generic notification
}
```

---

## SECTION 5 — API CALLS (FRONTEND → BACKEND)

```
GET /api/v1/notifications
Purpose: Fetch all notifications for the user
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Query params:
  ?page=1
  &limit=30
Success response (200): {
  data: {
    notifications: List<AppNotification>,
    total: Int,
    unread_count: Int,
    page: Int,
    total_pages: Int
  }
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on screen mount, on pull-to-refresh
```

```
PATCH /api/v1/notifications/:id/read
Purpose: Mark a single notification as read
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: { notification: AppNotification },
  message: "Notification marked as read"
}
Error responses:
  401: { error: "Unauthorized" }
  404: { error: "Notification not found" }
  500: { error: "Internal server error" }
When called: when user taps a notification
```

```
PATCH /api/v1/notifications/mark-all-read
Purpose: Mark all notifications as read
Auth required: yes
Request headers: { Authorization: "Bearer <token>" }
Success response (200): {
  data: null,
  message: "All notifications marked as read"
}
Error responses:
  401: { error: "Unauthorized" }
  500: { error: "Internal server error" }
When called: on "Mark all as read" button tap
```

---

## SECTION 6 — BACKEND IMPLEMENTATION

```
ENDPOINT: GET /api/v1/notifications
Controller: notificationsController.getNotifications
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Query notifications WHERE user_id = userId AND (scheduled_at IS NULL OR scheduled_at <= NOW())
3. Order by created_at DESC
4. Apply pagination
5. Count unread: COUNT WHERE is_read = false
6. Return notifications + counts

Database table(s) touched: notifications
Type of operation: SELECT

Business rules:
- Only show notifications whose scheduled_at has passed (or is null)
- Paginated, newest first
- Unread count returned for badge updates
```

```
ENDPOINT: PATCH /api/v1/notifications/:id/read
Controller: notificationsController.markAsRead
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Parse notification ID
3. Verify notification belongs to user
4. Update is_read = true
5. Return updated notification

Database table(s) touched: notifications (UPDATE)
Type of operation: UPDATE
```

```
ENDPOINT: PATCH /api/v1/notifications/mark-all-read
Controller: notificationsController.markAllAsRead
Middleware: [authMiddleware]

Steps:
1. Extract user ID from JWT
2. Update all notifications WHERE user_id = userId AND is_read = false → SET is_read = true
3. Return success

Database table(s) touched: notifications (UPDATE bulk)
Type of operation: UPDATE
```

---

## SECTION 7 — DATABASE SCHEMA

```sql
-- Uses notifications table (defined in Screen 08)
-- No new tables needed

CREATE TABLE notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reservation_id  UUID REFERENCES reservations(id) ON DELETE CASCADE,
  type            VARCHAR(50) NOT NULL,
  title           VARCHAR(255) NOT NULL,
  body            TEXT NOT NULL,
  is_read         BOOLEAN DEFAULT FALSE,
  scheduled_at    TIMESTAMP,
  created_at      TIMESTAMP DEFAULT NOW()
);

Indexes:
  CREATE INDEX idx_notifications_user_id ON notifications(user_id);
  CREATE INDEX idx_notifications_is_read ON notifications(is_read);
  CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at);
  CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

---

## SECTION 8 — NAVIGATION & ROUTING

- **Route name:** `/notifications`
- **Route parameters:** none
- **Navigation trigger:** Dashboard bell icon tap
- **Navigation type:** `push`
- **Tap notification:** `push` to `/reservation/:id` (if reservation_id exists)
- **Back button:** `pop`
- **Deep link path:** `/notifications`

---

## SECTION 9 — LOCALIZATION STRINGS

```
notifications_title: "Известия" / "Notifications"
notifications_mark_all_read: "Маркирай всички като прочетени" / "Mark all as read"
notifications_empty: "Всичко е наред!" / "You're all caught up!"
notifications_error_load: "Грешка при зареждане на известията" / "Error loading notifications"
notifications_check_in_tomorrow: "{guest} се настанява утре" / "{guest} checks in tomorrow"
notifications_check_out_today: "{guest} напуска днес" / "{guest} checks out today"
notifications_unpaid: "Резервацията с {guest} е неплатена" / "Reservation with {guest} is unpaid"
notifications_status_changed: "Статусът на резервацията е променен" / "Reservation status changed"
notifications_just_now: "Току-що" / "Just now"
notifications_minutes_ago: "Преди {count} мин" / "{count} min ago"
notifications_hours_ago: "Преди {count} часа" / "{count} hours ago"
notifications_yesterday: "Вчера" / "Yesterday"
notifications_days_ago: "Преди {count} дни" / "{count} days ago"
notifications_marked_read: "Всички известия са прочетени" / "All notifications marked as read"
```

---

## SECTION 10 — FLUTTER FILE STRUCTURE

```
lib/
  features/
    notifications/
      presentation/
        screens/
          notifications_screen.dart         -- main notifications screen
        widgets/
          notification_list_tile.dart       -- single notification row
          notification_icon.dart            -- type-based icon selector
          notification_timestamp.dart       -- relative timestamp formatter
          notification_empty_state.dart     -- empty state widget
        bloc/
          notifications_bloc.dart          -- load, mark read, mark all read
          notifications_event.dart         -- LoadNotifications, MarkRead, MarkAllRead
          notifications_state.dart         -- Loading, Loaded, Error
      data/
        models/
          app_notification.dart            -- AppNotification model + fromJson
        repositories/
          notification_repository.dart     -- notification API calls
        datasources/
          notification_remote_datasource.dart
      domain/
        entities/
          app_notification.dart
        usecases/
          get_notifications.dart
          mark_notification_read.dart
          mark_all_notifications_read.dart
```

---

## SECTION 11 — EDGE CASES & VALIDATION RULES

- **Network offline:** Show cached notifications if available; error if not
- **No notifications:** Show "You're all caught up!" empty state
- **All already read:** "Mark all as read" button disabled or hidden
- **Tapping notification with deleted reservation:** Handle 404 gracefully — show toast, keep notification visible
- **Notification without reservation_id:** Don't navigate on tap (or show notification detail inline)
- **Pagination:** Load more on scroll
- **Pull-to-refresh:** Resets to page 1
- **Marking read while offline:** Queue action, sync when online
- **Scheduled notifications not yet due:** Hidden from list (filtered by backend)
- **Very long notification text:** Truncate with ellipsis (2 lines max)

---

## SECTION 12 — DEPENDENCIES & PACKAGES

```
Flutter:
  flutter_bloc: ^8.1.0            // state management
  timeago: ^3.6.0                 // relative timestamp formatting ("2 hours ago")
  intl: ^0.19.0                   // date formatting fallback

Node.js / Backend:
  (no additional packages)
```
