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
    String? couponCode,
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

    if (couponCode != null && couponCode.isNotEmpty) {
      body['coupon_code'] = couponCode;
    }
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

      if (resp.statusCode == 201 && (json['success'] == true || json['success'] == null)) {
        return BookingInitiateResponse.fromJson(data);
      }

      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// POST /api/v1/bookings/initiate-with-saved-method/
  static Future<BookingInitiateResponse> initiateWithSavedMethod({
    required String token,
    required String listingId,
    required String bookingType,
    required String savedMethodId,
    String? couponCode,
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
      'saved_method_id': savedMethodId,
    };

    if (couponCode != null && couponCode.isNotEmpty) {
      body['coupon_code'] = couponCode;
    }
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
            Uri.parse('$_base/api/v1/bookings/initiate-with-saved-method/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = _unwrap(json);

      if (resp.statusCode == 201 && (json['success'] == true || json['success'] == null)) {
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
    bool? saveMethod,
  }) async {
    try {
      final body = <String, dynamic>{
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      };
      if (saveMethod != null) {
        body['save_method'] = saveMethod;
      }

      final resp = await http
          .post(
            Uri.parse('$_base/api/v1/bookings/$bookingId/verify-payment/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = _unwrap(json);

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        return BookingConfirmResponse.fromJson(data);
      }

      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/ — paginated list, optional status filter.
  static Future<ApiBookingsPage> listBookings({
    required String token,
    String? status,
    int page = 1,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (status != null) params['status'] = status;

    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/')
                .replace(queryParameters: params),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        final data = _unwrap(json);
        return ApiBookingsPage.fromJson(data);
      }
      if (resp.statusCode == 404) return ApiBookingsPage.empty();
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/{bookingId}/
  static Future<ApiBookingItem> getBookingDetail({
    required String token,
    required String bookingId,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/$bookingId/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        return ApiBookingItem.fromJson(_unwrap(json));
      }
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/{bookingId}/ticket/data/
  static Future<Map<String, dynamic>> fetchTicketData({
    required String token,
    required String bookingId,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/$bookingId/ticket/data/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        return _unwrap(json);
      }
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/{bookingId}/ticket/
  /// Returns HTML ticket with QR code
  static Future<String> fetchTicketHtml({
    required String token,
    required String bookingId,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/$bookingId/ticket/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        return resp.body;
      }
      throw Exception('Failed to load ticket HTML (${resp.statusCode})');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/{bookingId}/invoice/
  /// Returns HTML invoice
  static Future<String> fetchInvoiceHtml({
    required String token,
    required String bookingId,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/$bookingId/invoice/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        return resp.body;
      }
      throw Exception('Failed to load invoice HTML (${resp.statusCode})');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/bookings/payment/{razorpay_order_id}/
  static Future<Map<String, dynamic>> getPaymentDetail({
    required String token,
    required String razorpayOrderId,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/bookings/payment/$razorpayOrderId/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        return _unwrap(json);
      }
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// POST /api/v1/bookings/{bookingId}/cancel/
  static Future<ApiBookingItem> cancelBooking({
    required String token,
    required String bookingId,
    String? reason,
  }) async {
    final body = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;

    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/v1/bookings/$bookingId/cancel/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final json = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        return ApiBookingItem.fromJson(_unwrap(json));
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
      final code = err['code'] as String?;
      if (code == 'PAYMENT_GATEWAY_NOT_CONFIGURED') {
        return 'Online payment is temporarily unavailable for this booking. Please contact support.';
      }
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final msg = body['message'] ?? body['detail'];
    if (msg is String && msg.isNotEmpty) return msg;
    return 'Request failed ($statusCode). Please try again.';
  }
}

