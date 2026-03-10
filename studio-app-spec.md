# 🏖️ Beach Studio Rental App — Full Screen Specification

---

## APP OVERVIEW

A personal mobile app for managing a single beach studio rental unit. Used by the owner only. Tracks reservations, guests, payments, and expenses. Provides a calendar view, analytics, and full guest history.

---

## SCREENS LIST

1. Welcome / Splash Screen
2. Register Screen
3. Login Screen
4. Forgot Password Screen
5. Home / Dashboard Screen
6. Calendar Screen (Monthly View)
7. Reservation Bottom Sheet (Half-screen popup)
8. Add Reservation Screen
9. Edit Reservation Screen
10. Reservation Detail Screen (Full)
11. Guest List Screen
12. Guest Detail Screen
13. Add / Edit Guest Screen
14. Expenses Screen
15. Add / Edit Expense Screen
16. Analytics Screen
17. Settings Screen
18. Notifications Screen

---

## SCREEN DETAILS

---

### 1. WELCOME / SPLASH SCREEN

**Purpose:** App entry point shown briefly on launch.

**Contents:**
- App logo / icon (centered)
- App name (e.g. "My Studio")
- Tagline (e.g. "Your rental, organized.")
- Auto-redirects to Login if user is already authenticated, or to Welcome if not
- "Get Started" button → goes to Register
- "I already have an account" link → goes to Login

---

### 2. REGISTER SCREEN

**Purpose:** One-time account creation for the owner.

**Contents:**
- Screen title: "Create Account"
- Input: Full Name (text field)
- Input: Email address (text field, keyboard type email)
- Input: Password (text field, hidden, with show/hide toggle)
- Input: Confirm Password (text field, hidden, with show/hide toggle)
- Input: Studio Name (text field — e.g. "Sunset Studio", used across the app)
- Input: Studio Location / Address (optional, text field)
- Button: "Create Account" (primary, full-width)
- Link at bottom: "Already have an account? Log In"
- Validation messages shown inline under each field on error

---

### 3. LOGIN SCREEN

**Purpose:** Authenticate the owner on return visits.

**Contents:**
- Screen title: "Welcome Back"
- Studio name or logo shown above form
- Input: Email address (text field)
- Input: Password (text field, hidden, with show/hide toggle)
- Checkbox: "Remember me" (keeps the session alive)
- Button: "Log In" (primary, full-width)
- Link: "Forgot Password?" → goes to Forgot Password Screen
- Link at bottom: "Don't have an account? Register"
- Error message shown above the button if credentials are wrong

---

### 4. FORGOT PASSWORD SCREEN

**Purpose:** Allow the owner to reset their password via email.

**Contents:**
- Screen title: "Reset Password"
- Short description text: "Enter your email and we'll send you a reset link."
- Input: Email address (text field)
- Button: "Send Reset Link" (primary, full-width)
- Confirmation message shown inline after submission: "If this email exists, a reset link has been sent."
- Link: "Back to Login"

---

### 5. HOME / DASHBOARD SCREEN

**Purpose:** Quick overview of the studio's current status. This is the first screen after login.

**Contents:**
- Top bar: Studio name on the left, avatar/profile icon on the right (taps to Settings)
- Notification bell icon in top bar

**Summary Cards (horizontal scrollable row):**
- Card 1: "Tonight" — shows guest name if occupied, "Free" if not
- Card 2: "This Month" — number of nights booked vs. total nights in the month
- Card 3: "This Month's Revenue" — total income from confirmed reservations
- Card 4: "Occupancy Rate" — percentage of the current month booked

**Upcoming Reservations Section:**
- Section title: "Upcoming Reservations"
- List of the next 5 upcoming reservations, each showing:
  - Guest name
  - Check-in and check-out dates
  - Number of nights
  - Total price
  - Status badge (Confirmed / Pending / Cancelled)
- "See All" link → goes to Guest List screen

**Quick Action Buttons:**
- "＋ New Reservation" button → goes to Add Reservation Screen
- "📅 Open Calendar" button → goes to Calendar Screen
- "📊 Analytics" button → goes to Analytics Screen

**Current Month Mini-Stats (below quick actions):**
- Total revenue this month
- Total expenses this month
- Net profit this month

---

### 6. CALENDAR SCREEN (Monthly View)

**Purpose:** Visual overview of the whole month, day by day, showing which days are booked.

**Contents:**

**Top Bar:**
- Left arrow button: go to previous month
- Right arrow button: go to next month
- Center: Month name + Year (e.g. "June 2025")
- "Today" button: snaps back to the current month

**Calendar Grid:**
- Standard 7-column grid (Mon–Sun or Sun–Sat, configurable in Settings)
- Each day cell shows:
  - Day number
  - Color fill:
    - **Green** = Available (no reservation)
    - **Blue/teal** = Reserved (fully booked that day)
    - **Orange** = Check-in day
    - **Red** = Check-out day
    - **Grey** = Past date
  - If booked: guest's first name displayed inside the cell (abbreviated if needed)
  - Multi-night reservations shown as a continuous colored bar across connected days
- Today's date has a distinct ring or dot indicator
- Tapping any booked day → opens the Reservation Bottom Sheet (half-screen)
- Tapping any free day → shows a small prompt: "Add Reservation?" with a shortcut "＋" button

**Legend (below calendar):**
- Color key: Available / Reserved / Check-in / Check-out / Past

**Bottom of screen:**
- Monthly summary strip:
  - Nights booked: X / Y
  - Revenue: €/$ amount
  - "＋ Add Reservation" floating action button (bottom right)

---

### 7. RESERVATION BOTTOM SHEET (Half-Screen Popup)

**Purpose:** Quick-glance info when tapping a booked date on the calendar. Slides up from the bottom and covers ~50% of the screen.

**Contents:**
- Drag handle at top (pill indicator)
- Guest name (large, bold)
- Status badge: Confirmed / Pending / Cancelled
- Row: Check-in date — Check-out date
- Row: Number of nights
- Row: Price per night | Total price
- Row: Payment status: Paid / Partially Paid / Unpaid
- Short notes preview (first line only, if any notes exist)
- Two action buttons side by side:
  - "View Full Details" → opens Reservation Detail Screen (Full)
  - "Edit" → opens Edit Reservation Screen
- Dismiss: tap outside the sheet or drag it down to close

---

### 8. ADD RESERVATION SCREEN

**Purpose:** Create a new reservation for the studio.

**Contents:**
- Screen title: "New Reservation"
- Back button (top left)

**Guest Section:**
- Search/select existing guest field (autocomplete from saved guests)
- OR button: "＋ Create New Guest" → opens Add Guest modal/screen
- Selected guest shown as a chip/card with name and avatar initial

**Dates Section:**
- Toggle: "Number of Nights" mode OR "Date Range" mode
  - **Nights mode:** 
    - Date picker: Check-in date
    - Number input: How many nights (spinner or text field)
    - Check-out date auto-calculated and displayed (read-only)
  - **Date Range mode:**
    - Date range picker: Check-in → Check-out (calendar-style selector)
    - Number of nights auto-calculated and displayed (read-only)
- Conflict warning shown in red if selected dates overlap with existing reservation

**Pricing Section:**
- Toggle: "Price per Night" OR "Custom Total Price"
  - **Per Night mode:**
    - Input: Price per night (numeric, currency symbol shown)
    - Total auto-calculated and displayed (read-only)
  - **Custom Total mode:**
    - Input: Total price (numeric, currency symbol shown)
    - Per-night equivalent auto-calculated and displayed (read-only)
- Input: Deposit amount (optional, numeric)
- Toggle: Deposit received? (Yes / No)

**Status Section:**
- Dropdown / segmented control: Reservation Status
  - Confirmed
  - Pending
  - Cancelled

**Payment Section:**
- Dropdown: Payment Status
  - Unpaid
  - Partially Paid
  - Paid in Full
- Input: Amount received so far (optional, numeric — shown only if "Partially Paid" selected)

**Notes Section:**
- Text area: Internal notes (free text, e.g. "Brought dog", "Needs late checkout")

**Action Buttons:**
- "Save Reservation" (primary, full-width)
- "Cancel" (secondary, text link)

---

### 9. EDIT RESERVATION SCREEN

**Purpose:** Modify an existing reservation.

**Contents:**
- Identical layout to Add Reservation Screen
- All existing data pre-filled in every field
- Screen title: "Edit Reservation"
- Additional section at the bottom:
  - "Delete Reservation" button (destructive, shown in red)
  - Tapping delete shows a confirmation dialog: "Are you sure? This cannot be undone." with Cancel / Delete buttons
- "Save Changes" button (primary, full-width)

---

### 10. RESERVATION DETAIL SCREEN (Full)

**Purpose:** Complete view of a single reservation with all information.

**Contents:**
- Top bar: "Reservation Details" title, Edit button (top right), Back button (top left)
- Guest name (large)
- Guest contact info (phone, email if added)
- Status badge
- Divider

**Dates & Duration:**
- Check-in date and time (if applicable)
- Check-out date and time (if applicable)
- Total nights

**Financial:**
- Price per night
- Total price
- Deposit amount
- Amount paid
- Amount remaining (auto-calculated, shown in red if > 0)
- Payment status badge

**Notes:**
- Full notes text

**History / Activity Log (optional):**
- Simple timestamped list of changes made to this reservation (e.g. "Status changed to Confirmed — Jun 3, 2025")

**Action Buttons:**
- "Edit Reservation" (primary)
- "Mark as Paid" shortcut button (if not fully paid)
- "Delete Reservation" (destructive, red text button at bottom)

---

### 11. GUEST LIST SCREEN

**Purpose:** View all guests who have ever stayed or are scheduled to stay.

**Contents:**
- Screen title: "Guests"
- Search bar at top (search by name, phone, email)
- Filter tabs: All | Upcoming | Past | Cancelled
- Sort options (dropdown or icon): Name A–Z / Most Recent / Most Nights Stayed
- Guest list, each row showing:
  - Avatar circle with initials
  - Full name
  - Last stay date or upcoming stay date
  - Total number of stays
  - Arrow icon (taps to Guest Detail)
- Empty state message if no guests: "No guests yet. Add your first reservation."
- Floating "＋" button: Add new guest directly

---

### 12. GUEST DETAIL SCREEN

**Purpose:** Full profile of a single guest and their reservation history.

**Contents:**
- Top bar: Guest name, Edit button (top right), Back button (top left)
- Avatar circle with initials (large, centered)
- Full name (large)
- Contact info section:
  - Phone number (tappable → opens dialer)
  - Email (tappable → opens email client)
  - Nationality (optional)
- Stats row:
  - Total stays
  - Total nights
  - Total revenue from this guest
- Notes about guest (e.g. "Prefers early check-in", "Repeat guest")
- Divider
- **Reservation History section:**
  - List of all past and future reservations for this guest
  - Each item: dates, nights, total price, status badge
  - Tapping any item → goes to Reservation Detail Screen
- "Delete Guest" button at bottom (destructive, red — with confirmation dialog)

---

### 13. ADD / EDIT GUEST SCREEN

**Purpose:** Create a new guest profile or edit an existing one.

**Contents:**
- Screen title: "New Guest" or "Edit Guest"
- Input: First Name (text field)
- Input: Last Name (text field)
- Input: Phone Number (numeric/phone field, with country code selector)
- Input: Email Address (text field, optional)
- Input: Nationality (text field or country picker, optional)
- Input: ID / Passport Number (text field, optional — useful for legal compliance)
- Text area: Guest notes (free text, e.g. "Quiet guest", "Has a dog")
- "Save Guest" button (primary, full-width)
- "Cancel" link

---

### 14. EXPENSES SCREEN

**Purpose:** Track all money spent on the studio (maintenance, renovation, cleaning, bills, etc.)

**Contents:**
- Screen title: "Expenses"
- Month selector at top (left/right arrows or dropdown): shows expenses for selected month
- Summary card at top:
  - Total expenses for selected month
  - Largest single expense
  - Number of expense entries
- Filter by Category (horizontal scrollable chips): All | Maintenance | Renovation | Utilities | Cleaning | Supplies | Other
- Expense list, each row showing:
  - Category icon
  - Expense title / description
  - Date
  - Amount (in red)
  - Arrow to detail
- Total at the bottom of the list
- Floating "＋" button: Add new expense
- Empty state: "No expenses recorded for this month."

---

### 15. ADD / EDIT EXPENSE SCREEN

**Purpose:** Log a new expense or edit an existing one.

**Contents:**
- Screen title: "New Expense" or "Edit Expense"
- Input: Title / Description (text field, e.g. "Plumber repair", "New bedding")
- Input: Amount (numeric field, currency symbol)
- Date picker: Date of expense (defaults to today)
- Dropdown: Category
  - Maintenance
  - Renovation
  - Utilities (water, electricity, internet)
  - Cleaning
  - Supplies
  - Taxes / Fees
  - Other
- Text area: Notes (optional, free text)
- Toggle: Recurring expense? (Yes / No)
  - If Yes: Frequency selector (Monthly / Yearly)
- "Save Expense" button (primary, full-width)
- "Cancel" link
- If editing: "Delete Expense" red button at the bottom

---

### 16. ANALYTICS SCREEN

**Purpose:** Visual summary of the studio's financial performance over time.

**Contents:**
- Screen title: "Analytics"
- Period selector at top: This Month / Last Month / Last 3 Months / Last 6 Months / This Year / Custom Range

**Overview Cards (row of 3):**
- Total Revenue (selected period)
- Total Expenses (selected period)
- Net Profit (Revenue minus Expenses, green if positive / red if negative)

**Occupancy Section:**
- Occupancy rate as a large percentage
- Progress bar showing booked nights vs. available nights
- Booked nights count / Total nights in period

**Revenue Breakdown Chart:**
- Bar chart or line chart showing revenue per month across the selected period
- Each bar broken down by: Confirmed revenue vs. Pending revenue

**Expenses Breakdown:**
- Pie chart or donut chart showing expenses split by category
- List below the chart with each category, its total, and percentage of all expenses

**Reservation Statistics:**
- Average length of stay (nights)
- Average revenue per reservation
- Longest stay
- Most frequent guest (name + number of stays)

**Monthly Comparison Table:**
- Table with columns: Month | Nights Booked | Revenue | Expenses | Net Profit
- Rows for each month in the selected period

**Seasonal Trends (if enough data):**
- Simple chart showing which months historically perform best

---

### 17. SETTINGS SCREEN

**Purpose:** App-wide configuration and account management.

**Contents:**
- Screen title: "Settings"
- Back / close button

**Profile Section:**
- Avatar with edit button
- Display name (tappable to edit)
- Email address (tappable to edit)
- "Change Password" row → opens a sub-screen with: Current Password, New Password, Confirm New Password fields

**Studio Settings Section:**
- Studio Name (editable)
- Studio Address (editable)
- Default price per night (numeric, used as default when creating reservations)
- Currency selector (e.g. BGN, EUR, USD, GBP)
- Default check-in time (time picker)
- Default check-out time (time picker)

**Calendar Settings:**
- Week starts on: Sunday / Monday (toggle)
- Color theme for reserved days (color picker with presets)

**Notifications Section:**
- Toggle: Enable push notifications
- Toggle: Notify me 1 day before check-in
- Toggle: Notify me on check-out day
- Toggle: Notify me for upcoming unpaid reservations

**Data Section:**
- "Export Data" button → exports all reservations and expenses as a CSV or PDF report
- "Clear All Data" (destructive, red — requires typed confirmation)

**About Section:**
- App version
- "Rate the App" link
- "Privacy Policy" link
- "Terms of Use" link

**Logout Button:**
- Full-width, at the very bottom, styled in a neutral/warning color

---

### 18. NOTIFICATIONS SCREEN

**Purpose:** In-app notification history and reminders related to reservations.

**Contents:**
- Screen title: "Notifications"
- Mark all as read button (top right)
- Notification list (newest first), each item showing:
  - Icon (e.g. calendar icon for check-in, money icon for unpaid)
  - Notification text (e.g. "John Doe checks in tomorrow", "Reservation #5 is unpaid")
  - Timestamp (relative: "2 hours ago", "Yesterday")
  - Unread indicator (colored dot on the left)
  - Tapping a notification → navigates to the relevant reservation
- Empty state: "You're all caught up!"
- Pull-to-refresh gesture supported

---

## NAVIGATION STRUCTURE

```
Bottom Navigation Bar (always visible after login):
├── 🏠 Home           → Dashboard Screen
├── 📅 Calendar       → Calendar Screen
├── 👥 Guests         → Guest List Screen
├── 📊 Analytics      → Analytics Screen
└── ⚙️ Settings       → Settings Screen
```

The Expenses screen is accessible from: Dashboard quick links, Analytics screen, and Settings.

The Notifications screen is accessible from: the bell icon on the Dashboard top bar.

---

## BOTTOM SHEET BEHAVIOR (Detail)

- Triggered by tapping a booked day on the Calendar
- Slides up with animation, rests at ~50% screen height
- Background is dimmed (semi-transparent overlay)
- Dragging the sheet further up → expands to full screen (Reservation Detail Screen)
- Dragging down or tapping the dim overlay → dismisses the sheet
- If multiple reservations share the same day (e.g., check-out and check-in on the same day), the sheet shows both as a stacked list with a tab selector at the top: "Check-out" | "Check-in"

---

## KEY UX RULES

- Every list screen has an empty state with a helpful message and a call-to-action button
- Destructive actions (delete) always require a confirmation dialog
- All date/time pickers use the native mobile date picker
- Currency symbol is shown next to every price field, using the currency set in Settings
- Scrolling in any list is pull-to-refresh capable
- All screens except Login/Register/Forgot Password are protected (require authentication)
- The app works fully offline for viewing existing data; syncing happens when connection is restored (if cloud sync is implemented)
