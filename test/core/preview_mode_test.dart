import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlb_mobile_ui/core/preview_mode.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreviewMode.enabled.value = false;
  });

  group('PreviewMode.load', () {
    test('defaults to false when key absent', () async {
      SharedPreferences.setMockInitialValues({});
      await PreviewMode.load();
      expect(PreviewMode.enabled.value, isFalse);
    });

    test('reads stored true value', () async {
      SharedPreferences.setMockInitialValues({
        'tlb_device_preview_enabled': true,
      });
      await PreviewMode.load();
      expect(PreviewMode.enabled.value, isTrue);
    });

    test('reads stored false value', () async {
      SharedPreferences.setMockInitialValues({
        'tlb_device_preview_enabled': false,
      });
      await PreviewMode.load();
      expect(PreviewMode.enabled.value, isFalse);
    });
  });

  group('PreviewMode.toggle', () {
    test('flips value from false to true', () async {
      PreviewMode.enabled.value = false;
      await PreviewMode.toggle();
      expect(PreviewMode.enabled.value, isTrue);
    });

    test('flips value from true to false', () async {
      PreviewMode.enabled.value = true;
      await PreviewMode.toggle();
      expect(PreviewMode.enabled.value, isFalse);
    });

    test('persists flipped value to SharedPreferences', () async {
      PreviewMode.enabled.value = false;
      await PreviewMode.toggle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tlb_device_preview_enabled'), isTrue);
    });

    test('notifies listeners on change', () async {
      var notified = false;
      void listener() => notified = true;
      PreviewMode.enabled.addListener(listener);
      addTearDown(() => PreviewMode.enabled.removeListener(listener));

      await PreviewMode.toggle();
      expect(notified, isTrue);
    });
  });
}
