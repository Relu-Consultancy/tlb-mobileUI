import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_booking_model.dart';

class BookingService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// POST /api/v1/bookings/initiate/
  ///
  /// For events:   provide [lineItems] (list of ticket_id + quantity).
  /// For classes/programs: provide [batchId] and [quantity].
  /// For venues:   provide [slotId] and optionally [packageId], [guestCount].
  static Future<BookingInitiateResponse> initiateBooking({
    required String token,
    required String listingId,
    required String bookingType,
    List<BookingLineItem> lineItems = const [],
    List<BookingAttendee> attendees = const [],
    String? customerNotes,
    int? batchId,
    int? quantity,
    int? slotId,
    int? packageId,
    int? guestCount,
    String? specialRequests,
  }) async {
    final body = <String, dynamic>{
      'listing_id': listingId,
      'booking_type': bookingType,
    };

    if (lineItems.isNotEmpty) {
      body['line_items'] = lineItems.map((e) => e.toJson()).toList();
    }
    if (attendees.isNotEmpty) {
      body['attendees'] = attendees.map((e) => e.toJson()).toList();
    }
    if (customerNotes != null && customerNotes.isNotEmpty) {
      body['customer_notes'] = customerNotes;
    }
    if (batchId != null) body['batch_id'] = batchId;
    if (quantity != null) body['quantity'] = quantity;
    if (slotId != null) body['slot_id'] = slotId;
    if (packageId != null) body['package_id'] = packageId;
    if (guestCount != null) body['guest_count'] = guestCount;
    if (specialRequests != null && specialRequests.isNotEmpty) {
      body['special_requests'] = specialRequests;
    }

    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/v1/bookings/initiate/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = _unwrap(json);

      if (resp.statusCode == 201 && (json['success'] == true)) {
        return BookingInitiateResponse.fromJson(data);
      }

      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// POST /api/v1/bookings/{bookingId}/verify-payment/
  static Future<BookingConfirmResponse> verifyPayment({
    required String token,
    required String bookingId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/v1/bookings/$bookingId/verify-payment/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'razorpay_payment_id': razorpayPaymentId,
              'razorpay_order_id': razorpayOrderId,
              'razorpay_signature': razorpaySignature,
            }),
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = _unwrap(json);

      if (resp.statusCode == 200 && (json['success'] == true)) {
        return BookingConfirmResponse.fromJson(data);
      }

      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }

  static String _extractError(Map<String, dynamic> body, int statusCode) {
    final err = body['error'];
    if (err is Map) {
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final msg = body['message'] ?? body['detail'];
    if (msg is String && msg.isNotEmpty) return msg;
    return 'Request failed ($statusCode). Please try again.';
  }
}

