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

  // A class has no end_date column at all (it's an open-ended recurring
  // schedule, confirmed against ClassBatch's actual columns), so is_paused —
  // not a date — is the partner-controlled "not currently bookable" signal.
  // Verified live: it's a top-level field on the list endpoint, not nested
  // under `service` like most other class fields.
  group('ApiClass.isPaused (list endpoint)', () {
    Map<String, dynamic> listJson({bool? isPaused}) => {
          'id': '47e3be6c-8d2a-4a8b-8fd9-0ffefdf330fa',
          'title': 'Hip-Hop Dance Classes',
          'status': 'published',
          'is_live': true,
          'category': {'id': 4, 'name': 'Performing Arts', 'slug': 'pa', 'sort_order': 1},
          'average_rating': 0,
          'total_reviews': 0,
          'is_paused': isPaused,
        };

    test('parses is_paused: true', () {
      final c = ApiClass.fromJson(listJson(isPaused: true));
      expect(c.isPaused, isTrue);
    });

    test('parses is_paused: false', () {
      final c = ApiClass.fromJson(listJson(isPaused: false));
      expect(c.isPaused, isFalse);
    });

    test('defaults to false when is_paused is absent', () {
      final c = ApiClass.fromJson(listJson());
      expect(c.isPaused, isFalse);
    });
  });

  group('ApiClassDetail.isPaused', () {
    // is_paused sits top-level on the detail response, unlike category/mode/
    // city/etc which are nested under `service` — a mistake here would read
    // it from the wrong place and silently default to false.
    test('reads from the top level, not from service', () {
      final json = _baseJson();
      json['is_paused'] = true;
      final detail = ApiClassDetail.fromJson(json);
      expect(detail.isPaused, isTrue);
    });

    test('defaults to false when absent', () {
      final detail = ApiClassDetail.fromJson(_baseJson());
      expect(detail.isPaused, isFalse);
    });
  });

  group('ApiClassBatch.startDate', () {
    // The only schedule-anchor field the API sends for a class batch — there
    // is no matching end_date on this schema (unlike programs/venues, whose
    // batches carry both). A batch with no start_date is a fully open-ended
    // recurring schedule.
    test('parses a date string', () {
      final batch = ApiClassBatch.fromJson({
        'id': 61,
        'name': 'Morning Batch',
        'days': ['mon', 'tue'],
        'start_time': '16:00:00',
        'end_time': '18:00:00',
        'capacity': 25,
        'is_active': true,
        'start_date': '2026-09-10',
      });
      expect(batch.startDate, DateTime(2026, 9, 10));
    });

    test('is null when the API sends null', () {
      final batch = ApiClassBatch.fromJson({
        'id': 61,
        'name': 'Morning Batch',
        'days': ['mon', 'tue'],
        'start_time': '16:00:00',
        'end_time': '18:00:00',
        'capacity': 25,
        'is_active': true,
        'start_date': null,
      });
      expect(batch.startDate, isNull);
    });

    test('is null when the API omits the field entirely', () {
      final batch = ApiClassBatch.fromJson({
        'id': 61,
        'name': 'Morning Batch',
        'days': ['mon', 'tue'],
        'start_time': '16:00:00',
        'end_time': '18:00:00',
        'capacity': 25,
        'is_active': true,
      });
      expect(batch.startDate, isNull);
    });
  });
}
