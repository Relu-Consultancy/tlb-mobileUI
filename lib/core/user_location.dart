import '../providers/location_state.dart';

/// The user's coordinates as the listing endpoints want them.
///
/// The API's geo parameters are all-or-nothing — a lone or malformed `lat`
/// answers 400 INVALID_COORDS — so this hands back both or neither, and every
/// caller passes them straight through.
///
/// They are only ever present when the user has tapped "Use current location"
/// in the city picker; picking a city from the list clears them (the old fix
/// would put the user somewhere they no longer are). So most sessions send
/// nothing, the API returns `distance_km: null`, and the cards simply omit the
/// distance row.
class UserLocation {
  const UserLocation._();

  static double? get lat =>
      LocationState().hasCoordinates ? LocationState().latitude : null;

  static double? get lng =>
      LocationState().hasCoordinates ? LocationState().longitude : null;

  /// True when a request can carry coordinates at all.
  static bool get isKnown => LocationState().hasCoordinates;
}
