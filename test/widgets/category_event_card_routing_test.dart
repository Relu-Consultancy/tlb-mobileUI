import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/class_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/event_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/program_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/venue_detail_screen.dart';
import 'package:tlb_mobile_ui/widgets/category_event_card.dart';

import '../helpers/test_setup.dart';

/// The card's default tap opened the *event* detail screen whatever the
/// listing actually was. The grids showing classes, programs and venues had
/// to pass their own onTap to work around that, and the two that did not —
/// the Pick Your Pace and Find Your Fit screens — opened the wrong screen on
/// every result.
///
/// The default now routes on the listing's own type.
EventModel _event(String type) => EventModel(
      id: 'l1',
      title: 'A Listing',
      venue: 'Mumbai',
      imagePath: '',
      listingType: type,
    );

Future<void> _tapCard(WidgetTester tester, EventModel event) async {
  await pumpTLBApp(tester, Scaffold(body: CategoryEventCard(event: event)));
  await tester.tap(find.byType(CategoryEventCard));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('CategoryEventCard — default tap routes by listing type', () {
    testWidgets('TC_W_CEC_R01 — a class opens the class detail screen',
        (tester) async {
      await _tapCard(tester, _event('class'));
      expect(find.byType(ClassDetailScreen), findsOneWidget);
      expect(find.byType(EventDetailScreen), findsNothing);
    });

    testWidgets('TC_W_CEC_R02 — a program opens the program detail screen',
        (tester) async {
      await _tapCard(tester, _event('program'));
      expect(find.byType(ProgramDetailScreen), findsOneWidget);
      expect(find.byType(EventDetailScreen), findsNothing);
    });

    testWidgets('TC_W_CEC_R03 — a venue opens the venue detail screen',
        (tester) async {
      await _tapCard(tester, _event('venue'));
      expect(find.byType(VenueDetailScreen), findsOneWidget);
    });

    testWidgets('TC_W_CEC_R04 — an event still opens the event detail screen',
        (tester) async {
      await _tapCard(tester, _event('event'));
      expect(find.byType(EventDetailScreen), findsOneWidget);
    });

    testWidgets('TC_W_CEC_R05 — an explicit onTap still wins', (tester) async {
      // The category grids pass their own; it must not be overridden.
      var tapped = false;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: CategoryEventCard(
            event: _event('program'),
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(CategoryEventCard));
      await tester.pump();

      expect(tapped, isTrue);
      expect(find.byType(ProgramDetailScreen), findsNothing);
    });
  });

  group('The pace and fit grids tag their listings', () {
    test('TC_S_PC_TYPE — a class card says it is a class', () {
      final src =
          File('lib/screens/pace_classes_screen.dart').readAsStringSync();
      expect(src, contains("listingType: 'class'"));
    });

    test('TC_S_FP_TYPE — a program card says it is a program', () {
      final src =
          File('lib/screens/format_programs_screen.dart').readAsStringSync();
      expect(src, contains("listingType: 'program'"));
    });
  });
}
