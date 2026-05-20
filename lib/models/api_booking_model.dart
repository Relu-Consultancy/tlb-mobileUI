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
