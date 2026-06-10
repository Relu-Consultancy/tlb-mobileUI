import 'dart:math';
import '../widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_snackbar.dart';
import '../core/share_helper.dart';
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
import '../widgets/wishlist_button.dart';
import '../widgets/organizer_card.dart';
import '../widgets/detail_sections.dart';
import '../widgets/upcoming_events_section.dart';
import 'date_time_selection_screen.dart';
import 'gallery_screen.dart';

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

  /// Image URLs for the gallery row — real media if present, else the cover.
  List<String> get _galleryImages {
    final media = _galleryMedia;
    if (media.isNotEmpty) return media.map((m) => m.fileUrl).toList();
    return [_coverUrl];
  }

  Future<void> _openDirections() async {
    if (!AuthState.isLoggedIn.value) {
      showLoginSheet(context);
      return;
    }
    if (LocationState().selectedCity.value == 'Bhopal City') {
      if (mounted) AppSnackBar.show(context, 'Please set your current location');
      return;
    }
    final destination = Uri.encodeComponent(_locationText);
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not open map.');
    }
  }

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
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kDetailBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Image ──────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: kDetailBg,
                surfaceTintColor: kDetailBg,
                expandedHeight: Responsive.h(context, 230, min: 190),
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
                      onPressed: () => ShareHelper.shareListing(
                        context,
                        type: 'event',
                        title: _title,
                        id: _detail?.id ?? widget.event.id,
                      ),
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
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w500, color: Colors.white),
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

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 24, thickness: 1, color: kRowDivider),
                    ),

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

                    const SizedBox(height: 32),

                    // ── About Event ───────────────────────────────────────
                    if ((_description ?? '').isNotEmpty)
                      ExpandableAboutCard(
                        title: 'About Event',
                        text: _description!,
                      ),

                    const SizedBox(height: 32),

                    // ── Things to Know ────────────────────────────────────
                    const DetailSectionTitle('Things to Know'),
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

                    const SizedBox(height: 32),

                    // ── Gallery ───────────────────────────────────────────
                    DetailGallery(
                      images: _galleryImages,
                      onSeeAll: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => GalleryScreen(event: _eventForSheets))),
                    ),

                    const SizedBox(height: 32),

                    // ── Location map ──────────────────────────────────────
                    DetailDirectionsCard(
                      locationText: _locationText,
                      note: _detail?.address,
                      onGetDirection: _openDirections,
                    ),

                    const SizedBox(height: 32),

                    // ── Organizer ─────────────────────────────────────────
                    OrganizerCard(
                      listingId: widget.event.id,
                      partnerId: _detail?.organizer?.partnerId,
                      initialName: _detail?.organizer?.businessName,
                      initialLogoUrl: _detail?.organizer?.logoUrl,
                      listingType: 'event',
                    ),

                    // ── Terms & Conditions ──────────────────────────────
                    if (_detail != null && (
                      (_detail!.cancellationPolicy?.isNotEmpty == true) ||
                      (_detail!.refundPolicy?.isNotEmpty == true) ||
                      _detail!.faqs.isNotEmpty
                    )) ...[
                      const SizedBox(height: 32),
                      DetailTermsRow(
                        onTap: () => _showTermsConditionsBottomSheet(context),
                      ),
                    ],

                    // ── Reviews ───────────────────────────────────────────
                    if (_hasApiId) ...[
                      const SizedBox(height: 32),
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
                    //       Text('Related Events', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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

                    // ── Upcoming Events ───────────────────────────────────
                    const UpcomingEventsSection(),

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
                      child: Text('Free', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w500, color: const Color(0xFF2E7D32))),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _priceDisplay,
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
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
                        // Dummy spotlight / featured cards have no API UUID
                        // — booking would otherwise navigate three screens
                        // deep just to hit "Booking unavailable for this
                        // listing." Surface that here with a clearer hint.
                        if (!_hasApiId) {
                          AppSnackBar.show(
                            context,
                            'This is a featured highlight, not a bookable listing yet. Browse Events to find one you can book.',
                          );
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
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w500),
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


  Widget _buildThingsToKnowRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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
                  Text('Terms & Conditions', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
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
                    if (_detail?.cancellationPolicy?.isNotEmpty == true) ...[
                      Text('Cancellation Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Text(_detail!.cancellationPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.refundPolicy?.isNotEmpty == true) ...[
                      Text('Refund Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Text(_detail!.refundPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.faqs.isNotEmpty == true) ...[
                      Text('FAQs', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      ...(_detail!.faqs.map((faq) => _buildTermsBullet(faq['question'] ?? '', faq['answer'] ?? ''))),
                    ],
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
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}

