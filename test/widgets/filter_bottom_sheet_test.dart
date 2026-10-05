import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/filter_bottom_sheet.dart';

import '../helpers/test_setup.dart';

/// Opens the sheet from a button and hands back what Apply returned.
class _Host {
  FilterResult? result;
}

Future<_Host> _open(
  WidgetTester tester, {
  List<String> filters = const ['F1', 'F2'],
  String? initialSort,
  List<String> initialFilters = const [],
  List<String> initialCategories = const [],
  bool single = true,
}) async {
  final host = _Host();
  await pumpTLBApp(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => host.result = await FilterBottomSheet.show(
            context,
            sortOptions: const ['Top Picks', 'Distance- Near to Far'],
            filterOptions: filters,
            categoryOptions: const ['Cat1', 'Cat2'],
            singleCategory: single,
            initialSort: initialSort,
            initialFilters: initialFilters,
            initialCategories: initialCategories,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return host;
}

void main() {
  testWidgets('TC_W_FBS_001 — Apply returns the sort, filters and category',
      (tester) async {
    final host = await _open(tester);

    await tester.tap(find.text('Distance- Near to Far'));
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('F2'));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cat1'));
    await tester.tap(find.text('Cat2')); // pick-one: replaces Cat1
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(host.result?.selectedSort, 'Distance- Near to Far');
    expect(host.result?.selectedFilters, ['F2']);
    expect(host.result?.selectedCategories, ['Cat2']);
  });

  testWidgets('TC_W_FBS_002 — Clear All then Apply returns an empty result',
      (tester) async {
    final host = await _open(
      tester,
      initialSort: 'Top Picks',
      initialFilters: const ['F1'],
      initialCategories: const ['Cat1'],
    );
    await tester.tap(find.text('Clear All'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(host.result?.selectedSort, isNull);
    expect(host.result?.selectedFilters, isEmpty);
    expect(host.result?.selectedCategories, isEmpty);
  });

  testWidgets('TC_W_FBS_003 — an empty tab says so instead of a blank panel',
      (tester) async {
    await _open(tester, filters: const []);
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to choose here yet'), findsOneWidget);
  });

  testWidgets('TC_W_FBS_004 — tapping the chosen category again clears it',
      (tester) async {
    final host = await _open(tester, initialCategories: const ['Cat1']);
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cat1'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(host.result?.selectedCategories, isEmpty);
  });
}
