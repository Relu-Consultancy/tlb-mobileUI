import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_notification_model.dart';
import '../providers/auth_state.dart';
import '../providers/notifications_state.dart';
import '../services/notification_service.dart';
import '../widgets/app_refresh_indicator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _pageSize = 20;

  final _scrollCtrl = ScrollController();
  final List<ApiNotification> _items = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _markingAll = false;
  String? _error;
  int _page = 1;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool get _hasUnread => _items.any((n) => !n.isRead);

  Future<void> _load() async {
    final token = AuthState.accessToken;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Please log in to view notifications.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pageData = await NotificationService.listInApp(
        token: token,
        page: 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(pageData.results);
        _page = 1;
        _hasNext = pageData.hasNext;
        _loading = false;
      });
      // Keep the bell badge in sync with the freshest server count.
      NotificationsState.refreshFromApi();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onScroll() {
    if (!_hasNext || _loadingMore || _loading) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final token = AuthState.accessToken;
    if (token == null || _loadingMore || !_hasNext) return;
    setState(() => _loadingMore = true);
    try {
      final next = await NotificationService.listInApp(
        token: token,
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        // De-dupe by id in case of overlap between pages.
        final seen = _items.map((n) => n.id).toSet();
        _items.addAll(next.results.where((n) => !seen.contains(n.id)));
        _page += 1;
        _hasNext = next.hasNext;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _onTapNotification(ApiNotification n) async {
    if (!n.isRead) {
      final token = AuthState.accessToken;
      if (token != null) {
        // Optimistic: flip locally + drop the badge, then confirm with server.
        setState(() => n.isRead = true);
        NotificationsState.decrement();
        NotificationService.markRead(token: token, id: n.id);
      }
    }
    final url = n.actionUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _markAllRead() async {
    final token = AuthState.accessToken;
    if (token == null || _markingAll) return;
    setState(() => _markingAll = true);
    final marked = await NotificationService.markAllRead(token: token);
    if (!mounted) return;
    setState(() {
      _markingAll = false;
      if (marked != null) {
        for (final n in _items) {
          n.isRead = true;
        }
      }
    });
    if (marked != null) {
      NotificationsState.clear();
      AppSnackBar.success(context, 'All notifications marked as read');
    } else {
      AppSnackBar.error(context, 'Could not mark all as read. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => !n.isRead).length;
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (!_loading && _error == null && unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 11.5),
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentBlue,
                ),
              ),
          ],
        ),
        actions: [
          if (!_loading && _error == null && _hasUnread)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _markingAll ? null : _markAllRead,
                icon: _markingAll
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded,
                        size: 16, color: AppColors.accentBlue),
                label: Text(
                  'Mark all read',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 12.5),
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accentBlue.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
        ),
      );
    }
    if (_error != null) return _buildError();
    if (_items.isEmpty) return _buildEmpty();

    // Flatten notifications into a list of rows interleaved with date-group
    // headers ("Today", "Yesterday", …) so the feed reads as tidy sections.
    final rows = _buildRows();

    return AppRefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: rows.length + (_hasNext ? 1 : 0),
        separatorBuilder: (_, i) {
          if (i + 1 >= rows.length) return const SizedBox(height: 10);
          // Extra breathing room above a section header, tighter between cards.
          final next = rows[i + 1];
          return SizedBox(height: next is String ? 6 : 10);
        },
        itemBuilder: (context, i) {
          if (i >= rows.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            );
          }
          final row = rows[i];
          if (row is String) return _sectionHeader(context, row);
          final n = row as ApiNotification;
          return _NotificationCard(
            notification: n,
            onTap: () => _onTapNotification(n),
          );
        },
      ),
    );
  }

  /// Builds the interleaved [String header, ApiNotification, …] row list.
  List<Object> _buildRows() {
    final rows = <Object>[];
    String? currentBucket;
    for (final n in _items) {
      final bucket = _bucketFor(n.createdAt);
      if (bucket != currentBucket) {
        currentBucket = bucket;
        rows.add(bucket);
      }
      rows.add(n);
    }
    return rows;
  }

  String _bucketFor(DateTime? dt) {
    if (dt == null) return 'Earlier';
    final now = DateTime.now();
    final local = dt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(local.year, local.month, local.day);
    final days = today.difference(that).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return 'This Week';
    return 'Earlier';
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return AppRefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentBlue.withOpacity(0.12),
                          AppColors.accentBlue.withOpacity(0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded,
                        size: 52, color: AppColors.accentBlue.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Notifications Yet',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're all caught up! We'll let you know when "
                    'something new arrives.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18, color: AppColors.textPrimary),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final ApiNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final unread = !n.isRead;
    final accent = _accentColor(n.notificationType);
    final hasAction = n.actionUrl != null && n.actionUrl!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(0.06),
      elevation: unread ? 3 : 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            // Unread cards get a faint tinted wash + a colored leading strip.
            gradient: unread
                ? LinearGradient(
                    colors: [accent.withOpacity(0.06), Colors.white],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            border: Border(
              left: BorderSide(
                color: unread ? accent : Colors.transparent,
                width: 3.5,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient icon badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.20), accent.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconFor(n.notificationType), color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title.isEmpty ? 'Notification' : n.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.4),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        n.body,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: Colors.grey.shade600,
                          height: 1.45,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (n.isBroadcast) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded,
                                    size: 11, color: Color(0xFF7C3AED)),
                                const SizedBox(width: 4),
                                Text(
                                  'From Admin',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 9.5),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(Icons.schedule_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          _timeAgo(n.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10.5),
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (hasAction) ...[
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 10.5),
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10, color: accent),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentColor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return const Color(0xFF22C55E);
      case 'payment_failed':
      case 'booking_cancelled':
        return const Color(0xFFEF4444);
      case 'broadcast':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.accentBlue;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Icons.check_circle_outline;
      case 'payment_failed':
        return Icons.error_outline;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      case 'partner_new_booking':
        return Icons.event_available_outlined;
      case 'broadcast':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}
