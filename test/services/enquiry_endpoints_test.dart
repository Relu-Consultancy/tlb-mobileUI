import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for a bug that shipped silently: the program and venue
/// enquiry calls used the wrong URL path (a partner-only route that public
/// customers can't reach) and, separately, the wrong request-body field name
/// for the contact — so even a corrected URL would have 404'd, or the
/// request would have gone through with the phone number simply missing.
///
///   POST /listings/classes/{id}/enquiries/   {batch_id?, attendee_name, student_age, mobile, message}
///   POST /listings/programs/{id}/enquire/    {attendee_name, contact_number, student_age, message}
///   POST /listings/venues/{id}/enquiry/      {attendee_name, mobile, availability_slot_id?, message}
///
/// Field set per the backend's 2026-09-03 breaking change, which trimmed all
/// three endpoints to that minimal shape: the name key was renamed to
/// `attendee_name` everywhere (from `student_name` on classes and programs,
/// `name` on venues), and `parent_name`, `area`, `email` and the venue's
/// event-planning block (`guest_count`, `occasion`, `event_date`, `budget`,
/// `duration_hours`, `requirements`) were removed from the schema outright.
/// The three contact-field names still differ per type and are NOT
/// interchangeable.
///
/// The services in this codebase call http.post directly with no injectable
/// client (see auth_service_test.dart's note on this), so a real network mock
/// isn't available without a source refactor. This checks the literal path
/// and field-name strings in source instead — a static guard against the
/// exact mistake that shipped: a typo'd or reverted endpoint/field literal.
void main() {
  String read(String relativePath) => File(relativePath).readAsStringSync();

  /// Just the request body of one enquiry method.
  ///
  /// Every one of these files holds other methods that legitimately use the
  /// removed names — `area` as a listings query parameter, `student_name` for
  /// an event *booking*, which is a different schema — so a whole-file
  /// `isNot(contains(...))` would fail on code that is perfectly correct.
  String enquiryBody(String src, String methodName) {
    final start = src.indexOf('static Future<void> $methodName(');
    expect(start, isNot(-1), reason: '$methodName not found');
    final end = src.indexOf('final res = await http', start);
    expect(end, greaterThan(start), reason: '$methodName body not found');
    return src.substring(start, end);
  }

  group('Enquiry endpoint paths', () {
    test('classes posts to the plural /enquiries/ route (this one is correct)',
        () {
      final src = read('lib/services/classes_listing_service.dart');
      expect(
        src,
        contains("/api/v1/listings/classes/\$listingId/enquiries/"),
      );
    });

    test('programs posts to the singular verb /enquire/ route, not /enquiries/',
        () {
      final src = read('lib/services/programs_listing_service.dart');
      expect(
        src,
        contains("/api/v1/listings/programs/\$listingId/enquire/"),
        reason: '/enquiries/ (plural) is a partner-only route and 404s '
            'for a customer',
      );
      expect(src, isNot(contains("programs/\$listingId/enquiries/")));
    });

    test('venues posts to the singular noun /enquiry/ route, not /enquiries/',
        () {
      final src = read('lib/services/events_listing_service.dart');
      expect(
        src,
        contains("/api/v1/listings/venues/\$listingId/enquiry/"),
        reason: '/enquiries/ (plural) is a partner-only route and 404s '
            'for a customer',
      );
      expect(src, isNot(contains("venues/\$listingId/enquiries/")));
    });
  });

  group('Enquiry request-body field names', () {
    test('classes sends attendee_name and mobile', () {
      final body = enquiryBody(
          read('lib/services/classes_listing_service.dart'), 'submitEnquiry');
      expect(body, contains("'attendee_name': attendeeName"));
      expect(body, contains("'mobile': mobile"));
      expect(
        body,
        isNot(contains("'student_name'")),
        reason: 'renamed to attendee_name — the old key is no longer a field '
            'on this endpoint, so sending it loses the name entirely',
      );
    });

    test('programs sends contact_number, not mobile', () {
      final body = enquiryBody(
          read('lib/services/programs_listing_service.dart'), 'submitEnquiry');
      expect(body, contains("'attendee_name': attendeeName"));
      expect(body, contains("'contact_number': mobile"));
      expect(
        body,
        isNot(contains("'mobile': mobile")),
        reason: 'the programs enquiry schema has no `mobile` field — '
            'sending it silently drops the phone number',
      );
      expect(body, isNot(contains("'student_name'")));
    });

    test('venues sends attendee_name, not name, for the required contact name',
        () {
      final body = enquiryBody(read('lib/services/events_listing_service.dart'),
          'submitVenueEnquiry');
      expect(body, contains("'attendee_name': attendeeName"));
      expect(body, contains("'mobile': mobile"));
      expect(
        body,
        isNot(contains("'name': ")),
        reason: 'the venue enquiry schema now requires `attendee_name`; '
            '`name` was the pre-2026-09-03 key and is no longer a field, so '
            'the wrong key means a required field is missing entirely and '
            'the request is rejected',
      );
    });
  });

  // The 2026-09-03 trim removed these from the schema rather than merely
  // deprecating them. A client that still sends one is asking the customer to
  // fill in something the organiser will never receive.
  group('Enquiry bodies send no removed field', () {
    const gone = [
      'parent_name',
      'area',
      'email',
      'guest_count',
      'occasion',
      'event_date',
      'budget',
      'duration_hours',
      'requirements',
    ];

    const cases = {
      'classes': [
        'lib/services/classes_listing_service.dart',
        'submitEnquiry',
      ],
      'programs': [
        'lib/services/programs_listing_service.dart',
        'submitEnquiry',
      ],
      'venues': [
        'lib/services/events_listing_service.dart',
        'submitVenueEnquiry',
      ],
    };

    cases.forEach((type, target) {
      test(type, () {
        final body = enquiryBody(read(target[0]), target[1]);
        for (final field in gone) {
          expect(
            body,
            isNot(contains("'$field':")),
            reason: '`$field` was removed from the $type enquiry endpoint',
          );
        }
      });
    });

    test('programs sends no batch_id — that field is classes-only', () {
      final body = enquiryBody(
          read('lib/services/programs_listing_service.dart'), 'submitEnquiry');
      expect(body, isNot(contains("'batch_id'")));
    });
  });
}
