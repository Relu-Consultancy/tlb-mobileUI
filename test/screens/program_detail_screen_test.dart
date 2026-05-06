import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/program_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/class_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';

import '../helpers/test_setup.dart';

void main() {
  final testEvent = EventModel(
    title: 'Test Program',
    imagePath: 'assets/images/test.png',
    venue: 'Test Venue',
  );

  group('ProgramDetailScreen Tests', () {
    testWidgets('renders ClassDetailScreen with correct event', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ProgramDetailScreen(event: testEvent));

        expect(find.byType(ClassDetailScreen), findsOneWidget);
        expect(find.text('Test Program'), findsOneWidget);
      });
    });
  });
}
