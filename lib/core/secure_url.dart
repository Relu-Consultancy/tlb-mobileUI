/// Upgrades a media URL to https.
///
/// The API serves `cover_url`, `logo_url` and friends over **http** — e.g.
/// `http://tlb-api.reluconsultancy.in/media/events/media/cover.png` — while
/// Android 9 and later block cleartext traffic by default. `Image.network`
/// then fails silently and every card falls back to its grey placeholder,
/// which is exactly what "no images anywhere" looks like.
///
/// The same asset is served over https (verified against the live host), so
/// upgrading the scheme fixes it without weakening the app's network policy
/// the way `usesCleartextTraffic` would.
///
/// Asset paths, data URIs and anything already https are returned untouched.
String? secureUrl(String? raw) {
  if (raw == null) return null;
  final url = raw.trim();
  if (!url.startsWith('http://')) return raw;
  return 'https://${url.substring('http://'.length)}';
}
