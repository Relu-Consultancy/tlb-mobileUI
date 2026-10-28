import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/name_case.dart';

void main() {
  group('NameCase.of', () {
    test('capitalises a lowercase first name', () {
      expect(NameCase.of('bit'), 'Bit');
    });

    test('capitalises every word of a full name', () {
      expect(NameCase.of('bit forge'), 'Bit Forge');
    });

    test('leaves an already-capitalised name alone', () {
      expect(NameCase.of('Bit Forge'), 'Bit Forge');
    });

    test('does not lowercase the rest of a word', () {
      // A name the owner capitalised themselves must survive untouched.
      expect(NameCase.of('McDonald'), 'McDonald');
      expect(NameCase.of('DSouza'), 'DSouza');
    });

    test('breaks on hyphens and apostrophes', () {
      expect(NameCase.of('anne-marie'), 'Anne-Marie');
      expect(NameCase.of("o'brien"), "O'Brien");
    });

    test('an empty string stays empty', () {
      expect(NameCase.of(''), '');
    });

    test('never changes the length of the text', () {
      // The formatter relies on this to hold the caret still.
      for (final s in ['bit forge', 'ßeta', 'a-b-c', 'Bit', '']) {
        expect(NameCase.of(s).length, s.length, reason: s);
      }
    });
  });

  group('NameCaseFormatter', () {
    TextEditingValue format(String text, {int? caret}) =>
        const NameCaseFormatter().formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: caret ?? text.length),
          ),
        );

    test('capitalises as the name is typed', () {
      expect(format('bit').text, 'Bit');
      expect(format('bit forge').text, 'Bit Forge');
    });

    test('holds the caret where the user left it', () {
      final result = format('bit forge', caret: 3);
      expect(result.text, 'Bit Forge');
      expect(result.selection.baseOffset, 3);
    });

    test('passes text that needs no change straight through', () {
      const value = TextEditingValue(text: 'Bit Forge');
      expect(
        const NameCaseFormatter()
            .formatEditUpdate(TextEditingValue.empty, value),
        same(value),
      );
    });
  });
}
