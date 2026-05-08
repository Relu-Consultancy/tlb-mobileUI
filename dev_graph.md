# TLB Mobile UI — Development Graph
**Project:** The Little Broadways (TLB) — Event Booking App  
**Stack:** Flutter (Dart) · Firebase Auth · Google Sign-In · REST API  
**Package:** `com.thelittlebroadway.tlb_mobile_ui`  
**API Base:** `https://tlb-api.reluconsultancy.in`  
**Last Updated:** 2026-05-08 (Session 12)

---

## 1. Project Architecture

```
lib/
├── main.dart                      Entry point — Firebase init, tryRestoreSession(), SplashScreen → HomeScreen
├── core/                          Config/constants only
│   ├── app_colors.dart            Centralized color constants
│   ├── app_theme.dart             MaterialApp ThemeData
│   └── responsive.dart            Responsive.w / Responsive.h / Responsive.sp helpers
├── services/                      API + secure storage
│   ├── auth_service.dart          HTTP wrappers — login/signup/logout/Google/OTP/refresh/updateProfile
│   ├── token_storage.dart         FlutterSecureStorage wrapper — saveTokens/loadTokens/clearTokens
│   └── walkthrough_service.dart   SharedPreferences flag — markAsNewUser / isNewUser / markWalkthroughComplete
├── helpers/
│   └── walkthrough_keys.dart      All GlobalKeys + ShowcaseNavConfig / ShowcaseProfileConfig structs + pre-built config instances
├── providers/                     Global ValueNotifier state
│   ├── auth_state.dart            isLoggedIn (ValueNotifier<bool>), avatarUrl (ValueNotifier<String?>),
│   │                              userName (ValueNotifier<String?>) — all reactive
│   │                              + tryRestoreSession(), isProfileComplete, updateUserProfile()
│   │                              + firstName (static getter — first word of userName, fallback "User")
│   ├── location_state.dart        ValueNotifier for selected city
│   ├── saved_events_state.dart    ValueNotifier<List<EventModel>> for wishlist
│   ├── booked_events_state.dart   ValueNotifier<List<EventModel>> for bookings
│   └── user_reviews_state.dart    ValueNotifier for user reviews
├── models/
│   ├── event_model.dart           Core data model — title, venue, price, rating, date, image, etc.
│   └── category_model.dart        Category model with label, image, color
├── data/
│   └── dummy_data.dart            All mock data — events, categories, banners, partners, etc.
├── screens/                       44 screens (see Section 3)
├── widgets/                       30+ reusable widgets incl. login_sheet.dart, walkthrough_intro_overlay.dart (see Section 4)
└── sections/                      17 home-page sections (see Section 5)
```

---

## 2. Navigation Flow

```
SplashScreen
    └── HomeScreen  (Tab: Home)
        ├── EventsScreen        (Tab: Events)
        │   ├── CategoryEventsScreen
        │   │   └── EventDetailScreen → DateTimeSelectionScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
        │   └── EventDetailScreen (same checkout flow)
        ├── ClassesScreen       (Tab: Classes)
        │   ├── ClassDetailScreen → SelectBatchScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
        │   └── CategoryClassesScreen
        ├── ProgramsScreen      (Tab: Programs)
        │   ├── ProgramDetailScreen → SelectProgramBatchScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
        │   └── CategoryProgramsScreen
        └── VenuesScreen        (Tab: Venues)
            ├── VenueDetailScreen → PlanPartyScreen
            └── CategoryVenuesScreen

HomeScreen (sidebar/action flows)
    ├── SearchScreen            (filter bottom sheet)
    ├── NotificationScreen
    ├── LocationScreen
    ├── ProfileScreen
    │   ├── EditProfileScreen
    │   ├── BookingsScreen → BookingDetailScreen
    │   ├── SavedEventsScreen
    │   ├── PaymentSettingsScreen
    │   ├── YourReviewsScreen
    │   ├── RemindersScreen
    │   ├── NotificationScreen
    │   ├── AccountSettingsScreen → ChangePasswordScreen
    │   └── HelpCentreScreen
    └── LoginSheet (bottom sheet)
        ├── SignupScreen
        ├── ForgotPasswordScreen
        └── OTP verification (inline)
```

---

## 3. Screens (44 total)

### Home & Shell
| File | Description |
|------|-------------|
| `splash_screen.dart` | Logo animation → HomeScreen |
| `home_screen.dart` | Main scroll page with all home sections + FloatingNavbar |

### Auth
| File | Description |
|------|-------------|
| `widgets/login_sheet.dart` | Full-screen login — email/pass, Google, OTP. WelcomeBackDialog → routes to EditProfileScreen if profile incomplete, else HomeScreen |
| `signup_screen.dart` | New account creation with OTP verification flow |
| `forgot_password_screen.dart` | 3-step OTP password reset wizard — Step 0: email entry → "Send OTP"; Step 1: 6-box OTP verification with resend link; Step 2: new+confirm password fields → success dialog with confetti |
| `change_password_screen.dart` | Authenticated password change |

### Main Tab Screens
| File | Description |
|------|-------------|
| `events_screen.dart` | Full events listing — banners, categories grid, trending, weekend, holiday, partners, new-on-TLB, online |
| `classes_screen.dart` | Classes listing — banners, pick-your-pace, featured, nearby, camp cards |
| `programs_screen.dart` | Programs listing — banners, categories, unique minds, level-up cards |
| `venues_screen.dart` | Venues listing — big days, weekend plans, close-to-you, hands-on, easy-pocket, mall, thoughtful cards |

### Detail & Booking Flow
| File | Description |
|------|-------------|
| `event_detail_screen.dart` | Full event detail — hero image, info, gallery, map, reviews, "Book Now" CTA |
| `class_detail_screen.dart` | Class detail — same layout as event detail, "Check Availability" / "Send Enquiry" CTA. Accepts `onBookTapped` callback |
| `program_detail_screen.dart` | Thin wrapper around ClassDetailScreen, routes to SelectProgramBatchScreen |
| `venue_detail_screen.dart` | Venue detail — same layout as event detail, "Plan Event" CTA → PlanPartyScreen |
| `date_time_selection_screen.dart` | Pick date + time → TicketBookingScreen |
| `select_batch_screen.dart` | Classes batch selection — 3 dates, 3 batches → TicketBookingScreen |
| `select_program_batch_screen.dart` | Programs batch selection — 6 dates, Morning/Evening batches with seats chip → TicketBookingScreen |
| `ticket_booking_screen.dart` | Ticket count + price breakdown → ReviewPayScreen |
| `review_pay_screen.dart` | Order summary → PaymentScreen |
| `payment_screen.dart` | Payment method selection |
| `booking_confirmed_screen.dart` | Booking success — animated teaser flip → ticket card with full-width image, notch cut + dashed divider (CustomPainter), QR, Share/Download actions |
| `seat_reservation_screen.dart` | Interactive seat map |
| `plan_party_screen.dart` | "Plan Your Kid's Party" — child name, occasion, date/time grid, kids count → Continue |

### Category Screens
| File | Description |
|------|-------------|
| `category_events_screen.dart` | Filtered events by category |
| `category_classes_screen.dart` | Filtered classes by category |
| `category_programs_screen.dart` | Filtered programs by category |
| `category_venues_screen.dart` | Filtered venues by category |
| `category_detail_screen.dart` | Generic category detail |

### Profile & Account
| File | Description |
|------|-------------|
| `profile_screen.dart` | My Profile — avatar, name, email, Edit Profile button, menu items using profile_section.png sprite |
| `edit_profile_screen.dart` | Edit profile — first/last name, phone, gender, birthdate, region. Pre-fills from AuthState. Calls PATCH /api/v1/customer/profile/. `isOnboarding` mode for new-user post-signup flow (no back, Skip action) |
| `bookings_screen.dart` | Booking history list |
| `booking_detail_screen.dart` | Single booking detail + QR |
| `saved_events_screen.dart` | Wishlist of saved events |
| `payment_settings_screen.dart` | Saved cards & payment methods |
| `your_reviews_screen.dart` | User's posted reviews |
| `reminders_screen.dart` | Event reminders |
| `notification_screen.dart` | Notification inbox |
| `account_settings_screen.dart` | Account settings — avatar + email from `AuthState` (live `ValueListenableBuilder`), phone, change password, privacy, delete account |
| `help_centre_screen.dart` | FAQ + support |

### Utility
| File | Description |
|------|-------------|
| `search_screen.dart` | Search with filter bottom sheet (Age Group, Mode, Location dropdowns, Date chips) |
| `location_screen.dart` | City selection — popular cities grid (6 cards with images), all metro cities list (alphabetical), real GPS detection via `geolocator` + `geocoding`, Android runtime permission flow, `_matchToKnownCity()` fuzzy matching with Delhi NCR special-case |
| `gallery_screen.dart` | Full-screen image gallery |
| `organizer_profile_screen.dart` | Event organizer detail |
| ~~`shops_screen.dart`~~ | ~~Merchandise/shops~~ — **deleted** (dead screen) |

---

## 4. Widgets (30+)

| Widget | Purpose |
|--------|---------|
| `floating_navbar.dart` | Animated pill navbar — active tab expands with label, gradient scrim above |
| `banner_carousel.dart` | Auto-scroll image carousel with overlay style |
| `event_card.dart` / `event_card_with_rating.dart` / `event_card_with_price.dart` | Various event card styles |
| `class_nearby_card.dart` | Horizontal class card with tag + button |
| `wishlist_button.dart` | Heart toggle with disperse animation |
| `explore_categories_grid.dart` | 3-col category icon grid. `scrollable: true` + `visibleRows` = fixed-height inner scroll with "View All" chip overlaid at bottom |
| `explore_format_row.dart` | Horizontal format chip row |
| `holiday_special_card.dart` | Tall gradient card for holiday events |
| `new_on_tlb_card.dart` | PageView card for new listings |
| `online_event_card.dart` | Online event card with platform badge |
| `weekend_event_card.dart` | Compact horizontal weekend card |
| `partner_portrait_card.dart` | Featured partner portrait card |
| `section_divider_widget.dart` | Section title with "See All" |
| `filter_bottom_sheet.dart` | Legacy filter sheet |
| `all_categories_popup.dart` | Full-screen categories popup |
| `pick_your_pace_row.dart` | Skill level selector row |
| `inquire_now_sheet.dart` | "Send Enquiry" bottom sheet with confetti success |
| `banner_carousel.dart` | Spotlight banner with overlay gradient |
| `empty_location_widget.dart` | Empty state for no-location screens |
| `walkthrough_intro_overlay.dart` | Full-screen animated welcome card — fade+scale entrance (380ms), repeating icon pulse glow, "Let's Go" dismiss triggers showcase start |

---

## 5. Sections (Home Page, 17 total)

| Section | Content |
|---------|---------|
| `home_header.dart` | Gradient header (#FFB219 → white), first-name greeting (ValueListenableBuilder on `userName`), location, alert icon, avatar (ValueListenableBuilder on `avatarUrl`), search bar |
| `spotlight_section.dart` | Hero banner carousel |
| `browse_by_categories_section.dart` | Category icon grid |
| `trending_now_section.dart` | Horizontal trending cards |
| `hot_picks_section.dart` | Hot picks card list |
| `weekend_special_section.dart` | Weekend event chips |
| `featured_events_section.dart` | Featured event cards |
| `best_for_week_section.dart` | Best this week cards |
| `discover_near_you_section.dart` | Location-based cards |
| `near_you_section.dart` | Proximity-sorted cards |
| `family_feels_section.dart` | Family events section |
| `kids_favorites_section.dart` | Kids-specific events |
| `special_needs_section.dart` | Inclusive/special-needs events |
| `popular_categories_section.dart` | Popular category pills |
| `tlb_signature_section.dart` | TLB signature events |
| `stealers_section.dart` | Deal/discount events |
| `app_footer.dart` | `resources- tlb-ui/main-footer.png` with 60px top gap |

---

## 6. Core Services & State

### AuthService (`lib/services/auth_service.dart`)
- All methods have **30-second timeout**
- Typed error handling: `SocketException` → "Cannot reach server", `TimeoutException` → "Request timed out", `HandshakeException` → "SSL error"
- **OTP Login / Signup (unified flow):**
  - `requestOtp(identifier)` — POST `/api/v1/auth/request-otp/` body `{"identifier": email, "identifier_type": "email"}` → OTP sent to email
  - `verifyOtp(identifier, otp)` — POST `/api/v1/auth/verify-otp/` body `{"identifier", "otp", "role": "customer"}` → `{"access", "refresh", "is_new_user", "user"}`. Creates account automatically if email not registered. Handles `OTP_INVALID`, `OTP_EXPIRED`, `USER_ROLE_MISMATCH`, `OTP_LOCKED` error codes.
- `logout(refresh)` — POST `/api/v1/auth/logout/` body `{"refresh_token": refresh}`
- `refreshToken(refresh)` — POST `/api/v1/auth/refresh-token/` body `{"refresh_token": refresh}`
- `googleSignIn(firebaseIdToken)` — POST `/api/v1/auth/customer/google/` → `{"access", "refresh", "is_new_user", "user"}`
- `getProfile(accessToken)` — GET `/api/v1/customer/profile/` → `{"success", "profile": {..., "is_completed": bool}}`
- `updateProfile(accessToken, firstName, lastName, phoneNumber, gender, birthdate, region)` — PATCH `/api/v1/customer/profile/` (JSON body, partial — only non-null fields sent) → `{"success", "profile": {...}}`
- `changePassword()` — POST `/api/v1/auth/password/change/` (requires Bearer token)
- **Password reset (3-step OTP flow):**
  - `forgotPassword(email)` — POST `/api/v1/auth/customer/password/reset/request/`
  - `verifyResetOtp(identifier, code)` — POST `/api/v1/auth/customer/password/reset/verify-otp/` → `{"reset_token"}`
  - `confirmPasswordReset(resetToken, newPassword, newPasswordConfirm)` — POST `/api/v1/auth/customer/password/reset/confirm/`
- ~~`signup()`~~ / ~~`login()`~~ — removed (password-based auth dropped)

### TokenStorage (`lib/services/token_storage.dart`)
- Wraps `FlutterSecureStorage`
- Keys: `tlb_access_token`, `tlb_refresh_token`, `tlb_user_json`
- `saveTokens(access, refresh, userJson)` / `loadTokens()` / `clearTokens()`

### AuthState (`lib/providers/auth_state.dart`)
- `isLoggedIn` — `ValueNotifier<bool>`
- `avatarUrl` — `ValueNotifier<String?>` — updated in login / updateUserProfile / logout
- `userName` — `ValueNotifier<String?>` — updated in login / updateUserProfile / logout; null = not logged in
- `accessToken`, `refreshToken`, `userEmail`, `userPhone`, `userData` — plain static fields
- `login()` — sets all fields, fires notifiers, calls `TokenStorage.saveTokens()` as background save
- `logout()` — clears all fields, fires notifiers to null, calls `TokenStorage.clearTokens()`
- `tryRestoreSession()` — loads stored refresh → calls `refreshToken()` → re-logs in; returns bool
- `isProfileComplete` — getter; true if `profile.first_name` is non-empty
- `updateUserProfile(updatedUser)` — syncs API response into state, fires `userName` + `avatarUrl` notifiers, re-saves tokens
- `firstName` — static getter; first word of `userName.value`, fallback `"User"`. Use for `"Hi $firstName,"` greetings everywhere.

### WalkthroughService (`lib/services/walkthrough_service.dart`)
- Key: `tlb_is_new_user` (SharedPreferences)
- `markAsNewUser()` — sets flag `true`; called immediately after email or Google signup success
- `isNewUser()` — returns stored bool, false if unset
- `markWalkthroughComplete()` — sets flag `false`; called before tour starts (so force-quit mid-tour does not repeat it)

### WalkthroughKeys (`lib/helpers/walkthrough_keys.dart`)
- GlobalKeys: `locationRow`, `navHome`, `navEvents`, `navClasses`, `navPrograms`, `navVenues`, `profileAvatar`
- `orderedKeys` list: `[locationRow, navHome, navEvents, navClasses, navPrograms, navVenues, profileAvatar]`
- Config structs: `ShowcaseNavConfig(showcaseKey, title, description)`, `ShowcaseProfileConfig(showcaseKey, title, description)`
- Pre-built instances: `kNavShowcaseConfigs` (Map<int, ShowcaseNavConfig> keyed by navbar index 0–4), `kLocationShowcaseConfig`, `kProfileShowcaseConfig`
- Map keyed by index allows Events (index 1) to be included or excluded without changing loop logic

### Google Sign-In / Sign-Up (live)
```
google-services.json: real credentials for project tlb-events-ababb
  project_number: 690253990877
  mobilesdk_app_id: 1:690253990877:android:9b1a0b2a20b65f5f15c434
  serverClientId: 690253990877-jqog76u6vcre0a9qbd9d8p0g7o47scue.apps.googleusercontent.com

Flow (login_sheet.dart + signup_screen.dart):
  GoogleSignIn(serverClientId: ..., scopes: ['email','profile']).signIn()
  → FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(...))
  → fbCredential.user.getIdToken()
  → AuthService.googleSignIn(firebaseIdToken: token)
  → AuthState.login(access, refresh, user)
  → showWelcomeBackDialog()  [both login and signup]
     onDone: AuthState.isProfileComplete?
       true  → HomeScreen
       false → EditProfileScreen(isOnboarding: true)

API returns is_new_user flag — same endpoint handles both sign-in & sign-up.
google-services.json includes SHA-1 debug fingerprint: 67:FB:ED:80:72:FB:43:4A:1F:9D:C4:32:38:62:D6:05:EC:8C:36:D8
```

---

## 7. Assets & Resources

### Registered in `pubspec.yaml`
```
assets/images/          — General images
assets/images/new_home/ — Home screen assets (profilepic.jpg, map_thumb.png, etc.)
assets/images/event_subcategories/
assets/images/explore_formats/
assets/images/featured_partners/
assets/images/class_page/
assets/images/pick_pace/
assets/icons/           — SVG nav icons (nav_home, nav_events, nav_classes, nav_program, nav_spaces)
resources- tlb-ui/      — Design assets (main-footer.png, profile_section.png, etc.)
resources- tlb-ui/accounts_page/    — wishlist.png, payments.png, reviews.png, support.png, reminders.png
resources- tlb-ui/venues_page/
resources- tlb-ui/events_page/
resources- tlb-ui/homescreen-categoryicons/  — events.png, classes.png, programs.png, venues.png
resources- tlb-ui/venues_page/yourway/
location_screen_resources/  — City images: delhi.png, mumbai.png, hyderabad.png, kolkata.png, pune.png, bangalore.png
google_fonts/           — Bundled Poppins font (runtime fetching disabled)
```

### Key Asset References
| Asset | Used In |
|-------|---------|
| `resources- tlb-ui/main-footer.png` | `app_footer.dart` — full-width footer image |
| `resources- tlb-ui/profile_section.png` | `profile_screen.dart` — 7-icon sprite sheet |
| `resources- tlb-ui/homescreen-categoryicons/*.png` | `dummy_data.dart` homeCategories |
| `assets/images/new_home/profilepic.jpg` | `home_header.dart`, `profile_screen.dart` |

---

## 8. Key UI Implementations

### Floating Navbar with Gradient Scrim
```
FloatingNavbar returns a full-width Container with:
  - LinearGradient: Color(0xFF242424) transparent → Color(0xFF000000) opaque (top→bottom)
    Creates a dark scrim that frames the pill over scrolling content
  - padding: top 48 (scrim height above pill) + bottom safeBottom+15 or 30
  - Pill: white rounded rect, 92% screen width, active tab = yellow #FFCC00 with expand animation
  - Positioned in each screen at bottom: 0 with Align center wrapper
```

### Home Header
```
Layer 1 (image + gradient mask):
  ShaderMask(BlendMode.screen) on `resources- tlb-ui/header.jpg` (flipped vertically)
  Shader: LinearGradient — Color(0xFFFFB219) top → Colors.white bottom
  BlendMode.screen brightens image: golden tint at top, fades to white at bottom
  JPG-safe: screen works on RGB channels, no alpha needed

Layer 2 (content):
  SafeArea → Column → greeting row + search bar

Greeting row layout:
  Row(crossAxisAlignment: center)
    └── Expanded(Column)               ← bounds left side so icons are never pushed out
          ├── Row(Flexible(Text) + wave image)
          │     Text listens to AuthState.userName (ValueListenableBuilder<String?>)
          │     null → "Hello There" | non-null → "Hello <firstName>" (.split(' ').first)
          │     maxLines: 1, overflow: TextOverflow.ellipsis
          └── GestureDetector → LocationScreen (city label, max 18 chars)
    └── SizedBox(width: 8)
    └── Row(bell + avatar)
          Bell: resources- tlb-ui/alert.png in white circle (0.55 opacity, amber shadow)
          Avatar: ValueListenableBuilder<String?> on AuthState.avatarUrl
            non-null → NetworkImage(url) | null → AssetImage(profilepic.jpg)

Search bar: white pill with shadow, search icon + divider + filter icon
```

### Booking Confirmed Screen
```
Structure: _ClickHereTeaser (flip animation) → _TicketScreen

_HeaderSection:
  Balloon background (assets/images/booking_back.png) + bottom fade gradient
  White-ringed checkmark: outer Container(66×66, white circle, green shadow)
                          inner Container(50×50, Color(0xFF34C759), check icon)
  "Booking Confirmed!" (dark blue #1A3A8F, bold 20sp)
  "Booking ID: XXXX" (grey 12sp)

_TicketCard (Container + ClipRRect — no PNG overlay):
  ┌─ AspectRatio(16/9) Image.asset  — full-width, zero padding, top corners via ClipRRect
  ├─ Padding(18,16,18,20) _TicketContent
  │     event title | location + Map button | date + time (2-col)
  ├─ SizedBox(height:28) CustomPaint(_TicketNotchPainter)
  │     Draws 2 semicircles (radius 13) at x=0 and x=width in Color(0xFFD6E4F7)
  │     → appears as notch cuts against scaffold background
  │     Dashed line (gap 4, dash 6, color #DEDEDE) between notches
  └─ Padding(18,18,18,26) QR section
        "Scan QR Code" label + Container(border+radius) + CustomPaint(_QRCodePainter)

_ActionButtons: white bar (top shadow) with Share + Download tiles (Color(0xFFF5F6FA), radius 14)
```

### Profile Screen Icon Sprite
```
profile_section.png = 7-icon horizontal sprite
Extraction: ClipRect + Align(widthFactor: 1/7, alignment: -1 + pos*(2/6))
Tinted with ColorFilter.mode(color, BlendMode.srcIn)
Positions: 0=ticket, 1=X, 2=creditcard, 3=book, 4=bell, 5=alarm, 6=gear
Favorite → Icons.favorite_border | Help → Icons.help_outline | LogOut → Icons.logout (red)
```

### Welcome Back Dialog (Post-Login)
```
login_sheet.dart → showWelcomeBackDialog()
Purple card (#7C3AED), 👋 emoji, confetti animation (70 particles, gravity)
"Let's Go!" → checks AuthState.isProfileComplete:
  complete   → Navigator.pushAndRemoveUntil → HomeScreen
  incomplete → Navigator.pushAndRemoveUntil → EditProfileScreen(isOnboarding: true)
Triggered by both email/password login and Google sign-in/sign-up
```

### Edit Profile — Onboarding Mode
```
EditProfileScreen(isOnboarding: true):
  - Title: "Complete Your Profile"
  - PopScope(canPop: false) — Android back blocked
  - "Skip" action in AppBar → HomeScreen
  - "Save & Continue" → PATCH /api/v1/auth/users/me/ → AuthState.updateUserProfile() → HomeScreen
  - Avatar URL cached once in initState (_avatarUrl) — not rebuilt on keystroke

EditProfileScreen(isOnboarding: false):  [normal edit from ProfileScreen]
  - Title: "Edit Profile", back button works
  - "Update Profile" → same API → pops back to ProfileScreen

Fields (customer type): first_name, last_name, date_of_birth, city, state,
                        guardian_name, institution_name, institution_type
```

### Subcategory Grid — Scrollable with Overlay Button
```
ExploreCategoriesGrid(scrollable: true, visibleRows: 2.3):
  LayoutBuilder computes container height = visibleRows * cellHeight + spacing
  GridView with ClampingScrollPhysics scrolls independently of page
  Stack + Positioned(bottom: 10) overlays "View All →" chip
  Image padding: EdgeInsets.fromLTRB(6,6,6,2) inside each card

Applied to:
  programs_screen.dart  — all 11 programsCategories,  visibleRows: 2.3
  events_screen.dart    — all 6  exploreCategories,    visibleRows: 2.0
  classes_screen.dart   — all 11 classesCategories,    visibleRows: 2.3
```

### Send Enquiry Flow
```
ClassDetailScreen "Send Enquiry" button → showInquireNow()
Bottom sheet with name/phone/message fields
On submit → _EnquirySuccessDialog with confetti (same particle system)
```

### Batch Selection Screens
```
SelectBatchScreen (Classes):
  3 dates | 3 batches (time, days, slots, tag) | info card | Continue → TicketBookingScreen

SelectProgramBatchScreen (Programs):
  6 dates (Sat/Sun wrap) | Morning Batch + Evening Batch | seats-left pink chip
  Selected = dark filled circle with white check | Continue → TicketBookingScreen
```

### Plan Party Screen (Venues)
```
VenueDetailScreen "Plan Event" → PlanPartyScreen
Fields: Child Name | Occasion radios | Date grid (6 days) | Time chips | Kids range dropdown
Validation before Continue | MiniMapPainter for venue map thumbnail
```

### Forgot Password — 3-Step OTP Wizard
```
Single StatefulWidget (_ForgotPasswordScreenState) with shared state:
  _step: int (0/1/2) — controls which sub-widget is displayed
  _identifier: String — email captured at step 0, passed to step 1+2 API calls
  _resetToken: String — from verifyResetOtp response, passed to step 3 API call
  _loading: bool — disables button and shows CircularProgressIndicator

Back button logic:
  step 0 → Navigator.pop()  (exit screen)
  step 1 → _step--          (back to email)
  step 2 → _step--          (back to OTP)

Step 0 — Email:
  Email TextField (Color(0xFFF5F5F5), radius 26) → "Send OTP" button (yellow pill)
  On success: _identifier = email, _step = 1

Step 1 — OTP:
  6 individual TextEditingController + FocusNode pairs
  FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)
  Box: Color(0xFFF5F5F5) fill, BorderRadius.circular(12)
  Focused border: Color(0xFFFFD014) 2px
  Auto-advance on digit input (i < 5 → focus[i+1])
  Auto-retreat on backspace via Focus.onKeyEvent (empty field + backspace → focus[i-1])
  Resend OTP: TextButton → re-calls forgotPassword(), shows SnackBar
  "Verify OTP" → verifyResetOtp() → _resetToken = result['reset_token'], _step = 2

Step 2 — New Password:
  New Password + Confirm Password fields (same grey pill style, eye-toggle suffix)
  Client validation: both non-empty, passwords match (else SnackBar)
  "Set New Password" → confirmPasswordReset() → _PasswordResetSuccessDialog

Success dialog (_PasswordResetSuccessDialog):
  Blue card (Color(0xFF1D4ED8)) + confetti animation (55 particles, _ConfettiPainter)
  Icon: Icons.check_circle_rounded (white, size 38)
  Title: "Password Reset!"
  Body: "Your password has been successfully reset. You can now log in."
  Button: "Back to Login" → pops dialog → pops forgot screen
```

### Filter Bottom Sheet (Search)
```
4 sections: Age Group chips (0-3/3-5/6-8/9-12/13-16) | Mode radio (Offline/Hybrid/Online)
Location dropdowns (City + Area) | Date chips (Today/This Weekend/This Week/Upcoming)
"Clear All" + "Apply Filters" footer
```

### Onboarding Walkthrough (New-User Tour)
```
Package: showcaseview ^5.0.2 (controller-based v5 API — no ShowCaseWidget tree wrapper)
Trigger: WalkthroughService.isNewUser() checked in HomeScreen.initState()
Flag is marked complete BEFORE the tour starts (force-quit mid-tour won't repeat it)

7-step flow:
  [Intro]  WalkthroughIntroOverlay — full-screen welcome dialog
              showGeneralDialog(barrierColor: transparent, transitionDuration: Duration.zero)
              Overlay owns its own AnimationController: fade+scale card entrance (380ms, easeOutCubic)
              _IconBadge owns a repeating AnimationController: pulse glow (1400ms, repeat/reverse)
              "Let's Go" → _ctrl.reverse().then → Navigator.pop → ShowcaseView.get().startShowCase(keys)
  [Step 1] Location chip in HomeHeader — key: locationRow
              onTargetClick: opens LocationScreen; .then(() => ShowcaseView.get().next())
  [Step 2] Navbar Home tab (index 0) — key: navHome
  [Step 3] Navbar Events tab (index 1) — key: navEvents
  [Step 4] Navbar Classes tab (index 2) — key: navClasses
  [Step 5] Navbar Programs tab (index 3) — key: navPrograms
  [Step 6] Navbar Venues tab (index 4) — key: navVenues
  [Step 7] Profile avatar in HomeHeader — key: profileAvatar

Showcase styling (all steps):
  tooltipBackgroundColor: Color(0xFF1A1A2E) | textColor: Colors.white
  overlayOpacity: 0.78 | scaleAnimationDuration: 350ms | movingAnimationDuration: 350ms
  targetPadding: EdgeInsets.all(6) for navbar, EdgeInsets.all(8) for profile avatar

FloatingNavbar integration:
  Optional param: Map<int, ShowcaseNavConfig>? showcaseConfigs
  null (default) → no Showcase wrapping; existing call sites unaffected
  non-null → each index that has a config entry is wrapped in Showcase

HomeHeader integration:
  Optional params: ShowcaseProfileConfig? profileShowcaseConfig, ShowcaseProfileConfig? locationShowcaseConfig
  Location row extracted to _buildLocationRow(); conditionally wrapped in Showcase with onTargetClick
  Profile avatar conditionally wrapped in Showcase

Signup flag wiring:
  Email signup: WalkthroughService.markAsNewUser() called on result['success'] == true, before dialog
  Google signup: markAsNewUser() called only when result['is_new_user'] == true
```

### Subcategory Grid — Per-Item Image Inset
```
dummy_data.dart programsCategories entries can carry an optional 'imageInset': double key.
explore_categories_grid.dart reads it:
  final imageInset = (category['imageInset'] as double?) ?? 6.0;
  padding: EdgeInsets.fromLTRB(imageInset, imageInset, imageInset, 2)
Default 6.0 for all cards. Set to 0.0 for "Future Tech & AI" and "Design & Innovation"
to give their images ~12px more space per side within the fixed card area.
```

### Profile Sub-Screen Greeting
```
All 5 profile sub-screens use AuthState.firstName (static getter) for the "Hi X," greeting:
  saved_events_screen.dart | your_reviews_screen.dart | help_centre_screen.dart
  payment_settings_screen.dart | reminders_screen.dart
Pattern: 'Hi ${AuthState.firstName},'
AuthState.firstName = userName.value.trim().split(' ').first, fallback "User"
```

### Account Settings — Live User Data
```
account_settings_screen.dart Personal Info row uses ValueListenableBuilder<String?> on AuthState.avatarUrl:
  Avatar: NetworkImage(AuthState.avatarUrl) if non-null/non-empty
          else initials via https://ui-avatars.com/api/?name=X&background=FFCC00&color=1A1A2E&size=200
  Email: AuthState.userEmail ?? 'No email provided' (maxLines:1, ellipsis)
Reacts to profile edits without requiring screen re-navigation.
```

---

## 9. Booking / Checkout Flow

```
[Events]  EventDetailScreen  → DateTimeSelectionScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
[Classes] ClassDetailScreen  → SelectBatchScreen        → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
[Program] ProgramDetailScreen→ SelectProgramBatchScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
[Venues]  VenueDetailScreen  → PlanPartyScreen          (TODO: booking confirmation)
```

---

## 10. Pending / TODO Items

| Item | Location | Status |
|------|----------|--------|
| ~~Google Sign-In bypass removed~~ | `login_sheet.dart` | ✅ Done — real flow, serverClientId, SHA-1 registered |
| ~~Persistent login / token refresh~~ | `auth_state.dart`, `token_storage.dart`, `main.dart` | ✅ Done |
| ~~Google account picker always shown~~ | `login_sheet.dart`, `signup_screen.dart` | ✅ Done — signOut() before signIn() |
| ~~Project structure reorganized~~ | `services/`, `providers/`, `widgets/` | ✅ Done |
| ~~UpdateProfile API integrated~~ | `edit_profile_screen.dart`, `auth_service.dart` | ✅ Done |
| ~~Profile completion check post-login~~ | `login_sheet.dart:showWelcomeBackDialog` | ✅ Done |
| ~~Home header greeting reactive~~ | `home_header.dart`, `auth_state.dart` | ✅ Done — `userName` promoted to `ValueNotifier<String?>`, header listens directly |
| ~~Home header name overflow / layout break~~ | `home_header.dart` | ✅ Done — first name only, `Expanded` + ellipsis |
| ~~Booking Confirmed screen redesigned~~ | `booking_confirmed_screen.dart` | ✅ Done — white-ring badge, full-width image, CustomPainter notch+dash |
| ~~Onboarding walkthrough (new-user tour)~~ | `home_screen.dart`, `floating_navbar.dart`, `home_header.dart`, `walkthrough_service.dart`, `walkthrough_keys.dart`, `walkthrough_intro_overlay.dart` | ✅ Done — 7-step showcaseview tour with animated intro overlay |
| ~~Hardcoded username in profile sub-screens~~ | `saved_events_screen.dart`, `your_reviews_screen.dart`, `help_centre_screen.dart`, `payment_settings_screen.dart`, `reminders_screen.dart` | ✅ Done — `AuthState.firstName` getter |
| ~~Hardcoded avatar + email in AccountSettingsScreen~~ | `account_settings_screen.dart` | ✅ Done — live `ValueListenableBuilder` on `AuthState.avatarUrl` + `AuthState.userEmail` |
| ~~OTP verification real API~~ | `login_sheet.dart:_OTPVerificationScreen._onVerify` | ✅ Done — real `verifyOtp()` call; new user → EditProfileScreen, existing → WelcomeBackDialog |
| PlanPartyScreen → booking confirmation | `plan_party_screen.dart:_onContinue` | ❌ Pending — validated but navigates nowhere |
| Profile screen reactive to name/avatar changes | `profile_screen.dart` | ❌ Pending — reads `AuthState.userName.value` but no `ValueListenableBuilder`; won't update on profile edit without navigate-back rebuild |
| Profile avatar upload | `edit_profile_screen.dart` | ❌ Pending — removed from profile form (new API has no avatar field); needs separate endpoint when available |
| Startup profile completion check | `main.dart` | ❌ Pending — `tryRestoreSession()` restores session but does NOT redirect incomplete profiles |

---

## 11. Dependencies

```yaml
google_fonts: ^6.1.0          # Poppins — bundled, runtime fetch disabled
smooth_page_indicator: ^1.1.0  # PageView dots
flutter_rating_bar: ^4.0.1     # Star ratings
flutter_displaymode: ^0.7.0    # High refresh rate
video_player: ^2.11.0          # Splash / promo videos
flutter_svg: ^2.2.4            # Nav icon SVGs
like_button: ^2.1.0            # Heart animations
http: ^1.2.0                   # REST API calls
firebase_core: ^3.8.0          # Firebase init
firebase_auth: ^5.3.1          # Auth (Google Sign-In)
google_sign_in: ^6.2.1         # Google OAuth
showcaseview: ^5.0.2           # Onboarding walkthrough (controller-based v5)
shared_preferences: ^2.5.5     # Non-sensitive UX flag storage (isNewUser walkthrough flag)
geolocator: ^13.0.4            # GPS permission flow + getCurrentPosition()
geocoding: ^3.0.0              # placemarkFromCoordinates() — lat/lng → city name
```

---

## 12. Development Sessions Summary

### Session 1–3 (Prior)
- Full home screen with all 17 sections built
- Floating navbar with animated active tab
- Event/Class/Venue detail screens
- Full booking checkout flow (DateTimeSelection → TicketBooking → ReviewPay → Confirmed)
- Wishlist system with disperse animation
- Category screens and routing
- Auth screens (Login, Signup, OTP, Forgot Password)
- Seat reservation screen
- Profile sub-screens (8 screens redesigned)

### Session 4 (Current)
| Change | Files |
|--------|-------|
| Welcome Back dialog with confetti after login | `login_sheet.dart` |
| Filter bottom sheet redesign (Age/Mode/Location/Date) | `search_screen.dart` |
| Footer replaced with `main-footer.png` across all screens | `app_footer.dart` |
| `VenueDetailScreen` created (same as EventDetail, "Plan Event" button) | `venue_detail_screen.dart` |
| `PlanPartyScreen` — kid's party booking UI | `plan_party_screen.dart` |
| Footer gap fixed (60px before, none after) | `app_footer.dart` |
| Events + Programs background → white | `events_screen.dart`, `programs_screen.dart` |
| Auth error messages typed (Socket/Timeout/Handshake) | `auth_service.dart` |
| All API timeouts increased to 30s | `auth_service.dart` |
| Home category icons replaced with custom images | `dummy_data.dart`, `pubspec.yaml` |
| Profile menu icons use `profile_section.png` sprite | `profile_screen.dart` |
| Google Sign-In bypassed for dev testing | `login_sheet.dart` |
| Programs batch selection screen (Morning/Evening) | `select_program_batch_screen.dart` |
| `ProgramDetailScreen` wrapping `ClassDetailScreen` | `program_detail_screen.dart` |
| `SelectBatchScreen` Continue wired to `TicketBookingScreen` | `select_batch_screen.dart` |
| Programs screen navigates to `ProgramDetailScreen` | `programs_screen.dart` |
| `ClassDetailScreen` `onBookTapped` callback added | `class_detail_screen.dart` |
| FloatingNavbar gradient scrim (transparent → black, 48px above pill) | `floating_navbar.dart` |
| Home header redesigned: cloud image + gradient overlay, greeting, search bar | `home_header.dart` |
| Profile screen redesigned to match Figma (centered layout, Material icons) | `profile_screen.dart` |
| `EventCardWithRating` `onTap` callback added (override navigation per context) | `event_card_with_rating.dart` |
| `ClassNearbyCard` `onTap` callback added (override navigation per context) | `class_nearby_card.dart` |
| Programs screen cards wired to `ProgramDetailScreen` via `onTap` override | `programs_screen.dart` |
| Home header gradient: `ShaderMask(BlendMode.screen)` — golden→white tint on cloud image | `home_header.dart` |
| Google Sign-In bypass removed, real flow with serverClientId | `login_sheet.dart` |
| Google Sign-Up implemented with WelcomeBackDialog (consistent with login) | `signup_screen.dart` |
| Real `google-services.json` written (project 690253990877) | `android/app/google-services.json` |

### Session 5 (Current)
| Change | Files |
|--------|-------|
| `AuthState.userName` promoted to `ValueNotifier<String?>` (was plain `String?`) | `auth_state.dart` |
| All `userName =` writes updated to `userName.value =` (login, logout, updateUserProfile) | `auth_state.dart` |
| Home header greeting listens to `AuthState.userName` notifier — updates reactively on login, profile edit, logout, all screens | `home_header.dart` |
| Home header shows first name only — `userName.value.split(' ').first`; `maxLines:1` + `ellipsis` | `home_header.dart` |
| Home header layout fixed — left Column wrapped in `Expanded`, prevents long names pushing icons | `home_header.dart` |
| `profile_screen.dart` updated to read `AuthState.userName.value` | `profile_screen.dart` |
| `BookingConfirmedScreen` UI redesigned to match reference | `booking_confirmed_screen.dart` |
| → Header: white-ring green badge (outer 66px white circle + inner 50px green circle + green shadow) | `booking_confirmed_screen.dart` |
| → Added white tint overlay (`Colors.white` at 50% opacity) on balloon background | `booking_confirmed_screen.dart` |
| → Ticket card replaced with `_TicketShapePainter` `CustomPainter` for solid white fill, notch cutouts, and dashed divider | `booking_confirmed_screen.dart` |
| → Event image: full-width at card top, zero padding, top corners via parent `ClipRRect` | `booking_confirmed_screen.dart` |
| → QR section moved from `_TicketContent` into `_TicketCard` | `booking_confirmed_screen.dart` |
| → `_TicketContent` reduced to title + location row + date/time columns only | `booking_confirmed_screen.dart` |
| `BookingDetailScreen` UI redesigned to use exact same ticket design | `booking_detail_screen.dart` |
| → Header: added status badge, "Booking Details" title, and booking ID | `booking_detail_screen.dart` |
| → Replaced PNG ticket with `_TicketShapePainter` `CustomPainter` | `booking_detail_screen.dart` |
| → Matched layout structure: full-width image, details, notch area, QR code | `booking_detail_screen.dart` |
| → Applied consistent Share/Download action bar styling | `booking_detail_screen.dart` |

### Session 6 (Current)
| Change | Files |
|--------|-------|
| `forgotPassword()` — endpoint changed to `/api/v1/auth/customer/password/reset/request/`, body key changed from `email` to `identifier` | `auth_service.dart` |
| `verifyResetOtp(identifier, code)` added — POST `/api/v1/auth/customer/password/reset/verify-otp/`, returns `reset_token` | `auth_service.dart` |
| `confirmPasswordReset(resetToken, newPassword, newPasswordConfirm)` added — POST `/api/v1/auth/customer/password/reset/confirm/` | `auth_service.dart` |
| `ForgotPasswordScreen` fully rewritten as a 3-step wizard (`_step` 0/1/2) in one `StatefulWidget` | `forgot_password_screen.dart` |
| → Step 0: email entry + "Send OTP" button (was "Send Reset Link") — no more email-sent dialog | `forgot_password_screen.dart` |
| → Step 1: 6-box OTP (auto-advance/retreat, yellow focused border), "Resend OTP" link, "Verify OTP" button | `forgot_password_screen.dart` |
| → Step 2: New + Confirm password fields with eye-toggle, client-side match validation, "Set New Password" button | `forgot_password_screen.dart` |
| → `_ResetEmailSentDialog` replaced with `_PasswordResetSuccessDialog` (check icon, "Password Reset!" title, "Back to Login" button) | `forgot_password_screen.dart` |
| → `_Particle` + `_ConfettiPainter` classes retained, reused in success dialog | `forgot_password_screen.dart` |
| → Back button navigates step 1→0, step 2→1, step 0→exits screen | `forgot_password_screen.dart` |
| → Success dialog "Back to Login" correctly navigates back to login sheet (single pop) | `forgot_password_screen.dart` |

### Session 7 (Current)
| Change | Files |
|--------|-------|
| `WalkthroughService` — SharedPreferences-backed `tlb_is_new_user` flag; `markAsNewUser` / `isNewUser` / `markWalkthroughComplete` | `lib/services/walkthrough_service.dart` (NEW) |
| `WalkthroughKeys` — 7 GlobalKeys + `ShowcaseNavConfig` / `ShowcaseProfileConfig` structs + pre-built config instances (`kNavShowcaseConfigs`, `kLocationShowcaseConfig`, `kProfileShowcaseConfig`) | `lib/helpers/walkthrough_keys.dart` (NEW) |
| `WalkthroughIntroOverlay` — animated full-screen welcome card; `AnimationController` for fade+scale entrance (380ms); `_IconBadge` with repeating pulse glow (1400ms); "Let's Go" reverse-animates then pops | `lib/widgets/walkthrough_intro_overlay.dart` (NEW) |
| `HomeScreen` — `ShowcaseView.register/unregister`; `_checkAndStartWalkthrough()` reads `isNewUser` flag; `_launchWalkthrough()` shows intro overlay via `showGeneralDialog`, then calls `startShowCase(orderedKeys)` | `home_screen.dart` |
| `FloatingNavbar` — optional `showcaseConfigs: Map<int, ShowcaseNavConfig>?`; null = no change (all current call sites); non-null = wraps matching tab indices in `Showcase` with dark tooltip styling | `floating_navbar.dart` |
| `HomeHeader` — optional `locationShowcaseConfig` + `profileShowcaseConfig` params; location chip wrapped in `Showcase` with `onTargetClick` → opens `LocationScreen` then `ShowcaseView.get().next()` | `home_header.dart` |
| `SignupScreen` — `WalkthroughService.markAsNewUser()` called on email signup success; called on Google signup only when `result['is_new_user'] == true` | `signup_screen.dart` |
| Events navbar tab (index 1) added to walkthrough — was previously absent from `kNavShowcaseConfigs`, causing the step to be silently skipped | `walkthrough_keys.dart` |
| Showcase styling applied to all steps: `tooltipBackgroundColor: Color(0xFF1A1A2E)`, white text, `overlayOpacity: 0.78`, `scaleAnimationDuration: 350ms`, `movingAnimationDuration: 350ms` | `floating_navbar.dart`, `home_header.dart` |
| Programs subcategory grid — per-item `imageInset` double in category data; default `6.0`; set to `0.0` for "Future Tech & AI" and "Design & Innovation" for larger images | `dummy_data.dart`, `explore_categories_grid.dart` |
| `AuthState.firstName` static getter — first word of `userName.value`, fallback `"User"` | `auth_state.dart` |
| Hardcoded `"Hi Laxman,"` replaced with `"Hi ${AuthState.firstName},"` across all 5 profile sub-screens | `saved_events_screen.dart`, `your_reviews_screen.dart`, `help_centre_screen.dart`, `payment_settings_screen.dart`, `reminders_screen.dart` |
| `AccountSettingsScreen` Personal Info row — avatar replaced with `NetworkImage(AuthState.avatarUrl)` + initials URL fallback; email replaced with `AuthState.userEmail`; wrapped in `ValueListenableBuilder<String?>` for live reactivity | `account_settings_screen.dart` |

### Session 8 (Current)
| Change | Files |
|--------|-------|
| Category screen tint container: switched from `color:` to `decoration: BoxDecoration(color: ..., borderRadius: BorderRadius.circular(16))`, opacity raised 0.10 → 0.15, padding changed to `symmetric(vertical: 12)` — fixes invisible tint on pastel accent colors | `category_events_screen.dart`, `category_classes_screen.dart`, `category_programs_screen.dart`, `category_venues_screen.dart` |
| Category card active scale: 1.08 → 1.12; `AnimatedScale` curve changed `easeOutCubic` → `easeInOut` for stronger, symmetric enlargement feedback | `category_events_screen.dart`, `category_classes_screen.dart`, `category_programs_screen.dart`, `category_venues_screen.dart` |
| `SignupScreen` network fixes: added `dart:async` + `dart:io` imports; `if (!mounted) return` guard after `await markAsNewUser()` in `_onSignUp`; `_onGoogleSignUp` catch now maps `SocketException` / `TimeoutException` to friendly user-facing strings instead of raw `e.toString()`; `_GoogleButton.onTap` type widened to `VoidCallback?`; call site passes `null` when `_loading` is true to prevent concurrent signup requests | `signup_screen.dart` |
| Walkthrough intro overlay title corrected: "The Long Broadway" → "The Little Broadway" | `walkthrough_intro_overlay.dart` |

### Session 9
| Change | Files |
|--------|-------|
| `SectionDividerWidget` decorative line width extended: 70 → 110px for visual emphasis | `lib/widgets/section_divider_widget.dart` |
| Spotlight `SectionDividerWidget` moved out of fixed gradient container into `SingleChildScrollView` — title now scrolls with content instead of being pinned to header | `lib/screens/home_screen.dart` |
| Banner carousel `height` + `fixedCardWidth` replaced with `Responsive.h` / `Responsive.w` calls | `lib/screens/home_screen.dart` |
| 10 metro cities added to `_allCities` list (alphabetical): Chandigarh, Coimbatore, Guwahati, Indore, Kanpur, Nagpur, Patna, Surat, Vadodara, Visakhapatnam | `lib/screens/location_screen.dart` |
| Real GPS location detection added: `geolocator` permission flow (`checkPermission` → `requestPermission` → `openAppSettings`), `getCurrentPosition` with 15s timeout, `geocoding` reverse geocoding with 10s timeout | `lib/screens/location_screen.dart` |
| GPS loading spinner fixed: `_isLoadingLocation` set to `true` at function entry (not mid-flow), both `getCurrentPosition` and `placemarkFromCoordinates` wrapped with `.timeout()`, `TimeoutException` caught separately, `finally` block always resets flag | `lib/screens/location_screen.dart` |
| `_matchToKnownCity()` added: handles Delhi NCR alias set (New Delhi, Gurugram, Noida, etc.) then exact match then substring match against `_allCities` | `lib/screens/location_screen.dart` |
| Android permissions added: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` | `android/app/src/main/AndroidManifest.xml` |
| Popular cities cards updated: Kolkata → `kolkata.png`, Pune → `pune.png`, Bengaluru → `bangalore.png`; `childAspectRatio` 0.9 → 0.78; image height 42 → 58; font size 11 → 13; gap 12 → 14 | `lib/screens/location_screen.dart` |
| `location_screen_resources/` registered as asset directory | `pubspec.yaml` |
| Responsive refactor across 9 files — hardcoded px replaced with `Responsive` utility calls; no visual design changes; `textScaler: 1.0` clamp in `main.dart` already covers font scaling | multiple files (see below) |
| → `home_screen.dart`: `Responsive.h(context, 421.0)` + `Responsive.w(context, 329.27)` for banner | `lib/screens/home_screen.dart` |
| → `build_skill_card.dart`: card `width: 290` → `Responsive.w(context, 290, min: 240)`, image `width: 120` → `Responsive.w(context, 120, min: 96)` | `lib/widgets/build_skill_card.dart` |
| → `new_on_tlb_card.dart`: image `width: 120` → `Responsive.w(context, 120, min: 96)` | `lib/widgets/new_on_tlb_card.dart` |
| → `special_focus_card.dart`: `SizedBox(height: 155)` → `Responsive.h(context, 155, min: 130)`, image `width: 120` → `Responsive.w(context, 120, min: 96)` | `lib/widgets/special_focus_card.dart` |
| → `categories_grid.dart`: category card `height: 110` → `Responsive.h(context, 110, min: 95)` | `lib/widgets/categories_grid.dart` |
| → `event_card_with_rating.dart`: button `height: 32` → `Responsive.h(context, 32, min: 28)` | `lib/widgets/event_card_with_rating.dart` |
| → `family_feels_section.dart`: button `height: 36` → `Responsive.h(context, 36, min: 32)` | `lib/sections/family_feels_section.dart` |
| → `events_screen.dart`: `SizedBox(width: 240)` → `Responsive.cardWidth(context, fraction: 0.62, max: 240)` | `lib/screens/events_screen.dart` |
| → `programs_screen.dart`: `width: 220` → `Responsive.cardWidth(context, fraction: 0.56, max: 220)`; `height: 160` × 2 → `Responsive.h(context, 160, min: 140)` | `lib/screens/programs_screen.dart` |

### Session 10
| Change | Files |
|--------|-------|
| `CategoryScreenHeader` AppBar title centered — replaced `Row(backArrow + Expanded(Text))` with `Stack(Align(left: backArrow) + Center(Text))` so title is truly centered on screen regardless of arrow width | `lib/widgets/category_screen_header.dart` |
| "All [Category]" section divider centered — fixed left line from fixed `width: 28` to `Expanded`, matching the right line; applies to all four category screens | `lib/screens/category_events_screen.dart`, `lib/screens/category_classes_screen.dart`, `lib/screens/category_programs_screen.dart`, `lib/screens/category_venues_screen.dart` |
| `categorySubFilters` (Events) fully replaced — Arts & Crafts: 8 subs; Performing Arts: 6 subs; STEM & Innovation: 7 subs; Sports & Fitness: 8 subs; Languages & Communication: 7 subs; Life Skills: 6 subs | `lib/data/dummy_data.dart` |
| `classesSubFilters` fully replaced — 11 categories with accurate subcategories: Academic (4), Creative Arts (11), Tech & Innovation (9), Performing Arts (4), Sports & Fitness (14), Speech & Communication (8), Life Skills & Personality Dev (4), Creative Media (6), Outdoor & Nature Learning (5), Culinary (3), Brain Boosters (5) | `lib/data/dummy_data.dart` |
| `programsSubFilters` fully replaced — 11 categories: Future Tech & AI (6), Design & Innovation (5), Leadership & Entrepreneurship (5), Media & Content Creation (6), Stage Arts & Performance (4), Active Sports & Training (5), Academics & Competitive Prep (4), Analytical Thinking (5), Language & Communication (6), Culinary & Hospitality (5), Grooming & Personality Development (5) | `lib/data/dummy_data.dart` |
| `venuesSubFilters` fully replaced — 8 categories: Play & Adventure (8), Sports & Active (8), Creative & DIY (6), Party & Celebration (5), Science & Discovery (6), Nature & Animals (7), Reading & Study (5), Dining & Cafes (5) | `lib/data/dummy_data.dart` |
| Scaffold background changed to `Colors.white` on all 4 category screens | `lib/screens/category_events_screen.dart`, `category_classes_screen.dart`, `category_programs_screen.dart`, `category_venues_screen.dart` |

### Session 11
| Change | Files |
|--------|-------|
| Password-based auth removed — `signup()` and `login()` methods deleted; old endpoints `/customer/email/signup/` and `/customer/email/login/` gone | `lib/services/auth_service.dart` |
| `requestOtp(identifier)` added — POST `/api/v1/auth/request-otp/`, sends OTP to email | `lib/services/auth_service.dart` |
| `verifyOtp(identifier, otp)` added — POST `/api/v1/auth/verify-otp/`, handles login + signup in one call; returns `access`, `refresh`, `is_new_user`, `user`; structured error handling for `OTP_INVALID`, `OTP_EXPIRED`, `USER_ROLE_MISMATCH`, rate limits | `lib/services/auth_service.dart` |
| `logout()` body key updated: `'refresh'` → `'refresh_token'` | `lib/services/auth_service.dart` |
| `refreshToken()` endpoint updated: `/api/v1/auth/token/refresh/` → `/api/v1/auth/refresh-token/`; body key: `'refresh'` → `'refresh_token'` | `lib/services/auth_service.dart` |
| `LoginScreen` password mode removed — deleted `_passwordController`, `_isPasswordMode`, `_obscurePassword`, `_onSignInWithPassword()`, password field, toggle button, forgot password link | `lib/widgets/login_sheet.dart` |
| `LoginScreen` OTP flow wired — `_onSendOTP()` now async, calls `requestOtp()`, navigates to `_OTPVerificationScreen(identifier: email)` on success | `lib/widgets/login_sheet.dart` |
| `_OTPVerificationScreen` real API wired — `_onVerify()` calls `verifyOtp()`; `is_new_user == true` → `markAsNewUser()` + `EditProfileScreen(isOnboarding: true)`; existing user → `showWelcomeBackDialog()` | `lib/widgets/login_sheet.dart` |
| `_OTPVerificationScreen` resend wired — `_onResendOtp()` calls `requestOtp()` with snackbar feedback | `lib/widgets/login_sheet.dart` |
| "Don't have an account? Sign Up" → "New here? Sign Up with OTP" — taps `_onSendOTP()` (same flow, no `SignupScreen` navigation) | `lib/widgets/login_sheet.dart` |
| `SignupScreen` removed from navigation flow (dead code); fixed compile error by replacing `AuthService.signup()` call with `AuthService.requestOtp()` | `lib/screens/signup_screen.dart` |
| `_InputField` widget simplified — removed unused `obscureText` and `suffix` params | `lib/widgets/login_sheet.dart` |

### Session 12 (Current)
| Change | Files |
|--------|-------|
| **Root fix: "Complete Your Profile" no longer shown to existing users** — removed `AuthState.isProfileComplete` check from `showWelcomeBackDialog()`; `onDone` now always navigates to `HomeScreen`; profile completion prompt is exclusively controlled by `is_new_user` flag from API | `lib/widgets/login_sheet.dart` |
| Google sign-in routing fixed — `_onGoogleSignIn()` now mirrors OTP flow: `is_new_user == true` → `markAsNewUser()` + `EditProfileScreen(isOnboarding: true)`; existing user → `showWelcomeBackDialog()` | `lib/widgets/login_sheet.dart` |
| `getProfile(accessToken)` added — GET `/api/v1/customer/profile/`, returns profile with `is_completed` flag | `lib/services/auth_service.dart` |
| `updateProfile()` rewritten — endpoint changed from `PATCH /api/v1/auth/users/me/` to `PATCH /api/v1/customer/profile/`; MultipartRequest removed (now JSON body); fields updated to `first_name`, `last_name`, `phone_number`, `gender`, `birthdate`, `region`; returns `{'success', 'profile'}` | `lib/services/auth_service.dart` |
| `AuthState.updateProfileData(profile)` added — accepts profile object directly from profile API and merges into `userData`; fires `userName` notifier | `lib/providers/auth_state.dart` |
| `AuthState.isProfileComplete` updated — checks `is_completed` flag from new API first, falls back to `first_name` non-empty check | `lib/providers/auth_state.dart` |
| `EditProfileScreen` fields updated — removed: city, state, guardian_name, institution_name, institution_type, avatar upload, Education section, Guardian Details section; added: phone_number, gender dropdown (male/female/other/prefer_not_to_say), region; renamed `dateOfBirth` → `birthdate` | `lib/screens/edit_profile_screen.dart` |
| `EditProfileScreen` save wired to new API — calls `AuthService.updateProfile()` with new fields → `AuthState.updateProfileData(result['profile'])` | `lib/screens/edit_profile_screen.dart` |
| `dart:io` and `image_picker` imports removed from EditProfileScreen (no longer needed without avatar upload) | `lib/screens/edit_profile_screen.dart` |
| Change | Files |
|--------|-------|
| `CategoryScreenHeader` AppBar title centered — replaced `Row(backArrow + Expanded(Text))` with `Stack(Align(left: backArrow) + Center(Text))` so title is truly centered on screen regardless of arrow width | `lib/widgets/category_screen_header.dart` |
| "All [Category]" section divider centered — fixed left line from fixed `width: 28` to `Expanded`, matching the right line; applies to all four category screens | `lib/screens/category_events_screen.dart`, `lib/screens/category_classes_screen.dart`, `lib/screens/category_programs_screen.dart`, `lib/screens/category_venues_screen.dart` |
| `categorySubFilters` (Events) fully replaced — Arts & Crafts: 8 subs; Performing Arts: 6 subs; STEM & Innovation: 7 subs; Sports & Fitness: 8 subs; Languages & Communication: 7 subs; Life Skills: 6 subs | `lib/data/dummy_data.dart` |
| `classesSubFilters` fully replaced — 11 categories with accurate subcategories: Academic (4), Creative Arts (11), Tech & Innovation (9), Performing Arts (4), Sports & Fitness (14), Speech & Communication (8), Life Skills & Personality Dev (4), Creative Media (6), Outdoor & Nature Learning (5), Culinary (3), Brain Boosters (5) | `lib/data/dummy_data.dart` |
| `programsSubFilters` fully replaced — 11 categories: Future Tech & AI (6), Design & Innovation (5), Leadership & Entrepreneurship (5), Media & Content Creation (6), Stage Arts & Performance (4), Active Sports & Training (5), Academics & Competitive Prep (4), Analytical Thinking (5), Language & Communication (6), Culinary & Hospitality (5), Grooming & Personality Development (5) | `lib/data/dummy_data.dart` |
| `venuesSubFilters` fully replaced — 8 categories: Play & Adventure (8), Sports & Active (8), Creative & DIY (6), Party & Celebration (5), Science & Discovery (6), Nature & Animals (7), Reading & Study (5), Dining & Cafes (5) | `lib/data/dummy_data.dart` |
