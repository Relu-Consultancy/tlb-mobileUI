import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';

/// The app asked for location permission, took a GPS fix, reverse-geocoded it
/// to a city name and threw the coordinates away. The listing endpoints'
/// geo-distance sorting takes lat & lng, so the distance filter had no numbers
/// to work from even in principle. LocationState keeps them now.
void main() {
  setUp(() => LocationState().setCity('Mumbai'));

  group('LocationState coordinates', () {
    test('a city from a GPS fix keeps its coordinates', () {
      LocationState().setCity('Pune', latitude: 18.5204, longitude: 73.8567);

      expect(LocationState().selectedCity.value, 'Pune');
      expect(LocationState().latitude, 18.5204);
      expect(LocationState().longitude, 73.8567);
      expect(LocationState().hasCoordinates, isTrue);
    });

    test('a city picked from the list carries none', () {
      LocationState().setCity('Goa');

      expect(LocationState().hasCoordinates, isFalse);
    });

    test('picking a city by hand clears an earlier fix', () {
      // Otherwise the coordinates would still point at the old place while
      // the city on screen says somewhere else.
      LocationState().setCity('Pune', latitude: 18.5204, longitude: 73.8567);
      LocationState().setCity('Jaipur');

      expect(LocationState().selectedCity.value, 'Jaipur');
      expect(LocationState().latitude, isNull);
      expect(LocationState().longitude, isNull);
    });

    test('a blank city changes nothing', () {
      LocationState().setCity('Pune', latitude: 18.5204, longitude: 73.8567);
      LocationState().setCity('   ');

      expect(LocationState().selectedCity.value, 'Pune');
      expect(LocationState().latitude, 18.5204);
    });
  });
}
