import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/api_booking_model.dart';
import '../providers/auth_state.dart';
import '../services/booking_service.dart';
import '../services/classes_listing_service.dart';
import '../services/events_listing_service.dart';
import '../services/programs_listing_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_refresh_indicator.dart';
import 'booking_detail_screen.dart';

/// Muted gold-grey used to "discolor" Past-tab cards (attended/refunded) —
/// their thumbnail, badge and CTA border fade to this instead of the vivid
/// green/gold used for live bookings, reading as a washed-out memory.
const Color _kPastMutedColor = Color(0xFFB8A57C);

/// Sepia-style desaturation matrix applied to Past-tab thumbnails.
const List<double> _kPastImageFilterMatrix = [
  0.393, 0.769, 0.189, 0, 0,
  0.349, 0.686, 0.168, 0, 0,
  0.272, 0.534, 0.131, 0, 0,
  0, 0, 0, 1, 0,
];

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Upcoming', 'Past', 'Cancelled'];

  List<ApiBookingItem> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  // Status sets for each tab.
  // NOTE: 'payment_failed' belongs in Cancelled, NOT Upcoming — a failed
  // transaction is not an active/upcoming booking. Keeping it in Upcoming was
  // the cause of failed payments showing up alongside live bookings.
  static const _upcoming = {'hold', 'awaiting_payment', 'confirmed'};
  static const _past = {'attended', 'refunded'};
  static const _cancelled = {'cancelled', 'payment_failed'};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final token = AuthState.accessToken;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please log in to view bookings.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await BookingService.listBookings(token: token, page: 1);
      if (!mounted) return;
      setState(() {
        _allBookings = page.results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<ApiBookingItem> get _filtered {
    switch (_tabIndex) {
      case 0:
        return _allBookings.where((b) => _upcoming.contains(b.status)).toList();
      case 1:
        return _allBookings.where((b) => _past.contains(b.status)).toList();
      case 2:
        return _allBookings.where((b) => _cancelled.contains(b.status)).toList();
      default:
        return _allBookings;
    }
  }

  void _onBookingUpdated(ApiBookingItem updated) {
    setState(() {
      final idx = _allBookings.indexWhere((b) => b.id == updated.id);
      if (idx != -1) _allBookings[idx] = updated;
    });
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
          'All Bookings',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _TabBar(
            tabs: _tabs,
            activeIndex: _tabIndex,
            onTap: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AppLoader();
    if (_error != null) return _buildError();
    final items = _filtered;
    if (items.isEmpty) return _buildEmpty();
    return AppRefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _BookingCard(
          booking: items[i],
          onUpdated: _onBookingUpdated,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return AppRefreshIndicator(
      onRefresh: _loadBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No ${_tabs[_tabIndex]} Bookings',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 16),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Bar ──────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final void Function(int) onTap;

  const _TabBar({
    required this.tabs,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == activeIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: active ? FontWeight.w500 : FontWeight.w500,
                      color: active ? AppColors.textPrimary : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatefulWidget {
  final ApiBookingItem booking;
  final void Function(ApiBookingItem) onUpdated;

  const _BookingCard({required this.booking, required this.onUpdated});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  /// In-memory cache shared across all _BookingCard instances — keyed by
  /// `"$bookingType:$listingId"`. `null` value means "fetched, none found".
  /// The list API doesn't include cover URLs, so each unique listing needs
  /// one detail fetch; subsequent rebuilds (tab switches, scroll) reuse the
  /// cached URL.
  static final Map<String, String?> _coverCache = {};

  String? _coverUrl;

  ApiBookingItem get booking => widget.booking;

  @override
  void initState() {
    super.initState();
    if (booking.listingCover != null && booking.listingCover!.isNotEmpty) {
      _coverUrl = booking.listingCover;
      return;
    }
    final lid = booking.listingId;
    if (lid == null || lid.isEmpty) return;
    final key = '${booking.bookingType}:$lid';
    if (_coverCache.containsKey(key)) {
      _coverUrl = _coverCache[key];
      return;
    }
    _fetchCover(key, booking.bookingType, lid);
  }

  Future<void> _fetchCover(
      String cacheKey, String bookingType, String listingId) async {
    try {
      final url = await _resolveCover(bookingType, listingId);
      _coverCache[cacheKey] = url;
      if (!mounted) return;
      setState(() => _coverUrl = url);
    } catch (_) {
      _coverCache[cacheKey] = null;
    }
  }

  static Future<String?> _resolveCover(
      String bookingType, String listingId) async {
    switch (bookingType) {
      case 'event':
        return (await EventsListingService.fetchEventDetail(listingId)).coverUrl;
      case 'class':
        return (await ClassesListingService.fetchClassDetail(listingId))
            .coverUrl;
      case 'program':
        return (await ProgramsListingService.fetchProgramDetail(listingId))
            .cover;
      case 'venue':
        return (await EventsListingService.fetchVenueDetail(listingId)).cover;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canViewTicket =
        booking.status == 'confirmed' || booking.status == 'attended';
    // Past-tab bookings (attended/refunded) render "discolored" — a muted,
    // sepia-toned look that reads as history rather than a live booking.
    final isPast = booking.status == 'attended' || booking.status == 'refunded';

    Widget thumbnail = (_coverUrl != null && _coverUrl!.isNotEmpty)
        ? Image.network(
            _coverUrl!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildPlaceholder(context, booking.bookingType),
          )
        : _buildPlaceholder(context, booking.bookingType);
    if (isPast) {
      thumbnail = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_kPastImageFilterMatrix),
        child: thumbnail,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail (cover image or placeholder) ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: thumbnail,
          ),
          const SizedBox(width: 14),

          // ── Details ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: booking.status, muted: isPast),
                const SizedBox(height: 6),

                Text(
                  booking.listingTitle,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Booking reference
                Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.bookingReference,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 10.5),
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Amount
                Row(
                  children: [
                    Icon(Icons.currency_rupee,
                        size: 13, color: Colors.grey.shade700),
                    Text(
                      _fmtAmount(booking.totalAmount),
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12.5),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // CTA
                if (canViewTicket)
                  GestureDetector(
                    onTap: () => _openDetail(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isPast
                                ? _kPastMutedColor
                                : AppColors.starAmber,
                            width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Ticket',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              size: 16, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  )
                else if (booking.status == 'payment_failed')
                  Text(
                    'Payment failed — please try again',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11),
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (booking.status == 'hold' ||
                    booking.status == 'awaiting_payment')
                  Text(
                    booking.status == 'hold'
                        ? 'Awaiting payment — expires soon'
                        : 'Processing payment…',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11),
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String type) {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF0F0F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 26, color: Colors.grey.shade400),
          const SizedBox(height: 5),
          Text(
            _typeLabel(type),
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 9),
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(
          booking: booking,
          onUpdated: widget.onUpdated,
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'event':
        return 'Event';
      case 'class':
        return 'Class';
      case 'program':
        return 'Program';
      case 'venue':
        return 'Venue';
      default:
        return type.isNotEmpty
            ? type[0].toUpperCase() + type.substring(1)
            : 'Booking';
    }
  }

  String _fmtAmount(double amount) {
    if (amount == amount.truncateToDouble()) return amount.toInt().toString();
    return amount.toStringAsFixed(2);
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool muted;
  const _StatusBadge({required this.status, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = muted ? _kPastMutedColor : _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 10.5),
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'attended':
        return const Color(0xFF22C55E);
      case 'hold':
        return const Color(0xFFF59E0B);
      case 'awaiting_payment':
        return AppColors.blue;
      case 'payment_failed':
        return const Color(0xFFEF4444);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'refunded':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed ✓';
      case 'attended':
        return 'Attended';
      case 'hold':
        return 'Awaiting Payment';
      case 'awaiting_payment':
        return 'Processing...';
      case 'payment_failed':
        return 'Payment Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
