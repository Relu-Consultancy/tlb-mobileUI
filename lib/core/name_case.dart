import 'package:flutter/services.dart';

/// Capitalises the first letter of every word in a person's name.
///
/// Only the leading letter of each word is touched — the rest is left exactly
/// as it was written, so "McDonald", "DSouza" and "van Gogh" keep the casing
/// their owner chose. Words break on spaces, hyphens and apostrophes, which
/// covers "anne-marie" -> "Anne-Marie" and "o'brien" -> "O'Brien".
///
/// Used wherever a name reaches the app already lowercased — Google sign-in
/// hands back whatever the account holds, and a name typed in a hurry rarely
/// gets the shift key.
class NameCase {
  const NameCase._();

  static const _breaks = {' ', '-', "'", '.'};

  static String of(String raw) {
    if (raw.isEmpty) return raw;
    final out = StringBuffer();
    var atWordStart = true;
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (atWordStart) {
        final upper = ch.toUpperCase();
        // Some characters grow when uppercased (German 'ß' -> "SS"). Leaving
        // those alone keeps the text the same length, which is what lets the
        // formatter below hold the caret still.
        out.write(upper.length == ch.length ? upper : ch);
      } else {
        out.write(ch);
      }
      atWordStart = _breaks.contains(ch);
    }
    return out.toString();
  }
}

/// Applies [NameCase.of] as the user types, so the capital appears under the
/// caret rather than only once the field is saved.
///
/// [NameCase.of] never changes the text's length, so the incoming selection
/// and composing region stay valid and the caret does not jump.
class NameCaseFormatter extends TextInputFormatter {
  const NameCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cased = NameCase.of(newValue.text);
    return cased == newValue.text ? newValue : newValue.copyWith(text: cased);
  }
}
