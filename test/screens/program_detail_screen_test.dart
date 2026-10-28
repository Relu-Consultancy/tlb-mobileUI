import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/program_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';

import '../helpers/test_setup.dart';

void main() {
  // id: '' → dummy mode, no API call
  final testEvent = EventModel(
    id: '',
    title: 'Test Program',
    imagePath: 'assets/images/test.png',
    venue: 'Test Venue',
  );

  group('ProgramDetailScreen Tests', () {
    testWidgets('renders program details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ProgramDetailScreen(event: testEvent));

        // Session 32: CTA label changed to "Enquire Now" (was "Send Enquiry")
        expect(find.text('Test Program'), findsOneWidget);
        expect(find.text('Enquire Now'), findsOneWidget);
      });
    });
  });
}
