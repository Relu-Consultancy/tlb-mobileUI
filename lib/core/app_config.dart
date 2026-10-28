class AppConfig {
  /// Razorpay publishable key id (safe to ship; the key SECRET must never be
  /// in the app). The test key is the default; release builds pass the live
  /// one: `--dart-define=RAZORPAY_KEY_ID=rzp_live_...`.
  static const razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_SpYAGfwgdidCZq',
  );
}
