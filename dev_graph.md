# TLB Mobile UI — Development Graph
**Project:** The Little Broadways (TLB) — Event Booking App  
**Stack:** Flutter (Dart) · Firebase Auth · Google Sign-In · REST API  
**Package:** `com.thelittlebroadway.tlb_mobile_ui`  
**API Base:** `https://tlb-api.reluconsultancy.in`  
**Last Updated:** 2026-06-16 (Session 59)

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
│   ├── preview_mode.dart          PreviewMode.enabled ValueNotifier + SharedPreferences persistence (device_preview toggle)
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
│   ├── partner_service.dart       follow(token, partnerId) → POST /api/v1/partner/{id}/follow/; unfollow → DELETE /api/v1/partner/{id}/unfollow/
│   └── ticket_pdf_service.dart    downloadAndShare(ctx, bookingId) — fetches /ticket/data/, builds PDF natively, opens OS share sheet via printing.Printing.sharePdf
├── core/
│   ├── google_auth_error.dart     googleAuthErrorMessage(e) — exhaustive mapper for SocketException, TimeoutException, HandshakeException, FirebaseAuthException, PlatformException → user-facing snackbar text
│   ├── share_helper.dart          ShareHelper.shareListing(ctx, type, title, id) — opens OS share sheet via share_plus with a friendly TLB blurb + web URL
│   └── avatar_image.dart          avatarImageProvider(value, fallback:) — branches between NetworkImage (http) / FileImage (absolute path) / fallback
├── providers/
│   └── notifications_state.dart   NotificationsState.unreadCount ValueNotifier<int> — bell-badge dot only renders when > 0
├── services/
│   └── avatar_storage.dart        AvatarStorage.load/saveFromPickedFile/clear — copies picked image into app docs and remembers the path in SharedPreferences
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
| `banner_carousel.dart` | Auto-scroll image carousel with overlay style. Params incl. `fixedCardWidth`, `cornerRadius` (0 = full-bleed; S51), `overlayDots` (page dots overlaid on the banner bottom; S51) |
| `event_card.dart` / `event_card_with_rating.dart` / `event_card_with_price.dart` | Various event card styles |
| `class_nearby_card.dart` | Horizontal class card with tag + button |
| `wishlist_button.dart` | Heart toggle (`LikeButton`) with disperse animation. S56: `LikeButton` rendered at `buttonSize` (24) inside the 36px white circle and wrapped in `OverflowBox` so its internal layout can never trigger the red "OVERFLOWED" stripe; circular Container's `Clip.hardEdge` clips stray paint |
| `partner_follow_button.dart` | Follow/Unfollow stateful button — grey outlined "Follow" / yellow filled "Following"; auth guard; optimistic update; returns `SizedBox.shrink()` when partnerId is null |
| `explore_categories_grid.dart` | 3-col category icon grid. `scrollable: true` + `visibleRows` = fixed-height inner scroll with "View All" chip overlaid at bottom. S51: bottom-fade `ShaderMask` (soft dissolve) + `maxScrollRows` cap (Events uses 3) |
| `explore_format_row.dart` | Horizontal format circles row — 6 circle images from `Explore_by_format/`; `onFormatTap(index)`; `ColorFilter.matrix` inversion for MasterClass; per-entry `scale`; `ClipOval + BoxFit.cover`. S51: `LayoutBuilder` sizes circles so ~3 fill the width with even 12 px gaps (~112 px) |
| `holiday_special_card.dart` | Tall gradient card for holiday events |
| `new_on_tlb_card.dart` | PageView card for new listings |
| `online_event_card.dart` | Online event card with platform badge |
| `weekend_event_card.dart` | Compact horizontal weekend card |
| `partner_portrait_card.dart` | Featured partner portrait card |
| `section_divider_widget.dart` | Centered section title flanked by golden accent lines. Params: `title`, `lineLength`, `fontSize` (default **17**), `fontWeight` (default `w600`), `textColor` (default **`textPrimary`** dark navy), `lineColor` (default `dividerGold`), `lineThickness`. Default style matches every section title app-wide (S51) |
| `trending_event_card.dart` | **(S51)** Events "Trending" card — image-dominant, date badge + heart, title, `Workshop` lavender chip + age, star+reviews, location + Book Now |
| `filter_bottom_sheet.dart` | Legacy filter sheet |
| `all_categories_popup.dart` | Full-screen categories popup |
| `pick_your_pace_row.dart` | Skill level selector row |
| `inquire_now_sheet.dart` | "Send Enquiry" bottom sheet with confetti success |
| `banner_carousel.dart` | Spotlight banner with overlay gradient |
| `empty_location_widget.dart` | Empty state for no-location screens |
| `walkthrough_intro_overlay.dart` | Full-screen animated welcome card — fade+scale entrance (380ms), repeating icon pulse glow, "Let's Go" dismiss triggers showcase start |
| `category_event_card.dart` | Flat grid card for category screens (no container/shadow) — 12px rounded image, subcategory badge, title, 📍 venue, ⭐ reviewCount row, `Description –` body up to 3 lines (no price); accepts `onTap` callback override; used by CategoryEvents/Classes/Programs/VenuesScreen |
| `app_loader.dart` | Premium branded loading animation (bouncing dots). Uses `AppLoader.useCustomLoader` static flag for fallback to default `CircularProgressIndicator`. Contains `AppLoader()` (fullscreen) and `AppLoaderInline()` (buttons/spinners). |
| `preview_toggle_button.dart` | Draggable 44×44 floating button overlaying every screen. Tap toggles `PreviewMode.enabled`; dark icon (off) ↔ yellow icon (on). Position stored in widget state, clamped to screen bounds. |

---

## 5. Sections (Home Page, 11 active)

Session-50 redesign: all card sections share one visual language — **image-dominant cards** (image is `Expanded` so it fills the majority of the card and is flush to the card edges with rounded top corners; content sits below at natural height, no `spaceBetween` gaps). Section titles use `SectionDividerWidget(fontSize: 17, textColor: 0xFF1A1A2E)` (light-bold `w600` from the new default).

Feed order (top → bottom): Spotlight (inline) → Categories grid (inline) → Hot Picks → Weekend Specials → Discover Near You → Family Feels → New on the Block → Parents' Favorite → Stealers → Where Every Star Shines → TLB Signature → AppFooter.

| Section | Content |
|---------|---------|
| `home_header.dart` | Gradient header (#FFB219 → white), first-name greeting **bold `w700`** (ValueListenableBuilder on `userName`), location, bell icon, avatar (ValueListenableBuilder on `avatarUrl`), **search bar with golden gradient fill** (`#FFE9B8 → #FFF4D8 → #FFFDF7`, left→right) |
| `hot_picks_section.dart` | Image-dominant cards — "Filling Fast" diagonal badge top-left; title, 3-5 Yrs, stars+reviews, venue, `₹X / child`, Book Now |
| `weekend_special_section.dart` | PageView carousel — image-dominant; white date badge (Fri / mar 15) top-left, heart top-right; title, stars+reviews, venue, Book Now; dot indicator |
| `discover_near_you_section.dart` | Image-dominant; pink "X km away" gradient band at image bottom; title + grey `Outdoor Play` chip, venue, stars, `Description – …` (2 lines), Book Now |
| `family_feels_section.dart` | Family events section |
| `new_on_the_block_section.dart` | **NEW (S50)** — image-dominant; dark-navy time-ago band at image bottom ("2 days ago"); title, `area • distance`, View Details. Data: `DummyData.newOnTheBlock` (`venue`=location line, `tag`=time-ago) |
| `parents_favorite_section.dart` | **NEW (S50)** — image-dominant; pink→purple "Loved by Parents" diagonal badge top-left; title + age (person icon + `4-12 Yrs`), star+`4.8`+`(reviews)`, `Price – ₹X` + Visit. Data: `DummyData.parentsFavorite` (`description`=age range) |
| `stealers_section.dart` | Image-dominant; yellow countdown pill ("End in …") top-center, pink "60% OFF" band bottom; title, stars+reviews, `₹X` + Grab Deal. (`description`=countdown, `tag`=discount) |
| `special_needs_section.dart` | **Renamed "Where Every Star Shines" (S50)** — horizontal split card: left inset image + red circular star badge; right column has pink→purple `Sensory Friendly` pill (right-aligned), title, star+reviews, `area • km`, Explore. Data: `DummyData.specialNeeds` (`venue`=location, `tag`=pill) |
| `tlb_signature_section.dart` | Image-dominant poster; purple "TLB Originals" pill centered at top; title, description (2 lines), full-width Register Now |
| `app_footer.dart` | `main-footer.png` recoloured white→light-orange via a modulate `ShaderMask` (matches header palette); `bottomExtra` param stretches the colour past the floating navbar to the screen edge (S51) |

> Spotlight is rendered inline in `home_screen.dart` via `BannerCarousel`. The "Explore the Stage" category grid is `widgets/categories_grid.dart` (also inline). Note: the "Where Every Star Shines" section's class/file is still named `SpecialNeedsSection` / `special_needs_section.dart` — only the displayed title changed.

---

## 6. Core Services & State

### BookingService — ticket data (`lib/services/booking_service.dart`)
- **`fetchTicketData({token, bookingId})`** — GET `/api/v1/bookings/{id}/ticket/data/` → `Map<String, dynamic>` raw JSON (booking_reference, listing details, customer, line_items, date/time, `qr_code` as base64 PNG); only returns for `status=CONFIRMED`; 30s timeout, typed Socket/Timeout errors; unwraps `data` envelope

### TicketPdfService (`lib/services/ticket_pdf_service.dart`)
- **`downloadAndShare(context, bookingId)`** — one-shot helper: shows a blocking spinner, calls `BookingService.fetchTicketData`, builds an A4 PDF natively via the `pdf` package (yellow header band, cover image fetched separately, title, booking ref + date/time/venue rows, line-item table, total, decoded QR), then triggers OS share sheet via `Printing.sharePdf(filename: tlb_ticket_<ref>.pdf)`.
- Graceful degradation: QR decode failure / cover-image fetch failure don't abort — PDF renders without them. `context.mounted` checked before every navigation pop.
- `Navigator.of(context, rootNavigator: true).pop()` used for the spinner dismiss so it works regardless of nested route depth.

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
**`ApiClassDetail`** (extends ApiClass) — adds `description, organizer, subcategory, format, mode, ageGroup, tags, city, area, address, meetingLink, teaserVideoUrl, cancellationPolicy, refundPolicy, faqs, bookingType (String — "enquiry" | "direct_booking"), price (double? — parsed from service.price), batches, media`  
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
- `googleSignIn(idToken)` — POST `/api/v1/auth/google-login/` body `{"id_token": firebaseToken}` → `{"access_token"/"access", "refresh_token"/"refresh", "is_new_user", "user"}`; now maps the three documented backend error codes — `INVALID_GOOGLE_TOKEN`, `UNVERIFIED_EMAIL`, `USER_ROLE_MISMATCH` — to friendly user-facing messages (Session 46); returns `code` in the result map for telemetry
- `deleteAccount(accessToken)` — DELETE `/api/v1/customer/account/` (Session 48); soft-deletes the customer; on 200 the client logs out + navigates to LoginScreen; maps 401/403 to friendly messages
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
- `_refreshProfileFromApi(token)` — private fire-and-forget; called from `login()` when the auth response carries no `profile` block (the verify-OTP and Google sign-in payloads typically don't); GETs `/api/v1/customer/profile/` and feeds the result into `updateProfileData()` so the home greeting catches up to the real name without the user opening Edit Profile.

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
Layer 1 (cloud image, golden-tinted, fading out):
  Positioned(top:0,left:0,right:0, bottom: 28)   ← NOT Positioned.fill (S56 seam fix)
    └── ShaderMask(BlendMode.dstIn, stops [0,0.35,1.0])  ← fades cloud to transparent at bottom
          └── ColorFiltered(BlendMode.screen, Color(0xFFFFB219))  ← golden tint
                └── Transform.flip(flipY) → Image.asset('header.jpg', fitWidth, topCenter)
  ── Seam fix (S56): ShaderMask forces a saveLayer whose bottom edge leaves a 1px
     premultiplied-RGB fringe of the screen-blended cloud (independent of the alpha
     mask — fading the shader did NOT remove it). `bottom: 28` tucks that edge behind
     the opaque search bar, so it can't be seen, while the cloud still fades out around
     the search bar (visually full). The page gradient in home_screen.dart holds a flat
     cream band (#FFF0D0) across the header-bottom zone so the transition is continuous.
     Do NOT change the Stack to Clip.antiAlias or tweak shader stops — neither removes
     the fringe; only the inset (or covering it) works. Verified on-device.

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

### Device Preview Toggle (Dev Tool)
```
Always-mounted DevicePreview wrapper at app root + draggable floating toggle button:

main.dart structure:
  runApp(TLBRoot)
    └── TLBRoot
          Directionality(ltr) → Stack(fit: expand)
            ├── ValueListenableBuilder<bool>(PreviewMode.enabled)
            │     DevicePreview(enabled: isEnabled, builder: (_) => TLBApp())
            │       ← stays mounted; toggling `enabled` flips frame on/off
            │         without unmounting MaterialApp (navigation state preserved)
            └── PreviewToggleButton()  ← floats above device frame + chrome

TLBApp MaterialApp config:
  locale: DevicePreview.locale(context)
  builder: (ctx, child) {
    final clamped = MediaQuery(textScaler: 1.0, child: child!);
    return DevicePreview.appBuilder(ctx, clamped);   ← order matters: clamp first, frame second
  }

PreviewToggleButton:
  44×44 Material circle, Positioned in root Stack
  Default position: top-right (screen.width - 56, safeTop + 12)
  Drag via GestureDetector.onPanUpdate; Offset clamped to screen bounds
  Tap → PreviewMode.toggle()
  Visual: Icons.devices on dark-translucent (off) / Icons.phone_iphone on #FFCC00 (on)

PreviewMode:
  static ValueNotifier<bool> enabled
  SharedPreferences key: 'tlb_device_preview_enabled' (persists across restarts)
  load() called from main() after Firebase init

Integration with existing Responsive helper:
  Responsive.w/h/sp all read MediaQuery.of(context).size
  device_preview overrides MediaQuery per simulated device
  → switching device in preview shell re-flows all screens automatically
  → no per-screen changes required
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
| ~~Profile screen reactive to name/avatar changes~~ | `profile_screen.dart` | ✅ Done (Session 48) — wrapped in nested `ValueListenableBuilder` on both `userName` and `avatarUrl` |
| ~~Profile avatar upload~~ | `lib/screens/profile_screen.dart`, `lib/services/avatar_storage.dart` | ✅ Done (Session 48) — local-only upload via `image_picker` + `path_provider`; persists across launches; backend integration is a one-liner when an avatar endpoint ships |
| ~~Support Tickets Dynamic Integration~~ | `lib/screens/help_centre_screen.dart`, `lib/services/help_service.dart`, `ticket_detail_screen.dart` | ✅ Done (Session 52) — dynamic categories fetched from API, chat polling timezone issue solved using `sinceRaw`, manual refresh button added |
| ~~Payment Settings API Crash~~ | `lib/services/payment_method_service.dart` | ✅ Done (Session 52) — fixed plural `customers` path to `customer`; added resilient JSON parsing to handle HTML error pages gracefully |
| ~~Classes Screen UI Polish~~ | `lib/screens/classes_screen.dart`, `lib/widgets/class_nearby_card.dart` | ✅ Done (Session 52) — fixed CTA cutoff bugs for 'Top Picks For You' & 'Holiday Special', removed 'Right Around You' CTA button gracefully, enlarged specific Pick Your Pace images |
| Programs price flow (parallel of Session 43 class fix) | `lib/models/api_program_model.dart`, `lib/screens/program_detail_screen.dart` | ❌ Pending — `ApiProgramDetail` has no `price` field; `program_detail_screen.dart` reads only `widget.event.price`; same Review & Pay ₹0 bug likely present when arriving from list pages |
| Backend `/auth/request-otp/` should reject unregistered emails for login | backend | ❌ Pending — Session 48 added a client-side rejection of `is_new_user: true` on the login flow, but the OTP itself is still delivered (and an account is auto-created). Needs a `purpose: 'login'` flag on the request body that the backend honours |
| Backend `/auth/account/` recovery / re-signup flow after delete | backend | ❌ Pending — Session 48 wires the delete API. The account is soft-deleted server-side, so the next OTP-login attempt for that email likely returns a role/status error. Need to confirm the recovery path |
| Backend Reminders + Notifications APIs | backend | ❌ Pending — `NotificationsState.unreadCount` (Session 48) is ready to be populated; Reminders screen still hidden from profile menu since Session 45 |
| Invoice download (parallel of Session 45 ticket download) | `lib/services/booking_service.dart`, `lib/services/ticket_pdf_service.dart`, confirmation/detail screens | ❌ Pending — `GET /bookings/{id}/invoice/data/` not wired; users can download tickets but not separate invoices. Same shape as ticket flow; could be a second bottom-sheet option behind the Download button |
| Reminders feature restore | `lib/screens/profile_screen.dart`, `lib/screens/reminders_screen.dart` | ⏸️ On hold — profile entry + import commented out in Session 45 with "restore when ready" note; screen file untouched and ready to re-enable |
| Analyzer `info`-level cleanup | `lib/services/{events,classes,programs}_listing_service.dart`, `lib/screens/booking_detail_screen.dart` | ❌ Pending — 27 `use_null_aware_elements` hints (Dart 3 syntax `[?x]` over `if (x != null) x` in collection literals) + 1 `curly_braces_in_flow_control_structures`; non-blocking modernization, no warnings or errors |
| Test file unused imports | `test/helpers/test_setup.dart`, `test/screens/{category_venues,change_password,event_detail}_screen_test.dart` | ❌ Pending — 5 unused-import warnings in test files; doesn't affect runtime |
| Inject `http.Client` into services | `lib/services/{auth,booking,events_listing,wishlist,review,partner,classes_listing,programs_listing}_service.dart` | ❌ Pending — every service uses top-level `http.post/get` directly; unlockable with one static field per service (~30 LoC); blocks proper HTTP integration tests. See `testing_report.md` §7 for full details |
| Backend: include `cover_url` in `/bookings/` list response | backend (Django) | ❌ Pending — would eliminate the per-card lazy fetch + N+1 query pattern added in Session 46. The current workaround uses a process-lifetime in-memory cache keyed by `bookingType:listingId` |
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
device_preview: ^1.2.0       # Device-frame preview shell — resolved to 1.3.1 (added Session 42)
printing: ^5.13.0            # Native PDF generation + system share sheet (added Session 45)
pdf: ^3.11.0                 # PDF document model used by printing (added Session 45)
path_provider: ^2.1.4        # Local app-docs dir (avatar storage)             (added Session 48)
share_plus: ^7.2.2           # Native share sheet for events/classes/programs/venues (added Session 48)
```

---

## 12. Development Sessions Summary

### Session 59 — Spotlight motion/loop, animated badges/tags, detail-screen typography, quote & splash timing
A continuation of the Session 58 screenshot-driven polish pass. Focus: making the Spotlight banner feel alive (Ken Burns + shine + sparkles, endless loop), animating accent badges/tags, refining detail-screen typography, and retiming the quote carousel + splash.

#### Spotlight banner — interactive motion + endless loop (`banner_carousel.dart`)
| Change | Files |
|--------|-------|
| **Endless cycle** — carousel never rewinds to the first card; virtual `itemCount` (`events.length × 2000`) starting at a large base page (`× 1000`) with modulo lookup, auto-advance via `nextPage()`. Gated behind a new `infiniteScroll` flag (Spotlight only) | `lib/widgets/banner_carousel.dart`, `lib/screens/home_screen.dart` |
| **`animateImages` FX stack** — subtle Ken Burns (`Transform.scale` 1.0→1.18 + `AlignmentTween`, 10s reverse), diagonal shine sweep (first 50% of a 4.5s loop), and drifting/twinkling sparkle particles (`CustomPainter`, 10 seeds) overlaid via `IgnorePointer` | `lib/widgets/banner_carousel.dart` |

#### Animated badges & tags
| Change | Files |
|--------|-------|
| **Loved-by-Parents badge** — slow left→right shine sweep (`_ShineBadge`: ClipRRect + animated diagonal band, 3.2s loop) | `lib/sections/parents_favorite_section.dart` |
| **Holiday Edit tag (programs)** — animated red→purple sliding gradient flow via `AnimatedGradientTag` | `lib/screens/programs_screen.dart` |

#### Detail-screen typography + About box
| Change | Files |
|--------|-------|
| **Body text** softened to medium `#333333` (`kDetailText`), while **section titles** (e.g. "About Us", "Things to Know") kept **bold** (`w700`) | `lib/widgets/detail_sections.dart`, `*_detail_screen.dart` |
| **About box** — inner background pure white; body copy full-black slim (`w400`) | `lib/widgets/detail_sections.dart` |

#### Quote carousel + splash timing
| Change | Files |
|--------|-------|
| **Footer quote carousel** — vertical slideshow transition (new quote eases in from the top while the old slides down and fades), slower 1400ms pace | `lib/widgets/footer_quote_carousel.dart` |
| **Splash** — loading window extended to ~5s; animation intervals re-scaled accordingly | `lib/screens/splash_screen.dart` |

#### Misc polish
| Change | Files |
|--------|-------|
| **Home section CTA buttons** — reduced cell height with proportionally smaller font | `weekend_special / family_feels / special_needs / stealers / tlb_signature` sections |
| **Get Moving (venues)** — removed the stray radial shadow ellipse under the top-right sport image | `lib/screens/venues_screen.dart` |
| **What's the Plan? (venues)** — Party & Celebration circle vertical alignment nudged to match siblings | `lib/data/dummy_data.dart`, `venues_screen.dart` |
| **Home-header seam cover** — fade-in cream strip (`seamCoverColor #FFF0D0`) painted over the ShaderMask cloud's 1px bottom fringe to kill the on-device search-bar/Spotlight seam | `lib/sections/home_header.dart`, `lib/screens/home_screen.dart` |

**`flutter analyze`: clean (0 errors).**

### Session 58 — UI polish sweep: card redesigns, Spotlight peek-carousel, gradient extension, legal docs
A broad screenshot-driven polish pass across all tabs. Focus areas: inset "image-inside-the-card" redesigns, the Spotlight banner peek-carousel with an animated golden border, extending the warm header gradient down to each screen's first section title, normalising CTA button weight/colour, and new Privacy/Terms document screens.

#### Spotlight banner — peek carousel + animated golden border (`banner_carousel.dart`)
| Change | Files |
|--------|-------|
| **`viewportFraction` peek mode** — Spotlight banner now shows the previous/next banners peeking at the edges (`viewportFraction: 0.84`); side cards scale down to ~0.84 anchored to their **visible edge** (so the peek width is preserved, not collapsed) | `lib/widgets/banner_carousel.dart`, `lib/screens/home_screen.dart` |
| **`animatedGoldenBorder`** — ~4px golden `SweepGradient` border sweeps continuously (4s loop) around the Spotlight card via `CustomPaint`; corner radius matched to the venues banner (28) | `lib/widgets/banner_carousel.dart` |

#### Header gradient extended to first title (all 5 tabs)
| Change | Files |
|--------|-------|
| **Warm header gradient now wraps header → banner → first section title** (like the home Spotlight header), with an added stop holding cream down to the title before fading to white | `events/venues/programs/classes_screen.dart` |
| **Home-header seam fix attempt reverted** — the `ShaderMask(dstIn)` cloud fade (with its 1px premultiplied-alpha edge fringe) was kept as-is after an opaque-overlay replacement looked worse | `lib/sections/home_header.dart` (unchanged net) |

#### Card redesigns — image as an inset rounded component
| Change | Files |
|--------|-------|
| **Build New Skills (classes)** — image is a separate fully-rounded thumbnail inset inside the card; 10px content gaps; CTA pinned to the bottom; wider image | `lib/widgets/build_skill_card.dart`, `classes_screen.dart` |
| **Make Your Weekends Count / Zero to Hero (programs)** — image inset with all corners rounded (not cut at the edge), widened; Zero-to-Hero CTA made compact | `lib/screens/programs_screen.dart` |
| **Easy on the Pocket (venues)** — image inset inside the card with rounded corners + the green distance band following the rounded bottom; taller card with more image coverage | `lib/screens/venues_screen.dart` |
| **Hot Picks (home)** — removed the CTA button, image (Expanded) stretches down to fill, whole card tappable, 20px bottom gap | `lib/sections/hot_picks_section.dart` |
| **For the Big Days (venues)** — narrower, taller portrait card; smaller image-banner tag pills (`_bigDayPill(small:)`) | `lib/screens/venues_screen.dart` |

#### Section data + images
| Change | Files |
|--------|-------|
| **What's the Plan? (venues)** — 6 category circles repointed to new `venues_page/1–6.png`; rendered uniformly (`BoxFit.contain`, no clip/shadow) at 152px with a per-image `inset` for size normalisation | `lib/data/dummy_data.dart`, `venues_screen.dart` |
| **Find Your Fit (programs)** — softened the circular border (solid black → thin light-black hairline), per-card pastel gradient base + soft bottom gradient veil sampled from the reference | `lib/widgets/pick_your_pace_row.dart`, `dummy_data.dart` |
| **Missing image banners fixed** — `newontlb1.jpg` (Storytelling Club, Chess Academy) and the two Online Events images repointed to existing resources; registered `resources- tlb-ui/class_page/` in pubspec | `lib/data/dummy_data.dart`, `pubspec.yaml` |
| **Online Events card (events)** — image switched to `Expanded` (taller, 20px bottom gap) | `lib/widgets/online_event_card.dart`, `events_screen.dart` |

#### Global tweaks
| Change | Files |
|--------|-------|
| **CTA button text weight normalised to `w500`** (medium) across the app | many `lib/screens` + `lib/widgets` |
| **See-All colour** standardised to `#0068E7` | `lib/core/app_colors.dart` |
| **Holiday Special tag** — animated red→purple sliding gradient (seamless loop) via extended `AnimatedGradientTag` | `lib/widgets/animated_gradient_tag.dart`, `holiday_special_card.dart` |
| **Date/Time selection** — selected box gradient lightened (shine kept) + soft darker-gold border | `lib/screens/date_time_selection_screen.dart` |
| **Detail screens** — banner `expandedHeight` +20px (`230→250`) on event/class/program/venue detail | `*_detail_screen.dart` |
| **Account Settings** — separator dividers lightened to `#EFEFEF` / 0.7 thickness | `lib/screens/account_settings_screen.dart` |
| **Section-header gaps** standardised to 30px; card description darkened to `#333333` | `section_divider_widget.dart`, `app_colors.dart` |

#### Legal documents (new screens)
| Change | Files |
|--------|-------|
| **Privacy Policy + Terms of Service** screens (reached from the redesigned About Us list) built on a shared `LegalDocScaffold` (logo header + `LegalHeading/Subheading/Paragraph/Bullets`) | `lib/screens/privacy_policy_screen.dart` (NEW), `terms_of_service_screen.dart` (NEW), `lib/widgets/legal_doc.dart` (NEW), `about_us_screen.dart` |

**`flutter analyze`: clean (0 errors; pre-existing baseline hints only).**

### Session 57 — Logo/brand pass: SVG footer + splash + app icon, rotating quotes, branded refresh loader, About Us
A brand-consistency pass centred on the TLB wordmark logo (`assets/icons/the_little_broadway_logo.svg`, viewBox cropped to the artwork `100 198 900 706`). The same logo now appears in the footer, splash, and app launcher icon. Added a rotating cursive quote strip, a new About Us screen, a branded pull-to-refresh loader, and assorted card polish.

#### New brand asset + fonts
| Change | Files |
|--------|-------|
| **TLB wordmark SVG added** — black "tlb / The Little Broadway" logo; reused across footer, splash, About Us, app icon | `assets/icons/the_little_broadway_logo.svg` (NEW) |
| **Dancing Script cursive font bundled** — variable TTF in `google_fonts/`, registered as Flutter `fonts:` family `DancingScript` (works offline; runtime fetch stays disabled) | `google_fonts/DancingScript-Variable.ttf` (NEW), `pubspec.yaml` |

#### Footer redesign (`app_footer.dart`)
| Change | Files |
|--------|-------|
| **Replaced `main-footer.png` with the logo SVG** on a header-matched warm gradient that dissolves UP into the page (transparent cream at top → golden-orange `#FB9512` at the bottom edge; mirrors the header's down-fade). Logo width 0.46× screen; `bottomExtra` filled by the same gradient (no seam) | `lib/sections/app_footer.dart` |

#### Rotating quote strip
| Change | Files |
|--------|-------|
| **`FooterQuoteCarousel`** — 30 kids/energy quotes, one shown at a time in **cursive** (Dancing Script), new quote every **10 s** with a fade+slide+scale `AnimatedSwitcher` transition; golden accent bar above. Placed just above `AppFooter` on all 5 tab screens | `lib/widgets/footer_quote_carousel.dart` (NEW), `home/events/classes/programs/venues_screen.dart` |

#### Splash redesign (`splash_screen.dart`)
| Change | Files |
|--------|-------|
| **Rebuilt** — logo SVG (elastic scale + fade) on a brand golden gradient (`#FFE08A → #FFC93C → #FFB219`), soft radial glow, cursive "Where every star shines" tagline, pulsing loading dots; fade-out to `nextScreen` (~2.8 s). Old `assets/images/tlb_logo.png` reference dropped | `lib/screens/splash_screen.dart` |

#### App launcher icon
| Change | Files |
|--------|-------|
| **Icon updated to the TLB logo** — rasterised the SVG (headless Chrome) to a gold-bg legacy icon + a transparent padded adaptive foreground; generated all Android/iOS icons via `flutter_launcher_icons` (adaptive bg `#FFC21A`) | `assets/icon/app_icon.png` + `app_icon_fg.png` (NEW), `pubspec.yaml`, `android/.../mipmap-*`, `ios/.../AppIcon.appiconset` |

#### Branded pull-to-refresh loader
| Change | Files |
|--------|-------|
| **`AppRefreshIndicator`** — wraps `custom_refresh_indicator` to show TLB's golden bouncing-dots (`AppLoaderInline`) instead of the Material spinner; content slides down on pull. Swapped into all 12 `RefreshIndicator` call sites (11 screens) | `lib/widgets/app_refresh_indicator.dart` (NEW), `pubspec.yaml` (`custom_refresh_indicator`), home/events/classes/programs/venues/followed_partners/your_reviews/saved_events/notification/bookings/tickets_list screens |

#### About Us (new screen)
| Change | Files |
|--------|-------|
| **`AboutUsScreen`** — logo SVG on a golden banner that extends behind a transparent AppBar (gradient covers the top); highlighted title chip; placeholder "Who We Are" copy; **Terms & Conditions** button → popup dialog with placeholder copy. Added "About Us" item to the profile menu (after Help) | `lib/screens/about_us_screen.dart` (NEW), `lib/screens/profile_screen.dart` |

#### Followed Partners — interactive cards
| Change | Files |
|--------|-------|
| **More interactive + vibrant** — whole card tappable → `OrganizerProfileScreen` (pre-fetched `ApiProvider` from the followed-partner data) with press-scale + golden ripple + haptic; "View Profile" gradient **pill** affordance; Unfollow now shows a **confirmation dialog**. Muted amber `#F5A623` → vibrant orange `#FF7A00`; orange→gold gradient stripe/pill, gradient avatar | `lib/screens/followed_partners_screen.dart` |

#### Card polish
| Change | Files |
|--------|-------|
| **Price labels removed** from section cards (CTA buttons kept, right-aligned via `Spacer`) | `hot_picks/parents_favorite/stealers/family_feels_section.dart`, `event_card_with_price.dart`, `new_on_tlb_card.dart` |
| **Description text darkened** — card description body uses new `AppColors.textDescription` (`#2D2D2D`, dark grey not black); only the description line (not other secondary text) | `app_colors.dart`, `category_event_card/class_nearby_card/online_event_card/special_focus_card/trending_card.dart`, `discover_near_you_section.dart` |
| **Section-divider long-title accent length** 40 → 90 px (less stubby; `Flexible` still prevents overflow) | `lib/widgets/section_divider_widget.dart` |
| **Venues tag pills moved inside the image** (Big Days, Mall) — were straddling the image/description seam (`bottom: -13` → `bottom: 12`) | `lib/screens/venues_screen.dart` |

**Tests:** splash test updated for the SVG logo + tagline; three "scroll to bottom" tests switched from `pumpAndSettle()` to bounded `pump()` (screens now have perpetual auto-scroll rails + rotating quote). **`flutter test`: 130/130 pass.** `flutter analyze`: clean (37 pre-existing baseline hints only).

### Session 56 — Explore-the-Stage golden box, detail/empty-state polish, home-header seam fix
Continued UI polish, then a deep, on-device-verified fix of the long-standing header→Spotlight seam plus its two follow-up regressions. The seam work was diagnosed by running the app on the Android emulator and using pixel-level screenshot analysis (the cause was a `ShaderMask` saveLayer edge fringe, not a gradient/line).

#### Explore the Stage (home category grid)
| Change | Files |
|--------|-------|
| **New category icons** — Events=tickets (`image 264`), Classes=books+pencils (`image 295`), Programs=trophy+grad-cap (`image 267`), Venues=map-pin (`image 296`); folder registered in pubspec | `lib/data/dummy_data.dart`, `pubspec.yaml`, `resources- tlb-ui/homescreen_Explorethestage/` |
| **Golden-yellow gradient box** around each icon — light golden fill (`#FCE7A6`→`#FEF3D2`→white, holds white at bottom) that blends seamlessly into the page; 3-sided border (left/top/right, bottom open) darkened to `#CE9B1E` with a top→bottom fade shader so the sides dissolve into the page | `lib/widgets/categories_grid.dart` |

#### Detail screens & empty states
| Change | Files |
|--------|-------|
| **About box brighter** — page bg reverted to `#FAFAFC` while the About card stays pure white so it reads as whiter/lighter against the page | `lib/widgets/detail_sections.dart` |
| **Gallery shows ALL images as auto-carousel** — `DetailGallery` confirmed to pass every non-cover media item; static `ListView` swapped for `AutoScrollList` | `lib/widgets/detail_sections.dart` |
| **Coming-soon empty state image** — category-screen empty state (`SubcategoryEmptyState`) now uses `resources- tlb-ui/coming soon.png` | `lib/widgets/subcategory_empty_state.dart` |

#### TLB Signature CTA fix
| Change | Files |
|--------|-------|
| **Invisible "View Now" button fixed** — button had `height: 36 (min 32)` but kept the default `materialTapTargetSize: padded` (≥48px tap target), which collapsed it. Added `tapTargetSize: shrinkWrap` + `minimumSize: Size.zero` + explicit padding; height set to 42 (min 40) | `lib/sections/tlb_signature_section.dart` |

#### Home-header → Spotlight seam (the definitive fix)
| Change | Files |
|--------|-------|
| **Root cause (pixel-verified):** the cloud's `ShaderMask` (`BlendMode.dstIn`) forces a `saveLayer` whose hard bottom edge leaves a 1px premultiplied-RGB fringe (golden `#FFD78D`) of the screen-blended cloud, at the header's bottom — right under the search bar. It is independent of the mask's alpha (so fading the shader, changing stops, anti-aliased clipping, and transparent-cream overlays all FAILED; an earlier overlay using `Colors.transparent` = transparent **black** even introduced a dark band). | — |
| **Fix:** cloud layer changed from `Positioned.fill` → `Positioned(..., bottom: 28)`, tucking the fringe behind the opaque search bar; the cloud still fades out around the search bar (visually full). Page gradient in home_screen holds a flat cream band (`#FFF0D0`) across the header-bottom zone for a continuous surface. ShaderMask/ColorFiltered/image left at original values. | `lib/sections/home_header.dart`, `lib/screens/home_screen.dart` |
| **Walkthrough crash fixed (surfaced while running)** — location `Showcase` used `onTargetClick` without `disposeOnTap`, which `showcaseview` now asserts; red-screened the whole header on first launch. Added `disposeOnTap: true` | `lib/sections/home_header.dart` |

#### Seam-fix regressions (both fixed & on-device verified)
| Change | Files |
|--------|-------|
| **Cloud no longer cut off** — restored original header padding (top 14, bottom 20) that an interim step had reduced; with full padding the `bottom: 28` cloud extends to its original depth | `lib/sections/home_header.dart` |
| **Wishlist heart overflow removed** — `LikeButton` was given `size: containerSize` (36) and overflowed its 36px circle (red "OVERFLOWED" stripe). Now rendered at `buttonSize` (24) inside an `OverflowBox`; card spacing bumped 12→16 | `lib/widgets/wishlist_button.dart`, `lib/widgets/banner_carousel.dart` |

**`flutter analyze`:** clean (37 pre-existing baseline hints only). **`flutter test`:** smoke + wishlist tests pass. Seam/cloud/heart each verified on the Android emulator via zoomed screenshots + pixel scans.

### Session 55 — Home-feed wiring + section/card polish, detail-screen restyle, gallery carousel
A long UI/UX iteration pass across home, the four listing screens, and the four detail screens. Built the Spotlight section from the homepage API, then reverted home sections to mock data on request; fixed the wishlist crash; redesigned the Account header and several partner/section cards; and finished with a detail-screen restyle.

#### Home feed — Spotlight wiring then mock revert
| Change | Files |
|--------|-------|
| **Spotlight built from homepage API** — `HomepageListing` rewritten with full card fields + `toEventModel()`; `HomeFeedState.load()` maps listings directly (no cross-API hydration); `BannerCarousel` background made network-aware (`Image.network` for http covers, asset otherwise) | `lib/models/homepage_section_model.dart`, `lib/providers/home_feed_state.dart`, `lib/widgets/banner_carousel.dart` |
| **Reverted home sections to mock data** (per request) — API section data-source lines + `HomeFeedState.load()` calls commented out (retrievable); banner back to `DummyData.bannerEvents` | `lib/screens/home_screen.dart` |
| **Purple category badges removed** — overlay badges on section card images commented out (kept for future) | section card widgets |
| **Classes ↔ Programs images swapped** in "Explore the Stage" | `lib/data/dummy_data.dart` |

#### Wishlist crash fix
| Change | Files |
|--------|-------|
| **"type 'Null' is not a subtype of Map<String,dynamic>" fixed** — `fetchWishlist` normalizes all response shapes (array / data / data.results / results) via `.whereType<Map<String,dynamic>>()`; `loadFromApi({silent})` + tolerant item parser; saved-events screen converted to Stateful with loading / error+Retry / RefreshIndicator | `lib/services/wishlist_service.dart`, `lib/providers/saved_events_state.dart`, `lib/screens/saved_events_screen.dart` |

#### Account / cards redesign
| Change | Files |
|--------|-------|
| **Account header** — big avatar on the LEFT with camera badge, name/email/Edit-Profile stacked right; completion bar full-width below | `lib/screens/profile_screen.dart` |
| **Followed Partners card** — golden-yellow top stripe, gradient removed, text darkened | `lib/screens/followed_partners_screen.dart` |
| **Right-side illustrations enlarged** (80→110) in Favorites / Payment Settings / Reviews / Help | respective screens |
| **20px gap below every CTA button** across all section/listing cards (17 files); **40px gap** before next section title on home | `lib/sections/*`, card widgets |

#### Section-specific redesigns
| Change | Files |
|--------|-------|
| **Weekend Specials** → vertical card (image on top w/ date badge + heart, title, stars, venue + Book Now); image stretched taller | `lib/sections/weekend_special_section.dart` |
| **Stealers** — "View Now" CTA + "60% OFF" tag re-added | `lib/sections/stealers_section.dart` |
| **Where Every Star Shines** — Sensory-Friendly pill, View Now CTA, image flush to card's left edge + wider | `lib/sections/special_needs_section.dart` |
| **TLB Signature** — "TLB Originals" pink→purple gradient pill, View Now CTA (shorter) | `lib/sections/tlb_signature_section.dart` |
| **Family Feels** image enlarged/stretched right; section-card text size +1; lighter card borders (0.5→0.15) | `lib/sections/*` |

#### Listing screens (Events / Classes / Programs / Venues)
| Change | Files |
|--------|-------|
| **Filter chips** — selected = dark-yellow border + transparent golden tint; **image tag → corner-attached badge** (solid `0xFFE8941A`, bottom-left) | `category_*_screen.dart`, `lib/widgets/category_event_card.dart` |
| **Circle rows** sized so exactly 3 fit (Events "Explore by Format", Classes "Pick Your Pace", Venues "What's the Plan?" w/ light border + gradient tint) | `explore_format_row.dart`, `classes_screen.dart`, `venues_screen.dart` |
| **Auto-carousel everywhere** — new reusable `AutoScrollList` (auto-advances ~1 viewport/3s, loops, pauses on drag); top banners switched to Spotlight-style sliding; section rails auto-scroll; 45px inter-section gaps; Venues banner width matched to search bar | `lib/widgets/auto_scroll_list.dart` (NEW), all listing screens |

#### Detail screens (Event / Class / Program / Venue)
| Change | Files |
|--------|-------|
| **Restyle** — background lightened to `#FAFAFC`; About/card borders softened to `0x14000000` (~8% black); slim `kRowDivider` hairlines between content rows; inter-section spacing 24→32 | `lib/widgets/detail_sections.dart`, 4 detail screens |
| **Gallery → auto-carousel** — `DetailGallery` swapped static `ListView` for `AutoScrollList` so it cycles through **all** uploaded images | `lib/widgets/detail_sections.dart` |
| **Organized-By & Reviews cards** — dark `0x8A000000` borders lightened to `0x14000000`; **margin before "Upcoming Events"** increased 8→32 | `lib/widgets/organizer_card.dart`, `lib/widgets/review_sheet.dart`, `lib/widgets/upcoming_events_section.dart` |

**`flutter analyze`:** clean (37 pre-existing baseline hints only). **`flutter test`:** 129/129 pass.

### Session 54 — Real APIs: notifications, coupons, home feed + detail/profile redesign
Wired several screens to live backend data and redesigned the four listing detail screens, the organizer profile, and the home-feed sections. Design unchanged where the user required it; only data sources and the specified visuals changed.

#### Notifications (in-app) — wired to API
| Change | Files |
|--------|-------|
| **Model + service** — `ApiNotification`/`ApiNotificationPage`; `NotificationService` covers list, unread-count, mark-one-read, mark-all-read (`/api/v1/notifications/in-app/...`) | `lib/models/api_notification_model.dart` (NEW), `lib/services/notification_service.dart` (NEW) |
| **`NotificationsState` API refresh** — `refreshFromApi()` + `decrement()`; home header bell badge now reflects the live unread count (loaded on home init) | `lib/providers/notifications_state.dart`, `lib/screens/home_screen.dart` |
| **`NotificationScreen` rebuilt** — real list with loading / error+Retry / empty states, pull-to-refresh, infinite scroll, "From Admin" broadcast badge, optimistic mark-read on tap (+ open `action_url`), "Mark all read" | `lib/screens/notification_screen.dart` |

#### Coupons — validate/preview in checkout
| Change | Files |
|--------|-------|
| **Model + service** — `CouponValidationResult`; `CouponService.validate()` → `POST /api/v1/coupons/validate/` (handles invalid-coupon + 403 profile-incomplete) | `lib/models/api_coupon_model.dart` (NEW), `lib/services/coupon_service.dart` (NEW) |
| **Review & Pay coupon UI** — code field + Apply (spinner), applied chip with Remove, green discount line, totals recompute on `_effectiveSubtotal`; validated code threaded into `initiateBooking` (backend re-validates atomically) | `lib/screens/review_pay_screen.dart` |

#### Listing detail screens — redesign (Event / Class / Program / Venue)
| Change | Files |
|--------|-------|
| **Shared section widgets** — `DetailSectionTitle` (bold), `ExpandableAboutCard` (white card + slim black border, 3-line clamp + See more/less), `DetailGallery` (wider/taller cards), `DetailDirectionsCard` (detailed map-art `_MapArtPainter`), `DetailTermsRow` | `lib/widgets/detail_sections.dart` (NEW) |
| **Per-screen** — greyish background, smaller banner (300→230), bold titles, swapped About/Gallery/Location/Terms to the shared widgets; removed each screen's duplicated `_buildGallery`/`_MapPlaceholderPainter` | `event_detail_screen.dart`, `class_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| **`OrganizerCard` redesigned** — white rounded card, slim black border, avatar + ORGANIZED BY + name + Follow (no stats) | `lib/widgets/organizer_card.dart` |
| **Reviews inline section redesigned** — single white card, bold "Reviews", "Overall Rating: X.X ★", reviewer tiles | `lib/widgets/review_sheet.dart` |

#### Organizer Profile — exact-design rebuild + Upcoming Events
| Change | Files |
|--------|-------|
| **Rebuilt to reference** — gold gradient header, white rounded sheet (`StackFit.expand` so it fills), avatar straddling the seam + green badge, name, "X Followers", left About, 3-column stats (Events Hosted / Rating ★ / Experience). `ApiProvider` gained `totalFollowers` | `lib/screens/organizer_profile_screen.dart`, `lib/models/api_provider_model.dart` |
| **`UpcomingEventsSection`** — reusable rail sourced from the public Events API (`GET /api/v1/listings/events/`); wide image-dominant cards; added at the bottom of the organizer profile **and** all four detail screens | `lib/widgets/upcoming_events_section.dart` (NEW) + 4 detail screens |

#### Venue detail — enquiry vs direct booking
| Change | Files |
|--------|-------|
| **`bookingType` on venue** — `ApiVenueDetail.bookingType`/`isEnquiry`; bottom CTA reads **"Send Enquiry"** (opens enquiry sheet) for `enquiry` venues, **"Check Availability"** (PlanParty flow) for `direct_booking` | `lib/models/api_venue_model.dart`, `lib/screens/venue_detail_screen.dart` |
| **Venue enquiry** — `EventsListingService.submitVenueEnquiry()` → `POST /api/v1/listings/venues/{id}/enquiries/`; `showInquireNow(isVenue: true)` | `lib/services/events_listing_service.dart`, `lib/widgets/inquire_now_sheet.dart` |

#### Home feed — real data in the section cards
| Change | Files |
|--------|-------|
| **Section membership + full card fields** — `GET /api/v1/homepage/sections/` → `HomepageSection`/`HomepageListing` + `HomeFeedService`. The endpoint returns the full card fields (`cover_url`, `category`, `city`, `area`, `price`, `price_type`, `rating`, `total_reviews`), so `HomepageListing.toEventModel()` builds the card directly — no cross-API hydration needed | `lib/models/homepage_section_model.dart` (NEW), `lib/services/home_feed_service.dart` (NEW) |
| **`HomeFeedState`** — fetches sections, maps each listing → `EventModel`; `section(key)` + `version` notifier for reactivity | `lib/providers/home_feed_state.dart` (NEW) |
| **9 card sections wired** — each reads `HomeFeedState.section('<key>')` (reactive via `ValueListenableBuilder`), **hides when empty**, uses network-aware `listingImage()` covers and type-aware `openListingDetail()` taps. Card designs unchanged. Loaded on home init + pull-to-refresh | all `lib/sections/*_section.dart`, `lib/screens/home_screen.dart` |
| **Spotlight banner wired** — top hero `BannerCarousel` + its "Spotlight" divider now render the `spotlight` section (hidden when empty); `BannerCarousel` background made network-aware (`Image.network` for `http` covers, asset otherwise, same fallback) | `lib/screens/home_screen.dart`, `lib/widgets/banner_carousel.dart` |
| **Helpers** — `listingImage()` (network/asset + grey fallback), `openListingDetail()` (route by type); `EventModel` gained `listingType` | `lib/core/listing_image.dart` (NEW), `lib/core/listing_navigation.dart` (NEW), `lib/models/event_model.dart` |

#### Other
| Change | Files |
|--------|-------|
| **Payment Settings** error state + Retry; stripped `Exception:` prefix | `lib/screens/payment_settings_screen.dart` |
| **Tests** — updated stale copy (notification screen, venues section titles, venue detail CTA label); **129/129 pass** | `test/screens/notification_screen_test.dart`, `venues_screen_test.dart`, `venue_detail_screen_test.dart` |

### Session 53 — Tester bug-fix sweep + banner/Find-Your-Fit redesign
A QA-driven pass: fixed a critical auth-security bug, several UI/UX tester tickets, and finished the Programs "Find Your Fit" section with cleaned circular assets. Also redesigned the Events/Classes/Programs top banners.

#### Top banners — static animated image transition (Events / Classes / Programs)
| Change | Files |
|--------|-------|
| **Multi-image carousels added** — each banner list expanded from 1 → 4 entries using images from `resources- tlb-ui/` (with tag + description for the overlay) | `lib/data/dummy_data.dart` |
| **`staticFade` transition upgraded** — banner stays fixed (no swipe/slide); images cross-fade with a richer combined **fade + zoom (1.18→1.0) + slide-in (0.18→0)** via `AnimatedSwitcher` (900 ms, `easeOutCubic`). Events/Classes/Programs pass `staticFade: true` | `lib/widgets/banner_carousel.dart`, `events_screen.dart`, `classes_screen.dart`, `programs_screen.dart` |

#### Auth security — unregistered email could log in via OTP (Critical)
| Change | Files |
|--------|-------|
| **`requestOtp` gains `purpose` param** — login flow sends `purpose: 'login'`; backend now returns `400 USER_NOT_FOUND` for unregistered emails (no OTP sent) → surfaced as "Account not found. Please sign up first."; signup sends `purpose: 'register'` | `lib/services/auth_service.dart`, `login_sheet.dart`, `signup_screen.dart`, `otp_verification_screen.dart` |
| **Client defense-in-depth** — `_detectNewUser()` reads the new-user flag across several keys (no longer brittle `?? false`); `isAccountRegistered()` cross-checks the real profile completeness after verify; login flow rejects + signup flow forces onboarding so no one reaches Home without completing signup | `lib/services/auth_service.dart`, `lib/screens/otp_verification_screen.dart` |
| **Login screen "Skip" button removed** — non-functional | `lib/widgets/login_sheet.dart` |
| **OTP keyboard auto-close hardened** — completeness checked on every box (handles paste/autofill/edit), dismiss via `FocusManager.instance.primaryFocus?.unfocus()` in a post-frame callback so the Verify button stays visible | `lib/screens/otp_verification_screen.dart` |

#### Other tester tickets
| Change | Files |
|--------|-------|
| **Pull-to-refresh added (High)** — all 5 tab screens wrap their `SingleChildScrollView` in `RefreshIndicator` (physics → `AlwaysScrollableScrollPhysics`); `_handleRefresh` reloads wishlist state (+ live categories on Events) | `home_screen.dart`, `events_screen.dart`, `classes_screen.dart`, `programs_screen.dart`, `venues_screen.dart` |
| **Bottom-nav overlap on small screens (High)** — `FloatingNavbar` gains `pillHeight`, `bottomInset(context)`, `clearance(context)` helpers; all screens reserve `clearance()` instead of the hard-coded `+64` that under-reserved the true ~72 px pill | `lib/widgets/floating_navbar.dart` + 5 tab screens |
| **Location permission / settings redirect (High)** — added missing iOS `NSLocation*UsageDescription` keys (iOS silently denied without them); `_fetchCurrentLocation` now shows an "Open Settings" dialog for GPS-off (`openLocationSettings`) and permanently-denied (`openAppSettings`) | `ios/Runner/Info.plist`, `lib/screens/location_screen.dart` |
| **Failed payments shown as Upcoming/Processing (Critical)** — `payment_failed` moved from the Upcoming status set to the Cancelled set | `lib/screens/bookings_screen.dart` |
| **Search: network error on no-match (Medium)** — `_doSearch` runs the 4 source fetches independently/fault-tolerantly; error state only when ALL fail, else empty merged set → "No Results" | `lib/screens/search_screen.dart` |
| **Search: wrong/empty results per tab (High)** — relevance filter changed from "title/subtitle contains whole query" to token-based AND across title + subtitle + tag (e.g. "art class" now matches "Art & Craft Class") | `lib/screens/search_screen.dart` |
| **Help Centre search bar removed (Low)** — non-functional bar + its controller/handler deleted | `lib/screens/help_centre_screen.dart` |
| **Location section titles restyled (Low)** — "Popular Cities" / "All Cities" → bold 18 sp with a gold accent bar + divider | `lib/screens/location_screen.dart` |
| **Help Centre chat history (verified, no change)** — confirmed server-backed: `TicketDetailScreen` reloads full history from `GET …/messages/` on every open; reported bug not reproducible | (investigation only) |

#### Venues — "What's the Plan?" circles
| Change | Files |
|--------|-------|
| **Circular border added** — each circle gets a 2 px border using a darkened shade of its own gradient end-colour (`Color.lerp(colors.last, Colors.black, 0.4)`) | `lib/screens/venues_screen.dart` |

#### Programs — "Find Your Fit" finished
| Change | Files |
|--------|-------|
| **7 new circular assets cleaned** — source PNGs in `resources- tlb-ui/programs_findurfit/` were inconsistent (grey vignette backgrounds, metallic rims, a notch, varying circle ratios, all fully opaque). A Python/PIL+scipy script (`tool`-style, kept at `/tmp/clean_circles.py`) detects each circle per-mode (white-bg / dark-bg / white-circle / grey-bg), strips rims+corners, and outputs uniform transparent-corner circles → `programs_findurfit_clean/` | `resources- tlb-ui/programs_findurfit_clean/` (NEW), `pubspec.yaml`, `lib/data/dummy_data.dart` |
| **`PickYourPaceRow` redesigned** — circles enlarged to ~104 px; image fills the circle (`BoxFit.cover`); title overlaid **inside** the circle at the bottom (black text + soft white halo, no dark scrim); slim black circular border (`0.7 px`) | `lib/widgets/pick_your_pace_row.dart` |

#### Card borders (carried in this batch)
| Change | Files |
|--------|-------|
| **Slim black border on all cards** — Home/Events/Programs/Venues/Classes card widgets + home sections recoloured/added `Border.all(Colors.black.withOpacity(0.5), width: 0.7)` | `event_card*.dart`, `class_nearby_card.dart`, `new_on_tlb_card.dart`, `online_event_card.dart`, `holiday_special_card.dart`, `partner_portrait_card.dart`, `build_skill_card.dart`, `special_focus_card.dart`, `weekend_event_card.dart`, `trending_event_card.dart`, + 9 home `sections/*.dart` |

### Session 51 — Events-screen redesign + global header/footer/navbar polish
Continuation of the Session-50 design pass: unified section-title styling, footer recolour, and a full Events-screen redesign (banner, category grid, Trending card, format circles).

#### Section titles unified app-wide
| Change | Files |
|--------|-------|
| **`SectionDividerWidget` defaults changed** — `fontSize 14.5 → 17`, `textColor textSecondary → textPrimary` (dark navy). Every section title that uses defaults (Events / Classes / Programs screens) now matches the home-screen titles automatically; home sections pass explicit values so they're unchanged | `lib/widgets/section_divider_widget.dart` |
| **"Explore the Stage" + "Family Feels" titles aligned** — Explore-the-Stage (custom header in `categories_grid.dart`) set to `17 / w600 / #1A1A2E`; Family Feels divider given explicit `fontSize:17 / dark navy` | `lib/widgets/categories_grid.dart`, `lib/sections/family_feels_section.dart` |

#### Header / search bar / navbar
| Change | Files |
|--------|-------|
| **Search bar** — golden gradient now covers the whole bar (top→bottom wash `#FFF6DE → #FFEFC8`, was a left→right gold→white fade that left the right half white); added a 4 px white border frame | `lib/sections/home_header.dart` |
| **Floating navbar** — active tab label weight `w500 → w600` (little bold); the dark gradient scrim above the pill lightened from opaque black to `Color(0xFF000000).withOpacity(0.6)` so footer/content behind stays visible | `lib/widgets/floating_navbar.dart` |
| **Spotlight banner height** reduced `470 → 415` | `lib/screens/home_screen.dart` |

#### Footer recolour + stretch-to-bottom (all 5 tab screens)
| Change | Files |
|--------|-------|
| **`AppFooter` recoloured + extended** — single modulate `ShaderMask` recolours the white→`#FFCF19` PNG to white→light-orange (`gradient end #FFE2B0` → gold multiplies to ~`#FFB711`, matching the header palette); the logo stays black, the white top blends into the page. New `bottomExtra` param fills the floating-navbar clearance with the PNG's exact bottom colour (`#FFCF19`) so it recolours to the identical tone (seamless, no band) and the colour reaches the screen edge | `lib/sections/app_footer.dart` |
| Each screen folds its old white clearance `SizedBox` into `AppFooter(bottomExtra: …)` | `home_screen.dart`, `events_screen.dart`, `classes_screen.dart`, `programs_screen.dart`, `venues_screen.dart` |

#### Events screen
| Change | Files |
|--------|-------|
| **Top banner full-bleed** — `BannerCarousel` gains `cornerRadius` + `overlayDots` params. Events banner: `fixedCardWidth = screen width` (edges touch screen), `cornerRadius: 22` (rounded corners), `overlayDots: true` (white page-dots overlaid at the bottom of the banner instead of the external row) | `lib/widgets/banner_carousel.dart`, `lib/screens/events_screen.dart` |
| **Explore by Categories** — `ExploreCategoriesGrid` gains a bottom-fade (`ShaderMask` `dstIn`, opaque→transparent at ~72%) so the cut-off row dissolves softly; new `maxScrollRows` param caps the scroll at 3 rows (events passes `maxScrollRows: 3`); full list still reachable via "View All" | `lib/widgets/explore_categories_grid.dart`, `lib/screens/events_screen.dart` |
| **Trending Events redesigned** — new `TrendingEventCard` (image-dominant; white Sat/21-Mar date badge top-left + heart top-right; title; `Workshop` lavender chip + person-icon age; star + reviews; location + Book Now). New data list `DummyData.trendingEvents` (`eventDate`=date badge, `tag`=chip, `description`=age, `venue`=city). `EventCardWithRating` left untouched (still used by Classes/Programs) | `lib/widgets/trending_event_card.dart` (NEW), `lib/data/dummy_data.dart`, `lib/screens/events_screen.dart` |
| **Explore by Format circles enlarged** — `ExploreFormatRow` rewritten with `LayoutBuilder`: circle size computed so ~3 fill the width with even 12 px gaps (~112 px, bigger than the old fixed 99 px); 4th peeks to hint scroll; per-format `scale`/`invertColors` preserved; dropped unused `Responsive` import | `lib/widgets/explore_format_row.dart` |

### Session 50 — Home-feed visual redesign + global slim typography
A design-driven pass replicating provided mocks for every home-screen card section, plus an app-wide font-weight change.

#### Shared card pattern
| Change | Files |
|--------|-------|
| **Image-dominant cards** — across all card sections the image is now wrapped in `Expanded` (fills the majority of the card) and flush to the card edges (removed inset padding; top corners rounded via `BorderRadius.vertical(top:16)`). Content moved out of `Expanded`/`spaceBetween` into a natural-height `Padding` + `Column(mainAxisSize.min)` so it packs tightly under the image with no stray gap. Root cause of the earlier "image too small / big empty gap" was fixed-height image + `Expanded` content + `spaceBetween` | `hot_picks_section.dart`, `weekend_special_section.dart`, `discover_near_you_section.dart`, `stealers_section.dart`, `tlb_signature_section.dart` |
| `SectionDividerWidget` extended — new optional params `fontSize`, `fontWeight`, `textColor`, `lineThickness` (all with defaults); **default `fontWeight` changed `w500 → w600`** so every section title is light-bold. Line color/length still per-instance | `lib/widgets/section_divider_widget.dart` |
| All section headers set to `fontSize: 17, textColor: 0xFF1A1A2E` (dark navy) | all section files + `home_screen.dart` (Spotlight) |

#### Per-section
| Change | Files |
|--------|-------|
| **Spotlight** (inline) — header moved closer to banner; longer thin golden lines (`lineLength:100, lineThickness:1.5, lineColor:0xFFD4A537`); banner taller + tuned width (`height 470`, `fixedCardWidth 345`) | `lib/screens/home_screen.dart` |
| **Search bar golden gradient** — white fill replaced with L→R gradient `#FFE9B8 → #FFF4D8 → #FFFDF7` | `lib/sections/home_header.dart` |
| **Hot Picks** redesigned — image-dominant, flush; "Filling Fast"/"Bestseller" diagonal badge | `lib/sections/hot_picks_section.dart` |
| **Weekend Specials** (renamed from "Weekend Special") — image-dominant PageView; white Fri/mar-15 date badge, heart; Book Now (was "View Details") | `lib/sections/weekend_special_section.dart` |
| **Discover Near You** — image-dominant; pink "X km away" band at image bottom; `Description –` en-dash | `lib/sections/discover_near_you_section.dart` |
| **New on the Block** — NEW section below Family Feels; dark-navy time-ago band; View Details. New data list `DummyData.newOnTheBlock` | `lib/sections/new_on_the_block_section.dart` (NEW), `dummy_data.dart`, `home_screen.dart` |
| **Parents' Favorite** — NEW section below New on the Block; pink→purple "Loved by Parents" badge; age chip, star+rating+(reviews), `Price – ₹X` + Visit. New data list `DummyData.parentsFavorite` | `lib/sections/parents_favorite_section.dart` (NEW), `dummy_data.dart`, `home_screen.dart` |
| **Stealers** — image-dominant (removed `Spacer` gap); countdown pill top-center, "60% OFF" band bottom; moved above the renamed Special Needs section | `lib/sections/stealers_section.dart`, `home_screen.dart` |
| **"Where Every Star Shines"** — Special Needs renamed + fully redesigned to a horizontal split card (left image + red star badge, right column with "Sensory Friendly" pink pill, title, rating, `area • km`, Explore); moved below Stealers. Class/file still named `SpecialNeedsSection`/`special_needs_section.dart`. Data updated (`venue`=location, `tag`=pill) | `lib/sections/special_needs_section.dart`, `dummy_data.dart`, `home_screen.dart` |
| **TLB Signature** — image-dominant poster; "TLB Originals" purple pill centered at top (replaced heart); title, description, full-width Register Now | `lib/sections/tlb_signature_section.dart` |

#### Global typography
| Change | Files |
|--------|-------|
| **Slim font sweep** — project-wide replace `FontWeight.{w600,w700,w800,w900,bold} → w500` (531 occurrences, 90 files) so nothing renders bold by default. Excluded `ticket_pdf_service.dart` (`pw.FontWeight` from the `pdf` package only supports `normal`/`bold`) | `lib/**/*.dart` |
| **Two deliberate exceptions** — home header greeting "Hello …" set to **`w700`** (the one bold element); all section titles set to **`w600`** (light-bold) via `SectionDividerWidget` default + the 4 explicit call sites | `home_header.dart`, `section_divider_widget.dart`, section files, `home_screen.dart` |
| No tests assert on font weights; analyzer clean (only pre-existing `info`-level `use_null_aware_elements` hints remain) | — |

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

### Session 40
| Change | Files |
|--------|-------|
| **Flutter analyze run — all source warnings cleared** — ran `flutter analyze`; resolved 44 issues down to 0 warnings in production code (only test-file warnings and `info`-level style hints remain) | project-wide |
| **Removed stale unused imports (partner_follow_button + organizer_profile_screen)** — both imports were left over from a refactor that replaced them with `organizer_card.dart`; removed from all 4 detail screens | `lib/screens/class_detail_screen.dart`, `event_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart` |
| **Removed unused `app_snackbar` import from bookings_screen** | `lib/screens/bookings_screen.dart` |
| **Removed dead `_buildRelatedEventCard` method** — method body was 58 lines; all call sites were commented out; safe to delete | `lib/screens/event_detail_screen.dart` |
| **Removed unused `_error` field from `FormatEventsScreen`** — field was set in catch block but never read (error already shown via `AppSnackBar.error()`); removed field declaration and both assignments | `lib/screens/format_events_screen.dart` |
| **Responsiveness audit — 3 raw `fontSize` values fixed** — `fontSize: 9` → `Responsive.sp(context, 9)` (bookings filter tab label); `fontSize: 22` → `Responsive.sp(context, 22)` (partner avatar initial); `fontSize: 14` → `Responsive.sp(context, 14)` (review pay error dialog body); all other text already used `Responsive.sp()` | `lib/screens/bookings_screen.dart`, `followed_partners_screen.dart`, `review_pay_screen.dart` |

### Session 41
| Change | Files |
|--------|-------|
| **`_buildPlaceholder` context param added** — `_BookingCard._buildPlaceholder(String type)` → `_buildPlaceholder(BuildContext context, String type)`; both call sites updated (image `errorBuilder` and fallback branch); fixes missing `context` needed for `Responsive.sp()` calls inside the method | `lib/screens/bookings_screen.dart` |
| **`_Avatar._initial` context param added** — `_Avatar._initial(String name)` → `_initial(BuildContext context, String name)`; both call sites updated (`errorBuilder` and fallback branch); same pattern as above | `lib/screens/followed_partners_screen.dart` |

### Session 48 — Bug-fix sweep (20 issues)

A focused bug-fix pass driven by a QA punch-list. Each row below resolves one filed issue; grouped by area.

#### Auth & onboarding
| Change | Files |
|--------|-------|
| **First-name required even on Skip** — EditProfile onboarding `_skip()` previously navigated to HomeScreen with no save. Now validates `first_name`, saves it via `AuthService.updateProfile` (so the walkthrough greeting works immediately), then navigates. Skip button is disabled while loading | `lib/screens/edit_profile_screen.dart` |
| **Cold-start routes to Login when no session** — `main()` already computed `restored = await AuthState.tryRestoreSession()` but the result was ignored — `SplashScreen.nextScreen` was hard-coded to `HomeScreen`. Now: `TLBRoot(isLoggedIn: restored)` → `TLBApp(isLoggedIn)` → `SplashScreen(nextScreen: isLoggedIn ? HomeScreen() : LoginScreen())` | `lib/main.dart`, `test/widget_test.dart` |
| **OTP login rejects new-user response** — added `isLoginFlow: bool` to `OtpVerificationScreen`. LoginScreen passes `true`; SignupScreen leaves it `false`. When the backend's verify-OTP returns `is_new_user: true` AND `isLoginFlow == true`, surface "No account found with this email. Please sign up first." BEFORE any `AuthState.login` / `markAsNewUser` mutation, then pop back. TODO comment notes the backend would ideally reject OTP-request itself for unregistered emails | `lib/screens/otp_verification_screen.dart`, `lib/widgets/login_sheet.dart` |
| **OTP backspace + auto-dismiss** — wrapped each OTP `TextField` in `Focus(onKeyEvent:)` so backspace on an already-empty box clears the previous box and moves focus (matches Session-6 forgot-password pattern). On the 6th digit, `FocusScope.of(context).unfocus()` closes the keyboard so the Verify button is visible. Applied to both `otp_verification_screen.dart` and the same row in `forgot_password_screen.dart` for consistency | `lib/screens/otp_verification_screen.dart`, `lib/screens/forgot_password_screen.dart` |
| **Post-logout & post-Welcome-Back crash** — root cause of "app crashes after Welcome Back → Continue": `pushAndRemoveUntil(HomeScreen, false)` was called twice in quick succession (once on logout, once on re-login), and the ShowcaseView singleton's `get().unregister()` was unregistering the WRONG instance. Three fixes: logout now navigates to **`LoginScreen`** instead of HomeScreen (eliminates the double-HomeScreen race); `HomeScreen.initState/dispose` wrap `ShowcaseView.register()/get().unregister()` in `try-catch` (defensive); `showWelcomeBackDialog` uses `rootNavigator: true` for both the dialog and the captured navigator | `lib/screens/profile_screen.dart`, `lib/screens/home_screen.dart`, `lib/widgets/login_sheet.dart` |
| **Google sign-up — "Continue as Event Partner" moved to Signup** — the dead `onPressed: () {}` on LoginScreen's partner link was wired to `url_launcher.launchUrl('https://tlbpartner.reluconsultancy.in/', LaunchMode.externalApplication)`, then physically relocated to SignupScreen (where new partners actually look). Local helper in `login_sheet.dart` removed; `url_launcher` import dropped there | `lib/widgets/login_sheet.dart`, `lib/screens/signup_screen.dart` |

#### Home / catalog
| Change | Files |
|--------|-------|
| **Empty-state on cold start removed** — `LocationState.selectedCity` default changed from `'Bhopal City'` (an intentional QA shortcut to trigger the empty state) to `'Mumbai'`, which IS in `supportedCities`. Cold-start now shows real home content | `lib/providers/location_state.dart` |
| **Bell red-dot conditional** — root cause: red dot was baked into `resources- tlb-ui/alert.png`. Replaced the PNG with `Icons.notifications_outlined` + a `Positioned` red dot inside a `Stack`, gated on `NotificationsState.unreadCount > 0` via `ValueListenableBuilder`. New `NotificationsState` provider (`unreadCount`, `setUnread`, `clear`) ready for the future notifications-API integration | `lib/sections/home_header.dart`, `lib/providers/notifications_state.dart` (NEW) |
| **Spotlight slider — user swipe** — `BannerCarousel` switched from `AnimatedSwitcher` + timer-driven fade to a `PageView.builder` with a `PageController`. User swipe works natively; auto-slide now calls `_pageController.animateToPage(next, 600ms, easeInOut)`. `NotificationListener<ScrollNotification>` pauses auto-advance during a user drag so the gesture and timer don't fight. `BouncingScrollPhysics` for the rubber-band edge feel. Visual layout preserved (each page centres the same card design) | `lib/widgets/banner_carousel.dart` |
| **Explore-by-Format Competition shrink + MasterClass invert** — Competition PNG fills the full square (no built-in margin) so it visually dominated the row. Added `'scale': 0.85` in dummy_data; restored `scale` reading in `ExploreFormatRow`. MasterClass `'scale': 1.42` removed (was making it bigger than the rest); `'invertColors': true` retained to flip the white-bg PNG to the black-bg/white-text look from the Figma | `lib/data/dummy_data.dart`, `lib/widgets/explore_format_row.dart` |
| **Whole-page scroll across 5 tab screens** — root cause of "page does not scroll properly": each tab screen had `Column(Container(header), Expanded(SingleChildScrollView(body)))`. The gradient header + greeting + search bar were pinned outside the scroll view. Restructured all 5 (`home/events/classes/programs/venues_screen.dart`) to `Stack(SingleChildScrollView(Column(header, body, AppFooter, SizedBox(navOverlap))), Positioned(FloatingNavbar))` — header now scrolls away with the rest of the page; the navbar stays pinned because it's a Stack sibling. New trailing `SizedBox` (~94 px) clears the floating navbar so the last section isn't hidden | `lib/screens/home_screen.dart`, `events_screen.dart`, `classes_screen.dart`, `programs_screen.dart`, `venues_screen.dart` |
| **All Bookings list — per-card cover lazy fetch** | (Session 46) — referenced here for completeness |

#### Profile
| Change | Files |
|--------|-------|
| **Real profile-picture upload (local-only)** — backend customer-profile API has no avatar field, so this is client-side persistence: `image_picker` opens camera/gallery → `AvatarStorage.saveFromPickedFile` copies into `getApplicationDocumentsDirectory()/tlb_local_avatar.jpg` and stores the absolute path in SharedPreferences under `tlb_local_avatar_path` → `AuthState.avatarUrl.value` updated reactively. New `avatarImageProvider` helper branches `NetworkImage` (http) vs `FileImage` (absolute path) across the 3 avatar render sites (`home_header`, `profile_screen`, `account_settings_screen`). `main.dart` calls `AvatarStorage.load()` on cold start; `AuthState.login()` and `updateUserProfile()` no longer overwrite `avatarUrl` with null when the API has no value, so the locally-picked photo survives login refreshes; `AuthState.logout()` calls `AvatarStorage.clear()`. Bottom-sheet replaced "Change Profile Picture → EditProfileScreen" dead-end with **Take a Photo**, **Choose from Gallery**, and **Remove Profile Picture** | `lib/services/avatar_storage.dart` (NEW), `lib/core/avatar_image.dart` (NEW), `lib/main.dart`, `lib/providers/auth_state.dart`, `lib/screens/profile_screen.dart`, `lib/sections/home_header.dart`, `lib/screens/account_settings_screen.dart`, `pubspec.yaml` |
| **Profile completion tracker fixed** — `_calculateCompletion()` was checking field names from the OLD pre-Session-12 API (`date_of_birth`, `city`, `state`, `guardian_name`, `institution_name`, `institution_type`) — only `first_name` + `last_name` ever matched → ceiling 2/8 = **25 %**. Now checks the actual 6 EditProfile fields (`first_name`, `last_name`, `phone_number`, `gender`, `birthdate`, `region`) plus `userEmail` baseline + local/remote `avatar_url` → 8 / 8 reachable. Screen now also rebuilds on `avatarUrl` change (nested `ValueListenableBuilder`) | `lib/screens/profile_screen.dart` |
| **Change Password row removed from Account Settings** — auth is OTP-only; users never set a password. Row deleted, `change_password_screen.dart` import dropped, "Phone Number" promoted to `isLast: true`. Regression-guard test asserts `findsNothing` for "Change Password". `change_password_screen.dart` file kept on disk for potential future password-based partner flow | `lib/screens/account_settings_screen.dart`, `test/screens/account_settings_screen_test.dart` |
| **Coming-soon snackbars across profile dead-taps** — new `AppSnackBar.comingSoon(context, [feature])` helper. Wired to: Account Settings → Phone Number / Manage Permissions; Payment Settings → Add New Method / Chat with support; Help Centre → Chat with support / help-topic rows; Help Centre Support-Hours row shows an info snackbar with the hours text. Replaces silent `onTap: () {}` no-ops | `lib/core/app_snackbar.dart`, `lib/screens/account_settings_screen.dart`, `lib/screens/payment_settings_screen.dart`, `lib/screens/help_centre_screen.dart` |
| **Delete Account wired to real API** — `AuthService.deleteAccount({accessToken})` does `DELETE /api/v1/customer/account/` with 30 s timeout. Maps `401 → "Your session has expired. Please log in again."`, `403 → "This account type cannot be deleted from the mobile app."`. Account Settings row opens a confirmation `AlertDialog` → blocking `AppLoader` spinner → API call → on success: `AuthState.logout()` + `pushAndRemoveUntil(LoginScreen)` + success snackbar | `lib/services/auth_service.dart`, `lib/screens/account_settings_screen.dart` |

#### Booking / payment
| Change | Files |
|--------|-------|
| **"Booking Unavailable" pre-flight gate** — root cause: dummy spotlight / hot-pick / weekend-special cards use `DummyData.bannerEvents` with `EventModel.id = ''`. Book Now navigated 3 screens deep (`DateTimeSelectionScreen → TicketBookingScreen → ReviewPayScreen`) before hitting the empty-id check. Now `event_detail_screen.dart` (Book Now), `class_detail_screen.dart` (Check Availability / Enquire Now), `program_detail_screen.dart` (same), and `venue_detail_screen.dart` (Plan Event) ALL gate on `_hasApiId` at the button — show "This is a featured highlight, not a bookable listing yet. Browse \<Tab\> to find one you can book." snackbar before any navigation. `review_pay_screen`'s safety-net message rewritten to friendlier copy | `lib/screens/event_detail_screen.dart`, `class_detail_screen.dart`, `program_detail_screen.dart`, `venue_detail_screen.dart`, `review_pay_screen.dart`, `test/screens/event_detail_screen_test.dart` |
| **Programs enquiry — inline validation** — `_InquireNowDialog` converted from manual `_submit()` check + bottom snackbar to a real `Form` + `TextFormField`/`DropdownButtonFormField` with `validator:`. Errors render directly below each invalid field. `autovalidateMode` starts `disabled`, flips to `onUserInteraction` after the first failed submit so errors clear live. Failed submit also animates a scroll to top via `ScrollController` so the first error (Student Details section) isn't hidden behind the keyboard. Message section header now correctly shows `*` for programs / `(Optional)` otherwise — matches the actual validator | `lib/widgets/inquire_now_sheet.dart` |
| **Share buttons wired (frontend only)** — `share_plus: ^7.2.2` added. New `ShareHelper.shareListing(ctx, type, title, id)` constructs `Check out "<title>" on The Little Broadway\n<url>\nDiscover kids\' classes, programs, events & venues on TLB.` and triggers `Share.share()` with the title as subject. URL pattern: `https://thelittlebroadway.com/<events\|classes\|programs\|venues\|partners>/<id>` — single source to change when marketing finalises URLs. Wired across all 5 dead share buttons: `event_detail_screen`, `class_detail_screen`, `program_detail_screen`, `venue_detail_screen`, `organizer_profile_screen` | `lib/core/share_helper.dart` (NEW), `pubspec.yaml`, 5 detail-screen files |

#### Build / release
| Change | Files |
|--------|-------|
| **Device-preview dev tools hidden in profile + release** — initial gate used `kReleaseMode` which is `false` in profile builds, so the floating toggle button still appeared via `flutter run --profile`. Switched to `kDebugMode` — DevicePreview wrapper and `PreviewToggleButton` only mount in **debug**; profile and release builds strip both out via Dart's compile-time dead-code elimination. `MaterialApp.locale` and `MaterialApp.builder` also guard their `DevicePreview.locale(context)` / `DevicePreview.appBuilder(context, child)` calls behind `kDebugMode` so they never run without the ancestor provider in profile/release | `lib/main.dart` |
| **Reminders profile entry hidden** | (Session 45) — referenced for completeness |

#### Under-development surfaces (block-commented for restore)
Three screens have UI but no backing API yet. Rather than leave them showing fake data (Visa **** 4578 dummy cards) or a misleading empty state ("No Notifications Yet" — implies 0 unread when actually nothing is wired), each was replaced with a single clear "Currently being developed" card. The original design markup is preserved in-file as a `/* ... */` block comment so it can be reinstated verbatim once the respective backend ships.

| Change | Files |
|--------|-------|
| **Payment Settings — dummy Visa/UPI cards removed** — replaced the hard-coded "Visa **** 4578" + "UPI: designer@upi" entries and the "Add New Method" CTA with a centered coming-soon card (yellow `Icons.credit_card_outlined` in `#FFF8E1` disc). Greeting banner and "Chat with support" row at the bottom retained. Body copy: *"We're building the saved-methods feature. For now, payments still complete through the Razorpay checkout during booking."* Original markup block-commented for future restore | `lib/screens/payment_settings_screen.dart` |
| **Help Centre — search/topics/chat replaced** — kept the "Hi {firstName}" banner + headphones illustration; replaced the search bar, Common Topics list, Chat-with-support tile, and Support-Hours card with a single coming-soon card (blue `Icons.support_agent_rounded` in `#EDF4FF` disc). Body copy points users to `support@thelittlebroadway.com`. The `_buildTopic` helper method is also preserved as a block comment so the topics list can be re-enabled as a single uncomment. `import '../core/app_snackbar.dart'` dropped (no longer referenced) | `lib/screens/help_centre_screen.dart` |
| **Notifications — empty-state replaced** — `_NotificationScreenState.build` no longer renders the "No Notifications Yet / You're all caught up!" empty state (it implied a successful fetch that returned []). Now shows a centered coming-soon card (blue `Icons.notifications_active_outlined` in `#EDF4FF` disc). Body copy: *"We're building in-app notifications. You'll see booking updates, reminders and announcements here soon."* Original empty-state block-commented with a note that once the API ships, the empty state should only render after a successful `[]` fetch — loading + error need separate handling at that point | `lib/screens/notification_screen.dart` |
| **Test suite updated** — `notification_screen_test.dart` now asserts the coming-soon copy + new icon (replaces the old "No Notifications Yet" assertions). `help_centre_screen_test.dart` already passed with no edits (regression guards were resilient to copy changes). All **129/129** tests still green | `test/screens/notification_screen_test.dart` |

### Session 47
| Change | Files |
|--------|-------|
| **Explore-by-Format circle row — uniform sizing** — root cause of "circles aren't the same size": source PNGs have inconsistent internal margins (Competition fills the entire square edge-to-edge, MasterClass and Camp have built-in transparent padding around the artwork). Fix: every circle now renders at the Figma spec `99 px` (via `Responsive.w(context, 99, min: 72)`) with a fixed `ClipOval`; per-format `scale` overrides compensate for asset differences | `lib/widgets/explore_format_row.dart` |
| **Competition shrunk to fit the row** — added `'scale': 0.85` in dummy_data; renders the Competition PNG inside the same 99 px disc but at 85 % so its yellow splash artwork doesn't visually dominate the row | `lib/data/dummy_data.dart` |
| **MasterClass scale 1.42 removed; invertColors retained** — the old `scale: 1.42` was making MasterClass *bigger* than the other circles (it was originally meant to compensate for transparent padding, but the result was visually inconsistent). Removed. `invertColors: true` is kept so the source white-bg PNG flips to the black-bg / white-text look from the Figma | `lib/data/dummy_data.dart` |
| **`ExploreFormatRow` rewrite** — moved hard-coded 84 px to `Responsive.w(context, 99)`; restored `invertColors` reader (`ColorFiltered` with a luminance-inversion matrix); kept the `scale` reader; dropped the gray-bg + 1 px border container that an earlier iteration introduced — circles render with their native colored discs only | `lib/widgets/explore_format_row.dart` |
| **`format_events_screen.dart` already reads `scale` + `invertColors`** — no change needed; the destination screen's circle row automatically picks up the new MasterClass-no-scale and Competition-shrink behavior because it reads the same dummy_data entries | (no change) |

### Session 46
| Change | Files |
|--------|-------|
| **Bookings list cover images — per-card lazy fetch + cache** — root cause of "images of entities are not rendered" on the All Bookings screen: `GET /api/v1/bookings/` doesn't include `cover_url` per item, so `ApiBookingItem.listingCover` was always null → every card fell through to the grey calendar placeholder. Fix: `_BookingCard` converted from StatelessWidget to StatefulWidget; in `initState` it dispatches a per-`bookingType` detail fetch (`fetchEventDetail` / `fetchClassDetail` / `fetchProgramDetail` / `fetchVenueDetail`) using `booking.listingId` — same routing the detail screen has been using since Session 36 | `lib/screens/bookings_screen.dart` |
| **Static cover URL cache** — `_BookingCard._coverCache` is a `static final Map<String, String?>` keyed by `"$bookingType:$listingId"`; survives card rebuilds (tab switches, scroll in/out of view) and shares results across cards that point at the same listing; negative results (null) are cached too so missing listings aren't refetched | `lib/screens/bookings_screen.dart` |
| **`google_auth_error.dart` created** — shared `googleAuthErrorMessage(Object e)` helper that maps `SocketException`, `TimeoutException`, `HandshakeException`, `FirebaseAuthException` (8 known codes incl. `network-request-failed`, `user-disabled`, `invalid-credential`, `account-exists-with-different-credential`, `operation-not-allowed`, `too-many-requests`), `PlatformException` (incl. `sign_in_cancelled`, `sign_in_failed` with the platform-side message exposed), and falls back to `Sign-in failed (<RuntimeType>)` so unknown failure modes remain identifiable instead of being swallowed by a generic message | `lib/core/google_auth_error.dart` (NEW) |
| **`AuthService.googleSignIn` surfaces 3 backend error codes** — reads `body['error']['code']` and maps `INVALID_GOOGLE_TOKEN`, `UNVERIFIED_EMAIL`, `USER_ROLE_MISMATCH` to friendly text; falls back to `_extractError(body)` for anything else; result map now also includes the raw `code` for future telemetry | `lib/services/auth_service.dart` |
| **`signup_screen` + `login_sheet` use shared helper** — both `_onGoogleSignUp` / `_onGoogleSignIn` catch blocks call `googleAuthErrorMessage(e)`; `debugPrint` now logs `${e.runtimeType}` so dev console shows the underlying exception class; local `_googleErrorMessage` in `login_sheet.dart` removed (single source of truth); unused `dart:io` imports cleaned up | `lib/screens/signup_screen.dart`, `lib/widgets/login_sheet.dart` |
| **`class_detail_screen_test` repaired** — Session 43 dropped the `/mo` suffix from the bottom-bar price label, and the dummy-mode path (`id: ''`) renders "Enquire Now" with no price since `_detail` is null and `bookingType` is unknown. Test now asserts `'Enquire Now'` is present and no `₹500` / `₹500/mo` is rendered. Brings the suite back to 129/129 green | `test/screens/class_detail_screen_test.dart` |
| **`testing_report.md` generated** — full automated-testing audit: 129 tests across 37 files (100 % pass after the repair), coverage by layer (screens 46 %, widgets 26 %, services 18 %, providers 17 %, models 9 %), list of 26 untested screens prioritized by impact, root-cause writeup of the repaired test, known coverage gaps (service-layer http injection, PDF golden tests, navigation-timing tests), and 5 prioritized recommendations | `testing_report.md` (NEW, root of repo) |

### Session 45
| Change | Files |
|--------|-------|
| **`printing: ^5.13.0` + `pdf: ^3.11.0` added** — native PDF generation + OS share sheet via `Printing.sharePdf`; 9 transitive deps; no Android manifest or iOS Info.plist changes required | `pubspec.yaml` |
| **`BookingService.fetchTicketData()` added** — GET `/api/v1/bookings/{id}/ticket/data/` with Bearer auth; returns raw JSON for native rendering; 30s timeout + typed Socket/Timeout errors; unwraps `data` envelope; only succeeds for `status=CONFIRMED` per API spec | `lib/services/booking_service.dart` |
| **`TicketPdfService` created** — `downloadAndShare(ctx, bookingId)` one-shot helper: blocking spinner → `fetchTicketData` → builds A4 PDF (yellow header band, cover image fetched separately, title, booking ref + date/time/venue rows, line-item table, total, decoded base64 QR) → `Printing.sharePdf(filename: tlb_ticket_<ref>.pdf)`; graceful degradation on QR/cover-image failures; uses `rootNavigator: true` for spinner pop | `lib/services/ticket_pdf_service.dart` (NEW) |
| **`BookingConfirmedScreen` (events ticket) Download wired** — added `bookingId: String?` constructor param (threads API UUID separately from the existing `bookingReference` text); `_TicketScreen` gains `apiBookingId` field that flows into `_ActionButtons.bookingId`; both Share and Download buttons call `TicketPdfService.downloadAndShare`; `_ActionBtn.onTap` made nullable so buttons grey out when `bookingId` is null | `lib/screens/booking_confirmed_screen.dart` |
| **`ProgramBookingConfirmedScreen` Download button added** — new `bookingId: String?` constructor param; inserted a `_DownloadTicketButton` outlined button above the existing "View My Bookings" / "Explore More" CTAs when `bookingId` is non-null; tap calls `TicketPdfService.downloadAndShare` | `lib/screens/program_booking_confirmed_screen.dart` |
| **`VenueBookingConfirmedScreen` Download button added** — same pattern as Programs screen; new `bookingId: String?` constructor param; inline outlined "Download Ticket" button injected above existing CTAs when `bookingId` is non-null | `lib/screens/venue_booking_confirmed_screen.dart` |
| **`BookingDetailScreen` Download/Share wired** — existing no-op `onTap: () {}` replaced with `TicketPdfService.downloadAndShare(ctx, booking.id)`; gated on `booking.status` being `confirmed` or `attended` (matches API contract — ticket data is only available for those statuses); buttons grey out for `cancelled`/`hold`/`awaiting_payment`/`payment_failed`/`refunded`; `_ActionBtn.onTap` made nullable with grey-disabled styling | `lib/screens/booking_detail_screen.dart` |
| **`ReviewPayScreen` threads `confirmed.id` through** — after `verifyPayment` returns `BookingConfirmResponse(id, bookingReference, ...)`, the `id` (UUID) is now passed as `bookingId:` to all three confirmation screens; without this the new download buttons would never have anything to download against | `lib/screens/review_pay_screen.dart` |
| **Reminders profile entry hidden** — `_item(...)` for Reminders in `profile_screen.dart` commented out (not removed) with a "restore when the feature is ready" note; import of `reminders_screen.dart` also commented out; the screen file itself is untouched and remains in the codebase | `lib/screens/profile_screen.dart` |

#### Test coverage added (Sessions 42–45 backfill)
| Tests added | Coverage |
|-------------|----------|
| `test/core/preview_mode_test.dart` (NEW, 7 tests) | `PreviewMode.load()` default + stored true/false from SharedPreferences; `toggle()` flips value, persists to prefs, notifies listeners (Session 42) |
| `test/providers/auth_state_test.dart` (5 appended) | `login()` resolves `userName` to `first_name + last_name` when profile present; falls back to **null** (not email) when profile absent or has empty fields; explicit `name` param wins over profile; `userEmail` still populated independently (Session 44 regression) |
| `test/models/api_class_model_test.dart` (NEW, 6 tests) | `ApiClassDetail.price` parses `int` → double, parses `double`, returns null when `service.price` absent or explicitly null; `bookingType` defaults to `'enquiry'` when missing (Session 43) |
| `test/screens/attendee_details_screen_test.dart` (NEW, 4 tests) | Widget test — fee display shows `batch.fee` when present, falls back to `event.price` when `batch.fee` is null/`'0'`, shows `'Free'` only when both are missing (Session 43 regression) |
| **All 22 new tests pass; no existing tests broken** | |

#### Booking Flow (Post-Session 45)
```
[Events]   BookingConfirmedScreen          ← bookingId now threaded from confirmed.id
[Classes]  ProgramBookingConfirmedScreen   ← bookingId now threaded
[Programs] ProgramBookingConfirmedScreen   ← bookingId now threaded
[Venues]   VenueBookingConfirmedScreen     ← bookingId now threaded

Download tap on any of the above → TicketPdfService.downloadAndShare(ctx, bookingId)
  → GET /api/v1/bookings/{id}/ticket/data/  (with Bearer auth)
  → Build A4 PDF natively (pdf package)
  → Printing.sharePdf(filename: tlb_ticket_<ref>.pdf)
  → System share sheet: Save to Files / WhatsApp / Email / Print / etc.

BookingDetailScreen Share & Download buttons follow the same flow,
gated on booking.status ∈ {confirmed, attended}.
```

### Session 44
| Change | Files |
|--------|-------|
| **`AuthState.login()` no longer falls back to email for `userName`** — root cause of "Hello user@example.com" appearing in the home header after login: when the verify-OTP / Google sign-in response had no `profile` block (the API's actual default), the chained `??` cascade landed on `user?['email']`; replaced with `userName.value = resolvedName` (the trimmed `first_name last_name` if present, else `null`); the home header's existing `name != null` branch then shows `"Hello There"` instead of an email until the real name loads | `lib/providers/auth_state.dart` |
| **`AuthState._refreshProfileFromApi()` added** — fire-and-forget; called at the end of `login()` whenever `resolvedName` is null and an access token exists; GETs `/api/v1/customer/profile/`, then calls `updateProfileData()` (same code path that fixes the header after the user opens Edit Profile manually); greeting now self-heals within one network round-trip instead of requiring a profile-screen visit | `lib/providers/auth_state.dart` |
| **`avatarUrl` lookup simplified** — was reading `user?['profile']` again as a separate cast; now reuses the `profile` local already extracted at the top of `login()` | `lib/providers/auth_state.dart` |
| **`showWelcomeBackDialog` grey-flash fix** — root cause of the post-login grey screen: `Navigator.of(context).pushAndRemoveUntil(HomeScreen, (r) => false)` was being called from inside the dialog's `onPressed` while the dialog route was still on top; the predicate tore down the dialog + OTP + LoginScreen mid-transition, leaving a one-frame window with no painted route. Fix: capture `navigator = Navigator.of(context)` BEFORE `showDialog`; in `onDone`, `Navigator.of(dialogContext).pop()` first (dismisses dialog cleanly), then `navigator.pushAndRemoveUntil(...)` using the captured navigator — eliminates the gap | `lib/widgets/login_sheet.dart` |

### Session 43
| Change | Files |
|--------|-------|
| **`ApiClassDetail.price` field added** — root cause of "Review & Pay" showing ₹0 for class bookings: `service.price` was never parsed off the API response; added `final double? price` to `ApiClassDetail`, populated via `(service['price'] as num?)?.toDouble()` in `fromJson` | `lib/models/api_class_model.dart` |
| **ClassDetailScreen price wired to API** — `_eventForSheets.price` and the sticky bottom bar's price both changed from `widget.event.price` (which is null when arriving from a list page that carries no price) to `_detail?.price ?? widget.event.price`; this propagates the real price through the entire booking chain (`SelectBatchScreen → AttendeeDetailsScreen → ReviewPayScreen`) so subtotal/total compute correctly | `lib/screens/class_detail_screen.dart` |
| **`/mo` suffix dropped from class price** — bottom bar previously showed `₹X/mo` but the API has no period field, just a flat `price` value; replaced the two-`TextSpan` `RichText` with a plain `Text('₹X')` to avoid misleading users | `lib/screens/class_detail_screen.dart` |
| **`AttendeeDetailsScreen._fee` fallback added** — was `double.tryParse(widget.batch.fee ?? '0') ?? 0.0`, but the classes API response has no `fee` field on batches (only `service.price` at the listing level); now: returns `batch.fee` when present + positive, else falls back to `widget.event.price ?? 0.0`; this is the actual screen that feeds `subtotal` to `ReviewPayScreen` for class bookings | `lib/screens/attendee_details_screen.dart` |
| **Pricing/CTA gate confirmed correct** — `booking_type == 'direct_booking'` → show price + "Check Availability" button → `SelectBatchScreen`; `booking_type == 'enquiry'` → hide price + "Enquire Now" button → `showInquireNow()`; gating logic was already right, only the price data flow was broken | `lib/screens/class_detail_screen.dart` |

### Session 42
| Change | Files |
|--------|-------|
| **`device_preview: ^1.2.0` added** — resolves to 1.3.1; pulls transitive `device_frame`, `provider`, `flutter_localizations`, `intl` | `pubspec.yaml` |
| **`PreviewMode` created** — singleton-style helper class; `static ValueNotifier<bool> enabled` (default false); `load()` reads `tlb_device_preview_enabled` from SharedPreferences on app start; `toggle()` flips notifier + persists; both methods swallow exceptions silently | `lib/core/preview_mode.dart` (NEW) |
| **`PreviewToggleButton` widget created** — 44×44 draggable floating button; default position top-right (`screen.width - 56`, `safeTop + 12`); `GestureDetector.onPanUpdate` updates `Offset` state, clamped to screen bounds via `screen.width/height - _size`; `ValueListenableBuilder<bool>` swaps icon (`Icons.devices` white-on-dark when off, `Icons.phone_iphone` black-on-yellow #FFCC00 when on) and tap calls `PreviewMode.toggle()` | `lib/widgets/preview_toggle_button.dart` (NEW) |
| **`main.dart` restructured** — new top-level `TLBRoot` widget wraps the app in `Directionality(textDirection: ltr)` + root `Stack`; child 1 = `ValueListenableBuilder` on `PreviewMode.enabled` returning a permanently-mounted `DevicePreview(enabled: isEnabled, builder: …)` (toggling `enabled` keeps the MaterialApp element tree alive, preserving navigation state across previews); child 2 = the floating `PreviewToggleButton` sibling so it floats above both the device frame and the surrounding chrome; `main()` calls `await PreviewMode.load()` after Firebase init | `lib/main.dart` |
| **`TLBApp` updated** — added `locale: DevicePreview.locale(context)` and wrapped existing `MediaQuery(textScaler: 1.0)` builder output with `DevicePreview.appBuilder(context, …)` so device-preview MediaQuery overrides flow into the existing text-scaling clamp | `lib/main.dart` |
| **Why this works with `Responsive` helper** — `Responsive.w/h/sp` all read `MediaQuery.of(context).size`, which device_preview overrides per simulated device; switching device in the preview shell automatically re-flows every screen through existing `Responsive` calls — no per-screen changes needed | (architecture note) |

