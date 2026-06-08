/// A single in-app notification from
/// `GET /api/v1/notifications/in-app/`.
class ApiNotification {
  final String id;
  final String notificationType;
  final String title;
  final String body;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  /// Mutable so the UI can flip it locally after a successful mark-as-read
  /// without re-fetching the whole list.
  bool isRead;
  String? readAt;
  final DateTime? createdAt;

  ApiNotification({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    this.actionUrl,
    this.metadata,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  /// True for admin broadcast notifications — drives the "from admin" badge.
  bool get isBroadcast => notificationType == 'broadcast';

  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final rawCreated = json['created_at'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      created = DateTime.tryParse(rawCreated);
    }
    return ApiNotification(
      id: json['id']?.toString() ?? '',
      notificationType: json['notification_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      isRead: json['is_read'] == true,
      readAt: json['read_at'] as String?,
      createdAt: created,
    );
  }
}

/// One page of the paginated in-app notifications list.
class ApiNotificationPage {
  final int count;
  final bool hasNext;
  final List<ApiNotification> results;

  ApiNotificationPage({
    required this.count,
    required this.hasNext,
    required this.results,
  });
}
