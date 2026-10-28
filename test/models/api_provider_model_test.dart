import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_provider_model.dart';

/// The payload shape documented for GET /listings/{listing_id}/provider/.
Map<String, dynamic> _payload({
  Object? followerCount = 128,
  Map<String, dynamic>? socialLinks,
  Object? isFollowing = true,
}) =>
    {
      'id': '1b98e204-b813-4c1c-87ce-15ccc2667a3a',
      'name': 'Funtime Academy',
      'bio': 'We teach kids to code.',
      'logo_url': 'https://example.com/logo.png',
      'total_listings': 6,
      'average_rating': 4.5,
      'total_reviews': 32,
      'experience_years': 2,
      'follower_count': ?followerCount,
      'social_links': socialLinks ??
          {
            'instagram': 'https://instagram.com/funtime',
            'facebook': 'https://facebook.com/funtime',
            'website': 'https://funtime.example.com',
          },
      'is_following': ?isFollowing,
    };

void main() {
  group('ApiProvider — follower count', () {
    test('TC_M_AP_001 — reads follower_count', () {
      expect(ApiProvider.fromJson(_payload()).totalFollowers, 128);
    });

    // Null, not zero. A confident "0 Followers" beside a "Following" button
    // reads as a broken app; nothing at all reads as a field not yet sent.
    test('TC_M_AP_002 — an absent count is unknown, not zero', () {
      final p = ApiProvider.fromJson(_payload(followerCount: null));
      expect(p.totalFollowers, isNull);
    });

    test('TC_M_AP_003 — a real zero is kept as zero', () {
      expect(ApiProvider.fromJson(_payload(followerCount: 0)).totalFollowers, 0);
    });
  });

  group('ApiProvider — social links', () {
    test('TC_M_AP_004 — reads the nested social_links object', () {
      final p = ApiProvider.fromJson(_payload());
      expect(p.instagramUrl, 'https://instagram.com/funtime');
      expect(p.facebookUrl, 'https://facebook.com/funtime');
      expect(p.websiteUrl, 'https://funtime.example.com');
    });

    // The API writes an unset link as "" — never null, never a missing key.
    // Left as-is it would reach the UI as a link that goes nowhere.
    test('TC_M_AP_005 — an empty string is normalised to null', () {
      final p = ApiProvider.fromJson(_payload(socialLinks: {
        'instagram': '',
        'facebook': '   ',
        'linkedin': 'https://linkedin.com/company/funtime',
        'website': '',
      }));
      expect(p.instagramUrl, isNull);
      expect(p.facebookUrl, isNull);
      expect(p.websiteUrl, isNull);
      expect(p.linkedinUrl, 'https://linkedin.com/company/funtime');
    });

    test('TC_M_AP_006 — a link the partner has not set stays null', () {
      final p = ApiProvider.fromJson(_payload(socialLinks: {}));
      expect(p.instagramUrl, isNull);
      expect(p.facebookUrl, isNull);
      expect(p.linkedinUrl, isNull);
      expect(p.websiteUrl, isNull);
    });

    test('TC_M_AP_007 — a flat instagram_url is still read', () {
      final json = _payload(socialLinks: {})
        ..['instagram_url'] = 'https://instagram.com/flat';
      expect(ApiProvider.fromJson(json).instagramUrl,
          'https://instagram.com/flat');
    });
  });

  group('ApiProvider — is_following', () {
    test('TC_M_AP_008 — reads is_following', () {
      expect(ApiProvider.fromJson(_payload()).isFollowing, isTrue);
      expect(ApiProvider.fromJson(_payload(isFollowing: false)).isFollowing,
          isFalse);
    });

    test('TC_M_AP_009 — an absent is_following is false', () {
      expect(
          ApiProvider.fromJson(_payload(isFollowing: null)).isFollowing, isFalse);
    });
  });

  group('ApiProvider — copyWith', () {
    test('TC_M_AP_010 — carries every other field through', () {
      final p = ApiProvider.fromJson(_payload());
      final bumped = p.copyWith(totalFollowers: 129, isFollowing: false);
      expect(bumped.totalFollowers, 129);
      expect(bumped.isFollowing, isFalse);
      expect(bumped.id, p.id);
      expect(bumped.name, p.name);
      expect(bumped.instagramUrl, p.instagramUrl);
      expect(bumped.websiteUrl, p.websiteUrl);
      expect(bumped.averageRating, p.averageRating);
      expect(bumped.experienceYears, p.experienceYears);
    });
  });
}
