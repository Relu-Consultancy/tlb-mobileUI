import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for a bug that shipped silently: the program and venue
/// enquiry calls used the wrong URL path (a partner-only route that public
/// customers can't reach) and, separately, the wrong request-body field name
/// for the contact — so even a corrected URL would have 404'd, or the
/// request would have gone through with the phone number simply missing.
///
/// Verified against a live fetch of the API's published schema on 2026-08-24
/// (GET /api/schema/):
///   POST /listings/classes/{id}/enquiries/   ClassEnquiryCreateRequest  {..., mobile, ...}
///   POST /listings/programs/{id}/enquire/    EnquiryCreateRequest      {..., contact_number, ...}
///   POST /listings/venues/{id}/enquiry/      VenueEnquiryCreateRequest {name, mobile, ...}
///
/// The services in this codebase call http.post directly with no injectable
/// client (see auth_service_test.dart's note on this), so a real network mock
/// isn't available without a source refactor. This checks the literal path
/// and field-name strings in source instead — a static guard against the
/// exact mistake that shipped: a typo'd or reverted endpoint/field literal.
void main() {
  String read(String relativePath) =>
      File(relativePath).readAsStringSync();

  group('Enquiry endpoint paths', () {
    test('classes posts to the plural /enquiries/ route (this one is correct)', () {
      final src = read('lib/services/classes_listing_service.dart');
      expect(
        src,
        contains("/api/v1/listings/classes/\$listingId/enquiries/"),
      );
    });

    test('programs posts to the singular verb /enquire/ route, not /enquiries/', () {
      final src = read('lib/services/programs_listing_service.dart');
      expect(
        src,
        contains("/api/v1/listings/programs/\$listingId/enquire/"),
        reason: '/enquiries/ (plural) is a partner-only route and 404s '
            'for a customer',
      );
      expect(src, isNot(contains("programs/\$listingId/enquiries/")));
    });

    test('venues posts to the singular noun /enquiry/ route, not /enquiries/', () {
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
    test('programs sends contact_number, not mobile', () {
      final src = read('lib/services/programs_listing_service.dart');
      expect(src, contains("'contact_number': mobile"));
      expect(
        src,
        isNot(contains("'mobile': mobile")),
        reason: 'the programs enquiry schema has no `mobile` field — '
            'sending it silently drops the phone number',
      );
    });

    test('venues sends name, not student_name, for the required contact name', () {
      final src = read('lib/services/events_listing_service.dart');
      // Scope the check to submitVenueEnquiry's body construction, not the
      // whole file (other methods in this file legitimately use student_name
      // for event bookings, which is a different schema).
      final start = src.indexOf('submitVenueEnquiry');
      final body = src.substring(start, start + 1200);
      expect(body, contains("'name': studentName"));
      expect(
        body,
        isNot(contains("'student_name': studentName")),
        reason: 'the venue enquiry schema requires `name`, not '
            '`student_name` — the wrong key means a required field is '
            'missing entirely and the request is rejected',
      );
    });

    test('classes keeps sending mobile (this field name is correct)', () {
      final src = read('lib/services/classes_listing_service.dart');
      expect(src, contains("'mobile': mobile"));
    });
  });
}
