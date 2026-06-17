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
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (!_loading && _error == null && _hasUnread)
            TextButton(
              onPressed: _markingAll ? null : _markAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12.5),
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentBlue,
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

    return AppRefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _items.length + (_hasNext ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i >= _items.length) {
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
          return _NotificationCard(
            notification: _items[i],
            onTap: () => _onTapNotification(_items[i]),
          );
        },
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
                  Icon(Icons.notifications_off_outlined,
                      size: 72, color: Colors.grey.shade300),
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

    return Material(
      color: unread ? const Color(0xFFF4F8FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread
                  ? AppColors.accentBlue.withOpacity(0.18)
                  : Colors.black.withOpacity(0.06),
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(n.notificationType), color: accent, size: 20),
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
                              fontSize: Responsive.sp(context, 13.5),
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (n.isBroadcast) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'From Admin',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 9.5),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _timeAgo(n.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10.5),
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (n.actionUrl != null && n.actionUrl!.isNotEmpty) ...[
                          const Spacer(),
                          Icon(Icons.open_in_new,
                              size: 13, color: Colors.grey.shade400),
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
