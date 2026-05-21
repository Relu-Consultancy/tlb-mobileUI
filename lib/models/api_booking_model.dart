/// Request model — one selected ticket type with a quantity.
class BookingLineItem {
  final int ticketId;
  final int quantity;

  const BookingLineItem({required this.ticketId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'ticket_id': ticketId,
        'quantity': quantity,
      };
}

/// Request model — one attendee.
class BookingAttendee {
  final String name;
  final int? age;
  final String? phone;
  final String? email;
  final Map<String, dynamic>? extraData;

  const BookingAttendee({
    required this.name,
    this.age,
    this.phone,
    this.email,
    this.extraData,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'name': name};
    if (age != null) m['age'] = age;
    if (phone != null && phone!.isNotEmpty) m['phone'] = phone;
    if (email != null && email!.isNotEmpty) m['email'] = email;
    if (extraData != null) m['extra_data'] = extraData;
    return m;
  }
}

/// Response from POST /api/v1/bookings/initiate/
class BookingInitiateResponse {
  final String bookingId;
  final String bookingReference;
  final String razorpayOrderId;
  final double amount;
  final String currency;
  final DateTime? holdExpiresAt;
  final String status;

  const BookingInitiateResponse({
    required this.bookingId,
    required this.bookingReference,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    this.holdExpiresAt,
    required this.status,
  });

  factory BookingInitiateResponse.fromJson(Map<String, dynamic> json) =>
      BookingInitiateResponse(
        bookingId: json['booking_id'] as String,
        bookingReference: json['booking_reference'] as String,
        razorpayOrderId: json['razorpay_order_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: (json['currency'] as String?) ?? 'INR',
        holdExpiresAt: json['hold_expires_at'] != null
            ? DateTime.tryParse(json['hold_expires_at'] as String)
            : null,
        status: (json['status'] as String?) ?? 'awaiting_payment',
      );
}

/// A single booking from GET /api/v1/bookings/ or GET /api/v1/bookings/{id}/
class ApiBookingItem {
  final String id;
  final String bookingReference;
  final String bookingType;
  final String status;
  final String listingTitle;
  final double totalAmount;
  final String currency;
  final String paymentStatus;
  final DateTime? holdExpiresAt;
  final bool isCancellable;
  final DateTime createdAt;
  // Fields present only in cancel response
  final String? cancelledAt;
  final String? cancellationReason;
  final double? refundAmount;
  // Extended fields — may come from full detail response
  final String? listingId;
  final String? listingCover;

  const ApiBookingItem({
    required this.id,
    required this.bookingReference,
    required this.bookingType,
    required this.status,
    required this.listingTitle,
    required this.totalAmount,
    required this.currency,
    required this.paymentStatus,
    required this.holdExpiresAt,
    required this.isCancellable,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.refundAmount,
    this.listingId,
    this.listingCover,
  });

  factory ApiBookingItem.fromJson(Map<String, dynamic> json) => ApiBookingItem(
        id: (json['id'] as String?) ?? '',
        bookingReference: (json['booking_reference'] as String?) ?? '',
        bookingType: (json['booking_type'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        listingTitle: (json['listing_title'] as String?) ?? '',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        currency: (json['currency'] as String?) ?? 'INR',
        paymentStatus: (json['payment_status'] as String?) ?? '',
        holdExpiresAt: json['hold_expires_at'] != null
            ? DateTime.tryParse(json['hold_expires_at'] as String)
            : null,
        isCancellable: (json['is_cancellable'] as bool?) ?? false,
        createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
            DateTime.now(),
        cancelledAt: json['cancelled_at'] as String?,
        cancellationReason: json['cancellation_reason'] as String?,
        refundAmount: (json['refund_amount'] as num?)?.toDouble(),
        listingId: json['listing_id'] as String? ??
            (json['listing'] as Map?)?['id']?.toString(),
        listingCover: json['listing_cover'] as String? ??
            json['cover_url'] as String? ??
            (json['listing'] as Map?)?['cover_url'] as String?,
      );

  ApiBookingItem copyWith({
    String? status,
    String? paymentStatus,
    bool? isCancellable,
    String? cancelledAt,
    String? cancellationReason,
    double? refundAmount,
    String? listingId,
    String? listingCover,
  }) =>
      ApiBookingItem(
        id: id,
        bookingReference: bookingReference,
        bookingType: bookingType,
        status: status ?? this.status,
        listingTitle: listingTitle,
        totalAmount: totalAmount,
        currency: currency,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        holdExpiresAt: holdExpiresAt,
        isCancellable: isCancellable ?? this.isCancellable,
        createdAt: createdAt,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        refundAmount: refundAmount ?? this.refundAmount,
        listingId: listingId ?? this.listingId,
        listingCover: listingCover ?? this.listingCover,
      );
}

/// Paginated list of bookings from GET /api/v1/bookings/
class ApiBookingsPage {
  final int count;
  final String? next;
  final List<ApiBookingItem> results;

  const ApiBookingsPage({
    required this.count,
    this.next,
    required this.results,
  });

  bool get hasMore => next != null;

  factory ApiBookingsPage.fromJson(Map<String, dynamic> json) => ApiBookingsPage(
        count: (json['count'] as int?) ?? 0,
        next: json['next'] as String?,
        results: (json['results'] as List<dynamic>? ?? [])
            .map((e) => ApiBookingItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static ApiBookingsPage empty() =>
      const ApiBookingsPage(count: 0, results: []);
}

/// Response from POST /api/v1/bookings/{id}/verify-payment/
class BookingConfirmResponse {
  final String id;
  final String bookingReference;
  final String bookingType;
  final String status;
  final String listingTitle;
  final double totalAmount;
  final String currency;
  final String paymentStatus;

  const BookingConfirmResponse({
    required this.id,
    required this.bookingReference,
    required this.bookingType,
    required this.status,
    required this.listingTitle,
    required this.totalAmount,
    required this.currency,
    required this.paymentStatus,
  });

  factory BookingConfirmResponse.fromJson(Map<String, dynamic> json) =>
      BookingConfirmResponse(
        id: json['id'] as String,
        bookingReference: json['booking_reference'] as String,
        bookingType: (json['booking_type'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        listingTitle: (json['listing_title'] as String?) ?? '',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        currency: (json['currency'] as String?) ?? 'INR',
        paymentStatus: (json['payment_status'] as String?) ?? '',
      );
}
