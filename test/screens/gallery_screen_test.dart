import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/gallery_screen.dart';

import '../helpers/test_setup.dart';

const _kMedia = [
  'http://tlb-api.reluconsultancy.in/media/events/media/weekendspl1.png',
  'http://tlb-api.reluconsultancy.in/media/events/media/weekendspl2.png',
  'http://tlb-api.reluconsultancy.in/media/events/media/weekendspl3.png',
];

EventModel _event({String cover = 'http://example.com/cover.png'}) =>
    EventModel(
      id: '1',
      title: 'Summer Arts Festival',
      venue: 'Mumbai',
      imagePath: cover,
    );

void main() {
  group('GalleryScreen Tests', () {
    testWidgets('TC_S_GAL_001 — shows the listing media it was handed',
        (tester) async {
      // It used to build its own list of bundled demo art, so "See All"
      // opened a different set of pictures from the strip that was tapped.
      await pumpTLBApp(
        tester,
        GalleryScreen(event: _event(), images: _kMedia),
      );
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('TC_S_GAL_002 — no demo art leaks in', (tester) async {
      await pumpTLBApp(
        tester,
        GalleryScreen(event: _event(), images: _kMedia),
      );
      final assets = tester
          .widgetList<Image>(find.byType(Image))
          .where((i) => i.image is AssetImage)
          .map((i) => (i.image as AssetImage).assetName)
          .toList();
      expect(assets, isEmpty, reason: 'bundled art rendered: $assets');
    });

    testWidgets('TC_S_GAL_003 — falls back to the cover, not to demo art',
        (tester) async {
      await pumpTLBApp(tester, GalleryScreen(event: _event()));
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('TC_S_GAL_004 — blank entries do not become blank pages',
        (tester) async {
      await pumpTLBApp(
        tester,
        GalleryScreen(event: _event(), images: const ['', '  ', ..._kMedia]),
      );
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('TC_S_GAL_005 — a listing with no photos says so',
        (tester) async {
      // Rather than a "1/0" counter over an empty pager.
      await pumpTLBApp(
        tester,
        GalleryScreen(event: _event(cover: ''), images: const []),
      );
      expect(find.text('No photos yet'), findsOneWidget);
      expect(find.textContaining('/'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
