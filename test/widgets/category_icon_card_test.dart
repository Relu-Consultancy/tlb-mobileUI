import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/widgets/all_categories_popup.dart';
import 'package:tlb_mobile_ui/widgets/category_icon_card.dart';
import 'package:tlb_mobile_ui/widgets/explore_categories_grid.dart';

import '../helpers/test_setup.dart';

void main() {
  group('CategoryIconCard Tests', () {
    // Every band in the card is a fraction of its box, so the host has to give
    // it the preset's own aspect ratio for those bands to land as designed.
    const double cardW = 110;
    final double cardH = cardW / CategoryCardMetrics.events.aspectRatio; // ~189

    Widget host(Widget child) => Center(
          child: SizedBox(width: cardW, height: cardH, child: child),
        );

    const sample = CategoryIconCard(
      label: 'Mind & Strategy Games',
      iconAsset: 'assets/images/event_categories/mind_strategy_games.png',
      circleColor: Color(0xFFF2EAFD),
    );

    testWidgets('TC_W_CIC_001 — renders the label and the glyph asset',
        (tester) async {
      await pumpTLBApp(tester, host(sample));

      expect(find.text('Mind & Strategy Games'), findsOneWidget);

      final img = tester.widget<Image>(find.byType(Image));
      expect(
        (img.image as AssetImage).assetName,
        'assets/images/event_categories/mind_strategy_games.png',
      );
    });

    testWidgets('TC_W_CIC_002 — circle matches the preset icon band',
        (tester) async {
      await pumpTLBApp(tester, host(sample));

      // The circle is the SizedBox directly wrapping the glyph image.
      final circle = tester.getSize(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(SizedBox),
        ).first,
      );

      const m = CategoryCardMetrics.events;
      expect(circle.width, closeTo(cardH * m.iconBox, 0.5));
      expect(circle.height, closeTo(cardH * m.iconBox, 0.5));
      // Cross-check via the other expression of the same band: as a share of
      // the card's width it is iconBox / aspectRatio (~72%).
      expect(circle.width, closeTo(cardW * (m.iconBox / m.aspectRatio), 1.0));
    });

    testWidgets('TC_W_CIC_004 — label inset stays at 4% of card width',
        (tester) async {
      // Regression guard. At a 7% inset the longest label ("Mind & Strategy
      // Games") needs 96.6pt for its first line but only gets 94.3pt on a
      // 393pt screen, so it spills to a third line and the last word is
      // ellipsised away. Verified against the bundled Poppins Medium — the
      // widget-test font is uniform-width, so it cannot re-check that here.
      await pumpTLBApp(tester, host(sample));

      final pad = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Mind & Strategy Games'),
          matching: find.byType(Padding),
        ).first,
      );
      final inset = (pad.padding as EdgeInsets).left;

      expect(inset, closeTo(cardW * 0.04, 0.01));
    });

    testWidgets('TC_W_CIC_005 — card carries a gradient wash, not a flat fill',
        (tester) async {
      await pumpTLBApp(tester, host(sample));

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(CategoryIconCard),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final deco = box.decoration as BoxDecoration;
      final gradient = deco.gradient as LinearGradient;

      // Top stays near-white; the bottom is a deeper tone of the circle hue.
      expect(gradient.colors.first, const Color(0xFFFEFEFE));
      expect(gradient.colors.last, isNot(const Color(0xFFF2EAFD)));
      expect(
        HSLColor.fromColor(gradient.colors.last).lightness,
        lessThan(HSLColor.fromColor(const Color(0xFFF2EAFD)).lightness),
      );
      // A gradient and a flat colour are mutually exclusive in BoxDecoration.
      expect(deco.color, isNull);
    });

    testWidgets('TC_W_CIC_006 — selected draws an accent border and glow',
        (tester) async {
      BoxDecoration decoOf(WidgetTester t) => t
          .widget<DecoratedBox>(find.descendant(
            of: find.byType(CategoryIconCard),
            matching: find.byType(DecoratedBox),
          ).first)
          .decoration as BoxDecoration;

      await pumpTLBApp(tester, host(sample));
      final unselected = decoOf(tester);
      expect(unselected.boxShadow, isNull);
      expect(unselected.border!.top.width, 1);

      await pumpTLBApp(
        tester,
        host(const CategoryIconCard(
          label: 'Mind & Strategy Games',
          iconAsset: 'assets/images/event_categories/mind_strategy_games.png',
          circleColor: Color(0xFFF2EAFD),
          selected: true,
        )),
      );
      final selected = decoOf(tester);
      expect(selected.boxShadow, isNotNull);
      expect(selected.border!.top.width, 2);
      // Accent is a deeper tone of the category's own hue, not a generic grey.
      expect(selected.border!.top.color, isNot(const Color(0xFFF0F0F0)));
    });

    testWidgets('TC_W_CIC_007 — labelFontSize is honoured', (tester) async {
      // Sizes flow through Responsive.sp, so they scale with the viewport —
      // compare the two variants rather than asserting absolute points.
      Future<double> sizeFor(double? labelFontSize) async {
        await pumpTLBApp(
          tester,
          host(labelFontSize == null
              ? const CategoryIconCard(
                  label: 'Arts & Crafts',
                  iconAsset: 'assets/images/event_categories/arts_crafts.png',
                  circleColor: Color(0xFFF4EFFD),
                )
              : CategoryIconCard(
                  label: 'Arts & Crafts',
                  iconAsset: 'assets/images/event_categories/arts_crafts.png',
                  circleColor: const Color(0xFFF4EFFD),
                  labelFontSize: labelFontSize,
                )),
        );
        return tester.widget<Text>(find.text('Arts & Crafts')).style!.fontSize!;
      }

      final defaultSize = await sizeFor(null); // 12
      final chipSize = await sizeFor(9.5); // category-screen chips

      expect(chipSize, lessThan(defaultSize));
      expect(chipSize / defaultSize, closeTo(9.5 / 12, 0.02));
    });

    testWidgets('TC_W_CIC_008 — fromCategory tolerates missing icon/colour',
        (tester) async {
      // CategoryEventsScreen takes an arbitrary category list; one without the
      // new keys used to crash on `as String`. It must degrade to a placeholder.
      await pumpTLBApp(
        tester,
        host(CategoryIconCard.fromCategory(const {'label': 'Legacy Category'})),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Legacy Category'), findsOneWidget);
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('TC_W_CIC_003 — a two-line label still fits its band',
        (tester) async {
      await pumpTLBApp(tester, host(sample));

      final textSize = tester.getSize(find.text('Mind & Strategy Games'));
      // Whatever is left under the circle once the preset's bands are taken.
      const m = CategoryCardMetrics.events;
      final band = cardH * (1 - m.topPad - m.iconBox - m.gap);

      expect(textSize.height, lessThanOrEqualTo(band));
      // It really is wrapping to two lines (not being ellipsised on one).
      expect(textSize.height, greaterThan(20));
    });
  });

  group('Classes line-icon variant', () {
    testWidgets('TC_W_CLS_001 — classes metrics draw no circle behind the glyph',
        (tester) async {
      // The Classes mock puts bare coloured glyphs on the card; only Events
      // uses a pastel disc.
      final h = 110 / CategoryCardMetrics.classes.aspectRatio;
      await pumpTLBApp(
        tester,
        Center(
          child: SizedBox(
            width: 110,
            height: h,
            child: const CategoryIconCard(
              label: 'Academic',
              iconAsset: 'assets/images/class_categories/academic.png',
              circleColor: Color(0xFFEEF3F8),
              metrics: CategoryCardMetrics.classes,
            ),
          ),
        ),
      );

      final iconBox = tester.widget<DecoratedBox>(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final deco = iconBox.decoration as BoxDecoration;
      expect(deco.shape, BoxShape.rectangle);
      expect(deco.color, isNull);
    });

    testWidgets('TC_W_CLS_002 — events metrics still draw the circle',
        (tester) async {
      final h = 110 / CategoryCardMetrics.events.aspectRatio;
      await pumpTLBApp(
        tester,
        Center(
          child: SizedBox(
            width: 110,
            height: h,
            child: const CategoryIconCard(
              label: 'Arts & Crafts',
              iconAsset: 'assets/images/event_categories/arts_crafts.png',
              circleColor: Color(0xFFF4EFFD),
            ),
          ),
        ),
      );

      final iconBox = tester.widget<DecoratedBox>(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final deco = iconBox.decoration as BoxDecoration;
      expect(deco.shape, BoxShape.circle);
      expect(deco.color, const Color(0xFFF4EFFD));
    });

    testWidgets('TC_W_CLS_003 — both classes lists carry icon + tint',
        (tester) async {
      for (final list in [
        DummyData.classesCategories,
        DummyData.classesSeeAllCategories,
      ]) {
        expect(list.length, 11);
        for (final c in list) {
          expect(
            (c['icon'] as String?)
                ?.startsWith('assets/images/class_categories/'),
            isTrue,
            reason: 'icon missing/wrong for ${c['label']}',
          );
          expect(c['circleColor'], isA<Color>(),
              reason: 'circleColor missing for ${c['label']}');
        }
      }
    });

    testWidgets('TC_W_CLS_004 — classes popup renders icon cards',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: AllCategoriesPopup(
            categories: DummyData.classesSeeAllCategories,
            lineIcons: true,
            cardMetrics: CategoryCardMetrics.classes,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryIconCard), findsWidgets);
      expect(find.text('Academic'), findsOneWidget);
      expect(find.text('Creative Arts'), findsOneWidget);
    });

    testWidgets('TC_W_CLS_005 — classes grid pins the 0.50 aspect ratio',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: DummyData.classesCategories,
            scrollable: true,
            lineIcons: true,
            cardMetrics: CategoryCardMetrics.classes,
            childAspectRatio: 0.9, // wrong on purpose; must be ignored
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(CategoryIconCard).first);
      expect(size.width / size.height,
          closeTo(CategoryCardMetrics.classes.aspectRatio, 0.005));
    });
  });

  group('Card metrics — shared geometry', () {
    testWidgets('TC_W_MET_002 — all three sections use the same card box',
        (tester) async {
      // The mocks each drew a different card, which read as mismatched between
      // sections. They share one box now; only the circle and label alignment
      // differ.
      const e = CategoryCardMetrics.events;
      for (final m in [
        CategoryCardMetrics.classes,
        CategoryCardMetrics.programs,
      ]) {
        expect(m.aspectRatio, e.aspectRatio);
        expect(m.topPad, e.topPad);
        expect(m.iconBox, e.iconBox);
        expect(m.gap, e.gap);
      }
      // The intended differences survive.
      expect(CategoryCardMetrics.events.hasCircle, isTrue);
      expect(CategoryCardMetrics.classes.hasCircle, isFalse);
      expect(CategoryCardMetrics.programs.hasCircle, isFalse);
      expect(CategoryCardMetrics.programs.labelCentered, isTrue);
    });

    testWidgets('TC_W_MET_003 — a rendered card matches across sections',
        (tester) async {
      Future<Size> sizeFor(CategoryCardMetrics m, String icon) async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: ExploreCategoriesGrid(
              categories: [
                {
                  'label': 'Sample',
                  'icon': icon,
                  'circleColor': const Color(0xFFEEEEEE),
                }
              ],
              scrollable: true,
              lineIcons: true,
              cardMetrics: m,
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.getSize(find.byType(CategoryIconCard).first);
      }

      final ev = await sizeFor(CategoryCardMetrics.events,
          'assets/images/event_categories/arts_crafts.png');
      final cl = await sizeFor(CategoryCardMetrics.classes,
          'assets/images/class_categories/academic.png');
      final pr = await sizeFor(CategoryCardMetrics.programs,
          'assets/images/program_categories/future_tech_ai.png');

      expect(cl.width, closeTo(ev.width, 0.5));
      expect(cl.height, closeTo(ev.height, 0.5));
      expect(pr.width, closeTo(ev.width, 0.5));
      expect(pr.height, closeTo(ev.height, 0.5));
    });
  });

  group('Card metrics — height budget', () {
    testWidgets('TC_W_MET_001 — every preset leaves room for a 2-line label',
        (tester) async {
      // The cards were shortened on request. Because the bands are fractions of
      // height, trimming eats into the label band — this guards that each
      // preset still clears two lines at the size that section renders with.
      const cardW = 109.7; // popup / in-page grid card at a 393pt screen
      const specs = <String, List<double>>{
        // preset -> [label font size used by that section]
        'events': [12],
        'classes': [12],
        'programs': [11],
      };
      const presets = <String, CategoryCardMetrics>{
        'events': CategoryCardMetrics.events,
        'classes': CategoryCardMetrics.classes,
        'programs': CategoryCardMetrics.programs,
      };

      specs.forEach((name, sizes) {
        final m = presets[name]!;
        final h = cardW / m.aspectRatio;
        final band = h * (1 - m.topPad - m.iconBox - m.gap);
        final needed = 2 * sizes.first * 1.15; // two lines at height: 1.15
        expect(
          band,
          greaterThan(needed),
          reason: '$name label band ${band.toStringAsFixed(1)}pt cannot hold '
              'two ${sizes.first}sp lines (${needed.toStringAsFixed(1)}pt)',
        );
      });
    });
  });

  group('Programs line-icon variant', () {
    testWidgets('TC_W_PRG_001 — both programs lists carry icon + tint',
        (tester) async {
      for (final list in [
        DummyData.programsCategories,
        DummyData.programsSeeAllCategories,
      ]) {
        expect(list.length, 11);
        for (final c in list) {
          expect(
            (c['icon'] as String?)
                ?.startsWith('assets/images/program_categories/'),
            isTrue,
            reason: 'icon missing/wrong for ${c['label']}',
          );
          expect(c['circleColor'], isA<Color>(),
              reason: 'circleColor missing for ${c['label']}');
        }
      }
    });

    testWidgets('TC_W_PRG_002 — programs metrics centre the label',
        (tester) async {
      // Programs is the only mock that centres its label in the band below the
      // glyph; Events and Classes top-align.
      expect(CategoryCardMetrics.programs.labelCentered, isTrue);
      expect(CategoryCardMetrics.events.labelCentered, isFalse);
      expect(CategoryCardMetrics.classes.labelCentered, isFalse);

      final h = 110 / CategoryCardMetrics.programs.aspectRatio;
      await pumpTLBApp(
        tester,
        Center(
          child: SizedBox(
            width: 110,
            height: h,
            child: const CategoryIconCard(
              label: 'Future Tech & AI',
              iconAsset: 'assets/images/program_categories/future_tech_ai.png',
              circleColor: Color(0xFFEFF6FC),
              metrics: CategoryCardMetrics.programs,
              labelFontSize: 11,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(
        find.ancestor(
          of: find.text('Future Tech & AI'),
          matching: find.byType(Align),
        ).first,
      );
      expect(align.alignment, Alignment.center);
    });

    testWidgets('TC_W_PRG_003 — events/classes keep their labels top-aligned',
        (tester) async {
      final h = 110 / CategoryCardMetrics.events.aspectRatio;
      await pumpTLBApp(
        tester,
        Center(
          child: SizedBox(
            width: 110,
            height: h,
            child: const CategoryIconCard(
              label: 'Arts & Crafts',
              iconAsset: 'assets/images/event_categories/arts_crafts.png',
              circleColor: Color(0xFFF4EFFD),
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(
        find.ancestor(
          of: find.text('Arts & Crafts'),
          matching: find.byType(Align),
        ).first,
      );
      expect(align.alignment, Alignment.topCenter);
    });

    testWidgets('TC_W_PRG_004 — programs grid pins the 0.97 aspect ratio',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: DummyData.programsCategories,
            scrollable: true,
            lineIcons: true,
            cardMetrics: CategoryCardMetrics.programs,
            lineIconLabelSize: 11,
            childAspectRatio: 0.6, // wrong on purpose; must be ignored
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(CategoryIconCard).first);
      expect(size.width / size.height,
          closeTo(CategoryCardMetrics.programs.aspectRatio, 0.005));
    });

    testWidgets('TC_W_PRG_005 — see-all label matches the mock abbreviation',
        (tester) async {
      // "Grooming & Personality Development" is the one label that cannot fit
      // two lines at any readable size; the mock abbreviates it. This list is
      // display-only — taps map by index into programsCategories.
      final labels = DummyData.programsSeeAllCategories
          .map((c) => c['label'] as String)
          .toList();
      expect(labels, contains('Grooming & Personality Dev.'));
      expect(labels, isNot(contains('Grooming & Personality Development')));
    });
  });

  group('AllCategoriesPopup — Events line-icon variant', () {
    testWidgets('TC_W_ACP_001 — renders all 10 categories as icon cards',
        (tester) async {
      await pumpTLBApp(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: AllCategoriesPopup(
              categories: DummyData.allCategories,
              lineIcons: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(DummyData.allCategories.length, 10);
      // The grid is lazy, so only the on-screen cards are built — but they must
      // all be the new card type, never the gradient one.
      expect(find.byType(CategoryIconCard), findsWidgets);
      expect(find.text('Arts & Crafts'), findsOneWidget);
      expect(find.text('STEM & Innovation'), findsOneWidget);
    });

    testWidgets('TC_W_ACP_002 — every category carries an icon and circleColor',
        (tester) async {
      for (final c in DummyData.allCategories) {
        expect(c['icon'], isA<String>(), reason: 'icon missing for ${c['label']}');
        expect(
          (c['icon'] as String).startsWith('assets/images/event_categories/'),
          isTrue,
          reason: 'unexpected icon path for ${c['label']}',
        );
        expect(c['circleColor'], isA<Color>(),
            reason: 'circleColor missing for ${c['label']}');
      }
    });

    testWidgets('TC_W_ACP_005 — tapping a card pops the sheet and reports index',
        (tester) async {
      // The Events screen turns this callback into a push to
      // CategoryEventsScreen, so the index must survive the sheet closing.
      final taps = <int>[];
      await pumpTLBApp(
        tester,
        Scaffold(
          body: AllCategoriesPopup(
            categories: DummyData.allCategories,
            lineIcons: true,
            onCategoryTap: taps.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Performing Arts'));
      await tester.pumpAndSettle();

      // Index 1 == Performing Arts in DummyData.allCategories.
      expect(taps, [1]);
    });

    testWidgets('TC_W_ACP_006 — popup data satisfies CategoryEventsScreen',
        (tester) async {
      // That screen hard-casts `label` and `gradient`, and filters events by
      // label rather than slug — so the popup's list must carry both.
      for (final c in DummyData.allCategories) {
        expect(c['label'], isA<String>());
        expect(c['gradient'], isA<List<Color>>());
      }
    });

    testWidgets('TC_W_ACP_003 — gradient variant is untouched by default',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: AllCategoriesPopup(categories: DummyData.allCategories),
        ),
      );
      await tester.pumpAndSettle();

      // Classes / Programs / Venues still get the original gradient cards.
      expect(find.byType(CategoryIconCard), findsNothing);
    });
  });

  group('ExploreCategoriesGrid — Events in-page line-icon variant', () {
    testWidgets('TC_W_ECG_001 — renders the in-page grid as icon cards',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          backgroundColor: Colors.black,
          body: ExploreCategoriesGrid(
            categories: DummyData.exploreCategories,
            scrollable: true,
            lineIcons: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The scrollable variant shows a fixed 2 rows = 6 cards.
      expect(find.byType(CategoryIconCard), findsNWidgets(6));
      expect(find.text('Arts & Crafts'), findsOneWidget);
    });

    testWidgets('TC_W_ECG_002 — pins the card aspect ratio in line-icon mode',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: DummyData.exploreCategories,
            scrollable: true,
            lineIcons: true,
            // Deliberately wrong for this card — the grid must ignore it, since
            // CategoryIconCard's bands are fractions of the 0.581 box.
            childAspectRatio: 0.8,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(CategoryIconCard).first);
      expect(size.width / size.height,
          closeTo(CategoryCardMetrics.events.aspectRatio, 0.005));
    });

    testWidgets('TC_W_ECG_003 — gradient variant is untouched by default',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: DummyData.exploreCategories,
            scrollable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Classes / Programs keep the gradient artwork cards.
      expect(find.byType(CategoryIconCard), findsNothing);
    });

    testWidgets('TC_W_ECG_004 — every in-page category carries icon + colour',
        (tester) async {
      for (final c in DummyData.exploreCategories) {
        expect(c['icon'], isA<String>(),
            reason: 'icon missing for ${c['label']}');
        expect(c['circleColor'], isA<Color>(),
            reason: 'circleColor missing for ${c['label']}');
      }
    });
  });
}
