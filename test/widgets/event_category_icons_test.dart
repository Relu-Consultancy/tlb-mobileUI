import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/widgets/category_icon_card.dart';

/// The Events category artwork was replaced with the neon tile set — each icon
/// is now a dark rounded square carrying its own glyph, cut from the supplied
/// sheet. Because the tile is its own backdrop, the Events cards no longer
/// draw a pastel disc behind it.
void main() {
  group('Event category artwork', () {
    test('TC_A_ECI_001 — every category points at an icon that exists', () {
      // allCategories is the full set (the popup and the category screen's
      // row); exploreCategories is the first six, shown in the grid.
      expect(DummyData.allCategories, hasLength(10));
      expect(DummyData.exploreCategories, hasLength(6));
      for (final c in DummyData.allCategories) {
        final path = c['icon'] as String;
        expect(path, startsWith('assets/images/event_categories/'),
            reason: c['label'] as String);
        expect(File(path).existsSync(), isTrue,
            reason: '${c['label']} -> $path is missing');
      }
    });

    test('TC_A_ECI_002 — the ten icons are the ten shipped files', () {
      final referenced = DummyData.allCategories
          .map((c) => (c['icon'] as String).split('/').last)
          .toSet();
      final onDisk = Directory('assets/images/event_categories')
          .listSync()
          .whereType<File>()
          // uri.pathSegments avoids caring which slash the platform uses.
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.png'))
          .toSet();

      // No orphan asset shipped, and nothing referenced that isn't there.
      expect(referenced, onDisk);

      // The grid's six are the first six of the full set, so both surfaces
      // show the same artwork for the same category.
      expect(
        DummyData.exploreCategories.map((c) => c['icon']).toList(),
        DummyData.allCategories.take(6).map((c) => c['icon']).toList(),
      );
    });

    test('TC_A_ECI_003 — each icon is a square PNG with alpha corners', () {
      // The tiles are rounded, so the corners must be transparent — a square
      // opaque asset would show hard edges over the card's tint.
      for (final c in DummyData.allCategories) {
        final bytes = File(c['icon'] as String).readAsBytesSync();
        expect(bytes.length, greaterThan(1000), reason: c['label'] as String);
        // PNG signature, then IHDR: width, height, bit depth, colour type.
        expect(bytes.sublist(1, 4), [0x50, 0x4E, 0x47]);
        int be32(int o) => (bytes[o] << 24) | (bytes[o + 1] << 16) |
            (bytes[o + 2] << 8) | bytes[o + 3];
        expect(be32(16), be32(20), reason: '${c['label']} is not square');
        expect(be32(16), 384, reason: '${c['label']} is not 384px');
        // Colour type 6 = truecolour with alpha.
        expect(bytes[25], 6, reason: '${c['label']} has no alpha channel');
      }
    });

    test('TC_A_ECI_004 — the Events cards draw no disc behind the tile', () {
      // The tile is a dark rounded square; a pastel circle behind it would
      // show at the corners.
      expect(CategoryCardMetrics.events.hasCircle, isFalse);
      // The card's pastel tint still comes from circleColor, so every
      // category must keep one.
      for (final c in DummyData.allCategories) {
        expect(c['circleColor'], isNotNull, reason: c['label'] as String);
      }
    });
  });
}
