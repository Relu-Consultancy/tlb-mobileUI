import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlb_mobile_ui/services/walkthrough_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WalkthroughService Tests', () {
    test('isNewUser defaults to false', () async {
      final isNew = await WalkthroughService.isNewUser();
      expect(isNew, isFalse);
    });

    test('markAsNewUser sets isNewUser to true', () async {
      await WalkthroughService.markAsNewUser();
      final isNew = await WalkthroughService.isNewUser();
      expect(isNew, isTrue);
    });

    test('markWalkthroughComplete sets isNewUser to false', () async {
      // First make them a new user
      await WalkthroughService.markAsNewUser();
      expect(await WalkthroughService.isNewUser(), isTrue);

      // Then complete the walkthrough
      await WalkthroughService.markWalkthroughComplete();
      expect(await WalkthroughService.isNewUser(), isFalse);
    });
  });
}
