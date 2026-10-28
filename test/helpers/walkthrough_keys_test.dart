import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/helpers/walkthrough_keys.dart';

/// Regression guard for the step sequence itself — the kind of thing that's
/// easy to get subtly wrong when inserting a new step in the middle (off-by-
/// one stepIndex values, a key left out of orderedKeys, afterLocationKeys
/// drifting out of sync with orderedKeys).
void main() {
  group('WalkthroughKeys sequence', () {
    test('TC_H_WK_001 — has 8 steps: location, home, tap-a-card, 4 nav tabs, profile',
        () {
      expect(WalkthroughKeys.totalSteps, 8);
      expect(WalkthroughKeys.orderedKeys.length, 8);
    });

    test('TC_H_WK_002 — the section-card step sits between Home and Events',
        () {
      final keys = WalkthroughKeys.orderedKeys;
      expect(keys[1], WalkthroughKeys.navHome);
      expect(keys[2], WalkthroughKeys.firstSectionCard);
      expect(keys[3], WalkthroughKeys.navEvents);
    });

    test('TC_H_WK_003 — afterLocationKeys is orderedKeys minus the location step',
        () {
      final expected = WalkthroughKeys.orderedKeys.skip(1).toList();
      expect(WalkthroughKeys.afterLocationKeys, expected);
    });

    test('TC_H_WK_004 — every config\'s stepIndex matches its real position in orderedKeys',
        () {
      final keys = WalkthroughKeys.orderedKeys;

      expect(keys.indexOf(kLocationShowcaseConfig.showcaseKey),
          kLocationShowcaseConfig.stepIndex);
      expect(keys.indexOf(kSectionCardShowcaseConfig.showcaseKey),
          kSectionCardShowcaseConfig.stepIndex);
      expect(keys.indexOf(kProfileShowcaseConfig.showcaseKey),
          kProfileShowcaseConfig.stepIndex);

      for (final entry in kNavShowcaseConfigs.entries) {
        expect(keys.indexOf(entry.value.showcaseKey), entry.value.stepIndex,
            reason: 'nav config at map index ${entry.key}');
      }
    });

    test('TC_H_WK_005 — step indices across every config are 0..7 with no gaps or repeats',
        () {
      final indices = <int>{
        kLocationShowcaseConfig.stepIndex,
        kSectionCardShowcaseConfig.stepIndex,
        kProfileShowcaseConfig.stepIndex,
        ...kNavShowcaseConfigs.values.map((c) => c.stepIndex),
      };
      expect(indices, List.generate(8, (i) => i).toSet());
    });
  });
}
