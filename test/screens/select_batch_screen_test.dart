import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_class_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/select_batch_screen.dart';

import '../helpers/test_setup.dart';

/// `ApiClassBatch.startDate` is the only real schedule-anchor the API sends
/// for a class batch — there is no `end_date` field at all, unlike programs
/// and venues. A batch with no start date is a fully open-ended recurring
/// schedule, so the "Select Date" row should not invent dates for it.
ApiClassBatch _batch({DateTime? startDate}) => ApiClassBatch(
      id: 61,
      name: 'Morning Batch',
      days: const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      startTime: '16:00:00',
      endTime: '18:00:00',
      capacity: 25,
      isActive: true,
      startDate: startDate,
    );

const _event = EventModel(
  id: 'l1',
  title: 'Junior Swimming',
  venue: 'Mumbai',
  imagePath: '',
);

void main() {
  group('SelectBatchScreen — date selector visibility', () {
    testWidgets(
        'TC_S_SB_001 — no Select Date row when the batch has no start_date',
        (tester) async {
      await pumpTLBApp(
        tester,
        SelectBatchScreen(event: _event, batches: [_batch()]),
      );
      expect(find.text('Select Date'), findsNothing);
    });

    testWidgets(
        'TC_S_SB_002 — the starting-from card reads TBA rather than a guessed date',
        (tester) async {
      await pumpTLBApp(
        tester,
        SelectBatchScreen(event: _event, batches: [_batch()]),
      );
      expect(find.text('TBA'), findsOneWidget);
    });

    testWidgets('TC_S_SB_003 — Select Date shows once the API sends a start_date',
        (tester) async {
      final start = DateTime.now().add(const Duration(days: 3));
      await pumpTLBApp(
        tester,
        SelectBatchScreen(event: _event, batches: [_batch(startDate: start)]),
      );
      expect(find.text('Select Date'), findsOneWidget);
    });

    testWidgets(
        'TC_S_SB_004 — switching to a batch with no start_date hides the row again',
        (tester) async {
      final start = DateTime.now().add(const Duration(days: 3));
      await pumpTLBApp(
        tester,
        SelectBatchScreen(
          event: _event,
          batches: [
            _batch(startDate: start),
            ApiClassBatch(
              id: 62,
              name: 'Evening Batch',
              days: const ['mon', 'wed', 'fri'],
              startTime: '18:00:00',
              endTime: '20:00:00',
              capacity: 20,
              isActive: true,
            ),
          ],
        ),
      );
      expect(find.text('Select Date'), findsOneWidget);

      await tester.tap(find.text('Evening Batch'));
      await tester.pumpAndSettle();
      expect(find.text('Select Date'), findsNothing);
    });
  });
}
