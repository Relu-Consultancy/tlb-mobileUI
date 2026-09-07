import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/secure_url.dart';

/// The API serves media over http, Android 9+ blocks cleartext by default,
/// so Image.network failed silently and every card fell back to its grey
/// placeholder — "no images anywhere". The same asset is served over https.
void main() {
  group('secureUrl', () {
    test('upgrades an http media URL', () {
      expect(
        secureUrl('http://tlb-api.reluconsultancy.in/media/events/cover.png'),
        'https://tlb-api.reluconsultancy.in/media/events/cover.png',
      );
    });

    test('leaves an https URL alone', () {
      const url = 'https://tlb-api.reluconsultancy.in/media/x.png';
      expect(secureUrl(url), url);
    });

    test('leaves a bundled asset path alone', () {
      // Upgrading these would break every mock card.
      const asset = 'assets/images/pick_pace/weeklyclasses.png';
      expect(secureUrl(asset), asset);
      expect(secureUrl('resources- tlb-ui/banner.png'),
          'resources- tlb-ui/banner.png');
    });

    test('passes null and empty through', () {
      expect(secureUrl(null), isNull);
      expect(secureUrl(''), '');
    });

    test('is not fooled by http appearing later in the string', () {
      const url = 'https://cdn.example.com/?next=http://elsewhere';
      expect(secureUrl(url), url);
    });

    test('only the scheme changes, the rest is untouched', () {
      expect(
        secureUrl('http://host/a/b%20c.png?x=1&y=2'),
        'https://host/a/b%20c.png?x=1&y=2',
      );
    });
  });
}
