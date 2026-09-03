/// The languages a listing is delivered in, as set by the partner when they
/// create it.
///
/// The API sends two fields side by side:
///
/// ```json
/// { "languages": ["english", "hindi"], "other_language": "" }
/// ```
///
/// `languages` holds the picked-from-a-list values, lowercase; `other_language`
/// is the free-text box behind an "Other" option and is usually an empty
/// string rather than null.
class ListingLanguages {
  ListingLanguages._();

  /// Reads the list out of a detail payload.
  ///
  /// Checks [nested] first for the listing types that carry their attributes
  /// in a sub-object (a class keeps its under `service`), then the top level.
  /// Which one holds it could not be confirmed against the live API — the
  /// catalogue is empty — so both are tried rather than guessing one.
  static List<String> parse(
    Map<String, dynamic>? json, {
    Map<String, dynamic>? nested,
  }) {
    for (final source in [nested, json]) {
      final raw = source?['languages'];
      if (raw is List) {
        final out = raw
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (out.isNotEmpty) return List.unmodifiable(out);
      }
    }
    return const [];
  }

  /// Reads `other_language`, treating the empty string the API sends as absent.
  static String? parseOther(
    Map<String, dynamic>? json, {
    Map<String, dynamic>? nested,
  }) {
    for (final source in [nested, json]) {
      final raw = source?['other_language'];
      if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    }
    return null;
  }

  /// A display string, or null when the listing names no language at all —
  /// in which case the row is left off rather than shown empty.
  ///
  /// `["english", "hindi"]` with no other becomes `English, Hindi`; an
  /// `other_language` of `Marathi` is appended to it.
  static String? label(List<String> languages, String? other) {
    final parts = [
      ...languages.map(_titleCase),
      if (other != null && other.trim().isNotEmpty) _titleCase(other),
    ];
    // De-duplicated: a partner who picks "Hindi" and also types it into the
    // other box should not produce "Hindi, Hindi".
    final seen = <String>{};
    final unique = parts.where((p) => seen.add(p.toLowerCase())).toList();
    return unique.isEmpty ? null : unique.join(', ');
  }

  /// `english` -> `English`, `sign_language` -> `Sign Language`. Anything the
  /// partner typed with capitals of its own is left alone.
  static String _titleCase(String value) {
    final cleaned = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (cleaned.isEmpty) return cleaned;
    if (cleaned != cleaned.toLowerCase()) return cleaned;
    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
