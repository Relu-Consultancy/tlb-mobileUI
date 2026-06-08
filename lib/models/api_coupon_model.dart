/// Result of `POST /api/v1/coupons/validate/` — a preview of a coupon's
/// effect on a given booking amount before the booking is initiated.
class CouponValidationResult {
  final bool isValid;
  final double discountAmount;
  final double finalAmount;
  final String? errorCode;
  final String? errorMessage;

  const CouponValidationResult({
    required this.isValid,
    required this.discountAmount,
    required this.finalAmount,
    this.errorCode,
    this.errorMessage,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    return CouponValidationResult(
      isValid: json['is_valid'] == true,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      errorCode: json['error_code'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Local failure (network/parse) helper.
  factory CouponValidationResult.failure(String message, {double fallbackAmount = 0}) {
    return CouponValidationResult(
      isValid: false,
      discountAmount: 0,
      finalAmount: fallbackAmount,
      errorCode: 'CLIENT_ERROR',
      errorMessage: message,
    );
  }
}
