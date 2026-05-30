# TLB Mobile UI — Automated Testing Report

**Generated:** 2026-05-26
**Branch:** `dev-vishesh`
**Latest commit covered:** `6a2a358` (Sessions 44–45)
**Test runner:** `flutter test` (Flutter SDK on Windows 11)

---

## 1. Executive Summary

| Metric | Value |
|---|---|
| **Total tests** | **129** |
| **Passing** | **129** (100 %) |
| **Failing** | 0 |
| **Test files** | 37 |
| **Wall-clock to run full suite** | ~30 s |

A pre-existing test was **broken** by Session 43's removal of the `/mo` suffix from the class detail screen. It was fixed as part of this audit (see §6). After the fix, the suite is fully green.

---

## 2. Coverage by Layer

| Layer | Source files | With tests | Coverage |
|---|---:|---:|---:|
| **Screens** (`lib/screens/`) | 48 | 22 | **46 %** |
| **Widgets** (`lib/widgets/`) | 35 | 9 | **26 %** |
| **Services** (`lib/services/`) | 11 | 2 | **18 %** |
| **Providers** (`lib/providers/`) | 6 | 1 | **17 %** |
| **Models** (`lib/models/`) | 11 | 1 | **9 %** |

Coverage is concentrated on the high-traffic screens (auth, category, detail, confirmation) and on widgets that have non-trivial logic (review sheet, wishlist button, app loader, format-events scaffolding). Service- and model-layer coverage is sparse because most service modules use top-level `http.post` calls that can't accept an injected mock client without source changes — see §7.

---

## 3. Per-File Results (all 37 files, all green)

### Core / providers / models

| File | Pass | Fail | Notes |
|---|---:|---:|---|
| `test/core/preview_mode_test.dart` | 7 | 0 | Session 42 — toggle + persistence |
| `test/providers/auth_state_test.dart` | 8 | 0 | 3 pre-existing + 5 added in Session 45 backfill |
| `test/models/api_class_model_test.dart` | 6 | 0 | Session 43 — `price` parsing + `bookingType` default |
| `test/services/auth_service_test.dart` | 4 | 0 | Pattern-only (no client injection) |
| `test/services/walkthrough_service_test.dart` | 3 | 0 | SharedPreferences-backed flag |

### Screen tests (22 files, 64 tests)

| File | Pass | Fail | Scope |
|---|---:|---:|---|
| `account_settings_screen_test.dart` | 3 | 0 | Personal info row, avatar fallback |
| `attendee_details_screen_test.dart` | 4 | 0 | Session 43 — fee fallback (`batch.fee` → `event.price` → "Free") |
| `booking_confirmed_screen_test.dart` | 1 | 0 | Reveal-flip teaser, ticket render |
| `category_events_screen_test.dart` | 2 | 0 | Header + chip rendering |
| `category_programs_screen_test.dart` | 2 | 0 | Header + chip rendering |
| `category_venues_screen_test.dart` | 2 | 0 | Header + chip rendering |
| `change_password_screen_test.dart` | 2 | 0 | Form, validation |
| `class_detail_screen_test.dart` | 2 | 0 | Dummy-mode render, gallery scroll **(test repaired in this audit)** |
| `classes_screen_test.dart` | 2 | 0 | Sections, scrolling |
| `edit_profile_screen_test.dart` | 2 | 0 | Field prefill, country picker |
| `event_detail_screen_test.dart` | 3 | 0 | Render, login-gated Book Now |
| `forgot_password_screen_test.dart` | 3 | 0 | 3-step wizard |
| `format_events_screen_test.dart` | 9 | 0 | Format-circle interaction, header transition |
| `notification_screen_test.dart` | 3 | 0 | Empty state |
| `profile_screen_test.dart` | 2 | 0 | Menu, mocked AuthState |
| `program_detail_screen_test.dart` | 1 | 0 | Render |
| `programs_screen_test.dart` | 2 | 0 | Sections |
| `review_pay_screen_test.dart` | 3 | 0 | Price rows, navigation |
| `splash_screen_test.dart` | 1 | 0 | Animation + auto-navigate |
| `ticket_booking_screen_test.dart` | 3 | 0 | Qty + total |
| `venue_detail_screen_test.dart` | 2 | 0 | Render |
| `venues_screen_test.dart` | 2 | 0 | Sections |

### Widget tests (9 files, 44 tests)

| File | Pass | Fail | Scope |
|---|---:|---:|---|
| `app_loader_test.dart` | 9 | 0 | Custom/fallback toggle, inline/fullscreen |
| `category_event_card_test.dart` | 10 | 0 | All fields, callbacks, overflow |
| `event_card_test.dart` | 1 | 0 | Smoke |
| `explore_categories_grid_test.dart` | 3 | 0 | Static vs scrollable mode |
| `featured_event_card_test.dart` | 1 | 0 | Smoke |
| `review_sheet_test.dart` | 4 | 0 | Auth guard, loader integration |
| `section_divider_widget_test.dart` | 5 | 0 | Title, gradient lines |
| `subcategory_empty_state_test.dart` | 8 | 0 | UI + snackbars + narrow/tablet screens |
| `wishlist_button_test.dart` | 3 | 0 | Toggle, login gate |

### Top-level

| File | Pass | Fail | Scope |
|---|---:|---:|---|
| `widget_test.dart` | 1 | 0 | App boot smoke test |

---

## 4. Untested Screens (26 of 48)

The following screens have **no test file at all**. Listed in rough order of impact (booking + checkout flow first):

### Booking & payment chain — high impact

- `booking_detail_screen.dart` — booking detail + cancel + Session 45 download wiring
- `bookings_screen.dart` — list, status filter, cancel propagation
- `date_time_selection_screen.dart` — date + time selection
- `payment_screen.dart` — payment method selection (now bypassed by Razorpay, but still in tree)
- `plan_party_screen.dart` — venue planning, occasion + slot picker
- `program_booking_confirmed_screen.dart` — Session 45 download button injection lives here
- `seat_reservation_screen.dart` — seat picker
- `select_batch_screen.dart` — classes batch picker
- `select_program_batch_screen.dart` — programs batch picker
- `venue_booking_confirmed_screen.dart` — Session 45 download button injection lives here
- `venue_checkout_screen.dart` — venue checkout, package qty controls

### Auth — medium impact

- `otp_verification_screen.dart` — OTP entry + Session 44 navigation
- `signup_screen.dart` — email signup

### Discovery / profile — lower impact

- `home_screen.dart` — landing screen, walkthrough trigger
- `events_screen.dart` — events landing
- `search_screen.dart` — search with debounce + 4 parallel APIs
- `location_screen.dart` — GPS + city picker
- `category_classes_screen.dart` — only classes category missing test
- `followed_partners_screen.dart` — followed partner list
- `gallery_screen.dart` — full-screen image gallery
- `help_centre_screen.dart` — FAQ
- `organizer_profile_screen.dart` — provider detail
- `payment_settings_screen.dart` — saved cards
- `reminders_screen.dart` — currently hidden from profile (Session 45)
- `saved_events_screen.dart` — wishlist
- `your_reviews_screen.dart` — user-created reviews

---

## 5. Test Infrastructure

- **Framework:** `flutter_test` (default Flutter testing harness)
- **Mocking:** `mocktail ^1.0.5`, `mocktail_image_network ^1.3.0`
- **HTTP testing:** `http/testing.dart` `MockClient` available but **not currently wired into services** — see §7
- **Shared helper:** `test/helpers/test_setup.dart` — `pumpTLBApp(tester, child)` wraps a child in `MaterialApp` with the app theme, mocks `FlutterSecureStorage` to empty, swallows `RenderFlex overflow` errors (kept loose because layouts can break under various test viewports without that being a real bug), and sets a fixed 1080×2400 viewport with 3.0 device pixel ratio.

```dart
// Boilerplate usage
await pumpTLBApp(tester, MyScreen(...));
await tester.pumpAndSettle();
expect(find.text('…'), findsOneWidget);
```

For widget tests that load network images, wrap the body in `mockNetworkImages(() async { … })` from `mocktail_image_network`.

---

## 6. Regression Found & Fixed During This Audit

**`test/screens/class_detail_screen_test.dart::renders event details correctly`**

The test expected `'₹500/mo'` and `'Send Enquiry'`. Two issues:

1. **`/mo` suffix dropped:** Session 43 removed the `/mo` suffix from the bottom-bar price label (the API has no billing-period field). The test still expected the old format.
2. **Wrong CTA expected:** With `id: ''` the screen runs in dummy mode → `_detail` is null → `bookingType` is unknown → screen falls through to the **"Enquire Now"** CTA and **hides the price entirely** (price renders only when `bookingType == 'direct_booking'`). The test expected `'Send Enquiry'`, which is text from a much older revision.

**Fix:** Asserted that the dummy-mode render shows `'Enquire Now'` and that no price text is present. See [test/screens/class_detail_screen_test.dart:21-33](test/screens/class_detail_screen_test.dart#L21-L33).

This is a textbook example of **why fixes that change UI text should update tests in the same commit** — the broken test sat for ~10 commits before this audit caught it.

---

## 7. Known Coverage Gaps & Why

### Service-level HTTP

`AuthService`, `BookingService`, `EventsListingService`, `WishlistService`, `ReviewService`, `PartnerService`, `ClassesListingService`, `ProgramsListingService` all use **top-level `http.post(...)` / `http.get(...)`** directly — no `http.Client` dependency injection.

This means you cannot use `MockClient` to intercept calls without modifying source. The existing `test/services/auth_service_test.dart` is honest about this — it asserts the **request/response *shape* via a standalone MockClient** rather than driving the real service. That pattern has limited value for catching real bugs.

**Proper fix would be:** introduce a static field like `static http.Client client = http.Client();` on each service, allow tests to override it. Then full HTTP integration tests become possible. This is ~30 LOC per service and would unlock testing the actual error-extraction, envelope-unwrapping, and retry behavior.

### PDF builder (Session 45)

`TicketPdfService._buildPdf` builds a PDF from JSON. To test rigorously, would need golden tests (compare generated bytes to a reference PDF) via `golden_toolkit`. Skipped per the test-scope discussion in Session 45 — only useful if the PDF layout will keep changing.

### Welcome dialog grey-flash fix (Session 44)

The fix is a navigation-timing change that's hard to assert from a widget test — it would need a custom `NavigatorObserver` that records frame timings around `pushAndRemoveUntil`. Skipped for cost/benefit.

### Pre-existing failing-tests note (now resolved)

Session 23 dev-graph noted **11 pre-existing failing tests** that required API mocks. As of this audit, the suite reports 0 failures, which means either those tests were repaired since, removed, or the count was inaccurate at the time. Recommend dropping the stale TODO line from the dev_graph pending list.

---

## 8. Recommendations

Priority order:

1. **Inject `http.Client` into services** (3–5 h of refactor) → unlocks dozens of high-value service tests for the error/envelope/refund flows that are currently impossible to test.
2. **Write tests for the Session 45 download buttons** — at minimum verify the disabled state when `bookingId` is null and confirmed state when present. Doesn't need PDF golden tests; just verify the `_ActionBtn` greys out and `onTap` is null in the right conditions.
3. **Backfill tests for `bookings_screen.dart` and `booking_detail_screen.dart`** — these are now the most important untested screens since they're the entry point for the new download flow.
4. **Replace the pattern-only `auth_service_test.dart`** with real integration tests after (1) lands.
5. **Drop the stale "11 failing tests" note** from `dev_graph.md`.

These changes would lift overall confidence in the bookings/auth flows that just got the most substantial Sessions-44–45 changes.

---

## 9. How to Re-Run

```powershell
# Full suite, expanded reporter
flutter test --reporter expanded

# A single file
flutter test test/screens/class_detail_screen_test.dart

# Machine-readable JSON (for tooling/CI)
flutter test --machine > test_run.log
```

CI: no CI configuration currently exists in the repo. Recommend adding a GitHub Action that runs `flutter test` on push to `dev-vishesh` and `master`. The full suite finishes in ~30 s — easy to gate PRs on.
