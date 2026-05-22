# TLB Mobile UI — Development Graph
**Project:** The Little Broadways (TLB) — Event Booking App  
**Stack:** Flutter (Dart) · Firebase Auth · Google Sign-In · REST API  
**Package:** `com.thelittlebroadway.tlb_mobile_ui`  
**API Base:** `https://tlb-api.reluconsultancy.in`  
**Last Updated:** 2026-05-22 (Session 39)

---

## 1. Project Architecture

```
lib/
├── main.dart                      Entry point — Firebase init, tryRestoreSession(), SplashScreen → HomeScreen
├── core/                          Config/constants only
│   ├── app_colors.dart            Centralized color constants
│   ├── app_theme.dart             MaterialApp ThemeData
│   ├── app_snackbar.dart          AppSnackBar.show/error/success helpers
│   ├── app_spacing.dart           AppSpacing semantic spacing constants
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
├── services/
│   ├── wishlist_service.dart      fetchWishlist / add / remove — REST calls to /api/v1/wishlist/
│   ├── review_service.dart        fetchReviews / createReview / updateReview / deleteReview — /api/v1/listings/{id}/reviews/ + /api/v1/reviews/{id}/
│   └── partner_service.dart       follow(token, partnerId) → POST /api/v1/partner/{id}/follow/; unfollow → DELETE /api/v1/partner/{id}/unfollow/
├── models/
│   ├── event_model.dart           Core data model — title, venue, price, rating, date, image, etc.
│   ├── category_model.dart        Category model with label, image, color
│   ├── api_category_model.dart    API-backed category — id, name, slug, sortOrder, subcategories
│   ├── api_event_model.dart       API models: ApiEvent (list), ApiEventDetail (full), ApiEventsPage; ApiEventOrganizer has partnerId: String?
│   ├── api_provider_model.dart    ApiProvider — id, name, bio, logoUrl, totalListings, averageRating, totalReviews, experienceYears
│   ├── api_review_model.dart      ApiReviewMedia, ApiReview, ApiReviewPage (nested reviews.results pagination)
│   └── api_venue_model.dart       API models: ApiVenue (list), ApiVenueDetail (full), ApiVenuesPage,
│                                  ApiVenueCategory, ApiVenueMedia, ApiVenuePackage,
│                                  ApiVenueAvailability, ApiVenueOccasion;
│                                  ApiVenueOrganizer/ApiClassOrganizer/ApiProgramOrganizer all have partnerId: String?
├── services/
│   └── events_listing_service.dart  REST calls for events + venues listing APIs (see Section 6)
├── data/
│   └── dummy_data.dart            All mock data — events, categories, banners, partners, etc.
├── screens/                       48 screens (see Section 3)
├── widgets/                       25+ reusable widgets incl. login_sheet.dart, walkthrough_intro_overlay.dart (see Section 4)
└── sections/                      9 home-page sections (see Section 5)
```

---

## 2. Navigation Flow

```
SplashScreen
    └── HomeScreen  (Tab: Home)
        ├── EventsScreen        (Tab: Events)
        │   ├── CategoryEventsScreen
        │   │   └── EventDetailScreen → DateTimeSelectionScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
        │   ├── FormatEventsScreen (format circle tap → filtered events by format slug)
        │   └── EventDetailScreen (same checkout flow)
        ├── ClassesScreen       (Tab: Classes)
        │   ├── ClassDetailScreen → SelectBatchScreen → AttendeeDetailsScreen → ReviewPayScreen → BookingConfirmedScreen
        │   └── CategoryClassesScreen
        ├── ProgramsScreen      (Tab: Programs)
        │   ├── ProgramDetailScreen → SelectProgramBatchScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
        │   └── CategoryProgramsScreen
        └── VenuesScreen        (Tab: Venues)
            ├── VenueDetailScreen → PlanPartyScreen → VenueCheckoutScreen → ReviewPayScreen → VenueBookingConfirmedScreen
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
        │   └── OtpVerificationScreen → EditProfileScreen(isOnboarding: true) [new user] | HomeScreen [existing]
        ├── ForgotPasswordScreen
        └── OtpVerificationScreen → WelcomeBackDialog [existing] | EditProfileScreen(isOnboarding: true) [new user]
```

---

## 3. Screens (46 total)

### Home & Shell
| File | Description |
|------|-------------|
| `splash_screen.dart` | Logo animation → HomeScreen |
| `home_screen.dart` | Main scroll page with all home sections + FloatingNavbar |

### Auth
| File | Description |
|------|-------------|
| `widgets/login_sheet.dart` | Full-screen login — email OTP + Google (Firebase Auth). "Signup" link → SignupScreen. OTP verify → `OtpVerificationScreen(onExistingUser: showWelcomeBackDialog)`. WelcomeBackDialog always → HomeScreen |
| `signup_screen.dart` | Email-only OTP signup — email field → `OtpVerificationScreen`; Google sign-up via Firebase Auth. "Log In" link → `Navigator.pop()`. No password fields |
| `otp_verification_screen.dart` | Shared 6-box OTP screen — accepts `identifier` (email) + `onExistingUser` callback; new user → `markAsNewUser()` + `EditProfileScreen(isOnboarding: true)`; existing user → calls callback |
| `forgot_password_screen.dart` | 3-step OTP password reset wizard — Step 0: email entry → "Send OTP"; Step 1: 6-box OTP verification with resend link; Step 2: new+confirm password fields → success dialog with confetti |
| `change_password_screen.dart` | Authenticated password change |

### Main Tab Screens
| File | Description |
|------|-------------|
| `events_screen.dart` | Full events listing — banners, categories grid, trending, weekend, holiday, partners, new-on-TLB, online |
| `classes_screen.dart` | Classes listing — banners, pick-your-pace, featured, nearby, camp cards |
| `programs_screen.dart` | Programs listing — banners, categories, unique minds, level-up cards |
| `venues_screen.dart` | Venues listing — 9 dummy sections: big days, weekend plans, close-to-you, out & about, get moving, hands-on, easy pocket, mall, thoughtful. All sections retain dummy data. |

### Detail & Booking Flow
| File | Description |
|------|-------------|
| `event_detail_screen.dart` | Full event detail — StatefulWidget; fetches `GET /api/v1/listings/events/{id}/` when `event.id` is non-empty; falls back to dummy `EventModel` fields for non-API cards. Shows hero, info, availability, gallery, map, reviews, "Book Now" CTA |
| `class_detail_screen.dart` | Class detail — StatefulWidget; fetches `GET /api/v1/listings/classes/{id}/`. CTA gated on `booking_type`: `direct_booking` → "Check Availability" → `SelectBatchScreen(batches)`; otherwise → "Send Enquiry" → `showInquireNow()` |
| `program_detail_screen.dart` | Program detail — StatefulWidget; fetches `GET /api/v1/listings/programs/{id}/`. CTA gated on `_detail?.bookingType`: `direct_booking` → "Check Availability" → `SelectProgramBatchScreen(batches)`; otherwise → "Enquire Now" → `showInquireNow()`. Shows hero, schedule, Things to Know, gallery, map, organizer, reviews |
| `venue_detail_screen.dart` | Venue detail — StatefulWidget; fetches `GET /api/v1/listings/venues/{id}/` when `event.id` is non-empty; falls back to dummy `EventModel` fields. Shows cover, category tag, availability slot, About, Things to Know, Packages, Gallery, Location map, Organizer. "Plan Event" CTA → PlanPartyScreen |
| `date_time_selection_screen.dart` | Pick date + time → TicketBookingScreen |
| `select_batch_screen.dart` | Classes batch selection — real `List<ApiClassBatch>` data; date chips computed from batch days pattern (next 5 upcoming dates); selecting a batch refreshes dates; batch card shows time range, days, name tag → Continue → AttendeeDetailsScreen(bookingType: 'class', batchId) |
| `select_program_batch_screen.dart` | Programs batch selection — real `List<ApiProgramBatch>` data; same pattern as `SelectBatchScreen`; `daysOfWeek` handles both full ("monday") and short ("mon") day names; nullable `startTime`/`endTime` ("Time TBA" fallback); `totalSeats` chip when non-null; name tag with 5-color palette → Continue → TicketBookingScreen |
| `ticket_booking_screen.dart` | Ticket count + price breakdown → ReviewPayScreen |
| `review_pay_screen.dart` | Order summary → PaymentScreen |
| `payment_screen.dart` | Payment method selection |
| `booking_confirmed_screen.dart` | Booking success — animated teaser flip → ticket card with full-width image, notch cut + dashed divider (CustomPainter), QR, Share/Download actions |
| `venue_booking_confirmed_screen.dart` | Venue booking success — non-ticket design; animated ScaleTransition + FadeTransition green checkmark (700ms elasticOut); yellow-header summary card (venue, location, date, time, booking ref); PopScope prevents back navigation; "View My Bookings" → BookingsScreen, "Explore More" → HomeScreen |
| `seat_reservation_screen.dart` | Interactive seat map |
| `plan_party_screen.dart` | Venue planning screen — planner's name, API occasion chips (Wrap, multi-row), API availability date chips + time slot chips, numeric attendees field with min/max capacity validation → VenueCheckoutScreen |
| `venue_checkout_screen.dart` | Venue checkout — cover image card, date/time from selected slot, attendee count + occasion info chip, package selection with Add/+/- qty controls, bill details (subtotal + 8.26% taxes + total) → ReviewPayScreen(bookingType:'venue', slotId, packageId, guestCount) |

### Category Screens
| File | Description |
|------|-------------|
| `category_events_screen.dart` | Filtered events by category — fetches `GET /api/v1/listings/events/` with category slug; shows API cards (network image, navigates to EventDetailScreen with real `id`); falls back to SubcategoryEmptyState |
| `format_events_screen.dart` | Filtered events by format — animated gradient header that transitions color per selected format; horizontal format circle selector row (6 circles, animated selection ring); fetches `GET /api/v1/listings/events/?format=slug`; grid of `CategoryEventCard`; `SubcategoryEmptyState` when no results; error snackbar with friendly message |
| `category_classes_screen.dart` | Filtered classes by category |
| `category_programs_screen.dart` | Filtered programs by category — fetches program categories from `/api/v1/listings/programs/metadata/categories/` on init; resolves `category_id` (int) by normalized name match; passes `categoryId`/`subcategoryId` integers to `fetchPrograms()`; subcategory filter chips come from API `ApiSubcategory` objects (real IDs), falls back to dummy strings if metadata unavailable |
| `category_venues_screen.dart` | Filtered venues by category — fetches `GET /api/v1/listings/venues/` with matched `category_id`; name-matched from venue categories metadata; uses flat `CategoryEventCard` (navigates to VenueDetailScreen); falls back to SubcategoryEmptyState |
| ~~`category_detail_screen.dart`~~ | ~~Generic category detail~~ — **deleted** (replaced by CategoryEventsScreen/CategoryVenuesScreen) |

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
| `search_screen.dart` | Real-time search across all 4 entity types — 500ms debounced input fires parallel API calls to events, classes, programs, venues with `search=` param; unified result list with color-coded type badges (Event/Class/Program/Venue) and cover thumbnails; entity filter chips (All/Events/Classes/Programs/Venues); filter bottom sheet (Age Group, Mode, Location, Date) retained; idle/loading/no-results states |
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
| `partner_follow_button.dart` | Follow/Unfollow stateful button — grey outlined "Follow" / yellow filled "Following"; auth guard; optimistic update; returns `SizedBox.shrink()` when partnerId is null |
| `explore_categories_grid.dart` | 3-col category icon grid. `scrollable: true` + `visibleRows` = fixed-height inner scroll with "View All" chip overlaid at bottom |
| `explore_format_row.dart` | Horizontal format circles row — 6 pre-designed circle images from `Explore_by_format/`; `onFormatTap(index)` callback; `ColorFilter.matrix` inversion for MasterClass; `Transform.scale` per-entry zoom; `ClipOval + BoxFit.cover` |
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
| `category_event_card.dart` | Flat grid card for category screens (no container/shadow) — 12px rounded image, subcategory badge, title, 📍 venue, ⭐ reviewCount row, `Description –` body up to 3 lines (no price); accepts `onTap` callback override; used by CategoryEvents/Classes/Programs/VenuesScreen |
| `app_loader.dart` | Premium branded loading animation (bouncing dots). Uses `AppLoader.useCustomLoader` static flag for fallback to default `CircularProgressIndicator`. Contains `AppLoader()` (fullscreen) and `AppLoaderInline()` (buttons/spinners). |

---

## 5. Sections (Home Page, 9 active)

| Section | Content |
|---------|---------|
| `home_header.dart` | Gradient header (#FFB219 → white), first-name greeting (ValueListenableBuilder on `userName`), location, alert icon, avatar (ValueListenableBuilder on `avatarUrl`), search bar |
| `hot_picks_section.dart` | Hot picks card list |
| `weekend_special_section.dart` | Weekend event chips |
| `discover_near_you_section.dart` | Location-based cards |
| `family_feels_section.dart` | Family events section |
| `special_needs_section.dart` | Inclusive/special-needs events |
| `stealers_section.dart` | Deal/discount events |
| `tlb_signature_section.dart` | TLB signature events |
| `app_footer.dart` | `resources- tlb-ui/main-footer.png` with 60px top gap |

> Spotlight is rendered inline in `home_screen.dart` via `BannerCarousel`. The "Explore the Stage" category grid is `widgets/categories_grid.dart` (also inline).

---

## 6. Core Services & State

### EventsListingService (`lib/services/events_listing_service.dart`)
- Base URL: `https://tlb-api.reluconsultancy.in` · 30-second timeout · no auth token required
- All methods throw typed `Exception` messages for `SocketException` and `TimeoutException`
- **`fetchCategories()`** — GET `/api/v1/listings/events/metadata/categories/` → `List<ApiCategory>`
- **`fetchEvents({category, subcategory, format, mode, ageGroup, city, area, datePreset, priceType, search, page, pageSize})`** — GET `/api/v1/listings/events/` → `ApiEventsPage`; 404 treated as empty page (not error); nested `body['error']` Map `{code, message}` is extracted to readable string; `search` maps to `?search=` query param
- **`fetchEventDetail(listingId)`** — GET `/api/v1/listings/events/{id}/` → `ApiEventDetail`
- **`fetchVenueCategories()`** — GET `/api/v1/listings/venues/metadata/categories/` → `List<ApiCategory>` *(backend not yet live — callers catch silently)*
- **`fetchVenues({categoryId, city, area, locationType, isFeatured, isTopRated, isNewThisWeek, search, page, pageSize})`** — GET `/api/v1/listings/venues/` → `ApiVenuesPage`; same 404 + nested error handling as `fetchEvents`; `search` maps to `?search=` query param
- **`fetchVenueDetail(listingId)`** — GET `/api/v1/listings/venues/{id}/` → `ApiVenueDetail`
- **`fetchProvider(listingId)`** — GET `/api/v1/listings/{id}/provider/` → `ApiProvider`; handles both direct object and `{success, data}` envelope; Redis-cached on backend

### API Models
**`ApiCategory`** — `id, name, slug, sortOrder, subcategories: List<ApiSubcategory>`  
**`ApiEvent`** (list) — `id, title, category, subcategory, city, area, cover, isFeatured, startDate, endDate, mode, ageGroup`  
**`ApiEventDetail`** (extends ApiEvent) — adds `description, address, locationType, minAge, maxAge, price, priceType, media, schedules, organizer, cancellationPolicy, refundPolicy, faqs: List<Map<String,String>>`  
**`ApiVenue`** (list) — `id, title, category, city, area, cover, isFeatured, isNewThisWeek, isTopRated, distanceKm`  
**`ApiVenueDetail`** (extends ApiVenue) — adds `description, subcategory, locationType, address, minAge, maxAge, minCapacity, maxCapacity, media, packages, availability, organizer, cancellationPolicy, refundPolicy, faqs: List<Map<String,String>>`  
**`ApiVenuePackage`** — `id, name, price (double — parsed from "2500.00" string), description, durationMinutes, maxGuests`  
**`ApiVenueAvailability`** — `id, date ("2026-06-14"), startTime ("10:00:00"), endTime ("13:00:00"), note`  
**`ApiVenueOccasion`** — `id, name, slug` — API-fetched occasions for venue booking (e.g. Birthday Party, Weekend Fun, Community Event); added to `ApiVenueDetail.occasions`  
**`ApiProgramDetail`** (extends ApiProgram) — adds `description, area, address, maxCapacity, totalHours, moduleCount, bookingType (String — "enquiry" | "direct_booking"), subcategory, tags, batches, faqs, cancellationPolicy, refundPolicy, media, organizer`  
**`ApiProgramBatch`** — `id, name, startDate?, endDate?, startTime?, endTime?, fee?, totalSeats?, isActive, daysOfWeek: List<String>`

### API ↔ UI Gating Pattern
All 4 detail screens (`EventDetailScreen`, `ClassDetailScreen`, `ProgramDetailScreen`, `VenueDetailScreen`) accept `EventModel event` (legacy wrapper).  
`event.id.isNotEmpty` → fetch from API in `initState`; `event.id == ''` → show dummy `EventModel` fields without any network call.  
Dummy cards from listing screens pass `id = ''`, so they display gracefully without API.  
CTA gating: `ClassDetailScreen` and `ProgramDetailScreen` check `_detail?.bookingType == 'direct_booking'` to show "Check Availability" (→ batch selection) vs "Send Enquiry"/"Enquire Now" (→ enquiry popup).

### AuthService (`lib/services/auth_service.dart`)
- All methods have **30-second timeout**
- Typed error handling: `SocketException` → "Cannot reach server", `TimeoutException` → "Request timed out", `HandshakeException` → "SSL error"
- **Response envelope:** All TLB API responses use `{"success": bool, "data": {...}, "error": {"code": "...", "message": "..."}}`. `_inner(body)` unwraps `body['data']`. `_extractError(body)` reads `body['error']['message']` first, then falls back to flat DRF keys.
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
  GoogleSignIn(scopes: ['email','profile']).signOut()  ← force account picker
  GoogleSignIn(scopes: ['email','profile']).signIn()
  → googleUser.authentication (accessToken + idToken)
  → FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(...))
  → fbCredential.user.getIdToken()  ← Firebase ID token (NOT raw Google token)
  → AuthService.googleSignIn(idToken: firebaseToken)
  → POST /api/v1/auth/google-login/ body {"id_token": firebaseToken}
  → AuthState.login(access, refresh, user)
  → is_new_user == true  → markAsNewUser() + EditProfileScreen(isOnboarding: true)
     is_new_user == false → showWelcomeBackDialog() [login] | HomeScreen [signup]

API returns is_new_user flag — same endpoint handles both sign-in & sign-up.
Backend expects Firebase ID token, not raw Google token. serverClientId not needed.
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
resources- tlb-ui/event_page_subcategoryicons/          — 3D character icons per category
resources- tlb-ui/event_page_subcategoryicons/Explore_by_format/  — pre-designed circle images: Workshops.png, camp.png, competition.png, masterclass.png, shocase.png, demo.png
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
SelectBatchScreen (Classes) — real API data:
  Constructor: EventModel event + List<ApiClassBatch> batches
  Date chips: _nextDates(batch) computes next 5 upcoming dates whose weekday matches batch.days
              (batch.days uses "mon"/"tue"/... → mapped to DateTime.weekday 1–7)
              Selecting a different batch refreshes both dates and resets _dateIdx = 0
  Batch cards: time range (_fmt12h: "13:00:00" → "1 PM"), days (_dayLabel: "Sat, Su"),
               batch.name as tag pill with 5-color palette (teal/purple/green/amber/rose)
  "Batch starting from" card: shows _dates[_dateIdx] or "TBA" when no batches
  Continue → TicketBookingScreen(event, selectedDate, selectedTime)

SelectProgramBatchScreen (Programs) — real API data:
  Constructor: EventModel event + List<ApiProgramBatch> batches
  Date chips: _nextDates(batch) computes next 5 upcoming dates from batch.daysOfWeek
              (handles full names "monday" and short "mon" via first-3-chars truncation)
              Selecting a different batch refreshes both dates and resets _dateIdx = 0
  Batch cards: _timeRange() handles nullable startTime/endTime ("Time TBA" when absent)
               _dayLabel() from daysOfWeek | batch.name as tag pill (5-color palette)
               totalSeats shown as red seats chip when non-null (API field)
  "Batch starting from" card: shows _dates[_dateIdx] or "TBA" when no batches
  Continue → TicketBookingScreen(event, selectedDate, selectedTime)
```

### Plan Party / Venue Booking Flow
```
VenueDetailScreen "Plan Event" → PlanPartyScreen → VenueCheckoutScreen → ReviewPayScreen → VenueBookingConfirmedScreen

PlanPartyScreen:
  Fields: Planner's Name | Occasion (Wrap chips from API venueDetail.occasions, fallback to hardcoded) |
          Date chips (Wrap from venueDetail.availability unique dates) |
          Time slot chips (shown after date selected, from API slots for that date) |
          Number of Attendees (numeric TextField; validated against minCapacity / maxCapacity)
  Auto-selects slot when only one exists for the picked date
  _availableDates: unique sorted dates from venueDetail.availability
  _slotsForSelectedDate: all slots whose date matches _selectedDateStr
  Continue validation: name → occasion → slot (not null) → attendeeCount > 0 → capacity range
  MiniMapPainter for venue thumbnail in info card

VenueCheckoutScreen:
  Constructor: EventModel event, ApiVenueDetail? venueDetail, String childName,
               String occasion, ApiVenueAvailability? selectedSlot, int attendeeCount
  Package selection: Add/+/- qty controls; first package pre-selected; _packageQty: Map<int, int>
  _displayDateTime: reads from selectedSlot.date / startTime / endTime directly (no fuzzy matching)
  Bill: subtotal + 8.26% taxes + total (both shown in Bill Details card)
  Sticky CTA: "Pay ₹X  |  Continue to payment"
  On continue: validates subtotal > 0 and slot != null; builds ticketDetails string; pushes ReviewPayScreen

VenueBookingConfirmedScreen:
  Constructor: EventModel event, String selectedDate, String selectedTime, String bookingReference
  AnimationController (700ms, elasticOut): ScaleTransition + FadeTransition on green checkmark
  Yellow-header summary card with venue name, location icon row, date/time, booking reference
  Blue info note about confirmation email
  PopScope(canPop: false) — back navigation disabled on confirmation screen
  "View My Bookings" → BookingsScreen | "Explore More" → HomeScreen (both replace current route)
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

### "Explore the Stage" Category Grid (Home Screen)
```
CategoriesGrid (lib/widgets/categories_grid.dart):

Section header:
  Row — Expanded(_buildLine isLeft:true) + Text("Explore the Stage") + Expanded(_buildLine isLeft:false)
  Lines: gradient Container(height:1.2) — transparent → Color(0xFFCFAD6A) (left) / reverse (right)
  Title: Poppins 15sp w700, Color(0xFF5A5A5A)
  Padding: horizontal 16, vertical 20

Grid:
  Padding(horizontal: 16) → LayoutBuilder → GridView.builder(shrinkWrap:true, NeverScrollableScrollPhysics)
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, crossAxisSpacing:14, mainAxisSpacing:14)
  childAspectRatio: computed = cellWidth / Responsive.h(context, 178, min:158)
  cellWidth = (constraints.maxWidth - 14) / 2

Card (_buildCategoryCard):
  Stack(fit: StackFit.expand)               ← tight constraints → card fills grid cell exactly
    Container(decoration: BoxDecoration(
      gradient: LinearGradient topCenter→bottomCenter
        Color(0xFFF0E6D0) [0.0] → Color(0xFFF0E6D0) [0.58] → Colors.white [1.0]
      borderRadius: 20
      boxShadow: left(-4,0) + right(4,0) + top(0,-2) — no bottom shadow → seamless bottom blend
    ))
      Column: Expanded(Image.asset) + Text(label, 14sp w700) + SizedBox(3) + Padding(bottom:14)(Text subtitle, 11sp grey)
    Positioned.fill → CustomPaint(_ThreeSidedBorderPainter)

_ThreeSidedBorderPainter:
  Draws Path: moveTo(0,h) → lineTo(0,r) → arcToPoint(r,0) → lineTo(w-r,0) → arcToPoint(w,r) → lineTo(w,h)
  Omits bottom edge — card gradient is white at bottom, matching page → fully seamless

homeCategories data (dummy_data.dart):
  {label: 'Events',   subtitle: 'Join The Fun',     image: '.../events.png'}
  {label: 'Classes',  subtitle: 'Build Your Skill',  image: '.../classes.png'}
  {label: 'Programs', subtitle: 'Master The Craft',  image: '.../programs.png'}
  {label: 'Venues',   subtitle: 'Find Your Space',   image: '.../venues.png'}
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
[Events]  EventDetailScreen   → DateTimeSelectionScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
[Classes] ClassDetailScreen   → SelectBatchScreen → AttendeeDetailsScreen → ReviewPayScreen → BookingConfirmedScreen
[Program] ProgramDetailScreen → SelectProgramBatchScreen → TicketBookingScreen → ReviewPayScreen → BookingConfirmedScreen
[Venues]  VenueDetailScreen   → PlanPartyScreen → VenueCheckoutScreen → ReviewPayScreen → VenueBookingConfirmedScreen
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
| ~~CategoryEventsScreen API fetch~~ | `category_events_screen.dart` | ✅ Done — fetches live events by category slug; name-matched from metadata API |
| ~~CategoryVenuesScreen API fetch~~ | `category_venues_screen.dart` | ✅ Done — fetches live venues by category_id; name-matched from venue metadata API |
| ~~EventDetailScreen real data~~ | `event_detail_screen.dart` | ✅ Done — StatefulWidget; `event.id.isNotEmpty` gates API fetch; dummy cards still work |
| ~~VenueDetailScreen real data~~ | `venue_detail_screen.dart` | ✅ Done — StatefulWidget; fetches detail including packages, availability, gallery, organizer |
| ~~ProgramDetailScreen booking_type CTA~~ | `program_detail_screen.dart` | ✅ Done — `direct_booking` → "Check Availability" → `SelectProgramBatchScreen`; otherwise → "Enquire Now" → `showInquireNow()` |
| ~~SelectProgramBatchScreen real batch data~~ | `select_program_batch_screen.dart` | ✅ Done — accepts `List<ApiProgramBatch>`; real date computation from `daysOfWeek`; nullable time handling |
| ~~CategoryProgramsScreen API category filter~~ | `category_programs_screen.dart` | ✅ Done — fetches metadata, resolves `category_id` + `subcategory_id` integers; subcategory chips from API |
| ~~Set real Razorpay key~~ | `lib/core/app_config.dart` | ✅ Done (Session 35) — `rzp_test_SpYAGfwgdidCZq` |
| ~~All Bookings screen — real API~~ | `bookings_screen.dart`, `booking_detail_screen.dart`, `booking_service.dart`, `api_booking_model.dart` | ✅ Done (Session 36) — fetches `GET /api/v1/bookings/`; tab filter per API status; cancel flow with `POST /api/v1/bookings/{id}/cancel/` |
| ~~PlanPartyScreen → booking confirmation~~ | `plan_party_screen.dart`, `venue_checkout_screen.dart`, `venue_booking_confirmed_screen.dart` | ✅ Done (Session 37) — full flow: PlanPartyScreen → VenueCheckoutScreen → ReviewPayScreen → VenueBookingConfirmedScreen |
| ~~T&C real API data on all 4 detail screens~~ | all 4 detail screens + 3 models | ✅ Done (Session 39) — `cancellationPolicy`, `refundPolicy`, `faqs` fetched from API; hardcoded fallback sections removed; T&C row hidden when no data |
| ~~Category classes filter label mismatch~~ | `category_classes_screen.dart`, `dummy_data.dart` | ✅ Done (Session 39) — `apiName` mapping added to all 11 `classesCategories`; `_apiCategoryName` getter resolves correct backend string |
| Profile screen reactive to name/avatar changes | `profile_screen.dart` | ❌ Pending — reads `AuthState.userName.value` but no `ValueListenableBuilder`; won't update on profile edit without navigate-back rebuild |
| Profile avatar upload | `edit_profile_screen.dart` | ❌ Pending — removed from profile form (new API has no avatar field); needs separate endpoint when available |
| Startup profile completion check | `main.dart` | ❌ Pending — `tryRestoreSession()` restores session but does NOT redirect incomplete profiles |
| Venue metadata categories endpoint | backend | ❌ Pending — `GET /api/v1/listings/venues/metadata/categories/` not yet live; `fetchVenueCategories()` catch is silent so category filter falls back to fetching all venues |
| **Backend Razorpay SDK missing for venues** | backend server | ❌ Pending — `POST /api/v1/bookings/initiate/` with `booking_type:'venue'` returns `PAYMENT_GATEWAY_NOT_CONFIGURED`; backend's venue booking handler needs `pip install razorpay`, `razorpay` in `requirements.txt`, and `RAZORPAY_KEY_ID`/`RAZORPAY_KEY_SECRET` env vars; events already work; mobile app shows user-friendly message "Online payment is temporarily unavailable for this booking. Please contact support." |

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
url_launcher: ^6.3.2           # External URL / deep-link launching
image_picker: ^1.2.2         # Review media upload (re-added in Session 24)
razorpay_flutter: ^1.4.5     # Razorpay payment gateway SDK (added Session 34)
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

### Session 13
| Change | Files |
|--------|-------|
| `homeCategories` updated — added `subtitle` field per entry: Events → "Join The Fun", Classes → "Build Your Skill", Programs → "Master The Craft", Venues → "Find Your Space"; fixed label `'Program'` → `'Programs'` | `lib/data/dummy_data.dart` |
| `CategoriesGrid` fully redesigned — new "Explore the Stage" section title with gold gradient lines (same pattern as `SectionDividerWidget`); 2×2 card layout with warm cream (`#F0E6D0`) gradient fading to white; subtitle text below category name; 3-sided border (left/top/right only) via `_ThreeSidedBorderPainter` (`CustomPainter`) so bottom blends seamlessly into white page; side-only `BoxShadow` (left + right offsets, no bottom) | `lib/widgets/categories_grid.dart` |
| Grid layout switched from `Column + Row` to `GridView.builder` — `LayoutBuilder` computes `childAspectRatio = cellWidth / cardHeight` at runtime, ensuring cards fill available width symmetrically with no right-side gap | `lib/widgets/categories_grid.dart` |
| `Stack(fit: StackFit.expand)` used inside card — replaces `StackFit.loose`; passes tight cell constraints down to the `Container` so card fills the grid cell width exactly (fixes right-side gap bug) | `lib/widgets/categories_grid.dart` |
| Fixed `height:` removed from card `Container` — grid cell dimensions (via `childAspectRatio`) drive sizing; `Expanded` inside the card `Column` takes remaining height for the image | `lib/widgets/categories_grid.dart` |
| `SizedBox(height: 24)` before `CategoriesGrid` removed from `HomeScreen` — grid now includes its own top padding via the section title `Padding(vertical: 20)` | `lib/screens/home_screen.dart` |

### Session 14
| Change | Files |
|--------|-------|
| `ApiCategory`, `ApiSubcategory` models added — id, name, slug, sortOrder, subcategories | `lib/models/api_category_model.dart` (NEW) |
| `ApiEvent`, `ApiEventDetail`, `ApiEventsPage` models added — list + detail shapes from events API | `lib/models/api_event_model.dart` (NEW) |
| `ApiVenue`, `ApiVenueDetail`, `ApiVenuesPage`, `ApiVenueCategory`, `ApiVenueMedia`, `ApiVenuePackage`, `ApiVenueAvailability`, `ApiVenueOrganizer` models added | `lib/models/api_venue_model.dart` (NEW) |
| `EventsListingService` added — 6 methods covering events + venues listing and detail endpoints with 30s timeout and typed error handling | `lib/services/events_listing_service.dart` (NEW) |
| `CategoryEventsScreen` wired to live API — `initState` fetches categories then events by matched slug; `_ApiEventCard` shows network cover, navigates to `EventDetailScreen` with real `id`; `SubcategoryEmptyState` shown when no results | `lib/screens/category_events_screen.dart` |
| `CategoryVenuesScreen` wired to live API — fetches venue categories (silently ignored if endpoint not live), matches category label by name to resolve `category_id`, fetches venues; `_ApiVenueCard` with network image navigates to `VenueDetailScreen` with real `id` | `lib/screens/category_venues_screen.dart` |
| `EventDetailScreen` rewritten as `StatefulWidget` — `event.id.isNotEmpty` gates `fetchEventDetail()` in `initState`; loading spinner + retry error state; renders cover (network/asset), availability, About, gallery, location, organizer; dummy `event.id == ''` cards still display without API call | `lib/screens/event_detail_screen.dart` |
| `VenueDetailScreen` rewritten as `StatefulWidget` — same gating pattern as EventDetailScreen; new Packages section (`_buildPackageCard`) with name, description, duration_minutes, max_guests, price; first availability slot formatted as "Day, Mon DD, HH:MM AM – HH:MM PM"; Things to Know (age group, capacity, venue type); Gallery uses `galleryMedia` (non-cover media); Organizer section hidden when null; bottom bar shows lowest package price | `lib/screens/venue_detail_screen.dart` |
| `venues_screen.dart` kept fully intact — all 9 dummy sections unchanged; only `CategoryVenuesScreen` fetches live data | `lib/screens/venues_screen.dart` |

### Session 15
| Change | Files |
|--------|-------|
| Dead code audit — 18 orphaned files deleted | (see below) |
| Deleted 8 unused home sections no longer rendered in `home_screen.dart`: `browse_by_categories_section`, `spotlight_section`, `trending_now_section`, `popular_categories_section`, `featured_events_section`, `best_for_week_section`, `kids_favorites_section`, `near_you_section` | `lib/sections/` |
| `section_header.dart` deleted — only used by the 8 dead sections above | `lib/widgets/section_header.dart` |
| Legacy category detail flow deleted — entire `widgets/category_detail/` subdirectory (4 files), `screens/category_detail_screen.dart`, `widgets/category_card.dart`; only callers were the dead sections | multiple |
| `widgets/horizontal_card_widget.dart` + `widgets/vertical_card_widget.dart` deleted — defined but never imported anywhere | `lib/widgets/` |
| `image_picker: ^1.2.2` removed from `pubspec.yaml` — was left over after avatar upload was removed in Session 12 | `pubspec.yaml` |
| `CategoryEventCard` redesigned to match `event_subcategory.png` reference — removed location pin icon (venue is now plain text); rating numeric removed, replaced with `⭐ reviewCount` only (row hidden when null); description now uses `RichText` with bold `Description:` label prefix; `category_venues_screen.dart` unaffected (uses its own inline `_ApiVenueCard`) | `lib/widgets/category_event_card.dart` |

### Session 16
| Change | Files |
|--------|-------|
| `CategoryEventCard` further refined — card container/shadow removed (flat layout, image direct on page); `ClipRRect(radius: 12)` on image only; location icon re-added (`Icons.location_on`, size 13, low opacity); info padding `fromLTRB(2,8,2,0)`; description changed to `Description – {text}` (em dash); `maxLines` raised to 3; `onTap` optional callback added for navigation override | `lib/widgets/category_event_card.dart` |
| `url_launcher: ^6.3.2` added to `pubspec.yaml` | `pubspec.yaml` |
| `AppLoader` widget created — pure-Flutter staggered bouncing-dots animation in TLB golden/amber palette. `AppLoader()` = full-screen variant; `AppLoaderInline()` = compact button/spinner variant. `AppLoader.useCustomLoader` static bool flag: `true` (default) = custom dots; `false` = falls back to standard `CircularProgressIndicator` globally | `lib/widgets/app_loader.dart` (NEW) |
| Full-screen loaders replaced with `AppLoader()` — loading slivers in category screens; initial screen spinners in detail screens | `lib/screens/category_events_screen.dart`, `category_venues_screen.dart`, `event_detail_screen.dart`, `venue_detail_screen.dart` |
| Payment processing dialog loader replaced with `AppLoader()` | `lib/screens/payment_screen.dart` |
| Button/inline loaders replaced with `AppLoaderInline()` across all auth + profile screens | `lib/widgets/login_sheet.dart`, `lib/screens/signup_screen.dart`, `forgot_password_screen.dart`, `edit_profile_screen.dart`, `change_password_screen.dart` |
| "Fetching location…" button spinner replaced with `AppLoaderInline()` | `lib/screens/location_screen.dart` |

### Session 17
| Change | Files |
|--------|-------|
| `exploreFormats` data updated — 6 entries with pre-designed circle images from `resources-tlb-ui/event_page_subcategoryicons/Explore_by_format/`; each entry has `label`, `image`, `formatSlug`, `accentColor`; MasterClass adds `scale: 1.42` + `invertColors: true` | `lib/data/dummy_data.dart` |
| `ExploreFormatRow` rewritten — uses `asMap().entries.map()` to carry index; `ClipOval + BoxFit.cover` on 84×84 circles; per-entry `Transform.scale` zoom; `ColorFilter.matrix` inversion for MasterClass (white→black bg); `onFormatTap(index)` callback wired to navigation | `lib/widgets/explore_format_row.dart` |
| `FormatEventsScreen` created — animated gradient header transitions `accentColor` per selected format (350ms `AnimatedContainer`); horizontal format circles selector row reuses same render logic with animated selection ring (white border + scale); fetches `EventsListingService.fetchEvents(format: slug, city: ..., pageSize: 50)`; `_toEventModel()` maps API fields to `EventModel` (`city • dateLabel` venue, subcategory/category tag, ageGroup description, priceFrom price); 2-col `SliverGrid` of `CategoryEventCard`; `SubcategoryEmptyState` on empty; `AppLoader` on loading | `lib/screens/format_events_screen.dart` (NEW) |
| `EventsScreen` wired — `ExploreFormatRow.onFormatTap` navigates to `FormatEventsScreen(initialFormatIndex: index)` via `MaterialPageRoute` | `lib/screens/events_screen.dart` |
| `pubspec.yaml` assets updated — added `resources-tlb-ui/event_page_subcategoryicons/` and `resources-tlb-ui/event_page_subcategoryicons/Explore_by_format/` | `pubspec.yaml` |
| Compile error fixed — `ExploreFormatRow` was using `.map((format)` with no index access; changed to `.asMap().entries.map((entry)` with `final int index = entry.key; final format = entry.value` | `lib/widgets/explore_format_row.dart` |
| API error snackbar fixed — raw `{code: ERROR, message: Not found.}` string no longer shown; `fetchEvents` now returns empty `ApiEventsPage` on HTTP 404; `body['error']` nested Map is properly extracted: `rawErr is Map ? rawErr['message'] : rawErr.toString()` | `lib/services/events_listing_service.dart` |
| Same nested error extraction applied to `fetchVenues` | `lib/services/events_listing_service.dart` |

### Session 18
| Change | Files |
|--------|-------|
| **Critical auth fix — API envelope parsing** — all TLB auth APIs return `{"success", "data": {...}, "error": {"code", "message"}}` but service was reading top-level keys (e.g. `data['access']`) instead of inner payload (`data['data']['access']`), causing `accessToken` to always be `null` after every login → "Session expired" error on every profile save | `lib/services/auth_service.dart` |
| Added `_inner(body)` helper — extracts `body['data']` as `Map<String, dynamic>?`; used by all methods to unwrap the envelope before reading fields | `lib/services/auth_service.dart` |
| `_extractError` fixed — now reads `body['error']['message']` first (TLB nested format), then falls back to flat DRF fields (`message`, `detail`, `non_field_errors`) | `lib/services/auth_service.dart` |
| `verifyOtp` fixed — `access`, `refresh`, `is_new_user`, `user` now read from `_inner(body)`; OTP error codes read from `body['error']['code']` | `lib/services/auth_service.dart` |
| `googleSignIn` fixed — tokens and user now read from `_inner(body)` | `lib/services/auth_service.dart` |
| `refreshToken` fixed — new access/refresh tokens now correctly extracted; session restore now works | `lib/services/auth_service.dart` |
| `getProfile` / `updateProfile` fixed — now return `_inner(body)` as profile data instead of the full envelope | `lib/services/auth_service.dart` |
| `forgotPassword` / `verifyResetOtp` / `confirmPasswordReset` / `changePassword` fixed — `message` and `reset_token` fields now read from `_inner(body)` | `lib/services/auth_service.dart` |
| `FormatEventsScreen` fetch fixed — backend `?format=` query parameter not yet implemented (returns 404 for any value); changed to fetch all events (`pageSize: 100`) and filter client-side by both `e.format == slug` and `e.city.toLowerCase() == userCity.toLowerCase()` | `lib/screens/format_events_screen.dart` |
| `FormatEventsScreen` description field removed — cards were showing "Description – 6-8 years" (age group data); `description: null` now passed in `_toEventModel()` | `lib/screens/format_events_screen.dart` |

### Session 21 (Current)
| Change | Files |
|--------|-------|
| `WishlistService` added — `fetchWishlist` (GET /api/v1/wishlist/), `add` (POST /api/v1/wishlist/add/ — handles 200/201/400), `remove` (DELETE /api/v1/wishlist/remove/{id}/); all require `Authorization: Bearer {token}`; handles direct array + `{success,data}` envelope | `lib/services/wishlist_service.dart` (NEW) |
| `SavedEventsState` upgraded — `loadFromApi()` fetches server wishlist, builds `EventModel` list (id=listing_id, imagePath=cover_url, venue=city, tag=listing_type), replaces local state; `toggle()` made async `Future<bool>`; optimistic UI: update immediately, call API, revert + snackbar on failure; `clear()` method added | `lib/providers/saved_events_state.dart` |
| `WishlistButton.onTap` simplified — now `(isLiked) => SavedEventsState.toggle(event, context)` (returns Future<bool> directly to LikeButton) | `lib/widgets/wishlist_button.dart` |
| `SavedEventsScreen` — thumbnail image loading fixed to use `Image.network` when `imagePath.startsWith('http')` (API-loaded wishlist items have cover URLs) | `lib/screens/saved_events_screen.dart` |
| `main.dart` — calls `SavedEventsState.loadFromApi()` fire-and-forget after successful `tryRestoreSession()` | `lib/main.dart` |
| `login_sheet.dart` — calls `SavedEventsState.loadFromApi()` fire-and-forget after `AuthState.login()` in both Google sign-in and OTP verify flows | `lib/widgets/login_sheet.dart` |
| `signup_screen.dart` — same loadFromApi call after Google sign-up login | `lib/screens/signup_screen.dart` |

### Session 22
| Change | Files |
|--------|-------|
| `ApiReviewMedia`, `ApiReview`, `ApiReviewPage` models added — `ApiReviewPage` contains nested `reviews.results` list, `average_rating`, `total_reviews`, `rating_breakdown`, `has_next` | `lib/models/api_review_model.dart` (NEW) |
| `ReviewService` added — `fetchReviews(listingId)` GET public, `createReview(token, listingId, rating, comment)` POST (returns ApiReview), `updateReview(token, reviewId, rating, comment)` PATCH, `deleteReview(token, reviewId)` DELETE; handles both `{success, data}` envelope and flat responses | `lib/services/review_service.dart` (NEW) |
| `review_sheet.dart` added — `showReviewSheet()` fetches and displays all reviews with average rating summary; Write button (if logged in) opens `showWriteReviewSheet()`; `showWriteReviewSheet()` handles both create and edit (pass `existing: ApiReview` for edit mode); submit shows spinner, calls service, updates `UserReviewsState`, dismisses with SnackBar | `lib/widgets/review_sheet.dart` (NEW) |
| `UserReviewsState` rewritten as static-only class — removed singleton pattern and dummy data; `reviewsNotifier` is now `static ValueNotifier`; added `static updateReview(reviewId, changes)` and `static removeReview(reviewId)`; reviews now include `reviewId` int and `listingId` String fields | `lib/providers/user_reviews_state.dart` |
| `YourReviewsScreen` wired — Edit button opens `showWriteReviewSheet()` in edit mode (constructs `ApiReview` from stored map fields); Delete button calls `ReviewService.deleteReview()` then `UserReviewsState.removeReview()`; thumbnail loading uses `Image.network` for HTTP URLs, `Image.asset` for bundled images | `lib/screens/your_reviews_screen.dart` |
| All 4 detail screens — replaced `if (_detail == null)` dummy review section with `if (_hasApiId)` real "View all reviews" banner; removed `_reviews` static lists, `_showAddReviewBottomSheet`, `_showReviewsBottomSheet`, and `_buildReviewCard` dead helpers; replaced with `showReviewSheet()` call; reviews now shown for all API-backed listings | `lib/screens/event_detail_screen.dart`, `class_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| `program_detail_screen.dart` — removed pre-existing unused imports: `api_class_model.dart`, `classes_listing_service.dart`, `select_batch_screen.dart` | `lib/screens/program_detail_screen.dart` |
| `profile_screen.dart` — added `UserReviewsState.clear()` to logout flow (alongside existing `SavedEventsState` and `BookedEventsState` clears) | `lib/screens/profile_screen.dart` |

### Session 24
| Change | Files |
|--------|-------|
| `image_picker: ^1.2.2` re-added to `pubspec.yaml` — needed for review photo upload | `pubspec.yaml` |
| `ReviewService` fully rewritten — added `fetchMyReview(token, listingId)` (GET `/api/v1/listings/{id}/my-review/`); `createReview` + `updateReview` upgraded to `MultipartRequest` (supports `images: List<File>`); `updateReview` adds `remove_media_ids` repeated fields via `MultipartFile.fromBytes`; `uploadMedia` (POST `/api/v1/reviews/{id}/media/`) + `deleteMedia` (DELETE `/api/v1/reviews/{id}/media/{mediaId}/`) added | `lib/services/review_service.dart` |
| `fetchReviews` extended — now accepts `pageSize`, `ordering`, `rating` query params (page 1 default, 10 per page, `-created_at` ordering) | `lib/services/review_service.dart` |
| `review_sheet.dart` fully rewritten with 4 major features: | `lib/widgets/review_sheet.dart` |
| → **Rating breakdown bars** — `_ReviewListSheet` now shows a large avg number + 5/4/3/2/1 star `LinearProgressIndicator` bars from `ratingBreakdown` data; inline section has the same breakdown card | `lib/widgets/review_sheet.dart` |
| → **Media thumbnails** — `_ReviewTile` shows a horizontal `ListView` of 72×72 `Image.network` thumbnails from `review.media`; hidden when empty | `lib/widgets/review_sheet.dart` |
| → **Pagination** — `_ReviewListSheetState` accumulates pages in `_allReviews`; "Load more" button fetches `_currentPage + 1` and appends; `_loadingMore` spinner replaces button while fetching | `lib/widgets/review_sheet.dart` |
| → **Image picker** — `_WriteReviewSheet` has "Add Photos (optional)" section: horizontal `ListView` of 80×80 thumbnails (existing media + new picks), X button per image, "Add" button (hidden at 5 total); `ImagePicker.pickMultiImage(limit: remaining)` picks up to 5 total; edit mode shows existing API media with separate `_removeMediaIds` tracking | `lib/widgets/review_sheet.dart` |
| → **Comment made optional** — removed "Please write a review first" validation from `_WriteReviewSheet._submit()`; rating alone is sufficient | `lib/widgets/review_sheet.dart` |
| → **`buildReviewInlineSection()` exported** — stateless function that renders: section header with "See All >" link; rating summary card with breakdown bars (when `total > 0`); up to 3 preview `_ReviewTile`s; "Write a Review" amber button (always visible, auth guard inside tap); "Be the first to review!" fallback (no reviews); accepts `reviewPage`, `isLoading`, `onRefresh` callback | `lib/widgets/review_sheet.dart` |
| All 4 detail screens updated — `_reviewPage: ApiReviewPage?` + `_reviewLoading: bool` state added; `_fetchReviews()` fetches page 1 with `pageSize: 3`; `initState` calls both `_fetchDetail()` and `_fetchReviews()` in parallel; "View all reviews" button block replaced with `buildReviewInlineSection(...)` call | `lib/screens/event_detail_screen.dart`, `class_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| `VenueDetailScreen` — `if (widget.event.id.isNotEmpty)` check refactored to `_hasApiId` getter (matches pattern of other 3 screens) | `lib/screens/venue_detail_screen.dart` |
| **Login guard** — `_openWriteReviewWithGuard()` private helper checks `AuthState.accessToken`; null → `showLoginSheet(context)` (Navigator.push to LoginScreen); logged in → `showWriteReviewSheet()`; called by the "Write a Review" button in `buildReviewInlineSection` and the edit button in `_ReviewListSheet` | `lib/widgets/review_sheet.dart` |
| **Auto-detect existing review** — `_WriteReviewSheet.initState` calls `_checkExistingReview()` when `widget.existing == null`; if `fetchMyReview` returns a review, switches to edit mode automatically; shows "Loading..." title + `AppLoaderInline` while checking; blue info banner when editing auto-detected review | `lib/widgets/review_sheet.dart` |
| **Video support** — separate "Videos (optional)" section in write sheet; `ImagePicker.pickVideo(source: ImageSource.gallery)` adds to `_newVideos: List<XFile>`; max 2 total videos (existing + new); `_newVideoThumb` + `_existingVideoThumb` helpers; video play-icon placeholder in `_ReviewTile`; `createReview` and `updateReview` in `ReviewService` accept `List<File> videos`/`newVideos` | `lib/widgets/review_sheet.dart`, `lib/services/review_service.dart` |
| **`remove_media_ids[]` field name fixed** — `updateReview` sends each ID via `MultipartFile.fromBytes('remove_media_ids[]', ...)` repeated parts (was `remove_media_ids`) | `lib/services/review_service.dart` |
| **Test suite updated** — TC_RS_001 and TC_RS_002 updated to drive through `buildReviewInlineSection` (not `showWriteReviewSheet` directly); TC_RS_001 verifies login screen appears; TC_RS_002 verifies `BottomSheet` absent | `test/widgets/review_sheet_test.dart` |
| All tests pass (105 total) — no regressions | test suite |

### Session 25
| Change | Files |
|--------|-------|
| **Token key mismatch fixed** — `AuthService.verifyOtp`, `googleSignIn`, and `refreshToken` all extracted `inner['access']` / `inner['refresh']` but the API envelope uses `access_token` / `refresh_token`; fixed to `inner['access_token'] ?? inner['access']` and `inner['refresh_token'] ?? inner['refresh']` (dual-key for safety); root cause of "have to login each time I reopen the app" | `lib/services/auth_service.dart` |
| **Edit profile prefill fixed** — `EditProfileScreen.initState` now calls `_fetchAndPrefill()` which GETs `/api/v1/customer/profile/`, calls `AuthState.updateProfileData(profile)`, then re-runs `_prefillFromAuthState()`; form always shows latest API data; save button + loader disabled while fetching | `lib/screens/edit_profile_screen.dart` |
| All tests pass (105 total) — no regressions | test suite |

### Session 26
| Change | Files |
|--------|-------|
| **`ApiReview` extended** — added `listingId`, `listingTitle`, `listingImage` nullable fields (parsed from `listing` sub-object in customer reviews API response); `copyWith()` method added for non-destructive field overrides | `lib/models/api_review_model.dart` |
| **`ReviewService.fetchMyReviews`** — `GET /api/v1/customer/reviews/`; auth required; handles both flat list and `{success, data: [...]}` + paginated `{results: [...]}` response shapes | `lib/services/review_service.dart` |
| **`ReviewService.fetchReviewMedia`** — `GET /api/v1/reviews/<review_id>/media/`; auth required; returns `List<ApiReviewMedia>`; handles flat list and `{data: [...]}` envelope | `lib/services/review_service.dart` |
| **`UserReviewsState` rewritten** — now typed `ValueNotifier<List<ApiReview>>`; `loadFromApi()` fetches all user reviews then enriches each with media in parallel via `fetchReviewMedia` if `review.media.isEmpty`; `upsert(ApiReview)` replaces `addReview(map)` + `updateReview(id, map)`; `isLoaded` getter; `remove`/`clear` unchanged in API | `lib/providers/user_reviews_state.dart` |
| **`review_sheet.dart` `_submit()` updated** — both create and update paths now call `UserReviewsState.upsert(review.copyWith(listingId, listingTitle, listingImage))` preserving listing context from `widget` properties | `lib/widgets/review_sheet.dart` |
| **`YourReviewsScreen` rewritten** — `StatefulWidget`; `initState` calls `UserReviewsState.loadFromApi()`; shows `AppLoaderInline` while loading; pull-to-refresh; error + retry state; `_ReviewCard` uses `ApiReview` fields (listing image via `Image.network`, title, formatted date, star row, comment, horizontal media thumbnail strip with video play-icon placeholder, Edit/Delete actions) | `lib/screens/your_reviews_screen.dart` |
| All tests pass (105 total) — no regressions | test suite |

### Session 23 — Architecture Audit & Test Expansion
| Change | Files |
|--------|-------|
| **Architecture audit** — full scan: 42 screens, 32 widgets, 8 services, 5 providers, 9 models | (audit only) |
| `AppColors` extended — 7 new constants: `dividerGold`, `indigo`, `lightGray`, `bookingBlue`, `successGreen`, `starAmber`, `inputFill` | `lib/core/app_colors.dart` |
| `AppSpacing` created — 12 semantic spacing constants (xs/sm/md/base/lg/xl/xxl/xxxl/section + aliases) | `lib/core/app_spacing.dart` (NEW) |
| `AppSnackBar` created — `show()`, `error()`, `success()` helpers for consistent snackbar styling across 23 files | `lib/core/app_snackbar.dart` (NEW) |
| `AppTheme` hardcoded `Color(0xFF1A1A2E)` replaced with `AppColors.textPrimary` | `lib/core/app_theme.dart` |
| `SectionDividerWidget` — `Color(0xFFE4CD89)` → `AppColors.dividerGold`; `Color(0xFF6B6B6B)` → `AppColors.textSecondary` | `lib/widgets/section_divider_widget.dart` |
| `SubcategoryEmptyState` — all 3 hardcoded colors replaced with `AppColors` constants | `lib/widgets/subcategory_empty_state.dart` |
| `review_sheet.dart` — both `CircularProgressIndicator` instances replaced with `AppLoader`/`AppLoaderInline`; all hardcoded colors → `AppColors` | `lib/widgets/review_sheet.dart` |
| `section_header_test.dart` deleted — referenced widget deleted in Session 15; was a compile-breaking dead test | `test/widgets/section_header_test.dart` |
| 36 new tests added across 5 test files; all pass | `test/widgets/` × 4, `test/screens/format_events_screen_test.dart` |
| → `app_loader_test.dart` — 9 tests: custom/fallback toggle, inline/fullscreen, rapid pump | `test/widgets/app_loader_test.dart` (NEW) |
| → `section_divider_widget_test.dart` — 5 tests: title, line structure, long title, empty string | `test/widgets/section_divider_widget_test.dart` (NEW) |
| → `subcategory_empty_state_test.dart` — 8 tests: UI elements, snackbar, callbacks, narrow/tablet screens | `test/widgets/subcategory_empty_state_test.dart` (NEW) |
| → `category_event_card_test.dart` — 10 tests: title/venue/tag/description/reviewCount, tap callbacks, overflow, network image | `test/widgets/category_event_card_test.dart` (NEW) |
| → `review_sheet_test.dart` — 4 tests: auth guard snackbar, AppLoader integration (both flag states) | `test/widgets/review_sheet_test.dart` (NEW) |
| → `format_events_screen_test.dart` — 9 tests: render, format switching, header transition, overflow, empty state | `test/screens/format_events_screen_test.dart` (NEW) |

**Pre-existing failing tests (11) confirmed not caused by this session:**  
`category_events_screen_test`, `category_programs_screen_test`, `class_detail_screen_test` (×2), `edit_profile_screen_test`, `event_detail_screen_test` (×3), `program_detail_screen_test`, `venue_detail_screen_test` — all require live API mocks not yet set up.

### Session 27
| Change | Files |
|--------|-------|
| **`_extractError()` hardened** — previous cast `error['message'] as String?` threw `TypeError` when DRF returns validation errors as `{"message": {"phone_number": [...]}}` (a Map, not a String); replaced with `is String` / `is Map` / `is List` guards; added `_flattenValidationMap()` helper that picks the first field's first error string | `lib/services/auth_service.dart` |
| **Country code picker added to Edit Profile** — phone field split into prefix button + digits field; 29-country list as Dart 3 record tuples `(String dialCode, String flag, String name)`; `_showCountryPicker()` bottom sheet with live search filter (62% screen height); prefill auto-detects dial code by longest-prefix match and strips it from stored number; save composes E.164: `dialCode + digits` | `lib/screens/edit_profile_screen.dart` |
| **`ApiReview` persistence serialisation** — `toJson()` added (round-trips `id`, `customer`, `rating`, `comment`, `media`, `created_at`, `listingId`, `listingTitle`, `listingImage`); `ApiReviewMedia.toJson()` added (`id`, `media_type`, `file`) | `lib/models/api_review_model.dart` |
| **`UserReviewsState` SharedPreferences persistence** — `_persist()` serialises the review list to `user_reviews_v1` key; `_loadFromStorage()` deserialises on startup; `upsert()`, `remove()`, and `clear()` all made `async` and call `_persist()`; reviews now survive app restarts | `lib/providers/user_reviews_state.dart` |
| **Edit profile test updated** — phone assertion changed from `find.widgetWithText(TextField, '+91 9876543210')` (single field) to `find.text('+91')` + `find.widgetWithText(TextField, '9876543210')` (split prefix button + digits field) | `test/screens/edit_profile_screen_test.dart` |
| **Root-cause fix: no "list my reviews" API endpoint exists** — `GET /api/v1/customer/reviews/` and `GET /api/v1/reviews/` both return 404; confirmed from API docs: only per-listing (`/listings/{id}/reviews/`) and per-review-ID (`/reviews/{id}/`) routes exist | investigation |
| **`ReviewService.fetchMyReviews()` removed** — dead method that tried both 404 endpoints; callers updated | `lib/services/review_service.dart` |
| **`UserReviewsState.loadFromApi()` reworked** — now loads exclusively from SharedPreferences, then for each stored review calls `ReviewService.fetchReviewMedia(token, id)` to refresh media via `GET /api/v1/reviews/{id}/media/`; never throws; reviews only appear after being created/edited via the app | `lib/providers/user_reviews_state.dart` |

### Session 28
| Change | Files |
|--------|-------|
| **`AuthState.userId` getter added** — reads `userData?['id'] as String?`; returns the customer UUID used to detect whether the logged-in user owns a given review | `lib/providers/auth_state.dart` |
| **`_ReviewTile` updated with owner actions** — accepts optional `onEdit: VoidCallback?` and `onDelete: VoidCallback?`; when provided, renders an amber pencil icon button and a red trash icon button in the top-right of the tile header (next to name/date); non-owners see no action buttons | `lib/widgets/review_sheet.dart` |
| **`_confirmDeleteReview` helper added** — top-level function shared by inline section and list sheet; shows a confirmation `AlertDialog`, calls `DELETE /api/v1/reviews/{id}/` via `ReviewService.deleteReview()`, removes from `UserReviewsState`, fires `onSuccess` callback; error shown via `SnackBar` | `lib/widgets/review_sheet.dart` |
| **`buildReviewInlineSection` ownership check** — for each preview `_ReviewTile`, checks `AuthState.userId == r.customerId`; owners receive `onEdit` (opens `showWriteReviewSheet` pre-filled with the existing review, then calls `onRefresh`) and `onDelete` (calls `_confirmDeleteReview`, then `onRefresh`) | `lib/widgets/review_sheet.dart` |
| **`_ReviewListSheet` ownership check** — same `AuthState.userId == r.customerId` check per tile; `onEdit` pops the sheet then opens the write sheet pre-filled; `onDelete` calls `_confirmDeleteReview` with an `onSuccess` that removes the row from `_allReviews` and decrements `_totalReviews` without a full re-fetch | `lib/widgets/review_sheet.dart` |
| All tests pass (4 review sheet tests, no regressions) | test suite |

### Session 20
| Change | Files |
|--------|-------|
| `ApiProvider` model added — `id, name, bio, logoUrl, totalListings, averageRating, totalReviews, experienceYears` | `lib/models/api_provider_model.dart` (NEW) |
| `EventsListingService.fetchProvider(listingId)` added — GET `/api/v1/listings/{id}/provider/`; handles direct + envelope response formats | `lib/services/events_listing_service.dart` |
| `OrganizerProfileScreen` rewritten as `StatefulWidget` — accepts `listingId, initialName?, initialLogoUrl?`; fetches provider on load; shows `AppLoader` while loading; non-fatal error banner with Retry; stats row uses real `totalListings/averageRating/experienceYears`; `totalReviews` shown as review count under name; star icon in rating stat; upcoming events remain dummy (no provider-filter API) | `lib/screens/organizer_profile_screen.dart` |
| All 4 detail screens — organizer card wrapped in `GestureDetector` (whole card tappable); inner avatar `GestureDetector` removed; navigation target changed to `OrganizerProfileScreen(listingId: widget.event.id, initialName:, initialLogoUrl:)` | `lib/screens/event_detail_screen.dart`, `class_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |

### Session 19
| Change | Files |
|--------|-------|
| ClassDetailScreen fully rewritten as StatefulWidget � event.id.isNotEmpty gates etchClassDetail() in initState; handles loading and network errors gracefully; dynamic rendering of gallery, organizer info, policies, and batches; falls back to dummy cards if id == \x27\x27 | lib/screens/class_detail_screen.dart |
| Enquiry workflow integrated � \x22Send Enquiry\x22 uses API-fetched listingId; calls ClassesListingService.submitEnquiry() | lib/screens/class_detail_screen.dart |
| inquire_now_sheet.dart UI mapped to pass the dynamically fetched listingId from the class detail screen instead of falling back to default values | lib/widgets/inquire_now_sheet.dart |
| Gallery section redesigned � _buildGallery slider uses API media (excluding cover photo); fallback to repeated cover if no gallery images available | lib/screens/class_detail_screen.dart |
| Organizer avatar dynamic � _buildOrganizerAvatar pulls logoUrl from API; falls back to letter-initial avatar if missing | lib/screens/class_detail_screen.dart |
| Terms & Policies updated � added Cancellation and Refund policy sections from API; falls back to default static terms | lib/screens/class_detail_screen.dart |
| Location map fixed � Container closure and nesting issues resolved; added launchUrl for directions via Google Maps | lib/screens/class_detail_screen.dart |
| ProgramDetailScreen fully rewritten as StatefulWidget � integrated ProgramsListingService.fetchProgramDetail; dynamic mapping for age group, capacity, total hours, module count, and multi-batch schedule; gallery wired to GalleryScreen | lib/screens/program_detail_screen.dart |
| ProgramsListingService.submitEnquiry fixed � endpoint updated to /enquiries/; field contactNumber renamed to mobile; added rea field to match backend spec | lib/services/programs_listing_service.dart |
| Program enquiry integration � InquireNowSheet updated to pass mobile and rea when submitting for programs | lib/widgets/inquire_now_sheet.dart |
| Profile Reactivity — Wrapped greetings in SavedEventsScreen, YourReviewsScreen, HelpCentreScreen, PaymentSettingsScreen, and RemindersScreen with ValueListenableBuilder to reflect AuthState.userName changes in real-time | Multiple profile sub-screens |

### Session 29
| Change | Files |
|--------|-------|
| **Google Sign-In fixed** — restored Firebase Auth flow: `GoogleSignIn.signIn()` → `FirebaseAuth.signInWithCredential(GoogleAuthProvider.credential(accessToken, idToken))` → `fbUser.getIdToken()` → `AuthService.googleSignIn(idToken: firebaseToken)`; removed `serverClientId` (not needed with Firebase); added `debugPrint` for exact error logging; `_googleErrorMessage()` helper maps `SocketException`, `TimeoutException`, and known error strings to friendly messages | `lib/widgets/login_sheet.dart`, `lib/screens/signup_screen.dart` |
| **"Sign Up with OTP" → "Signup"** — login screen signup link text changed; tap now navigates to `SignupScreen` instead of re-calling `_onSendOTP` | `lib/widgets/login_sheet.dart` |
| **`_GoogleButton` made nullable** — `VoidCallback?` type; login and signup pass `_loading ? null : _onGoogleSignIn` to prevent double-tapping | `lib/widgets/login_sheet.dart`, `lib/screens/signup_screen.dart` |
| **`OtpVerificationScreen` extracted** — new public screen `lib/screens/otp_verification_screen.dart`; moved from private `_OTPVerificationScreen` in login_sheet; accepts `identifier` + `onExistingUser: void Function(BuildContext)?` callback; new user → `markAsNewUser()` + `EditProfileScreen(isOnboarding: true)`; existing user → calls `onExistingUser`; login passes `showWelcomeBackDialog`, signup passes `Navigator.pushAndRemoveUntil(HomeScreen)` | `lib/screens/otp_verification_screen.dart` (NEW) |
| **`SignupScreen` refactored to email-only OTP** — removed firstName, lastName, password, confirmPassword fields; removed wrong `_EmailVerificationDialog` (was showing "verification link" for OTP flow); now: email field → "Send OTP" → navigates to `OtpVerificationScreen`; Google sign-up also uses Firebase Auth; "Log In" link uses `Navigator.pop()` | `lib/screens/signup_screen.dart` |
| **Onboarding flow preserved** — new user OTP and Google paths both call `WalkthroughService.markAsNewUser()` before navigating to `EditProfileScreen(isOnboarding: true)` → `HomeScreen` triggers walkthrough; existing users bypass all onboarding | `lib/screens/otp_verification_screen.dart`, `lib/screens/signup_screen.dart`, `lib/widgets/login_sheet.dart` |
| **Circular import broken** — `signup_screen.dart` no longer imports `login_sheet.dart`; `otp_verification_screen.dart` no longer imports `home_screen.dart`; chain `home_screen → home_header → login_sheet → signup_screen → otp_verification_screen` is now one-way | `lib/screens/otp_verification_screen.dart`, `lib/screens/signup_screen.dart` |
| **`search` param added to all 4 listing services** — `fetchEvents`, `fetchVenues`, `fetchClasses`, `fetchPrograms` each accept `String? search`; maps to `'search'` query param when non-empty | `lib/services/events_listing_service.dart`, `lib/services/classes_listing_service.dart`, `lib/services/programs_listing_service.dart` |
| **`SearchScreen` rewritten** — removed all mock data (Bollywood trending list, wrong chips); chips replaced with `['All', 'Events', 'Classes', 'Programs', 'Venues']` filter tabs; `_onSearchChanged` debounced 500ms fires `_doSearch(q)` which runs all 4 service calls in parallel; unified `_SearchItem` model holds type, `EventModel` (for navigation), title, subtitle, coverUrl; `_filteredResults` applies chip filter client-side | `lib/screens/search_screen.dart` |
| **Search result tiles** — `ListTile` with 56×56 cover thumbnail (`ClipRRect` radius 10, network image with placeholder fallback), color-coded type badge (`Event` indigo / `Class` purple / `Program` green / `Venue` red), subtitle (category or city), arrow trailing icon; tap navigates to correct detail screen (`EventDetailScreen` / `ClassDetailScreen` / `ProgramDetailScreen` / `VenueDetailScreen`) using same `EventModel` conversion as category screens | `lib/screens/search_screen.dart` |
| **Search states** — idle (empty query): centered search icon + "Find events, classes, programs & venues" prompt; loading: `CircularProgressIndicator(color: 0xFFFFCC00)`; no results: `search_off` icon + "No results for…" message; clear button (`Icons.close`) in search field when text is present | `lib/screens/search_screen.dart` |
| **Filter bottom sheet retained** — Age Group chips, Mode radio, City/Area dropdowns, Date chips all kept; filter state stored (`_selectedMode`, `_selectedCity`, `_selectedArea`, `_ageGroupSelected`, `_dateSelected`) but not yet wired to API calls | `lib/screens/search_screen.dart` |

### Session 30
| Change | Files |
|--------|-------|
| **Search client-side filter added** — backend ignores the `?search=` param and returns unrelated results (e.g. "Jaat mela" for "Advanced AI"); after receiving all 4 API responses, results are now filtered client-side: only items whose `title` or `subtitle` contains the query (case-insensitive) are kept; API still receives `search=` so backend improvements will take effect automatically | `lib/screens/search_screen.dart` |
| **NotificationScreen mock data removed** — all 4 dummy notification cards (`_today` + `_yesterday` lists) deleted; "Mark All as Read" action removed; body replaced with empty state: `notifications_off_outlined` icon + "No Notifications Yet" heading + subtitle copy | `lib/screens/notification_screen.dart` |
| **13 compile errors fixed** (from prior-session bulk `Responsive.sp` replacement) — `const` removed from 4 `Text`/`Center` widgets containing non-const `Responsive.sp()` calls; `BuildContext context` added as first positional param to 7 helper methods on `StatelessWidget` subclasses and one top-level function; `_viewAllChip()` in `explore_categories_grid.dart` reverted `fontSize` to literal `12` (closure scope has no `context`) | `lib/screens/events_screen.dart`, `lib/sections/home_header.dart`, `lib/widgets/inquire_now_sheet.dart`, `lib/widgets/login_sheet.dart`, `lib/screens/account_settings_screen.dart`, `lib/screens/help_centre_screen.dart`, `lib/screens/payment_screen.dart`, `lib/widgets/categories_grid.dart`, `lib/widgets/explore_categories_grid.dart` |
| **`GET /api/v1/customer/reviews/` confirmed live** — Session 27 investigation concluded the endpoint was 404; re-tested and confirmed live; Session 27 entries corrected below | `lib/services/review_service.dart` |
| **`ReviewService.fetchCustomerReviews()` added** — `GET /api/v1/customer/reviews/`; auth required; handles all response shapes (direct list, `body['data'] is List`, paginated `body['data']['results']`); returns `List<ApiReview>` | `lib/services/review_service.dart` |
| **`UserReviewsState.loadFromApi()` wired to real API** — previously read exclusively from SharedPreferences (Session 27 interim workaround); now calls `fetchCustomerReviews(token)` first, updates notifier and persists; falls back to cache on error or when not logged in | `lib/providers/user_reviews_state.dart` |
| **`YourReviewsScreen` empty bug fixed** — API returns `{"success":true,"data":{"count":N,"results":[...]}}` but parser was reading `body['results']` (null) and `body['data'] is List` (false — it's a Map); added third case: `body['data'] is Map` → reads `data['results']`; screen now populates correctly | `lib/services/review_service.dart` |

### Session 32
| Change | Files |
|--------|-------|
| **CategoryProgramsScreen API category filter fixed** — root cause: `fetchPrograms(category: string)` was silently ignored by backend (API only accepts `category_id: int`); fix: fetch program categories from `/api/v1/listings/programs/metadata/categories/` on init, resolve `category_id` by normalized name match (handles truncated dummy labels like "Grooming & Personality Dev" → id 22), pass `categoryId`/`subcategoryId` integers to all fetch calls | `lib/screens/category_programs_screen.dart` |
| **API subcategories replace dummy filter chips** — `_currentSubcategories: List<ApiSubcategory>` populated from matched API category; filter chips built from API subcategory names+IDs when available (falls back to dummy strings if metadata unavailable); tapping a subcategory chip passes `subcategoryId` (integer) to `fetchPrograms()` | `lib/screens/category_programs_screen.dart` |
| **`bookingType` added to `ApiProgramDetail`** — new `final String bookingType` field; parsed from `json['booking_type']` first, then `service['booking_type']` fallback; defaults to `'enquiry'` when absent | `lib/models/api_program_model.dart` |
| **`SelectProgramBatchScreen` rewritten with real API data** — constructor signature changed to `EventModel event + List<ApiProgramBatch> batches`; removed all hardcoded `_kProgramBatches`/`_kProgramDates` constants; `_nextDates(batch)` computes next 5 upcoming dates whose weekday matches `batch.daysOfWeek` (handles full names e.g. "monday" and short "mon" via first-3-chars truncation); batch cards show `_fmt12h` time range, day labels, `batch.name` as color-tagged pill; `batch.totalSeats` shown as red seats chip when non-null; "Batch starting from" reflects selected date chip; selecting batch refreshes dates | `lib/screens/select_program_batch_screen.dart` |
| **`ProgramDetailScreen` CTA gated on `booking_type`** — removed `buttonLabel`/`onBookTapped` constructor params (all call sites only passed `event:`); `_isDirectBooking` getter checks `_detail?.bookingType == 'direct_booking'`; direct booking → "Check Availability" → `Navigator.push(SelectProgramBatchScreen(event: _eventForSheets, batches: _detail?.batches ?? []))`; enquiry → "Enquire Now" → `showInquireNow()` | `lib/screens/program_detail_screen.dart` |
| **`_eventForSheets` enriched** — `rating` and `reviewCount` now populated from `_detail.averageRating` / `_detail.totalReviews` so the venue card in `SelectProgramBatchScreen` shows live star and review count | `lib/screens/program_detail_screen.dart` |

### Session 31
| Change | Files |
|--------|-------|
| **`bookingType` added to `ApiClassDetail`** — new `final String bookingType` field; parsed from `service['booking_type']`; defaults to `'enquiry'` when absent | `lib/models/api_class_model.dart` |
| **`SelectBatchScreen` rewritten with real API data** — constructor signature changed from `EventModel event` only to `EventModel event + List<ApiClassBatch> batches`; removed hardcoded `_kBatches` / `_kDates` constants; `_nextDates(batch, {count: 5})` computes upcoming calendar dates whose weekday matches `batch.days` (day-name → `DateTime.weekday` map); selecting a batch calls `_refreshDates()` which recomputes dates and resets date index; batch cards show `_fmt12h` time range (`"13:00:00"` → `"1 PM"`), 3-char day labels, `batch.name` as tag with 5-color teal/purple/green/amber/rose palette; "Batch starting from" reflects selected date chip | `lib/screens/select_batch_screen.dart` |
| **`ClassDetailScreen` CTA gated on `booking_type`** — bottom bar `Builder` checks `_detail?.bookingType == 'direct_booking'`; direct booking → "Check Availability" → `Navigator.push(SelectBatchScreen(event: _eventForSheets, batches: _detail?.batches ?? []))`; enquiry → "Send Enquiry" → `showInquireNow()` | `lib/screens/class_detail_screen.dart` |
| **`_eventForSheets` enriched** — `rating` and `reviewCount` now populated from `_detail.averageRating` / `_detail.totalReviews` so the venue card in `SelectBatchScreen` displays live star and review count | `lib/screens/class_detail_screen.dart` |

### Session 33
| Change | Files |
|--------|-------|
| **"Explore by Categories" always visible** — removed `_isCategoriesLoading`, `_categoriesError`, `_buildCategoriesShimmer()`, `_buildCategoriesError()`; `_gridCategories` now initialised immediately with `_buildFallbackCategories()` (maps `DummyData.exploreCategories` + `_kFallbackSlugs`); `_loadCategories()` silently replaces with live API data on success, keeps fallback on error; section is never blank | `lib/screens/events_screen.dart` |
| **Events booking flow wired end-to-end** — `EventDetailScreen` "Book Now" now navigates to `DateTimeSelectionScreen(event: _eventForSheets, apiTickets: _detail?.tickets, eventDateTime: _detail?.startDatetime, eventEndDateTime: _detail?.endDatetime)` | `lib/screens/event_detail_screen.dart` |
| **`_eventForSheets` enriched with date/time** — `eventDate` and `eventTime` now populated from `_detail.startDatetime.toLocal()` (formatted) so downstream screens receive correct local-time strings even when API data is available | `lib/screens/event_detail_screen.dart` |
| **`DateTimeSelectionScreen` updated** — new constructor params: `apiTickets: List<ApiEventTicket>?`, `eventDateTime: DateTime?`, `eventEndDateTime: DateTime?`; added `_fmtDate` and `_fmtTime` static helpers; `initState` rewritten: when `eventDateTime` is non-null shows a single real date chip and a single time-range chip (`_fmtTime(start) – _fmtTime(end)`) from `.toLocal()` values; falls back to 6 generated chips when no API datetime provided; `apiTickets` forwarded to `TicketBookingScreen` | `lib/screens/date_time_selection_screen.dart` |
| **UTC → local timezone fix** — all datetime values from the API are UTC; fixed by calling `.toLocal()` before any `_formatDate`/`_formatTime`/`_fmtDate`/`_fmtTime` call in both `EventDetailScreen` and `DateTimeSelectionScreen`; resolves "4:30 AM" showing instead of "10:00 AM IST" | `lib/screens/event_detail_screen.dart`, `lib/screens/date_time_selection_screen.dart` |
| **`TicketBookingScreen` accepts real ticket data** — new constructor param `apiTickets: List<ApiEventTicket>?`; `_tickets` changed to `late`; `_initTickets()` builds list from API data (`name`, `price`, `count: 0`, `available: availableQuantity`) when available; falls back to 3 hardcoded dummy tiers using `event.price` as base | `lib/screens/ticket_booking_screen.dart` |
| **Dynamic "spots left" count** — hardcoded `"Only 5 spots left"` replaced with `_totalAvailableSpots` getter (sums `availableQuantity` across all API ticket maps); shown only when `_tickets` contains `'available'` key (API path); hidden for dummy-data path | `lib/screens/ticket_booking_screen.dart` |
| **Offers section removed** — entire `_buildOffersSection()` method and its call in `build()` deleted from `TicketBookingScreen` | `lib/screens/ticket_booking_screen.dart` |
| **Network image fix in checkout** — event image in `_buildEventInfoCard` now checks `event.imagePath.startsWith('http')` and uses `Image.network` for API URLs; falls back to `Image.asset` for local bundled paths | `lib/screens/ticket_booking_screen.dart` |

### Session 34
| Change | Files |
|--------|-------|
| **`razorpay_flutter 1.4.5` added** | `pubspec.yaml` |
| **`AppConfig` created** — `razorpayKeyId` constant (replace `'rzp_test_YOUR_KEY_HERE'` with real key before testing) | `lib/core/app_config.dart` (NEW) |
| **`ApiBookingModel` created** — `BookingLineItem` (ticketId + quantity), `BookingAttendee` (name, age, phone, email), `BookingInitiateResponse` (bookingId, bookingReference, razorpayOrderId, amount, currency, holdExpiresAt), `BookingConfirmResponse` (id, bookingReference, status, listingTitle, totalAmount, paymentStatus) | `lib/models/api_booking_model.dart` (NEW) |
| **`BookingService` created** — `initiateBooking(token, listingId, bookingType, lineItems, attendees, batchId, quantity, slotId, packageId, ...)` → POST `/api/v1/bookings/initiate/`; `verifyPayment(token, bookingId, razorpayPaymentId, razorpayOrderId, razorpaySignature)` → POST `/api/v1/bookings/{id}/verify-payment/`; 30s timeout; typed Socket/Timeout error messages; `_unwrap()` + `_extractError()` helpers | `lib/services/booking_service.dart` (NEW) |
| **`TicketBookingScreen` updated** — new params `bookingType: String = 'event'` and `batchId: int?`; `ticketId` key added to `_tickets` maps when initialised from API data; "Proceed to Pay" now passes `lineItems`, `attendee`, `bookingType`, `batchId` to `ReviewPayScreen` | `lib/screens/ticket_booking_screen.dart` |
| **`ReviewPayScreen` rewritten as `StatefulWidget` with Razorpay** — new params: `lineItems`, `attendee`, `bookingType`, `batchId`; `_onProceedToPay()` calls `BookingService.initiateBooking()` then opens `Razorpay.open(options)` with `order_id`/`amount`/`currency` from API; `_handlePaymentSuccess()` shows confirming loader then calls `BookingService.verifyPayment()` → navigates to `BookingConfirmedScreen` with real `bookingReference`; `_handlePaymentError()` shows error snackbar; verification failure shows support dialog with booking reference; `Razorpay.clear()` in `dispose()`; PaymentScreen is now bypassed | `lib/screens/review_pay_screen.dart` |
| **`BookingConfirmedScreen` updated** — new optional param `bookingReference: String?`; when provided (real payment), used as `_bookingId` instead of `BookingEntry.generateId()`; shown in ticket card and booking history | `lib/screens/booking_confirmed_screen.dart` |
| **`SelectBatchScreen` updated** — passes `bookingType: 'class'` and `batchId: batches[_batchIdx].id` to `TicketBookingScreen` | `lib/screens/select_batch_screen.dart` |
| **`SelectProgramBatchScreen` updated** — passes `bookingType: 'program'` and `batchId: batches[_batchIdx].id` to `TicketBookingScreen` | `lib/screens/select_program_batch_screen.dart` |
| **`SeatReservationScreen` fixed** — `ReviewPayScreen` call updated to include `lineItems: []` and `attendee: {}` to satisfy new required params | `lib/screens/seat_reservation_screen.dart` |

#### Booking Flow (Post-Session 34)
```
[Events]  EventDetailScreen
  → DateTimeSelectionScreen (real date/time from API)
  → TicketBookingScreen (real tickets; bookingType='event')
  → ReviewPayScreen
      ├── _onProceedToPay(): POST /api/v1/bookings/initiate/ → BookingInitiateResponse
      ├── Razorpay.open(order_id, amount_in_paise, ...)
      ├── On success: POST /api/v1/bookings/{id}/verify-payment/ → BookingConfirmResponse
      └── Navigate → BookingConfirmedScreen(bookingReference: confirmed.bookingReference)

[Classes]  ClassDetailScreen → SelectBatchScreen (batchId threaded)
  → TicketBookingScreen(bookingType='class', batchId=X)
  → ReviewPayScreen → same Razorpay flow, POST with batch_id + quantity

[Programs] ProgramDetailScreen → SelectProgramBatchScreen (batchId threaded)
  → TicketBookingScreen(bookingType='program', batchId=X)
  → ReviewPayScreen → same Razorpay flow

IMPORTANT: Replace AppConfig.razorpayKeyId with real Razorpay key before live use.
```

### Session 35
| Change | Files |
|--------|-------|
| **Real Razorpay key set** — `AppConfig.razorpayKeyId` updated from placeholder `'rzp_test_YOUR_KEY_HERE'` to `'rzp_test_SpYAGfwgdidCZq'` | `lib/core/app_config.dart` |
| **Backend SDK error diagnosed (not a mobile fix)** — `POST /api/v1/bookings/initiate/` returns `{"success":false,"error":{"code":"PAYMENT_GATEWAY_NOT_CONFIGURED","message":"Razorpay SDK is not installed. Add razorpay to requirements.txt."}}` — this is a **server-side Python error**; the Django backend is missing the `razorpay` pip package; Flutter `razorpay_flutter` is correctly installed in the app; **fix required on backend**: `pip install razorpay`, add `razorpay` to `requirements.txt`, set `RAZORPAY_KEY_ID` + `RAZORPAY_KEY_SECRET` env vars on the server | backend (not mobile) |
| **API spec compliance audit — 5 bugs found and fixed** | (see below) |
| **`_handlePaymentSuccess` status guard added** — after `BookingService.verifyPayment()` returns, now checks `confirmed.status == 'confirmed' && confirmed.paymentStatus == 'paid'` before navigating to `BookingConfirmedScreen`; API spec requires both conditions; if either fails the recovery dialog is shown instead of a false booking confirmation | `lib/screens/review_pay_screen.dart` |
| **`BookingInitiateResponse.holdExpiresAt` made nullable** — field changed from `final DateTime holdExpiresAt` to `final DateTime? holdExpiresAt`; `fromJson` now uses `DateTime.tryParse` with null guard; prevents a hard cast-error crash when the API omits or sends a malformed `hold_expires_at` value | `lib/models/api_booking_model.dart` |
| **`BookingAttendee.extraData` added** — new optional `Map<String, dynamic>? extraData` field; serialised as `'extra_data'` in `toJson()` when non-null; matches `extra_data: {}` field in API attendee object spec | `lib/models/api_booking_model.dart` |
| **`ReviewPayScreen` venue booking support** — added 4 new optional params: `slotId: int?`, `packageId: int?`, `guestCount: int?`, `specialRequests: String?`; all forwarded to `BookingService.initiateBooking()` for `booking_type: 'venue'` bookings; `slot_id` is required by the API for venues | `lib/screens/review_pay_screen.dart` |
| **`_onProceedToPay` per-type branching** — replaced single attendee-replication block with explicit branches: `'event'` → builds `lineItems` from ticket maps + replicates attendee for total qty; `'class'`/`'program'` → sends `batch_id` + `quantity` + attendees only if form data present; `'venue'` → sends `slot_id`/`guest_count`/`special_requests`, attendees optional (only sent if name provided) | `lib/screens/review_pay_screen.dart` |
| **`SeatReservationScreen` venue booking wired** — added constructor params `slotId: int?`, `guestCount: int?`, `specialRequests: String?`; `ReviewPayScreen` call now passes `bookingType: 'venue'`, `slotId: widget.slotId`, `guestCount: widget.guestCount ?? _selectedSeats.length`, `specialRequests: widget.specialRequests` | `lib/screens/seat_reservation_screen.dart` |
| All 107 tests pass — no regressions | test suite |

### Session 36
| Change | Files |
|--------|-------|
| **`ApiBookingItem` model added** — full booking list/detail response shape: `id, bookingReference, bookingType, status, listingTitle, totalAmount, currency, paymentStatus, holdExpiresAt, isCancellable, createdAt, cancelledAt?, cancellationReason?, refundAmount?`; `copyWith()` for cancel response merge | `lib/models/api_booking_model.dart` |
| **`ApiBookingsPage` model added** — paginated list wrapper: `count, next, results: List<ApiBookingItem>`, `hasMore` getter, `empty()` factory | `lib/models/api_booking_model.dart` |
| **`BookingService.listBookings()` added** — `GET /api/v1/bookings/` with optional `status` filter and `page` param; returns `ApiBookingsPage`; 404 → empty page | `lib/services/booking_service.dart` |
| **`BookingService.getBookingDetail()` added** — `GET /api/v1/bookings/{id}/`; returns `ApiBookingItem` | `lib/services/booking_service.dart` |
| **`BookingService.cancelBooking()` added** — `POST /api/v1/bookings/{id}/cancel/` with optional `reason` body; returns updated `ApiBookingItem` | `lib/services/booking_service.dart` |
| **`BookingsScreen` rewritten** — fetches `GET /api/v1/bookings/` on load; tab filter applied client-side: Upcoming = `{confirmed, hold, awaiting_payment, payment_failed}`, Past = `{attended, refunded}`, Cancelled = `{cancelled}`; pull-to-refresh; loading/error/empty states; `_BookingCard` shows status badge, title, booking reference, amount, CTA ("View Ticket" for confirmed/attended, inline status message for others); `_StatusBadge` widget with color-coded labels for all 7 API statuses; cancelled booking updates propagate to list without re-fetch via `onUpdated` callback | `lib/screens/bookings_screen.dart` |
| **`ApiBookingItem.listingId` + `listingCover` added** — optional fields parsed from `listing_id`, `listing_cover`, `cover_url`, `listing.cover_url`; propagated through `copyWith()` | `lib/models/api_booking_model.dart` |
| **`BookingDetailScreen` cover image fetch** — `initState` calls `BookingService.getBookingDetail()` to get full detail; if `listingCover` present uses it; else uses `listingId` to call `fetchEventDetail` / `fetchClassDetail` / `fetchProgramDetail` / `fetchVenueDetail` based on `bookingType`; cover shown as `AspectRatio(16/9) Image.network` in the ticket card header; `_BookingTypeBanner` gradient remains as fallback; non-fatal on any error | `lib/screens/booking_detail_screen.dart` |
| **`_BookingCard` cover image** — shows `Image.network(listingCover)` when `ApiBookingItem.listingCover` is non-null; falls back to gray calendar placeholder | `lib/screens/bookings_screen.dart` |
| **`BookingDetailScreen` rewritten** — accepts `ApiBookingItem` (replacing old `BookingEntry`); `_BookingTypeBanner` gradient placeholder replaces event image (icon + type label per booking_type); `_TicketContent` shows: listing title, booking reference, type, booked-on date, amount paid; cancellation fields (cancelled_at, refund_amount) shown when `status == 'cancelled'`; bottom `_ActionBar` adds "Cancel Booking" outlined red button above Share/Download when `isCancellable == true`; cancel flow: confirmation `AlertDialog` with optional reason `TextField` → `BookingService.cancelBooking()` → updates local state + fires `onUpdated` callback; `AppLoaderInline` spinner replaces cancel button during API call | `lib/screens/booking_detail_screen.dart` |

#### Booking Status → Tab Mapping
| API Status | Tab |
|------------|-----|
| `hold` | Upcoming ("Awaiting Payment") |
| `awaiting_payment` | Upcoming ("Processing...") |
| `confirmed` | Upcoming ("Confirmed ✓") |
| `payment_failed` | Upcoming ("Payment Failed") |
| `attended` | Past |
| `refunded` | Past |
| `cancelled` | Cancelled |

#### Booking Flow (Post-Session 35 — Unified Razorpay Service)
```
[Events]  EventDetailScreen
  → DateTimeSelectionScreen (real date/time from API)
  → TicketBookingScreen (real API tickets; bookingType='event')
  → ReviewPayScreen._onProceedToPay():
      lineItems = [{ticket_id, quantity}]          ← from API ticket maps
      attendees = [qty copies of form data]
      POST /api/v1/bookings/initiate/ → { booking_id, razorpay_order_id, amount }
      Razorpay.open(order_id, amount_in_paise)
      On success: POST /api/v1/bookings/{id}/verify-payment/
        → check status=='confirmed' && payment_status=='paid'
        → BookingConfirmedScreen(bookingReference)

[Classes] ClassDetailScreen → SelectBatchScreen(batches)
  → TicketBookingScreen(bookingType='class', batchId=X)
  → ReviewPayScreen._onProceedToPay():
      batch_id=X, quantity=N, attendees=[N copies of form data]
      → same Razorpay flow

[Programs] ProgramDetailScreen → SelectProgramBatchScreen(batches)
  → TicketBookingScreen(bookingType='program', batchId=X)
  → ReviewPayScreen._onProceedToPay():
      batch_id=X, quantity=N, attendees=[N copies of form data]
      → same Razorpay flow

[Venues] VenueDetailScreen → PlanPartyScreen → VenueCheckoutScreen
  → ReviewPayScreen._onProceedToPay():
      booking_type='venue', slot_id=X, package_id=Y, guest_count=N, special_requests='...'
      attendees=[] (optional)
      POST /api/v1/bookings/initiate/ → BookingInitiateResponse
      Razorpay.open(order_id, amount_in_paise)
      On success: POST /api/v1/bookings/{id}/verify-payment/
        → check status=='confirmed' && payment_status=='paid'
        → VenueBookingConfirmedScreen(bookingReference)

NOTE: backend currently returns PAYMENT_GATEWAY_NOT_CONFIGURED for venue bookings —
      fix requires pip install razorpay on server; frontend is correct.
```

### Session 37
| Change | Files |
|--------|-------|
| **`ApiVenueOccasion` model added** — `id, name, slug`; parsed from `occasions` list in venue detail API response | `lib/models/api_venue_model.dart` |
| **`ApiVenueDetail.occasions` added** — `List<ApiVenueOccasion>` field; `fromJson` maps `json['occasions']` array | `lib/models/api_venue_model.dart` |
| **`VenueCheckoutScreen` created** — full checkout for venue booking; package selection with Add/+/- qty controls (`_PackageItem` + `_QtyButton`); `_displayDateTime` reads directly from `selectedSlot`; bill details: subtotal + 8.26% taxes; sticky CTA "Pay ₹X \| Continue to payment"; navigates to `ReviewPayScreen(bookingType:'venue', slotId, packageId, guestCount, specialRequests)` | `lib/screens/venue_checkout_screen.dart` (NEW) |
| **`VenueBookingConfirmedScreen` created** — non-ticket design; `AnimationController` (700ms, elasticOut): `ScaleTransition + FadeTransition` green checkmark; yellow-header summary card with venue, location, date, time, booking reference; blue info note; `PopScope(canPop: false)`; "View My Bookings" → BookingsScreen, "Explore More" → HomeScreen | `lib/screens/venue_booking_confirmed_screen.dart` (NEW) |
| **`PlanPartyScreen` redesigned** — AppBar title "Plan Your Kid's Party" → "Plan Your Idea"; "Child Name" label → "Planner's Name"; date grid replaced with API availability date chips (`Wrap` from `venueDetail.availability` unique dates); Morning/Afternoon/Evening buttons replaced with API time slot chips per selected date; "Number of Kids" dropdown replaced with numeric `TextField` "Number of Attendees" validated against `venueDetail.minCapacity/maxCapacity`; occasions read from `venueDetail.occasions` (API) with fallback to hardcoded; occasions displayed in `Wrap` (multi-row, no overflow); auto-selects slot when only one exists for chosen date; navigates to `VenueCheckoutScreen` | `lib/screens/plan_party_screen.dart` |
| **`VenueDetailScreen` "Plan Event" button** — now passes `venueDetail: _detail` to `PlanPartyScreen` so API data flows through the full booking pipeline | `lib/screens/venue_detail_screen.dart` |
| **`ReviewPayScreen` venue routing** — `_handlePaymentSuccess()` now routes to `VenueBookingConfirmedScreen` when `widget.bookingType == 'venue'`; all other types continue to `BookingConfirmedScreen` | `lib/screens/review_pay_screen.dart` |
| **`BookingService._extractError()` hardened** — intercepts `PAYMENT_GATEWAY_NOT_CONFIGURED` error code and returns "Online payment is temporarily unavailable for this booking. Please contact support." instead of leaking the raw backend Python/pip error to users | `lib/services/booking_service.dart` |

### Session 38
| Change | Files |
|--------|-------|
| **`partnerId: String?` added to all 4 organizer models** — `ApiEventOrganizer`, `ApiClassOrganizer`, `ApiProgramOrganizer`, `ApiVenueOrganizer` all gain a nullable `partnerId` field parsed from `json['partner_id']` | `lib/models/api_event_model.dart`, `lib/models/api_class_model.dart`, `lib/models/api_program_model.dart`, `lib/models/api_venue_model.dart` |
| **`PartnerService` created** — `follow(token, partnerId)` → `POST /api/v1/partner/{id}/follow/` (200/201 success, 400 treated as success); `unfollow(token, partnerId)` → `DELETE /api/v1/partner/{id}/unfollow/` (200 success, 404 treated as success); 30s timeout, Socket/Timeout error handling | `lib/services/partner_service.dart` (NEW) |
| **`PartnerFollowButton` widget created** — StatefulWidget with `partnerId: String?`; returns `SizedBox.shrink()` when partnerId is null/empty; grey `OutlinedButton` "Follow" when not following; yellow `ElevatedButton.icon` with check icon "Following" when following; spinner during loading; auth guard via `showLoginSheet(context)`; optimistic state flip with revert on error; SnackBar feedback on success/error | `lib/widgets/partner_follow_button.dart` (NEW) |
| **Follow buttons wired in all 4 detail screens** — replaced dead `OutlinedButton(onPressed: () {}, ...)` Follow buttons with `PartnerFollowButton(partnerId: _detail?.organizer?.partnerId)` in each organizer section | `lib/screens/event_detail_screen.dart`, `lib/screens/class_detail_screen.dart`, `lib/screens/program_detail_screen.dart`, `lib/screens/venue_detail_screen.dart` |
| **`OrganizerProfileScreen` Follow button added** — `PartnerFollowButton(partnerId: _provider?.id)` inserted below review count in the gradient header; uses the UUID from the provider API response | `lib/screens/organizer_profile_screen.dart` |

### Session 39
| Change | Files |
|--------|-------|
| **`ApiEventDetail` extended with T&C fields** — added `cancellationPolicy: String?`, `refundPolicy: String?`, `faqs: List<Map<String,String>>`; all 3 fields parsed at top-level JSON (not under `service`) | `lib/models/api_event_model.dart` |
| **`ApiProgramDetail` extended with T&C fields** — added `cancellationPolicy: String?`, `refundPolicy: String?` (faqs already existed); parsed at top-level | `lib/models/api_program_model.dart` |
| **`ApiVenueDetail` extended with T&C fields** — added `cancellationPolicy: String?`, `refundPolicy: String?`, `faqs: List<Map<String,String>>`; parsed at top-level JSON; `faqs = const []` default | `lib/models/api_venue_model.dart` |
| **T&C row conditional on real data** — all 4 detail screens: T&C "Terms & Conditions" row is now hidden when `_detail` has no `cancellationPolicy`, `refundPolicy`, or `faqs` data; was previously always visible with hardcoded content | `lib/screens/class_detail_screen.dart`, `event_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| **T&C bottom sheets use real API data** — removed all hardcoded "Attendance & Participation", "Safety & Conduct", "Supervision & Responsibility", "Health & Safety Rules" sections; replaced with `cancellationPolicy`, `refundPolicy`, and `faqs` sections dynamically rendered from API; each section hidden when its field is empty/null | `lib/screens/class_detail_screen.dart`, `event_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| **`VenueDetailScreen` T&C added** — T&C row placed after OrganizerCard (before Reviews); `_showTermsBottomSheet()` and `_buildTermsBullet()` methods added; previously no T&C row existed on venue detail | `lib/screens/venue_detail_screen.dart` |
| **`classesCategories` `apiName` mapping** — all 11 `DummyData.classesCategories` entries now carry an `apiName` key with the exact backend category name string; critical fix: `'Life Skills &\nPersonality Dev'` → `apiName: 'Life Skills & Personality Development'`; all other newline-containing labels also mapped (e.g. `'Outdoor &\nNature Learning'` → exact API string) | `lib/data/dummy_data.dart` |
| **`CategoryClassesScreen` category filter fixed** — added `_apiCategoryName` getter that reads `currentCategory['apiName']` (falls back to label with `\n` → ` `); `_fetchClasses` and `_loadMore` now use `category: _apiCategoryName` instead of the display label; city filter (`LocationState().selectedCity.value`) and subcategory filter preserved; root cause was label mismatch between DummyData and API | `lib/screens/category_classes_screen.dart` |
| **Class booking flow confirmed** — `SelectBatchScreen` routes to `AttendeeDetailsScreen(bookingType: 'class', batchId)`, NOT `TicketBookingScreen`; TicketBookingScreen is only used by Events and Programs | `lib/screens/select_batch_screen.dart` |
