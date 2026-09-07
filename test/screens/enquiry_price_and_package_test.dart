import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// An enquiry listing quotes no price beside its button.
///
/// The figure shown there is the cheapest package's ("₹50000 onwards"), and
/// printing it next to "Send Enquiry" implies a rate the customer can just
/// book at — they cannot; they have to ask. The packages, with their real
/// prices, are listed inside the enquiry form instead, where picking one also
/// tells the partner what the enquiry is about.
///
/// These screens fetch their listing from the API on open, so they cannot be
/// reached in a widget test without a network mock (see auth_service_test's
/// note on the services having no injectable client). This guards the source.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('No price beside an enquiry CTA', () {
    test('venue detail hides the package price for an enquiry venue', () {
      final src = read('lib/screens/venue_detail_screen.dart');
      expect(src, contains('if (!_isEnquiry) ...['));
      expect(src, contains('bool get _isEnquiry => _detail?.isEnquiry == true;'));
    });

    test('program detail shows a price only for direct booking', () {
      final src = read('lib/screens/program_detail_screen.dart');
      expect(
        src,
        contains("if (_isDirectBooking && _priceDisplay != 'Price TBA')"),
      );
    });

    test('class detail already gated its price on direct booking', () {
      // Unchanged — recorded here so the three stay in step.
      final src = read('lib/screens/class_detail_screen.dart');
      expect(src, contains('final showPrice = isDirectBooking && price != null;'));
    });
  });

  group('The chosen package reaches the partner', () {
    final src = read('lib/widgets/enquire_now_sheet.dart');

    test('the venue submit sends the package-aware message', () {
      expect(src, contains('message: _messageForApi(),'));
    });

    test('the package is named at the top of the message', () {
      // The venue enquiry endpoint has no package field — its schema is
      // attendee_name, mobile, availability_slot_id, message — so this
      // prefix is the only channel the selection has today.
      expect(src, contains(r"'Package: ${_packageLabel(chosen)}\n\n$typed'"));
    });

    test('an unselected package leaves the message untouched', () {
      expect(src, contains('if (chosen == null) return typed;'));
    });

    test('the venue detail screen hands its packages to the sheet', () {
      final venue = read('lib/screens/venue_detail_screen.dart');
      expect(venue, contains('packages: _detail?.packages ?? const []'));
    });
  });
}
