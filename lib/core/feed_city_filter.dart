import '../models/homepage_section_model.dart';
import 'city_resolver.dart';

/// Keeps the admin-curated feeds (Home and the four browse tabs) to the city
/// the customer has selected.
///
/// The sections endpoints are not city-aware yet — they return the same
/// curated listings everywhere, so a customer in Prayagraj was shown Mumbai
/// listings. Each card carries its own city, so the feed is narrowed here
/// until the backend filters by `?city=` itself (see plan.md). Once it does,
/// this becomes a no-op: every card it returns already matches.
class FeedCityFilter {
  const FeedCityFilter._();

  /// Whether [listing] belongs in the feed for [selectedCity].
  ///
  /// No city selected keeps everything. An online listing has no place, so it
  /// is shown in every city. A card with no city at all is left out: there is
  /// nothing to say it is anywhere near the customer.
  static bool keep(HomepageListing listing, String? selectedCity) {
    final selected = selectedCity?.trim() ?? '';
    if (selected.isEmpty) return true;
    if ((listing.mode ?? '').toLowerCase() == 'online') return true;
    return sameCity(listing.city, selected);
  }

  /// City names compared the way the city picker names them, so "Gurugram"
  /// and "New Delhi" both land on "Delhi NCR", and case and spacing don't
  /// matter. Cities the picker doesn't list (e.g. Prayagraj) compare by name.
  static bool sameCity(String? a, String? b) {
    String norm(String? v) {
      final raw = (v ?? '').trim();
      if (raw.isEmpty) return '';
      return (CityResolver.matchKnown(raw) ?? raw).toLowerCase();
    }

    final na = norm(a);
    return na.isNotEmpty && na == norm(b);
  }
}
