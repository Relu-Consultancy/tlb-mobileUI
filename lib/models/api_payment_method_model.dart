class ApiPaymentMethod {
  final int id;
  final String methodType;
  final String? cardLast4;
  final String? cardNetwork;
  final String? cardIssuer;
  final String? cardType;
  final String? upiVpaMasked;
  final DateTime? createdAt;

  const ApiPaymentMethod({
    required this.id,
    required this.methodType,
    this.cardLast4,
    this.cardNetwork,
    this.cardIssuer,
    this.cardType,
    this.upiVpaMasked,
    this.createdAt,
  });

  factory ApiPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ApiPaymentMethod(
      id: json['id'] as int,
      methodType: json['method_type'] as String,
      cardLast4: json['card_last4'] as String?,
      cardNetwork: json['card_network'] as String?,
      cardIssuer: json['card_issuer'] as String?,
      cardType: json['card_type'] as String?,
      upiVpaMasked: json['upi_vpa_masked'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
