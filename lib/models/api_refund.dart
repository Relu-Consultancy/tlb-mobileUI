/// Lifecycle of a refund, as reported by the API:
///
/// ```
/// requested → processing → settled
///                       ↘ failed
/// ```
///
/// Only [settled] means the customer actually has their money back — refunds
/// are asynchronous on the payment provider's side and `processing` can last
/// days. UI copy must not say "Refunded" before [settled].
enum RefundStatus {
  /// About to call / just called the payment provider. Very short-lived.
  requested,

  /// The provider accepted the request. The money has not necessarily arrived.
  processing,

  /// The provider confirmed the refund completed. Money is back.
  settled,

  /// The attempt failed and needs manual follow-up.
  failed,

  /// A status this build doesn't know about — treated as in-flight so we
  /// never claim money has landed when we can't tell.
  unknown;

  static RefundStatus parse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'requested':
        return RefundStatus.requested;
      case 'processing':
        return RefundStatus.processing;
      case 'settled':
        return RefundStatus.settled;
      case 'failed':
        return RefundStatus.failed;
      default:
        return RefundStatus.unknown;
    }
  }

  /// True while the refund is still moving — not yet settled, not failed.
  bool get isInFlight =>
      this == RefundStatus.requested ||
      this == RefundStatus.processing ||
      this == RefundStatus.unknown;

  bool get isSettled => this == RefundStatus.settled;
  bool get isFailed => this == RefundStatus.failed;
}

/// A refund against a booking. Null on the booking when no refund was ever
/// initiated — e.g. it was cancelled before payment, or is still active.
class ApiRefund {
  final String id;
  final RefundStatus status;

  /// Raw status string as sent by the API, kept for diagnostics when the
  /// value is one [RefundStatus] doesn't recognise.
  final String rawStatus;

  final double? amount;
  final String currency;
  final DateTime? requestedAt;
  final DateTime? settledAt;
  final DateTime? failedAt;

  const ApiRefund({
    required this.id,
    required this.status,
    required this.rawStatus,
    this.amount,
    this.currency = 'INR',
    this.requestedAt,
    this.settledAt,
    this.failedAt,
  });

  /// The moment this refund reached its current state, for display.
  DateTime? get lastUpdatedAt => settledAt ?? failedAt ?? requestedAt;

  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v) : null;

  /// `amount` arrives as a decimal string ("500.00"); tolerate a number too.
  static double? _amount(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Reads the `refund` object off a booking payload. Returns null when the
  /// field is absent or explicitly null.
  static ApiRefund? fromJson(dynamic json) {
    if (json is! Map) return null;
    final raw = (json['status'] as String?) ?? '';
    return ApiRefund(
      id: (json['id'] as String?) ?? '',
      status: RefundStatus.parse(raw),
      rawStatus: raw,
      amount: _amount(json['amount']),
      currency: (json['currency'] as String?) ?? 'INR',
      requestedAt: _date(json['requested_at']),
      settledAt: _date(json['settled_at']),
      failedAt: _date(json['failed_at']),
    );
  }
}
