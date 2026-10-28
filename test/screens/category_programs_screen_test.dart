import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/category_programs_screen.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';

import '../helpers/test_setup.dart';

void main() {
  group('CategoryProgramsScreen Tests', () {
    testWidgets('renders category title and programs', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const CategoryProgramsScreen(initialCategoryIndex: 0));

        final title = DummyData.programsCategories[0]['label'].toString().replaceAll('\n', ' ');
        // Title appears in both CategoryScreenHeader and the category chip row
        expect(find.text(title), findsWidgets);
        expect(find.text('Explore other Programs'), findsOneWidget);
        expect(find.text('All $title'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
      });
    });

    testWidgets('switching category updates the header title', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const CategoryProgramsScreen(initialCategoryIndex: 0));

        final cat1Label = DummyData.programsCategories[1]['label'].toString();
        await tester.tap(find.text(cat1Label));
        await tester.pumpAndSettle();

        // Header shows replaceAll('\n', ' ') version; chip keeps raw label with any newline
        final title1 = cat1Label.replaceAll('\n', ' ');
        expect(find.text(title1), findsWidgets);
      });
    });
  });
}
