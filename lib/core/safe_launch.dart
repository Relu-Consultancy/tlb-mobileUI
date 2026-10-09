import 'package:url_launcher/url_launcher.dart';

/// Opens [raw] in the external browser, but only if it is a plain web link.
///
/// Links come from the server (notification actions, partner social links,
/// media), so a bad or compromised record must not be able to fire `intent:`,
/// `file:`, `javascript:` or other app-specific schemes. Returns whether a
/// launch happened.
Future<bool> launchWebUrl(String? raw) async {
  final uri = Uri.tryParse((raw ?? '').trim());
  if (uri == null || !uri.hasAuthority) return false;
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
