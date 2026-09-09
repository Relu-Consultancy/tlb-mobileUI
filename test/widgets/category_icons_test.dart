import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/widgets/category_icon_card.dart';

/// The Events, Classes and Programs category artwork was replaced with the
/// neon tile set — each icon is now a dark rounded square carrying its own
/// glyph, cut from the supplied sheets. Because the tile is its own backdrop,
/// no card draws a pastel disc behind it.
void main() {
  /// screen list name -> (categories, asset directory, expected count)
  final sets = <String, (List<Map<String, dynamic>>, String, int)>{
    'events': (DummyData.allCategories, 'assets/images/event_categories', 10),
    'classes': (
      DummyData.classesSeeAllCategories,
      'assets/images/class_categories',
      11
    ),
    'programs': (
      DummyData.programsSeeAllCategories,
      'assets/images/program_categories',
      11
    ),
  };

  group('Category artwork', () {
    sets.forEach((name, spec) {
      final (categories, dir, count) = spec;

      test('TC_A_CAT_${name}_001 — every category points at a real icon', () {
        expect(categories, hasLength(count));
        for (final c in categories) {
          final path = c['icon'] as String;
          expect(path, startsWith('$dir/'), reason: c['label'] as String);
          expect(File(path).existsSync(), isTrue,
              reason: '${c['label']} -> $path is missing');
        }
      });

      test('TC_A_CAT_${name}_002 — no orphan asset, nothing referenced twice',
          () {
        final referenced =
            categories.map((c) => (c['icon'] as String).split('/').last).toSet();
        final onDisk = Directory(dir)
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((n) => n.endsWith('.png'))
            .toSet();
        expect(referenced, onDisk);
        expect(referenced, hasLength(count));
      });

      test('TC_A_CAT_${name}_003 — each icon is a 384px square with alpha', () {
        for (final c in categories) {
          final bytes = File(c['icon'] as String).readAsBytesSync();
          expect(bytes.sublist(1, 4), [0x50, 0x4E, 0x47]);
          int be32(int o) => (bytes[o] << 24) | (bytes[o + 1] << 16) |
              (bytes[o + 2] << 8) | bytes[o + 3];
          expect(be32(16), be32(20), reason: '${c['label']} is not square');
          expect(be32(16), 384, reason: '${c['label']} is not 384px');
          expect(bytes[25], 6, reason: '${c['label']} has no alpha channel');
        }
      });

      test('TC_A_CAT_${name}_004 — the cards keep their pastel tint', () {
        // The tint comes from circleColor through the bottom gradient, not
        // from a disc, so every category still needs one.
        for (final c in categories) {
          expect(c['circleColor'], isNotNull, reason: c['label'] as String);
        }
      });
    });

    test('TC_A_CAT_005 — no section draws a disc behind the tile', () {
      // The tiles are dark rounded squares; a pastel circle would show at
      // the corners.
      expect(CategoryCardMetrics.events.hasCircle, isFalse);
      expect(CategoryCardMetrics.classes.hasCircle, isFalse);
      expect(CategoryCardMetrics.programs.hasCircle, isFalse);
    });
  });

  group('The grid and the popup show the same artwork', () {
    test('TC_A_CAT_006 — Events grid is the first six of the full set', () {
      // exploreCategories is the six shown in the grid; allCategories is the
      // full set behind View All and the category screen's row.
      expect(DummyData.exploreCategories, hasLength(6));
      expect(
        DummyData.exploreCategories.map((c) => c['icon']).toList(),
        DummyData.allCategories.take(6).map((c) => c['icon']).toList(),
      );
    });

    test('TC_A_CAT_007 — Classes grid and See All share every icon', () {
      expect(
        DummyData.classesCategories.map((c) => c['icon']).toSet(),
        DummyData.classesSeeAllCategories.map((c) => c['icon']).toSet(),
      );
    });

    test('TC_A_CAT_008 — Programs grid and See All share every icon', () {
      expect(
        DummyData.programsCategories.map((c) => c['icon']).toSet(),
        DummyData.programsSeeAllCategories.map((c) => c['icon']).toSet(),
      );
    });
  });
}
