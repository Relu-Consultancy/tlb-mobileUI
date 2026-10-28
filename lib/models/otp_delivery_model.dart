/// Delivery state of a single OTP challenge.
///
/// One shape is returned by `POST /auth/request-otp/`,
/// `GET /auth/otp-delivery-status/`, `POST /auth/send-otp-via-email/` and
/// `POST /auth/send-otp-via-whatsapp/`, so one model covers all four.
///
/// WhatsApp accepting a message is not the same as delivering it, which is why
/// [status] exists at all and why the verification screen polls it: the only
/// honest thing to show while it is [OtpDeliveryStatus.queued] is "sending".
library;

/// How far the primary channel got. Describes the channel the code was
/// originally sent on — a fallback is reported by [OtpDelivery.emailSent]
/// instead, never here.
enum OtpDeliveryStatus {
  /// Handed to the provider, nothing confirmed.
  queued,

  /// Provider accepted it, nothing confirmed.
  sent,

  /// The provider confirmed delivery.
  delivered,

  /// No confirmation after ~45s. Not a failure: the server does NOT send a
  /// fallback on its own in this case, so the customer has to ask for one.
  unconfirmed,

  /// The provider rejected it or reported a failed delivery. The server
  /// emails the code itself when it has an address.
  failed,

  /// A value this build does not know. Treated as "still in flight" so a new
  /// server state can never make the UI claim a failure.
  unknown;

  static OtpDeliveryStatus fromWire(Object? raw) => switch ('$raw') {
        'queued' => queued,
        'sent' => sent,
        'delivered' => delivered,
        'unconfirmed' => unconfirmed,
        'failed' => failed,
        _ => unknown,
      };

  /// Waiting on the provider — show "sending", offer nothing yet.
  bool get isPending => this == queued || this == sent || this == unknown;

  /// Nothing more will change, so polling can stop.
  bool get isSettled => this == delivered || this == failed;
}

/// Which way an email login can be nudged to WhatsApp.
enum OtpAlternateMode {
  /// The account has a verified phone; the server can send the code there.
  verifiedPhone,

  /// No verified phone on file. The server cannot send anywhere — the
  /// customer has to sign in with a phone number instead, which may well be a
  /// different account. Deliberately not an account-recovery path.
  phoneLogin,

  /// A value this build does not know; treated as unavailable.
  unknown;

  static OtpAlternateMode fromWire(Object? raw) => switch ('$raw') {
        'verified_phone' => verifiedPhone,
        'phone_login' => phoneLogin,
        _ => unknown,
      };
}

/// The `alternate` block on an email login: the option to get the same code
/// on WhatsApp, which the server unlocks only after enough resends.
class OtpAlternate {
  final OtpAlternateMode mode;

  /// Whether the option may be shown at all. False until [resendCount]
  /// reaches [resendsRequired].
  final bool available;

  /// True when signing in by phone would reach a different account from the
  /// email — the customer must be warned before being sent down that path.
  final bool separateAccount;

  /// Masked, e.g. `+91********10`. Never the full number.
  final String? phoneHint;

  final int resendCount;
  final int resendsRequired;

  const OtpAlternate({
    this.mode = OtpAlternateMode.unknown,
    this.available = false,
    this.separateAccount = false,
    this.phoneHint,
    this.resendCount = 0,
    this.resendsRequired = 0,
  });

  factory OtpAlternate.fromJson(Map<String, dynamic> json) => OtpAlternate(
        mode: OtpAlternateMode.fromWire(json['mode']),
        available: json['available'] == true,
        separateAccount: json['separate_account'] == true,
        phoneHint: _text(json['phone_hint']),
        resendCount: _count(json['resend_count']),
        resendsRequired: _count(json['resends_required']),
      );

  /// Offer "send it to my WhatsApp": the server has a number to send to.
  bool get canSendToWhatsApp =>
      available && mode == OtpAlternateMode.verifiedPhone;

  /// Offer "sign in with WhatsApp instead": nothing to send to, so the only
  /// route is a fresh phone login on a possibly different account.
  bool get needsPhoneLogin =>
      available && mode == OtpAlternateMode.phoneLogin;
}

/// Delivery state of one OTP challenge — see the library doc above.
class OtpDelivery {
  /// Identifies this challenge to the status and switch-channel endpoints.
  /// Every `request-otp` call mints a new code and invalidates the previous
  /// one, so only the newest id is ever usable.
  final String otpId;

  /// The channel the code was sent on: `whatsapp` or `email`.
  final String? channel;

  final OtpDeliveryStatus status;

  /// True once the code has also gone to the fallback email — either because
  /// WhatsApp failed and the server emailed it unprompted, or because the
  /// customer asked. Each code is only ever emailed once.
  final bool emailSent;

  /// Whether an email fallback can be requested for this code. Always false
  /// for an email login (there is nothing to fall back to).
  final bool fallbackAvailable;

  /// The fallback channel's name, `email` today.
  final String? fallbackChannel;

  /// Masked, e.g. `u***@example.com`. Never the full address.
  final String? emailHint;

  /// Set on email logins only — the WhatsApp option. See [OtpAlternate].
  final OtpAlternate? alternate;

  /// When this code dies. Switching channel does not extend it.
  final DateTime? expiresAt;

  const OtpDelivery({
    required this.otpId,
    this.channel,
    this.status = OtpDeliveryStatus.unknown,
    this.emailSent = false,
    this.fallbackAvailable = false,
    this.fallbackChannel,
    this.emailHint,
    this.alternate,
    this.expiresAt,
  });

  /// Reads the delivery fields out of any of the four endpoints' `data`.
  /// Returns null when there is no `otp_id`, because without one none of the
  /// follow-up calls can be made and a half-built state would only mislead
  /// the UI.
  static OtpDelivery? fromJson(Map<String, dynamic>? json) {
    final id = _text(json?['otp_id']);
    if (json == null || id == null) return null;
    final alternate = json['alternate'];
    return OtpDelivery(
      otpId: id,
      channel: _text(json['channel']),
      status: OtpDeliveryStatus.fromWire(json['status']),
      emailSent: json['email_sent'] == true,
      fallbackAvailable: json['fallback_available'] == true,
      fallbackChannel: _text(json['fallback_channel']),
      emailHint: _text(json['email_hint']),
      alternate: alternate is Map<String, dynamic>
          ? OtpAlternate.fromJson(alternate)
          : null,
      expiresAt: DateTime.tryParse('${json['expires_at']}'),
    );
  }

  /// Offer "send it by email instead": a fallback exists and this code has
  /// not been emailed yet. Asking twice returns `EMAIL_ALREADY_SENT`, so the
  /// button has to disappear once it is used.
  bool get canSendToEmail =>
      fallbackAvailable && !emailSent && fallbackChannel != 'whatsapp';

  /// WhatsApp failed and there is no address to fall back to, so the customer
  /// has to supply one — which means a brand-new code (`fallback_email` is
  /// only read by `request-otp`).
  bool get needsEmailAddress =>
      status == OtpDeliveryStatus.failed && !emailSent && !fallbackAvailable;
}

/// Trimmed, or null when absent or blank — keeps `"null"` and `""` out of the
/// UI, where a masked hint is printed as-is.
String? _text(Object? raw) {
  if (raw == null) return null;
  final value = '$raw'.trim();
  return value.isEmpty || value == 'null' ? null : value;
}

int _count(Object? raw) => raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0;
