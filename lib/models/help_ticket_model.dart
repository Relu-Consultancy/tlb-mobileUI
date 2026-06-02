// Models for the Help / Support API.
//
// Endpoints documented at:
//   POST   /api/v1/help/tickets/                          create
//   GET    /api/v1/help/tickets/list/                     list mine
//   GET    /api/v1/help/tickets/{id}/                     detail
//   GET    /api/v1/help/tickets/{id}/messages/?since=...  poll
//   POST   /api/v1/help/tickets/{id}/messages/send/       reply

/// Categories the backend accepts. Keep in sync with the API enum —
/// `refund_status` is the only one documented in the swagger example,
/// the others are inferred from the original Help Centre design and
/// are safe to send (DRF validates and we surface the error inline).
class HelpCategory {
  final String slug;
  final String label;
  const HelpCategory(this.slug, this.label);

  static const bookingIssue =
      HelpCategory('booking_issue', 'Booking Issues');
  static const paymentProblem =
      HelpCategory('payment_problem', 'Payment Problems');
  static const refundStatus =
      HelpCategory('refund_status', 'Refund Status');
  static const general = HelpCategory('general', 'General');

  static const all = <HelpCategory>[
    bookingIssue,
    paymentProblem,
    refundStatus,
    general,
  ];

  static HelpCategory fromSlug(String? s) {
    for (final c in all) {
      if (c.slug == s) return c;
    }
    // Unknown slug — render the raw token so we never silently lose info.
    return HelpCategory(s ?? 'general', _humanize(s ?? 'general'));
  }

  static String _humanize(String s) =>
      s.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');
}

class HelpTicket {
  final String id;
  final String category;
  final String subject;
  final String status; // open / pending / resolved / closed
  final String? bookingReference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;
  final int unreadCount;

  HelpTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.status,
    this.bookingReference,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.unreadCount = 0,
  });

  factory HelpTicket.fromJson(Map<String, dynamic> j) {
    // List endpoint returns `unread_count` as a string ("0") — the rest of
    // the API uses ints. Accept both.
    final unreadRaw = j['unread_count'];
    int unread = 0;
    if (unreadRaw is int) {
      unread = unreadRaw;
    } else if (unreadRaw is String) {
      unread = int.tryParse(unreadRaw) ?? 0;
    } else if (unreadRaw is num) {
      unread = unreadRaw.toInt();
    }

    return HelpTicket(
      id: (j['id'] ?? '').toString(),
      category: (j['category'] ?? 'general').toString(),
      subject: (j['subject'] ?? '').toString(),
      status: (j['status'] ?? 'open').toString(),
      bookingReference: j['booking_reference']?.toString(),
      createdAt: _parseDate(j['created_at']),
      updatedAt: _parseDate(j['updated_at']),
      closedAt: _parseDate(j['closed_at']),
      unreadCount: unread,
    );
  }
}

class HelpTicketMessage {
  final String id;
  final String senderEmail;
  final String senderRole; // customer / support / admin
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  HelpTicketMessage({
    required this.id,
    required this.senderEmail,
    required this.senderRole,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  bool get isFromCustomer => senderRole == 'customer';

  factory HelpTicketMessage.fromJson(Map<String, dynamic> j) {
    return HelpTicketMessage(
      id: (j['id'] ?? '').toString(),
      senderEmail: (j['sender_email'] ?? '').toString(),
      senderRole: (j['sender_role'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      isRead: j['is_read'] == true,
      createdAt: _parseDate(j['created_at']),
    );
  }
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isEmpty) return null;
  return DateTime.tryParse(v.toString());
}
