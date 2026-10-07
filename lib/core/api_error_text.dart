/// Turns what the API says went wrong into a message a customer can read.
///
/// The backend sometimes sends a Django validation error stringified as
/// Python instead of as JSON — e.g. for request-otp with an invalid email:
///
///     {'identifier': [ErrorDetail(string='Enter a valid email address.', code='invalid')]}
///
/// Shown verbatim, that is code on screen. Every service's error extractor
/// passes its server message through here first.
class ApiErrorText {
  const ApiErrorText._();

  static const String fallback = 'Something went wrong. Please try again.';

  // `ErrorDetail(string='…'` — Python quotes with ' unless the text itself
  // contains one, then with ".
  static final RegExp _detail = RegExp(
    r'''ErrorDetail\(string=(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")''',
  );
  static final RegExp _key = RegExp(r'''['"](\w+)['"]\s*:\s*\[?\s*$''');

  /// [raw] as readable text: the message inside a stringified validation
  /// error, the text itself when it is already plain, or [fallback] when it
  /// is some other code-shaped string.
  static String readable(String raw) {
    final text = raw.trim();
    final m = _detail.firstMatch(text);
    if (m != null) {
      final message = (m.group(1) ?? m.group(2) ?? '')
          .replaceAllMapped(RegExp(r'\\(.)'), (e) => e.group(1)!)
          .trim();
      if (message.isEmpty) return fallback;
      final key = _key.firstMatch(text.substring(0, m.start))?.group(1);
      return key == null ? message : field(key, message);
    }
    if (text.isEmpty || _looksLikeCode(text)) return fallback;
    return text;
  }

  /// A field's validation message, without the raw field key: DRF's
  /// messages already say what is wrong ("Enter a valid email address."),
  /// except the generic "This field …" ones, which get the field's name.
  static String field(String key, Object? message) {
    final text = readable('$message');
    if (!text.startsWith('This field')) return text;
    if (key == 'non_field_errors' || key == 'detail') return text;
    return '${_fieldName(key)}${text.substring('This field'.length)}';
  }

  static String _fieldName(String key) {
    // The auth endpoints call the email the "identifier".
    if (key == 'identifier' || key == 'email') return 'Email';
    final words = key.replaceAll('_', ' ').trim();
    if (words.isEmpty) return 'This field';
    return words[0].toUpperCase() + words.substring(1);
  }

  static bool _looksLikeCode(String text) =>
      text.startsWith('{') ||
      text.startsWith('[') ||
      text.contains('Traceback') ||
      text.contains('Exception:') ||
      text.contains('<html');
}
