import 'package:flutter/widgets.dart';

/// Where a listing was opened from, for the `utm_source` on a Listing View.
///
/// The partner Analytics screen groups "Where customers come from" by this
/// string, so it must stay a small, fixed vocabulary — a new ad-hoc string
/// splits the breakdown into near-duplicates. Add a value here, never inline.
///
/// A surface not listed (a booking confirmation, a notification) reports no
/// source, which the backend counts as organic/direct. That is deliberate:
/// only send a source when the surface is actually known.
abstract final class ListingSource {
  /// The Home tab and its curated sections.
  static const homepage = 'homepage';

  /// The Events, Classes, Programs and Venues tabs.
  static const browse = 'browse';

  /// A category, format ("Explore by Format") or pace listing page.
  static const category = 'category';

  /// Keyword search results.
  static const search = 'search';

  /// Another listing's detail screen — similar or upcoming listings.
  static const recommendation = 'recommendation';

  /// A partner's profile page.
  static const partnerProfile = 'partner_profile';

  /// The user's saved listings.
  static const wishlist = 'wishlist';

  static final Expando<String> _sourceOfRoute = Expando('listing source');
  static final Expando<Route<dynamic>> _openedFrom = Expando('opened from');

  /// Tags the route [context] sits in as a listing surface. Call from the
  /// surface screen's `build`; it is a cheap lookup, safe on every rebuild.
  static void mark(BuildContext context, String source) {
    final route = ModalRoute.of(context);
    if (route != null) _sourceOfRoute[route] = source;
  }

  /// The source of the screen the route [context] sits in was opened from, or
  /// null when that screen is not a tagged surface.
  ///
  /// Read from the detail screen itself, so every way of opening a listing —
  /// sixty-odd call sites across cards, rails, banners and search — reports
  /// without any of them having to pass a value along.
  static String? originOf(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return null;
    final from = _openedFrom[route];
    return from == null ? null : _sourceOfRoute[from];
  }

  /// Registered on the app's navigator: remembers which route each new route
  /// was pushed on top of.
  static final NavigatorObserver observer = _OriginObserver();
}

/// How a listing's detail is requested — GET /listings/{type}/{id}/.
///
/// The backend records the Listing View from that request itself: `utm_source`
/// says where the listing was opened from (a [ListingSource] value; without
/// one the view counts as organic/direct), and the signed-in customer's token
/// lets it count unique viewers. A fetch that is not the customer opening the
/// listing — a booking card loading its cover — passes neither.
abstract final class ListingViewRequest {
  static Uri uri(String url, {String? source}) {
    final base = Uri.parse(url);
    if (source == null || source.isEmpty) return base;
    return base.replace(
      queryParameters: {...base.queryParameters, 'utm_source': source},
    );
  }

  static Map<String, String> headers({String? token}) => {
        'Accept': 'application/json',
        'X-Client-Platform': 'app',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
}

class _OriginObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) ListingSource._openedFrom[route] = previousRoute;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute == null || oldRoute == null) return;
    // A replacement takes over where the old route was opened from.
    final from = ListingSource._openedFrom[oldRoute];
    if (from != null) ListingSource._openedFrom[newRoute] = from;
  }
}
