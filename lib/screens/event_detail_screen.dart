import 'dart:math';
import '../widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/location_state.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/api_event_model.dart';
import '../models/event_model.dart';
import '../providers/auth_state.dart';
import '../services/events_listing_service.dart';
import '../models/api_review_model.dart';
import '../services/review_service.dart';
import '../widgets/login_sheet.dart';
import '../widgets/review_sheet.dart';
import '../widgets/partner_follow_button.dart';
import '../widgets/wishlist_button.dart';
import 'date_time_selection_screen.dart';
import 'gallery_screen.dart';
import 'organizer_profile_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  ApiEventDetail? _detail;
  bool _isLoading = false;
  String? _error;

  ApiReviewPage? _reviewPage;
  bool _reviewLoading = false;

  bool get _hasApiId => widget.event.id.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasApiId) {
      _fetchDetail();
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _reviewLoading = true);
    try {
      final page = await ReviewService.fetchReviews(widget.event.id, pageSize: 3);
      if (!mounted) return;
      setState(() { _reviewPage = page; _reviewLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reviewLoading = false);
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await EventsListingService.fetchEventDetail(widget.event.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Derived display values ────────────────────────────────────────────────

  String get _title => _detail?.title ?? widget.event.title;
  String get _tag => _detail?.subcategory?.name ?? _detail?.category.name ?? widget.event.tag ?? '';

  String get _locationText {
    if (_detail == null) return widget.event.venue;
    final parts = <String>[];
    if ((_detail!.area ?? '').isNotEmpty) parts.add(_detail!.area!);
    parts.add(_detail!.city);
    return parts.join(', ');
  }

  String get _dateTimeText {
    if (_detail == null) {
      return '${widget.event.eventDate ?? "TBD"}, ${widget.event.eventTime ?? ""}';
    }
    final start = _detail!.startDatetime.toLocal();
    final date = _formatDate(start);
    final startTime = _formatTime(start);
    if (_detail!.endDatetime != null) {
      return '$date, $startTime – ${_formatTime(_detail!.endDatetime!.toLocal())}';
    }
    return '$date, $startTime';
  }

  String? get _description => _detail?.description ?? widget.event.description;

  String get _coverUrl => _detail?.coverUrl ?? widget.event.imagePath;
  bool get _isCoverNetwork => _coverUrl.startsWith('http');

  double? get _lowestTicketPrice {
    if (_detail == null || _detail!.tickets.isEmpty) return widget.event.price;
    return _detail!.tickets.map((t) => t.price).reduce(min);
  }

  String get _priceDisplay {
    if (_detail != null) {
      if (_detail!.priceType == 'free') return 'Free';
      final low = _lowestTicketPrice;
      if (low != null) return '₹${low.toStringAsFixed(0)}';
      if (_detail!.priceFrom != null) return '₹${_detail!.priceFrom}';
      return 'Paid';
    }
    return widget.event.price != null ? '₹${widget.event.price!.toStringAsFixed(0)}' : '₹0';
  }

  bool get _isFree => _detail?.priceType == 'free';

  List<ApiEventMedia> get _galleryMedia =>
      _detail?.media.where((m) => m.mediaType != 'cover').toList() ?? [];

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  EventModel get _eventForSheets => EventModel(
        id: _detail?.id ?? widget.event.id,
        title: _title,
        venue: _locationText,
        imagePath: _coverUrl,
        tag: _tag.isNotEmpty ? _tag : null,
        price: _lowestTicketPrice,
        rating: widget.event.rating,
        reviewCount: widget.event.reviewCount,
        eventDate: _detail != null
            ? _formatDate(_detail!.startDatetime.toLocal())
            : widget.event.eventDate,
        eventTime: _detail != null
            ? _formatTime(_detail!.startDatetime.toLocal())
            : widget.event.eventTime,
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: AppLoader(),
      );
    }

    if (_error != null && _detail == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Image ──────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                expandedHeight: Responsive.h(context, 300, min: 220),
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: WishlistButton(event: _eventForSheets, containerSize: 40, showShadow: false),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: Color(0xFF1A1A2E), size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: _isCoverNetwork
                        ? Image.network(
                            _coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : Image.asset(
                            _coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Tag ───────────────────────────────────────────────
                    if (_tag.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC00),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _tag,
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ── Title ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _title,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 20),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Location ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                            child: const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationText,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF1A1A2E)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Date & Time ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                            child: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateTimeText,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF1A1A2E)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── About Event ───────────────────────────────────────
                    if ((_description ?? '').isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About Event',
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _description!,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600, height: 1.5),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Things to Know ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Things to Know',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (_detail?.ageGroup != null && _detail!.ageGroup!.displayRange.isNotEmpty) ...[
                            _buildThingsToKnowRow(Icons.group_outlined, 'Age Group', _detail!.ageGroup!.displayRange),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                          ],
                          if (_detail != null) ...[
                            _buildThingsToKnowRow(Icons.style_outlined, 'Format', _capitalize(_detail!.format)),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildThingsToKnowRow(
                              _detail!.mode == 'online' ? Icons.videocam_outlined : Icons.place_outlined,
                              'Mode',
                              _capitalize(_detail!.mode),
                            ),
                            if (_detail!.availableSeats != null) ...[
                              const Divider(height: 16, color: Color(0xFFEEEEEE)),
                              _buildThingsToKnowRow(Icons.check_circle_outline, 'Available', '${_detail!.availableSeats} spots'),
                            ],
                          ] else ...[
                            _buildThingsToKnowRow(Icons.group_outlined, 'Age Group', '3 - 10 yrs'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildThingsToKnowRow(Icons.translate, 'Language', 'English'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildThingsToKnowRow(Icons.check_circle_outline, 'Available', '20 Spots available'),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Gallery ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gallery', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryScreen(event: _eventForSheets))),
                            child: Text('See All >', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Sneak peek into what awaits you!', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                    ),
                    const SizedBox(height: 12),
                    _buildGallery(context),

                    const SizedBox(height: 24),

                    // ── Location map ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Location', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: Responsive.h(context, 180, min: 140),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFFE8F0E8)),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CustomPaint(painter: _MapPlaceholderPainter()),
                            ),
                          ),
                          const Positioned(
                            top: 12, left: 0, right: 0,
                            child: Icon(Icons.location_on, size: 36, color: Color(0xFFD32F2F)),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16, left: 16, right: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _locationText,
                                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                if ((_detail?.address ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _detail!.address!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: const Color(0xFFFFCC00)),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: Responsive.h(context, 44, min: 38),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      if (!AuthState.isLoggedIn.value) {
                                        showLoginSheet(context);
                                        return;
                                      }
                                      if (LocationState().selectedCity.value == 'Bhopal City') {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please set your current location')),
                                          );
                                        }
                                        return;
                                      }
                                      final destination = Uri.encodeComponent(_locationText);
                                      final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destination');
                                      try {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Could not open map.')),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.directions, size: 16),
                                    label: Text(
                                      'Get Direction',
                                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFCC00),
                                      foregroundColor: const Color(0xFF1A1A2E),
                                      elevation: 0,
                                      minimumSize: const Size(0, 46),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Organizer ─────────────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrganizerProfileScreen(
                            listingId: widget.event.id,
                            initialName: _detail?.organizer?.businessName,
                            initialLogoUrl: _detail?.organizer?.logoUrl,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: Responsive.w(context, 54, min: 46),
                              height: Responsive.w(context, 54, min: 46),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(27),
                                child: _buildOrganizerAvatar(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ORGANIZED BY', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w600, color: const Color(0xFFF5A623), letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _detail?.organizer?.businessName ?? 'Fun Event Co.',
                                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
                                  ),
                                ],
                              ),
                            ),
                            PartnerFollowButton(
                              partnerId: _detail?.organizer?.partnerId,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Terms & Conditions (only for non-API events) ──────
                    if (_detail == null) ...[
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _showTermsConditionsBottomSheet(context),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined, size: 24, color: Colors.grey.shade600),
                              const SizedBox(width: 14),
                              Expanded(child: Text('Terms & Conditions', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)))),
                              Icon(Icons.chevron_right, color: Colors.blue.shade500, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ── Reviews ───────────────────────────────────────────
                    if (_hasApiId) ...[
                      const SizedBox(height: 24),
                      buildReviewInlineSection(
                        context,
                        listingId: widget.event.id,
                        listingTitle: _title,
                        listingImage: _coverUrl,
                        reviewPage: _reviewPage,
                        isLoading: _reviewLoading,
                        onRefresh: _fetchReviews,
                      ),
                    ],

                    // ── Related Events ────────────────────────────────────
                    // TODO: Uncomment when multiple events are available via API
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text('Related Events', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                    //       Text('See All >', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6))),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // SizedBox(
                    //   height: Responsive.h(context, 220, min: 180),
                    //   child: ListView(
                    //     scrollDirection: Axis.horizontal,
                    //     padding: const EdgeInsets.symmetric(horizontal: 16),
                    //     children: [
                    //       _buildRelatedEventCard(context, 'Halloween Party', 'assets/images/halloween_party.png', 'Central Park, NYC', 'Limited Seats'),
                    //       _buildRelatedEventCard(context, 'Kids Party', 'assets/images/kids_party.png', 'Fun Zone, Mumbai', 'Limited Seats'),
                    //       _buildRelatedEventCard(context, 'World Book Day', 'assets/images/story_telling.png', 'Library Hall, Delhi', 'Open'),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: Responsive.h(context, 100)),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Bar ───────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  if (_isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Free', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32))),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _priceDisplay,
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                          ),
                          TextSpan(text: '/', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey)),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!AuthState.isLoggedIn.value) {
                          showLoginSheet(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DateTimeSelectionScreen(
                              event: _eventForSheets,
                              apiTickets: _detail?.tickets,
                              eventDateTime: _detail?.startDatetime,
                              eventEndDateTime: _detail?.endDatetime,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        _isFree ? 'Register Now' : 'Book Now',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────────

  Widget _imagePlaceholder() => Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.event, size: 60, color: Colors.grey)),
      );

  Widget _buildOrganizerAvatar() {
    final logoUrl = _detail?.organizer?.logoUrl;
    final name = _detail?.organizer?.businessName ?? '';
    if (logoUrl != null) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _organizerInitial(name),
      );
    }
    if (name.isNotEmpty) return _organizerInitial(name);
    return Image.asset('assets/images/new_home/profilepic.jpg', fit: BoxFit.cover);
  }

  Widget _organizerInitial(String name) => Container(
        color: const Color(0xFFFFF5E0),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
          ),
        ),
      );

  Widget _buildGallery(BuildContext context) {
    final media = _galleryMedia;
    if (media.isNotEmpty) {
      return SizedBox(
        height: Responsive.h(context, 100, min: 80),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: media.length,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(right: 12),
            width: Responsive.w(context, 120, min: 90),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(media[index].fileUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
            ),
          ),
        ),
      );
    }
    // Fall back to cover image or asset
    return SizedBox(
      height: Responsive.h(context, 100, min: 80),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 1,
        itemBuilder: (context, _) => Container(
          margin: const EdgeInsets.only(right: 12),
          width: Responsive.w(context, 120, min: 90),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isCoverNetwork
                ? Image.network(_coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200))
                : Image.asset(_coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
          ),
        ),
      ),
    );
  }

  Widget _buildThingsToKnowRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildRelatedEventCard(BuildContext context, String title, String imagePath, String location, String tag) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.41, max: 160),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  width: Responsive.cardWidth(context, fraction: 0.41, max: 160),
                  height: Responsive.h(context, 120, min: 90),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 120, min: 90), color: Colors.grey.shade200),
                ),
              ),
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tag == 'Limited Seats' ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheets ─────────────────────────────────────────────────────────

  void _showTermsConditionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terms & Conditions', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supervision & Responsibility', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 10),
                    _buildTermsBullet('Adult Presence:', 'All children under the age of 14 must be accompanied and supervised by a parent or legal guardian throughout the event.'),
                    _buildTermsBullet('Sign-in/Sign-out:', 'Guardians must register children at the entrance and sign them out personally at the end of the activities.'),
                    _buildTermsBullet('Conduct:', 'Parents or guardians are fully responsible for the behavior and safety of their children at all times.'),
                    const SizedBox(height: 20),
                    Text('Health & Safety Rules', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 10),
                    _buildTermsBullet('Attire:', 'All children must be dressed appropriately for the activity. For play zones, socks are often required, and sharp objects must be removed for safety.'),
                    _buildTermsBullet('Illness Policy:', 'Children showing signs of communicable illness will not be permitted to participate. Please inform us in advance if your child needs special accommodations.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsBullet(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE8F0E8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    final roadPaint = Paint()
      ..color = const Color(0xFFD0D8D0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    final accentPaint = Paint()
      ..color = const Color(0xFFC8E0C8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 12, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 16, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 10, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
