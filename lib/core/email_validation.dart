/// Validation for the email address typed into sign-in, sign-up and
/// forgot-password.
///
/// Checked before any request so a malformed address gets a plain message
/// immediately instead of a round trip — and the rule is kept close to the
/// backend's (Django's `EmailValidator`), so what passes here is what the
/// server accepts: a dot-atom local part, `@`, and a dotted domain whose last
/// label is at least two characters.
class EmailAddress {
  const EmailAddress._();

  static final RegExp _pattern = RegExp(
    r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
    r'@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
    r'[A-Za-z0-9-]{2,63}$',
  );

  static bool isValid(String? raw) => _pattern.hasMatch((raw ?? '').trim());

  /// Message for an empty or malformed address, or null when it is fine.
  static String? validate(String? raw) {
    final email = (raw ?? '').trim();
    if (email.isEmpty) return 'Please enter your email address';
    if (!isValid(email)) return 'Please enter a valid email address';
    return null;
  }
}
