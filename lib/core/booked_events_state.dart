import 'dart:math';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class BookingEntry {
  final EventModel event;
  final String bookingId;
  final DateTime bookedAt;
  final String status; // 'Confirmed', 'Pending', 'Completed'
  final String date;
  final String time;

  const BookingEntry({
    required this.event,
    required this.bookingId,
    required this.bookedAt,
    this.status = 'Confirmed',
    this.date = 'Saturday, March',
    this.time = '3:00 pm–6:00 pm',
  });

  static String generateId() {
    final rand = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final code = StringBuffer();
    for (int i = 0; i < 4; i++) {
      code.write(letters[rand.nextInt(letters.length)]);
    }
    for (int i = 0; i < 4; i++) {
      code.write(rand.nextInt(10));
    }
    return code.toString();
  }
}

class BookedEventsState {
  static final ValueNotifier<List<BookingEntry>> bookings =
      ValueNotifier<List<BookingEntry>>([]);

  static void addBooking(EventModel event, {String? date, String? time}) {
    final list = List<BookingEntry>.from(bookings.value);
    list.insert(
      0,
      BookingEntry(
        event: event,
        bookingId: BookingEntry.generateId(),
        bookedAt: DateTime.now(),
        date: date ?? 'Saturday, March',
        time: time ?? '3:00 pm–6:00 pm',
      ),
    );
    bookings.value = list;
  }

  static bool hasBooking(EventModel event) {
    return bookings.value.any((b) => b.event.uniqueId == event.uniqueId);
  }
}
