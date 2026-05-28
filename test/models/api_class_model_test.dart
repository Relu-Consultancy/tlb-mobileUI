import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_class_model.dart';

Map<String, dynamic> _baseJson({Object? price}) {
  return {
    'id': '6445f683-e203-4438-a2aa-3d00d270351a',
    'title': 'Sur Sangram Singing Academy',
    'short_description': null,
    'status': 'published',
    'is_live': true,
    'average_rating': 0,
    'total_reviews': 0,
    'service': {
      'category': {'id': 4, 'name': 'Performing Arts', 'slug': 'pa', 'sort_order': 1},
      'mode': 'offline',
      'city': 'Mumbai',
      'tags': [],
      'booking_type': 'direct_booking',
      'active_batches_count': 0,
      'batches': [],
      'media': [],
      if (price != null) 'price': price,
    },
  };
}

void main() {
  group('ApiClassDetail.price (Session 43)', () {
    test('parses an int price as double', () {
      final detail = ApiClassDetail.fromJson(_baseJson(price: 1500));
      expect(detail.price, 1500.0);
    });

    test('parses a double price', () {
      final detail = ApiClassDetail.fromJson(_baseJson(price: 1500.50));
      expect(detail.price, 1500.5);
    });

    test('price is null when service.price is absent', () {
      final detail = ApiClassDetail.fromJson(_baseJson());
      expect(detail.price, isNull);
    });

    test('price is null when service.price is explicitly null', () {
      // Build with an explicit null instead of mutating — the base Map's
      // value type is inferred as non-null, so direct assignment throws.
      final json = _baseJson();
      final service = Map<String, dynamic>.from(
          json['service'] as Map<String, dynamic>);
      service['price'] = null;
      json['service'] = service;
      final detail = ApiClassDetail.fromJson(json);
      expect(detail.price, isNull);
    });

    test('parses bookingType=direct_booking', () {
      final detail = ApiClassDetail.fromJson(_baseJson(price: 1500));
      expect(detail.bookingType, 'direct_booking');
    });

    test('defaults bookingType to "enquiry" when service.booking_type missing',
        () {
      final json = _baseJson();
      (json['service'] as Map<String, dynamic>).remove('booking_type');
      final detail = ApiClassDetail.fromJson(json);
      expect(detail.bookingType, 'enquiry');
    });
  });
}
