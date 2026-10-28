import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_listing_terms.dart';

/// The API returns Terms & Conditions as a single `terms` object on every
/// listing type. Events, programs and venues carry no `cancellation_policy`
/// or `refund_policy` at all, so before this was parsed the Terms row could
/// never appear on those screens.
void main() {
  group('ApiListingTerms', () {
    test('parses the live payload shape', () {
      final t = ApiListingTerms.fromJson({
        'content': 'User above 12 allowed',
        'document_url': null,
        'updated_at': '2026-08-20T09:57:33.252948Z',
      });

      expect(t, isNotNull);
      expect(t!.content, 'User above 12 allowed');
      expect(t.documentUrl, isNull);
      expect(t.updatedAt, DateTime.parse('2026-08-20T09:57:33.252948Z'));
      expect(t.hasContent, isTrue);
    });

    test('is null when the listing has no terms', () {
      expect(ApiListingTerms.fromJson(null), isNull);
    });

    test('is null when the object carries nothing to show', () {
      // The partner created a terms record then cleared it.
      expect(
        ApiListingTerms.fromJson({
          'content': '',
          'document_url': null,
          'updated_at': '2026-08-20T09:57:33.252948Z',
        }),
        isNull,
      );
    });

    test('counts a document-only record as content', () {
      final t = ApiListingTerms.fromJson({
        'content': '',
        'document_url': 'https://example.com/terms.pdf',
        'updated_at': '2026-08-20T09:57:33.252948Z',
      });
      expect(t, isNotNull);
      expect(t!.hasContent, isTrue);
    });

    test('tolerates a bare string, and a blank one yields null', () {
      expect(ApiListingTerms.fromJson('Some terms')?.content, 'Some terms');
      expect(ApiListingTerms.fromJson('   '), isNull);
    });

    test('survives a malformed updated_at rather than throwing', () {
      final t = ApiListingTerms.fromJson({
        'content': 'Terms body',
        'document_url': null,
        'updated_at': 'not-a-date',
      });
      expect(t, isNotNull);
      expect(t!.updatedAt, isNull);
      expect(t.hasContent, isTrue);
    });
  });
}
