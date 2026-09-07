import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_image.dart';

import '../helpers/test_setup.dart';

/// The listing cards were built against bundled artwork and called
/// `Image.asset(event.imagePath)`. That path is a network URL for anything
/// from the API, and `Image.asset` cannot load one — so every real listing
/// fell straight through to the card's own placeholder. That is what "no
/// images in any section" was: not a broken URL, a loader that never tried.
void main() {
  /// The provider under the ResizeImage wrapper that `cacheWidth` adds — the
  /// decode cap that keeps a 4000px cover from costing tens of MB of RAM.
  ImageProvider unwrap(ImageProvider p) =>
      p is ResizeImage ? p.imageProvider : p;

  group('listingImageSource', () {
    testWidgets('TC_C_LIS_001 — a network URL becomes a network image',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: listingImageSource('https://example.com/cover.png'),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(unwrap(image.image), isA<NetworkImage>());
    });

    testWidgets('TC_C_LIS_002 — an http URL is upgraded, not left cleartext',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: listingImageSource('http://example.com/cover.png')),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect((unwrap(image.image) as NetworkImage).url,
          startsWith('https://'));
    });

    testWidgets('TC_C_LIS_003 — a bundled asset still loads as an asset',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: listingImageSource('assets/images/x.png')),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(unwrap(image.image), isA<AssetImage>());
    });

    testWidgets('TC_C_LIS_004 — the caller keeps its own error placeholder',
        (tester) async {
      // Each card styles its own fallback; routing must not swallow it.
      await pumpTLBApp(
        tester,
        Scaffold(
          body: listingImageSource(
            'https://example.invalid/nope.png',
            errorBuilder: (_, __, ___) => const Text('card fallback'),
          ),
        ),
      );
      await tester.pump();
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);
    });
  });

  group('Every listing card can show a network cover', () {
    // Each of these draws EventModel.imagePath, which is a URL for API data.
    const cards = <String>[
      'build_skill_card',
      'class_nearby_card',
      'event_card',
      'event_card_with_price',
      'event_card_with_rating',
      'featured_event_card',
      'holiday_special_card',
      'new_on_tlb_card',
      'online_event_card',
      'partner_portrait_card',
      'special_focus_card',
      'spotlight_banner',
      'trending_card',
      'trending_event_card',
      'weekend_event_card',
    ];

    for (final card in cards) {
      test('$card does not load a listing cover with Image.asset', () {
        final src = File('lib/widgets/$card.dart').readAsStringSync();
        expect(
          RegExp(r'Image\.asset\(\s*(?:event|e)\.imagePath').hasMatch(src),
          isFalse,
          reason: '$card cannot show an API cover',
        );
        expect(src, contains('listingImageSource('), reason: card);
      });
    }
  });
}
