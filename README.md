# The Little Broadway (TLB) — Mobile App

A Flutter-based event discovery and booking platform for kids and families. Users can explore events, classes, programs, and venues; book tickets; manage their profile; and receive a guided onboarding walkthrough on first launch.

**Package:** `com.thelittlebroadway.tlb_mobile_ui`  
**Stack:** Flutter (Dart) · Firebase Auth · Google Sign-In · REST API  
**API Base:** `https://tlb-api.reluconsultancy.in`

---

## Modules

### 1. Authentication
- **Email Sign-Up** — name, email, password with OTP email verification
- **Email Login** — email + password with JWT token persistence
- **Google Sign-In / Sign-Up** — Firebase Auth + Google OAuth, routes new vs. returning users
- **Forgot Password** — 3-step OTP wizard: email → OTP verify → new password
- **Change Password** — authenticated in-app password update
- **Persistent Session** — `FlutterSecureStorage` token storage; `tryRestoreSession()` on app launch restores login state silently

### 2. Home
- Personalised greeting with first-name from live `AuthState`
- Location selector chip
- Spotlight banner carousel
- Browse by Categories grid (Events / Classes / Programs / Venues)
- 16 content sections: Trending Now, Hot Picks, Weekend Special, Featured Events, Best for Week, Discover Near You, Family Feels, Kids Favorites, Special Needs, Popular Categories, TLB Signature, Stealers, and more
- Animated floating pill navbar with gradient scrim

### 3. Events
- Events listing screen — banners, category grid, trending, weekend, holiday, partners, new-on-TLB, online sections
- Category Events screen — filterable grid per category with sub-filter chips
- Event Detail screen — hero image, info, gallery, map, reviews, Book Now CTA
- Full booking checkout: Date & Time Selection → Ticket Booking → Review & Pay → Booking Confirmed

### 4. Classes
- Classes listing — banners, pick-your-pace selector, featured, nearby, camp cards
- Category Classes screen — filterable grid per category
- Class Detail screen — same layout as Event Detail, "Check Availability" / "Send Enquiry" CTA
- Send Enquiry flow — bottom sheet with name/phone/message + confetti success dialog
- Batch Selection screen — 3 dates, 3 batch time slots → Ticket Booking flow

### 5. Programs
- Programs listing — banners, categories, Unique Minds, Level-Up cards
- Category Programs screen — filterable grid per category
- Program Detail screen — wraps Class Detail, routes to Program Batch Selection
- Program Batch Selection — 6 dates, Morning / Evening batches with seats-left chip

### 6. Venues
- Venues listing — Big Days, Weekend Plans, Close to You, Hands-On, Easy Pocket, Mall, Thoughtful cards
- Category Venues screen — filterable grid per category with circular card layout
- Venue Detail screen — same layout as Event Detail, "Plan Event" CTA
- Plan Party screen — child name, occasion, date grid, time chips, kids-count dropdown

### 7. Booking & Checkout
- **Ticket Booking** — ticket count + price breakdown
- **Review & Pay** — order summary → payment method selection
- **Booking Confirmed** — animated teaser flip, full-width image ticket card, CustomPainter notch + dashed divider, QR code, Share / Download actions
- **Booking Detail** — same ticket design for booking history items
- **Seat Reservation** — interactive seat map

### 8. Profile & Account
- **Profile Screen** — avatar, name, email, Edit Profile, 7-icon sprite menu
- **Edit Profile** — first/last name, DOB, city, state, guardian, institution; onboarding mode blocks back navigation
- **Bookings** — booking history list → Booking Detail
- **Saved Events** — wishlist with heart disperse animation
- **Payment Settings** — saved cards and methods
- **Your Reviews** — user-posted reviews
- **Reminders** — event reminders
- **Notifications** — notification inbox
- **Account Settings** — live avatar + email via `ValueListenableBuilder`, phone, change password, privacy, delete account
- **Help Centre** — FAQ + support

### 9. Search & Discovery
- **Search Screen** — full-text search with filter bottom sheet (Age Group, Mode, Location, Date)
- **Location Screen** — city selection
- **Gallery Screen** — full-screen image gallery
- **Organizer Profile** — event organizer detail

### 10. Onboarding Walkthrough (New Users Only)
- Triggered once per new account via `SharedPreferences` flag (`tlb_is_new_user`)
- **Intro Overlay** — animated full-screen welcome card with fade+scale entrance, repeating pulse-glow icon badge, "Let's Go" dismiss
- **7-step showcase tour** (showcaseview ^5.0.2): Location chip → Home tab → Events tab → Classes tab → Programs tab → Venues tab → Profile avatar
- Dark tooltip styling (`#1A1A2E`, 78% overlay opacity)
- Flag is cleared before tour starts — force-quit mid-tour will not repeat the walkthrough

---

## Screens (44 total)

| Screen | Module |
|--------|--------|
| `splash_screen.dart` | Shell |
| `home_screen.dart` | Home |
| `events_screen.dart` | Events |
| `category_events_screen.dart` | Events |
| `event_detail_screen.dart` | Events |
| `date_time_selection_screen.dart` | Booking |
| `ticket_booking_screen.dart` | Booking |
| `review_pay_screen.dart` | Booking |
| `payment_screen.dart` | Booking |
| `booking_confirmed_screen.dart` | Booking |
| `seat_reservation_screen.dart` | Booking |
| `classes_screen.dart` | Classes |
| `category_classes_screen.dart` | Classes |
| `class_detail_screen.dart` | Classes |
| `select_batch_screen.dart` | Classes |
| `programs_screen.dart` | Programs |
| `category_programs_screen.dart` | Programs |
| `program_detail_screen.dart` | Programs |
| `select_program_batch_screen.dart` | Programs |
| `venues_screen.dart` | Venues |
| `category_venues_screen.dart` | Venues |
| `venue_detail_screen.dart` | Venues |
| `plan_party_screen.dart` | Venues |
| `widgets/login_sheet.dart` | Auth |
| `signup_screen.dart` | Auth |
| `forgot_password_screen.dart` | Auth |
| `change_password_screen.dart` | Auth |
| `profile_screen.dart` | Profile |
| `edit_profile_screen.dart` | Profile |
| `bookings_screen.dart` | Profile |
| `booking_detail_screen.dart` | Profile |
| `saved_events_screen.dart` | Profile |
| `payment_settings_screen.dart` | Profile |
| `your_reviews_screen.dart` | Profile |
| `reminders_screen.dart` | Profile |
| `notification_screen.dart` | Profile |
| `account_settings_screen.dart` | Profile |
| `help_centre_screen.dart` | Profile |
| `search_screen.dart` | Discovery |
| `location_screen.dart` | Discovery |
| `gallery_screen.dart` | Discovery |
| `organizer_profile_screen.dart` | Discovery |
| `category_detail_screen.dart` | Discovery |

---

## Key Dependencies

```yaml
google_fonts: ^6.1.0
smooth_page_indicator: ^1.1.0
flutter_rating_bar: ^4.0.1
flutter_displaymode: ^0.7.0
video_player: ^2.11.0
flutter_svg: ^2.2.4
like_button: ^2.1.0
http: ^1.2.0
firebase_core: ^3.8.0
firebase_auth: ^5.3.1
google_sign_in: ^6.2.1
showcaseview: ^5.0.2
shared_preferences: ^2.5.5
```

---

## Project Structure

```
lib/
├── main.dart                   Entry point — Firebase init, session restore, SplashScreen
├── core/                       App-wide constants (colors, theme, responsive helpers)
├── services/                   API wrappers and storage
│   ├── auth_service.dart       HTTP auth endpoints (login/signup/Google/OTP/profile)
│   ├── token_storage.dart      FlutterSecureStorage JWT wrapper
│   └── walkthrough_service.dart  SharedPreferences new-user flag
├── providers/                  Global ValueNotifier state
│   ├── auth_state.dart         isLoggedIn, userName, avatarUrl notifiers + session helpers
│   ├── location_state.dart     Selected city
│   ├── saved_events_state.dart Wishlist
│   ├── booked_events_state.dart Bookings
│   └── user_reviews_state.dart Reviews
├── helpers/
│   └── walkthrough_keys.dart   GlobalKeys and showcase config structs for onboarding tour
├── models/                     Data models (EventModel, CategoryModel)
├── data/
│   └── dummy_data.dart         Mock data — events, categories, banners, partners
├── screens/                    44 screens
├── widgets/                    30+ reusable widgets
└── sections/                   17 home-page content sections
```

---

## Getting Started

```bash
flutter pub get
flutter run
```

Requires `android/app/google-services.json` with valid Firebase credentials and SHA-1 debug fingerprint registered in the Firebase console for Google Sign-In to work.
