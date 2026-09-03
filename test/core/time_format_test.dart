import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/time_format.dart';

void main() {
  group('TimeFormat.h12', () {
    test('afternoon hour, on the hour, drops the minutes', () {
      expect(TimeFormat.h12('16:00:00'), '4 PM');
    });

    test('afternoon hour, with minutes', () {
      expect(TimeFormat.h12('16:30:00'), '4:30 PM');
    });

    test('morning hour, on the hour', () {
      expect(TimeFormat.h12('09:00:00'), '9 AM');
    });

    test('noon stays 12, not 0', () {
      expect(TimeFormat.h12('12:00:00'), '12 PM');
    });

    test('midnight becomes 12 AM, not 0', () {
      expect(TimeFormat.h12('00:00:00'), '12 AM');
    });

    test('accepts HH:mm with no seconds', () {
      expect(TimeFormat.h12('16:00'), '4 PM');
    });

    test('an unparseable string is returned unchanged', () {
      expect(TimeFormat.h12('not-a-time'), 'not-a-time');
    });
  });
}
