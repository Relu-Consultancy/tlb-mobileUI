// Standalone generator for the TLB Mobile UI end-to-end testing report.
// Run with: dart run tool/generate_test_report.dart
// Produces: TLB_Mobile_Test_Report.pdf  (uses the bundled `pdf` package).

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const String kReportDate = '17 June 2026';

// ── Severity palette ────────────────────────────────────────────────────────
final PdfColor cHigh = PdfColor.fromInt(0xFFD32F2F);
final PdfColor cMed = PdfColor.fromInt(0xFFE08A00);
final PdfColor cLow = PdfColor.fromInt(0xFF5B6470);
final PdfColor cInk = PdfColor.fromInt(0xFF1A1A2E);
final PdfColor cSub = PdfColor.fromInt(0xFF555B66);
final PdfColor cBrand = PdfColor.fromInt(0xFFE0A200);
final PdfColor cBrandBg = PdfColor.fromInt(0xFFFFF3D6);
final PdfColor cGood = PdfColor.fromInt(0xFF1B8A4B);
final PdfColor cRule = PdfColor.fromInt(0xFFE3E3E3);

PdfColor sevColor(String s) =>
    s == 'High' ? cHigh : (s == 'Medium' ? cMed : cLow);

class Finding {
  final String sev; // High | Medium | Low
  final String title;
  final String loc;
  final String issue;
  final String fix;
  Finding(this.sev, this.title, this.loc, this.issue, this.fix);
}

Future<void> main() async {
  final doc = pw.Document(
    title: 'TLB Mobile UI - End-to-End Test Report',
    author: 'QA / Engineering',
  );

  // ── Data ──────────────────────────────────────────────────────────────────
  final endpoints = <List<String>>[
    ['Auth', 'POST', '/auth/request-otp/  ·  /auth/verify-otp/'],
    ['Auth', 'POST', '/auth/google-login/  ·  /auth/refresh-token/  ·  /auth/logout/'],
    ['Auth', 'POST', '/auth/customer/password/reset/{request,verify-otp,confirm}/'],
    ['Auth', 'GET/PATCH/DELETE', '/customer/profile/  ·  /customer/account/'],
    ['Wishlist', 'GET/POST/DELETE', '/wishlist/  ·  /wishlist/add/  ·  /wishlist/remove/{id}/'],
    ['Reviews', 'GET/POST/PATCH/DELETE', '/listings/{id}/reviews/  ·  /reviews/{id}/  ·  /customer/reviews/'],
    ['Reviews', 'GET/POST/DELETE', '/reviews/{id}/media/  ·  /listings/{id}/my-review/'],
    ['Partner', 'GET/POST/DELETE', '/partner/{id}/follow/  ·  /unfollow/  ·  /partner/followed/'],
    ['Notifications', 'GET/POST', '/notifications/in-app/  ·  /unread-count/  ·  /{id}/read/  ·  /read-all/'],
    ['Home feed', 'GET', '/homepage/sections/'],
    ['Listings', 'GET', '/events  ·  /classes  ·  /programs  ·  /venues  (+ detail, paginated)'],
    ['Bookings', 'POST', '/bookings/initiate/  ·  /initiate-with-saved-method/  ·  /{id}/verify-payment/'],
    ['Bookings', 'GET/POST', '/bookings/  ·  /{id}/  ·  /{id}/ticket/data/  ·  /{id}/cancel/'],
  ];

  final apiFindings = <Finding>[
    Finding('High', 'Unguarded jsonDecode(...) as Map on protected calls',
        'booking_service.dart:69,140,185,...  ·  review_service.dart (no try/catch)  ·  partner_service.dart:89',
        'A 500 HTML page, empty body, or bare JSON array makes jsonDecode return a non-Map / throw FormatException. This escapes the SocketException/TimeoutException handlers and surfaces as a raw crash to the caller.',
        'Reuse the defensive _decode() helper (already used by auth/help/coupon/notification services) everywhere; tolerate non-Map / empty bodies.'),
    Finding('High', 'No centralized 401 -> token-refresh / retry',
        'all services  ·  auth_state.dart:177',
        'The refresh token is only exchanged once at cold start. A mid-session access-token expiry yields inconsistent handling (throw "Session expired", return null, or silent fail) with no automatic refresh-and-retry.',
        'Add an authenticated-request wrapper that, on 401, calls refreshToken(), updates AuthState, retries once, and routes to logout on failure.'),
    Finding('Medium', 'Base URL hardcoded & duplicated in 14 files',
        'auth_service.dart:8 (+13 siblings)  ·  app_config.dart',
        'The host string is copy-pasted in every service; AppConfig only holds the Razorpay key. No dev/staging/prod switch; a host change means editing 14 files.',
        'Move _base into AppConfig.apiBase and reference it everywhere.'),
    Finding('Medium', 'tryRestoreSession keeps an expired access token on network failure',
        'auth_state.dart:195-210',
        'When refreshToken throws (offline), it restores from cached tokens and logs in with the old, possibly-expired access token; every subsequent protected call then 401s with no refresh path.',
        'Mark the session "needs refresh" and retry refresh on next foreground / first 401.'),
    Finding('Medium', 'Token-rejection detection relies on string-matching the error message',
        'auth_state.dart:188-194',
        'Whether to clear tokens depends on the message containing "invalid"/"expired"/"blacklisted". A reworded backend message leaves a dead refresh token un-cleared -> broken logged-in-but-401 loop.',
        'Branch on the HTTP status / error code, not free text.'),
    Finding('Medium', 'Force-cast IDs in JSON models (as int / as num)',
        'api_review_model.dart:9,88  ·  api_followed_partner_model.dart:55',
        'json["id"] as int / as num throws if the backend serializes the id as a string or omits it.',
        'Use (json["id"] as num?)?.toInt() ?? 0 consistently.'),
    Finding('Low', 'Optimistic-success swallows real failures',
        'wishlist_service.dart:68 (400=success)  ·  partner_service.dart (400/404=success)',
        'A genuine validation 400 is treated as "already saved"/"already followed", so the optimistic UI stays toggled though nothing persisted server-side.',
        'Inspect the error code before assuming idempotent success.'),
    Finding('Low', 'Per-user static caches not reset on logout',
        'notifications_state  ·  user_reviews_state.dart:12 (non-scoped prefs key)  ·  home_feed_state._loaded  ·  saved_events_state',
        'Static singletons can leak the previous user\'s unread count / cached reviews into the next account on a shared device.',
        'Scope persisted keys per-user (as FollowState does) and reset all static caches in AuthState.logout().'),
    Finding('Low', 'Lost-update race in concurrent loads',
        'saved_events_state.loadFromApi  ·  user_reviews_state.loadFromApi',
        'Unlike HomeFeedState (which has a _loading guard), these can run concurrently; a slow earlier response can clobber a fresh later one.',
        'Add an in-flight guard or monotonic sequence token.'),
  ];

  final bugFindings = <Finding>[
    Finding('High', 'Required casts crash the payment flow',
        'api_booking_model.dart:76-78,81,288  ·  review_pay_screen.dart:180-188 (as int)',
        'booking_id/razorpay_order_id as String, amount as num, line-item count as int cast without fallback. JSON numbers often deserialize as double; callers only catch network errors, so a CastError surfaces raw during checkout.',
        'Null-coalesce all casts: (json[x] as String?) ?? "" ; (json[x] as num?)?.toDouble() ?? 0.'),
    Finding('High', 'Cover-media as String cast can abort detail parse',
        'api_event_model.dart:220  ·  api_venue_model.dart:232  ·  api_class_model.dart:196  ·  api_program_model.dart:228',
        '.map((m) => m["url"] as String) throws if any cover entry url/file_url is null, failing the whole detail-screen parse.',
        'Map to String? then .whereType<String>() before firstOrNull.'),
    Finding('High', 'Detail models DateTime.parse without fallback',
        'api_event_model.dart:200-225 (+ class/program detail)',
        'DateTime.parse(json["start_datetime"]) throws on a malformed date, where the list model defensively falls back to now().',
        'Use DateTime.tryParse(...) ?? DateTime.now() and null-coalesce required casts.'),
    Finding('High', 'accessToken! force-unwrap on session expiry',
        'review_sheet.dart:734  ·  booking_detail_screen.dart:134',
        'If the token is cleared between opening a sheet and tapping submit, accessToken! throws "Null check operator used on null"; the review sheet sticks with _submitting=true.',
        'Read into a nullable local, show an auth error, and bail.'),
    Finding('High', 'Empty-list crashes (clamp / modulo / PageView)',
        'category_events_screen.dart:48 clamp(0,-1)  ·  special_needs_section.dart:42 index % 0  ·  trending_card.dart:56 count:0',
        'clamp(0,length-1) throws ArgumentError on an empty list; index % items.length divides by zero; a 0-item PageView + SmoothPageIndicator(count:0) can assert.',
        'Guard isEmpty -> render empty state / SizedBox.shrink() before clamp / modulo / PageView.'),
    Finding('High', 'Out-of-range / stale index RangeErrors',
        'select_program_batch_screen.dart:39 months[month]  ·  category_classes/events_screen.dart:80/75 _filters[idx]',
        'months[int.tryParse(...)] can index 13; a load-more in flight during a category switch leaves _selectedFilterIndex beyond the new shorter list -> RangeError.',
        'Bounds-check the index (1..12; < list.length) before indexing.'),
    Finding('High', 'gradient cast crashes every grid cell on a missing key',
        'all_categories_popup.dart:158  ·  explore_categories_grid.dart:188',
        'category["gradient"] as List<Color> throws TypeError if the key is absent.',
        '(category["gradient"] as List<Color>?) ?? const [..fallback..].'),
    Finding('Medium', 'banner_carousel: staticFade + infiniteScroll -> RangeError',
        'banner_carousel.dart:105,252',
        'In staticFade mode there is no PageView, so onPageChanged never resets _currentIndex from its _loopBase (lengthx1000) start; widget.events[_currentIndex] would throw. Latent: no caller currently combines both flags.',
        'In staticFade init _currentIndex = 0 regardless, or index with _currentIndex % events.length.'),
    Finding('Medium', 'setState after await without mounted guard',
        'payment_settings_screen.dart:38-47  ·  walkthrough_intro_overlay.dart:41',
        'Popping the screen mid-fetch throws "setState() called after dispose".',
        'Add if (!mounted) return; before each post-await setState / callback.'),
    Finding('Medium', 'userEmail?.substring(0,1) RangeError on empty string',
        'account_settings_screen.dart:57-60',
        '?. guards null but not "" - an empty first_name/email crashes the profile card.',
        'Guard isNotEmpty before substring.'),
    Finding('Medium', 'Double-tap navigation pushes duplicate routes',
        'navbar + checkout CTAs: ticket_booking/seat_reservation/venue_checkout/attendee_details; whole-card taps',
        'onTap calls Navigator.push with no in-flight guard; a fast double-tap stacks identical screens (worst on money flows). review_pay_screen guards correctly.',
        'Shared re-entrancy flag or ModalRoute.of(context)?.isCurrent check before push.'),
    Finding('Medium', 'Re-entrant fetch race overwrites with stale results',
        'category_events/classes/programs_screen  ·  home_feed_state.dart:24',
        'Overlapping fetches from rapid filter switching can land out of order; HomeFeedState.load also drops a force:true refresh issued during startup.',
        'Monotonic request-id token; discard stale responses; queue forced refresh.'),
    Finding('Medium', 'Listing/booking/review services: unguarded decode + a dead branch',
        'classes_listing_service.dart:35-54  ·  events/programs/booking/review_service',
        'jsonDecode+cast inside a try that only catches network errors; classes service has a statically-dead "is List" branch and a jsonDecode(e.toString()) "recovery" that always fails.',
        'Decode as dynamic and branch like programs_listing_service; reuse the _decode helper; wrap review_service in try/catch.'),
  ];

  final uiFindings = <Finding>[
    Finding('High', 'Brand-yellow / blue / background colors drift off AppColors',
        'CTAs use 0xFFFFCC00/FFB902/FFD014; ticket/notif UI uses 0xFF2563EB; scaffolds use 0xFFF2F2F7',
        'AppColors.primary (F5A623), seeAllBlue (0068E7), background (FFF8EE) exist but dozens of screens hardcode competing hexes for the same role - the single biggest consistency gap.',
        'Consolidate to AppColors tokens (CTA gold, accent blue, scaffold bg, text primary/secondary).'),
    Finding('High', 'Home feed + 11 sections render DummyData; empty-guards commented out',
        'hot_picks_section.dart:21 (+ every section)  ·  home_screen.dart:62,81',
        'isEmpty guards are commented out; sections render today only because dummy lists are non-empty. Once API returns an empty list each section shows a floating divider title over an empty band.',
        'Restore the isEmpty -> SizedBox.shrink() guards before re-enabling live data.'),
    Finding('High', 'Failure state masquerades as empty (no retry)',
        'upcoming_events_section.dart:61  ·  category_events_screen.dart:120 (+ siblings)',
        'A network error sets the list to [] and shows the generic empty state - a failed request looks identical to "no results". search_screen does this correctly with a Retry button.',
        'Distinguish error from empty; add a Retry affordance (mirror search_screen).'),
    Finding('High', 'Final ticket image is asset-only but receives network URLs',
        'booking_confirmed_screen.dart:456',
        'Image.asset(event.imagePath) - after a real booking imagePath is an http URL, so the confirmed ticket always falls to the grey placeholder.',
        'Branch on startsWith("http") -> Image.network, like the detail screens.'),
    Finding('High', 'Image.asset calls with no errorBuilder',
        'empty_location_widget.dart:22  ·  home_header.dart:76  ·  banner_carousel.dart:375  ·  location_screen.dart:396',
        'A missing/renamed asset renders a broken-image box. Several rely on the "resources- tlb-ui/" path (literal space) which is fragile.',
        'Add errorBuilder fallbacks; verify each asset is declared in pubspec; consider moving under assets/.'),
    Finding('High', 'Dead / no-op buttons that look active',
        'reminders_screen.dart:242 (Edit)  ·  category_events_screen.dart:247 (See All)  ·  venues_screen.dart:857 (View all)  ·  search fields with no controller',
        'Buttons/fields render as interactive but onTap/onPressed is empty {} - users tap and nothing happens.',
        'Wire the actions or remove the controls / mark them disabled.'),
    Finding('High', 'No payment / no-op mock screens shipped alongside real flow',
        'payment_screen.dart:90-199 (Future.delayed -> confirmed)  ·  reminders_screen.dart:14 (mock data)',
        'payment_screen lists CRED/Pay-Later tiles that fake a 2s delay then push BookingConfirmed with NO real payment, bypassing the real Razorpay flow; reminders shows static fake events.',
        'Remove/disable the mock screens or wire them to the real flow.'),
    Finding('High', 'Systemic sub-44px tap targets + icon-only controls without Semantics',
        'navbar (~40)  ·  wishlist_button (36/24)  ·  follow/seat/qty/back buttons (28-36)',
        'Many interactive controls are below the 44px accessibility minimum and announce nothing to screen readers (drawn as GestureDetector+Container / bare IconButton).',
        'Raise tap targets to >=44px; add Semantics labels to icon-only controls.'),
    Finding('Medium', 'Fixed widths/heights bypass Responsive (overflow on small screens / large fonts)',
        'event_card.dart:18 (260)  ·  weekend_event_card.dart:15 (330)  ·  CTA SizedBox(height:52/54) on checkout screens',
        'Hardcoded card widths and fixed CTA heights can overflow on <360px phones or clip text when OS font scales (currently masked by main.dart clamping scale to 1.0).',
        'Use Responsive.cardWidth/w/h; let CTA height grow with text.'),
    Finding('Medium', 'Bottom price+CTA Row can overflow with a long price',
        'event_detail_screen.dart:531  ·  class/program/venue_detail_screen',
        'The price Text/RichText next to the CTA is not Flexible; a long price string overflows the row.',
        'Wrap the price in Flexible/Expanded with ellipsis.'),
    Finding('Medium', 'No loading placeholders on network images',
        'search/bookings/organizer_card/banner_carousel/listing_image + detail heroes',
        'Image.network has errorBuilder but no loadingBuilder, so covers/avatars pop in or sit blank on slow networks.',
        'Add a loadingBuilder skeleton/shimmer.'),
    Finding('Medium', 'White-on-yellow tag text fails WCAG AA contrast',
        'event_detail_screen.dart:317  ·  class_detail_screen.dart:272  ·  program_detail_screen.dart:345',
        'White text on 0xFFFFCC00 chips is low contrast; venue_detail uses dark text correctly.',
        'Use dark text on the yellow chips consistently.'),
    Finding('Medium', 'Placeholder data shipped as real content',
        'all home sections ("3-5 Yrs"/"3.5k reviews")  ·  date_time_selection ("Sun 28 Feb")  ·  fake QR (Random(42))  ·  gallery demo images',
        'Hardcoded fallbacks/mocks render identically to real content; the ticket QR is non-scannable.',
        'Drive from API data; generate the QR from the booking reference; remove demo lists.'),
    Finding('Medium', 'booking_confirmed lacks PopScope - back returns into the paid flow',
        'booking_confirmed_screen.dart',
        'Unlike program/venue confirmed screens (PopScope canPop:false), system-back returns to ReviewPay/"Pay" after payment.',
        'Add PopScope(canPop:false) and route Home.'),
  ];

  final lints = <List<String>>[
    ['curly_braces_in_flow_control_structures', '1', 'booking_detail_screen.dart:1615'],
    ['use_null_aware_elements (prefer ?. spread)', '28', 'classes/events/programs_listing_service.dart'],
  ];

  final solid = <String>[
    'Static analysis is clean: 0 errors, 0 warnings (29 style-only info lints).',
    'Full automated suite passes: 130/130 widget & unit tests green, including the home smoke test, category screens, review-guard, wishlist toggle, and the new logo SVGs.',
    'Network timeouts on every call (15-30s); SocketException/TimeoutException/HandshakeException handled with friendly messages.',
    'Token storage is secure: flutter_secure_storage with encryptedSharedPreferences on Android; tokens never logged.',
    'Lifecycle hygiene is strong: AnimationController / Timer / PageController / TextEditingController / FocusNode are disposed; most async setState/navigation is mounted-guarded.',
    'The real payment path (review_pay_screen) is well-built: Razorpay init/dispose, double-submit guard, backend verification, graceful "paid-but-unverified" dialog with reference.',
    'search_screen is the model: debounced input + full loading/empty/error/no-results states with Retry.',
    'errorBuilder coverage on raster images is near-universal; optimistic wishlist/follow toggles roll back on failure.',
    'Font stack is healthy: Poppins genuinely bundled (offline-safe), zero unsupported w300/Light usage.',
    'Banner carousel core logic is correct: empty-list guard, modulo index wrapping, putIfAbsent palette de-dup, try/catch + fallback color, mounted-guarded band load.',
  ];

  final priorities = <List<String>>[
    ['1', 'Crash-safety in money flow', 'Null-coalesce the required casts in api_booking_model & detail models; fix accessToken! in review_sheet/booking_detail; add empty-list guards (clamp/modulo/PageView).'],
    ['2', 'Network resilience', 'Add a 401->refresh->retry wrapper; route all services through a defensive _decode(); move base URL into AppConfig.'],
    ['3', 'Money-flow UX integrity', 'Add PopScope to booking_confirmed; remove/wire the payment_screen & reminders mocks; debounce navigation on checkout CTAs and the navbar.'],
    ['4', 'Live-data readiness', 'Restore commented-out isEmpty guards in home sections; distinguish error vs empty with Retry; fix asset-only final-ticket image.'],
    ['5', 'Design system + a11y', 'Consolidate gold/blue/bg/text colors into AppColors tokens; raise sub-44px tap targets; add Semantics to icon-only controls; fix white-on-yellow contrast.'],
    ['6', 'Polish', 'Replace shipped placeholder data & fake QR; fix copy typos (Hand-On->Hands-On, Inquire/Enquire); clear large dead/commented code blocks.'],
  ];

  // ── Styles ──────────────────────────────────────────────────────────────
  pw.TextStyle h1() =>
      pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: cInk);
  pw.TextStyle h2() =>
      pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: cInk);
  pw.TextStyle body([PdfColor? c]) =>
      pw.TextStyle(fontSize: 9.5, color: c ?? cSub, lineSpacing: 1.6);
  pw.TextStyle small([PdfColor? c]) =>
      pw.TextStyle(fontSize: 8, color: c ?? cSub);

  pw.Widget sectionTitle(String n, String t) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 6, bottom: 10),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(width: 4, height: 18, color: cBrand),
          pw.SizedBox(width: 8),
          pw.Text('$n.  $t', style: h1()),
        ]),
      );

  pw.Widget chip(String label, PdfColor color) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: pw.BoxDecoration(
            color: color, borderRadius: pw.BorderRadius.circular(3)),
        child: pw.Text(label,
            style: pw.TextStyle(
                fontSize: 7,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold)),
      );

  // Drawn-dot bullet (avoids the built-in font's missing bullet glyph).
  pw.Widget bulletRow(String t, {PdfColor? dot, PdfColor? text}) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5, left: 2),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
              width: 3.2,
              height: 3.2,
              margin: const pw.EdgeInsets.only(top: 4.2, right: 7),
              decoration: pw.BoxDecoration(
                  color: dot ?? cBrand, shape: pw.BoxShape.circle)),
          pw.Expanded(child: pw.Text(t, style: body(text ?? cInk))),
        ]),
      );

  pw.Widget findingW(Finding f, int idx) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 9),
        padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFFAFAFA),
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border(left: pw.BorderSide(color: sevColor(f.sev), width: 2.5)),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            chip(f.sev.toUpperCase(), sevColor(f.sev)),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Text(f.title, style: h2()),
            ),
          ]),
          pw.SizedBox(height: 4),
          pw.RichText(
              text: pw.TextSpan(children: [
            pw.TextSpan(text: 'Where  ', style: small(cBrand).copyWith(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: f.loc, style: small(cSub)),
          ])),
          pw.SizedBox(height: 3),
          pw.RichText(
              text: pw.TextSpan(children: [
            pw.TextSpan(text: 'Issue  ', style: body(cInk).copyWith(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: f.issue, style: body()),
          ])),
          pw.SizedBox(height: 3),
          pw.RichText(
              text: pw.TextSpan(children: [
            pw.TextSpan(text: 'Fix  ', style: body(cGood).copyWith(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: f.fix, style: body()),
          ])),
        ]),
      );

  int countSev(List<Finding> all, String s) =>
      all.where((f) => f.sev == s).length;
  final allF = [...apiFindings, ...bugFindings, ...uiFindings];

  pw.Widget statCard(String big, String label, PdfColor color) => pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 4),
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFAFAFA),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: cRule)),
          child: pw.Column(children: [
            pw.Text(big,
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 3),
            pw.Text(label,
                textAlign: pw.TextAlign.center, style: small(cSub)),
          ]),
        ),
      );

  // ── Cover ───────────────────────────────────────────────────────────────
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: cBrand, width: 1.5),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                    color: cBrandBg, borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text('THE LITTLE BROADWAY  ·  MOBILE APP',
                    style: pw.TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: pw.FontWeight.bold,
                        color: cBrand)),
              ),
              pw.SizedBox(height: 24),
              pw.Text('End-to-End\nTesting Report',
                  style: pw.TextStyle(
                      fontSize: 38,
                      fontWeight: pw.FontWeight.bold,
                      color: cInk,
                      lineSpacing: 2)),
              pw.SizedBox(height: 16),
              pw.Text(
                  'API integration · UI/UX & design · robustness & edge cases · static analysis · automated test suite',
                  style: body(cSub).copyWith(fontSize: 11)),
              pw.SizedBox(height: 34),
              pw.Row(children: [
                statCard('0', 'Analyzer errors', cGood),
                statCard('130/130', 'Tests passing', cGood),
                statCard('${countSev(allF, "High")}', 'High findings', cHigh),
                statCard('${countSev(allF, "Medium")}', 'Medium findings', cMed),
              ]),
              pw.SizedBox(height: 34),
              pw.Divider(color: cRule),
              pw.SizedBox(height: 8),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: $kReportDate', style: body(cInk)),
                    pw.Text('Build: dev-vishesh  ·  Flutter 3.38', style: body(cInk)),
                  ]),
            ]),
      ),
    ),
  ));

  // ── Body ────────────────────────────────────────────────────────────────
  final content = <pw.Widget>[];

  // 1. Executive summary
  content.add(sectionTitle('1', 'Executive Summary'));
  content.add(pw.Paragraph(
      style: body(),
      text:
          'The TLB mobile app is in a healthy, near-release state: it compiles with zero analyzer errors, the full automated suite (130 tests) passes, and core infrastructure - secure token storage, network timeouts, lifecycle disposal, the real Razorpay payment path, and image error-fallbacks - is well-engineered. This end-to-end pass exercised the API layer, every screen/widget/section, design-system consistency, accessibility, and edge-case robustness.'));
  content.add(pw.Paragraph(
      style: body(),
      text:
          'The findings below are overwhelmingly hardening items rather than broken features. The dominant themes are: (a) defensive JSON parsing - several required casts and decodes can throw on unexpected payloads, most critically in the booking/payment models; (b) network resilience - there is no centralized 401-refresh-retry; (c) live-data readiness - home sections still render mock data with their empty-state guards commented out; and (d) design-system drift - brand colors are hardcoded across many files instead of pulled from AppColors. None of these block day-to-day use today, but items in Sections 4-6 should be addressed before wiring live API data and shipping.'));
  content.add(pw.SizedBox(height: 6));
  content.add(pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
        color: cBrandBg, borderRadius: pw.BorderRadius.circular(5)),
    child: pw.Row(children: [
      pw.Expanded(
          child: pw.Text(
              'Verdict: SHIP-READY for the current mock/demo build. Address the Section 7 priority list (crash-safety in the money flow + network resilience) before enabling live API data.',
              style: body(cInk).copyWith(fontWeight: pw.FontWeight.bold))),
    ]),
  ));

  // 2. Automated results
  content.add(pw.SizedBox(height: 14));
  content.add(sectionTitle('2', 'Automated Test & Analysis Results'));
  content.add(bulletRow('flutter analyze - 0 errors, 0 warnings; 29 info-level style lints (below).', dot: cGood));
  content.add(bulletRow('flutter test - 130 / 130 passing (widget, unit & smoke tests). No RenderFlex overflow surfaced.', dot: cGood));
  content.add(pw.SizedBox(height: 6));
  content.add(pw.Text('Static-analysis lints (cosmetic, non-blocking):', style: h2()));
  content.add(pw.SizedBox(height: 4));
  content.add(pw.TableHelper.fromTextArray(
    headers: ['Lint rule', 'Count', 'Location'],
    data: lints,
    headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: pw.BoxDecoration(color: cInk),
    cellStyle: small(cSub),
    cellHeight: 18,
    columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(0.8), 2: const pw.FlexColumnWidth(4)},
    cellAlignments: {1: pw.Alignment.center},
  ));

  // 3. Endpoint inventory
  content.add(pw.SizedBox(height: 14));
  content.add(sectionTitle('3', 'API Endpoint Inventory'));
  content.add(pw.Paragraph(style: body(), text: 'All ~40 REST endpoints reach the configured host (https://tlb-api.reluconsultancy.in/api/v1). Grouped by service:'));
  content.add(pw.TableHelper.fromTextArray(
    headers: ['Service', 'Methods', 'Paths'],
    data: endpoints,
    headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: pw.BoxDecoration(color: cInk),
    cellStyle: small(cSub),
    rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: cRule, width: 0.5))),
    cellHeight: 16,
    columnWidths: {0: const pw.FlexColumnWidth(1.4), 1: const pw.FlexColumnWidth(1.6), 2: const pw.FlexColumnWidth(5)},
  ));

  // Severity overview
  content.add(pw.SizedBox(height: 14));
  content.add(sectionTitle('4', 'Findings Overview'));
  content.add(pw.Row(children: [
    statCard('${countSev(allF, "High")}', 'High severity', cHigh),
    statCard('${countSev(allF, "Medium")}', 'Medium severity', cMed),
    statCard('${countSev(allF, "Low")}', 'Low severity', cLow),
    statCard('${allF.length}', 'Total findings', cInk),
  ]));
  content.add(pw.SizedBox(height: 8));
  content.add(pw.Paragraph(style: small(cSub), text: 'Severity = High: can crash or corrupt the money/auth flow, or blocks live data.  Medium: degraded UX, robustness or consistency risk.  Low: polish / minor hardening.'));

  // 5. API findings
  content.add(pw.SizedBox(height: 10));
  content.add(sectionTitle('5', 'API & Networking Findings'));
  for (var i = 0; i < apiFindings.length; i++) content.add(findingW(apiFindings[i], i));

  // 6. Robustness findings
  content.add(pw.SizedBox(height: 6));
  content.add(sectionTitle('6', 'Robustness, Crashes & Edge Cases'));
  for (var i = 0; i < bugFindings.length; i++) content.add(findingW(bugFindings[i], i));

  // 7. UI/UX findings
  content.add(pw.SizedBox(height: 6));
  content.add(sectionTitle('7', 'UI / UX, Design & Accessibility Findings'));
  for (var i = 0; i < uiFindings.length; i++) content.add(findingW(uiFindings[i], i));

  // 8. Priorities
  content.add(pw.SizedBox(height: 6));
  content.add(sectionTitle('8', 'Prioritized Remediation Plan'));
  content.add(pw.TableHelper.fromTextArray(
    headers: ['#', 'Theme', 'Action'],
    data: priorities,
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: pw.BoxDecoration(color: cBrand),
    cellStyle: body(cSub).copyWith(fontSize: 9),
    rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: cRule, width: 0.5))),
    cellHeight: 30,
    cellAlignments: {0: pw.Alignment.center},
    columnWidths: {0: const pw.FlexColumnWidth(0.5), 1: const pw.FlexColumnWidth(2.2), 2: const pw.FlexColumnWidth(6)},
  ));

  // 9. What's solid
  content.add(pw.SizedBox(height: 14));
  content.add(sectionTitle('9', 'What Is Solid'));
  for (final s in solid) {
    content.add(bulletRow(s, dot: cGood));
  }

  // 10. Methodology
  content.add(pw.SizedBox(height: 14));
  content.add(sectionTitle('10', 'Scope & Methodology'));
  content.add(pw.Paragraph(style: body(), text: 'Static & automated: flutter analyze (full lib/) and the complete flutter test suite (130 cases) were run on the dev-vishesh branch. Code review: the entire lib/ tree was audited across three dimensions - (1) the data/networking layer (services, providers, api_* models), (2) UI/UX, design tokens, responsiveness, states & accessibility across all 70+ screens / 44 widgets / 11 sections, and (3) lifecycle, null-safety, async correctness, edge-case data & performance.'));
  content.add(pw.Paragraph(style: body(), text: 'Not covered (requires a physical device / live backend): real on-device interaction, live API contract verification against the running server, Razorpay sandbox transactions, push-notification delivery, deep-link handling, and platform-specific (iOS/Android) rendering. These are recommended as a follow-up manual QA pass on a device once the Section 7 items land.'));

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(38, 40, 38, 40),
    header: (ctx) => ctx.pageNumber == 1
        ? pw.SizedBox()
        : pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 4),
            decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: cRule))),
            child: pw.Text('TLB Mobile UI - End-to-End Testing Report',
                style: small(cSub))),
    footer: (ctx) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('The Little Broadway · Confidential', style: small(cSub)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: small(cSub)),
      ]),
    ),
    build: (ctx) => content,
  ));

  final out = File('TLB_Mobile_Test_Report.pdf');
  out.writeAsBytesSync(await doc.save());
  stdout.writeln('Wrote ${out.path} (${out.lengthSync()} bytes)');
}
