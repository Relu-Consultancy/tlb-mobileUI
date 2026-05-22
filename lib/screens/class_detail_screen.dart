import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../providers/auth_state.dart';
import '../providers/location_state.dart';
import '../widgets/login_sheet.dart';
import '../core/responsive.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/review_sheet.dart';
import '../widgets/organizer_card.dart';
import '../models/event_model.dart';
import '../models/api_class_model.dart';
import '../services/classes_listing_service.dart';
import '../services/review_service.dart';
import '../models/api_review_model.dart';
import '../widgets/app_loader.dart';
import 'gallery_screen.dart';
import 'select_batch_screen.dart';
import '../widgets/inquire_now_sheet.dart';

class ClassDetailScreen extends StatefulWidget {
  final EventModel event;
  final String buttonLabel;
  final VoidCallback? onBookTapped;

  const ClassDetailScreen({
    super.key,
    required this.event,
    this.buttonLabel = 'Send Enquiry',
    this.onBookTapped,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  ApiClassDetail? _detail;
  bool _isLoading = false;
  String? _error;

  ApiReviewPage? _reviewPage;
  bool _reviewLoading = false;

  bool get _hasApiId => widget.event.id.isNotEmpty;

  // ── Derived display helpers ──
  String get _title => _detail?.title ?? widget.event.title;
  String get _tag => _detail?.subcategory?.name ?? _detail?.category.name ?? widget.event.tag ?? 'Class';
  String get _coverUrl => _detail?.coverUrl ?? widget.event.imagePath;
  bool get _isCoverNetwork => _coverUrl.startsWith('http');
  String? get _description => _detail?.description ?? widget.event.description;

  String get _locationText {
    if (_detail == null) return widget.event.venue;
    if (_detail!.mode == 'online') return 'Online';
    final parts = <String>[];
    if (_detail!.area != null && _detail!.area!.isNotEmpty) parts.add(_detail!.area!);
    if (_detail!.city.isNotEmpty) parts.add(_detail!.city);
    return parts.isEmpty ? 'Location TBA' : parts.join(', ');
  }

  String get _scheduleText {
    if (_detail == null) return widget.event.eventDate ?? 'Schedule TBA';
    if (_detail!.batches.isNotEmpty) {
      final b = _detail!.batches.first;
      final days = b.days.map((d) => d.length >= 3 ? '${d[0].toUpperCase()}${d.substring(1)}' : d).join(', ');
      return '$days • ${b.startTime} – ${b.endTime}';
    }
    return 'Schedule TBA';
  }

  String get _ratingText {
    if (_detail != null && _detail!.totalReviews > 0) {
      return '${_detail!.averageRating.toStringAsFixed(1)} (${_detail!.totalReviews} reviews)';
    }
    return widget.event.reviewCount ?? '(0 reviews)';
  }

  int get _fullStars => (_detail?.averageRating ?? 4.5).floor();
  bool get _hasHalfStar => ((_detail?.averageRating ?? 4.5) - _fullStars) >= 0.25;

  EventModel get _eventForSheets => EventModel(
    id: _detail?.id ?? widget.event.id,
    title: _title,
    venue: _locationText,
    imagePath: _coverUrl,
    tag: _tag.isNotEmpty ? _tag : null,
    price: widget.event.price,
    rating: _detail?.averageRating ?? widget.event.rating,
    reviewCount: _detail != null && _detail!.totalReviews > 0
        ? '(${_detail!.totalReviews} reviews)'
        : widget.event.reviewCount,
  );

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
    setState(() { _isLoading = true; _error = null; });
    try {
      final detail = await ClassesListingService.fetchClassDetail(widget.event.id);
      if (!mounted) return;
      setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  static String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: AppLoader());
    }
    if (_error != null && _detail == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade600))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _fetchDetail, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)), child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
        ])),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                expandedHeight: Responsive.h(context, 300, min: 220),
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: WishlistButton(
                      event: _eventForSheets,
                      containerSize: 40,
                      showShadow: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
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
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(child: Icon(Icons.school, size: 60, color: Colors.grey)),
                            ),
                          )
                        : Image.asset(
                            _coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(child: Icon(Icons.school, size: 60, color: Colors.grey)),
                            ),
                          ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Tag
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
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
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

                    const SizedBox(height: 8),

                    // Rating
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(
                              _fullStars,
                              (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
                            ),
                          ),
                          if (_hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 18),
                          ...List.generate(5 - _fullStars - (_hasHalfStar ? 1 : 0), (_) => const Icon(Icons.star_border, color: Colors.amber, size: 18)),
                          const SizedBox(width: 8),
                          Text(
                            _ratingText,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _detail?.mode == 'online' ? Icons.videocam_outlined : Icons.location_on_outlined,
                              size: 20, color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationText,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Schedule
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _scheduleText,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About Class
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
                              'About Class',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 16),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _description!,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Things to Know
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Things to Know',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (_detail?.ageGroup != null && _detail!.ageGroup!.displayRange.isNotEmpty) ...[
                            _buildInfoRow(Icons.group_outlined, 'Age Group', _detail!.ageGroup!.displayRange),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                          ] else ...[
                            _buildInfoRow(Icons.group_outlined, 'Age Group', '6 - 16 yrs'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                          ],
                          if (_detail != null && _detail!.format.isNotEmpty) ...[
                            _buildInfoRow(Icons.style_outlined, 'Format', _capitalize(_detail!.format)),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                          ],
                          if (_detail != null && _detail!.mode.isNotEmpty)
                            _buildInfoRow(
                              _detail!.mode == 'online' ? Icons.videocam_outlined : Icons.place_outlined,
                              'Mode',
                              _capitalize(_detail!.mode),
                            )
                          else
                            _buildInfoRow(Icons.event_seat_outlined, 'Slots Available', '12 Slots available'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Gallery
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

                    // Location map (only for offline/hybrid)
                    if (_detail?.mode != 'online') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Location',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: Responsive.h(context, 180, min: 140),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFE8F0E8),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CustomPaint(painter: _MapPlaceholderPainter()),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Icon(Icons.location_on, size: 36, color: Colors.red.shade600),
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
                            bottom: 16,
                            left: 16,
                            right: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _locationText,
                                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                                if ((_detail?.address ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(_detail!.address!, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: const Color(0xFFFFCC00))),
                                ] else ...[
                                  const SizedBox(height: 4),
                                  Text('Free parking available on-site', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: const Color(0xFFFFCC00))),
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
                                          AppSnackBar.show(context, 'Please set your current location');
                                        }
                                        return;
                                      }
                                      final destination = Uri.encodeComponent(_locationText);
                                      final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destination');
                                      try {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } catch (_) {
                                        if (context.mounted) {
                                          AppSnackBar.error(context, 'Could not open map.');
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.directions, size: 16),
                                    label: Text(
                                      'Get Direction',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFCC00),
                                      foregroundColor: const Color(0xFF1A1A2E),
                                      elevation: 0,
                                      minimumSize: const Size(0, 46),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
                    ],

                    const SizedBox(height: 24),

                    // Organizer
                    OrganizerCard(
                      listingId: widget.event.id,
                      partnerId: _detail?.organizer?.partnerId,
                      initialName: _detail?.organizer?.businessName,
                      initialLogoUrl: _detail?.organizer?.logoUrl,
                    ),

                    const SizedBox(height: 24),

                    // Terms & Conditions
                    if (_detail != null && (
                      (_detail!.cancellationPolicy?.isNotEmpty == true) ||
                      (_detail!.refundPolicy?.isNotEmpty == true) ||
                      _detail!.faqs.isNotEmpty
                    )) GestureDetector(
                      onTap: () => _showTermsBottomSheet(context),
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
                            Expanded(
                              child: Text(
                                'Terms & Conditions',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.blue.shade500, size: 24),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reviews
                    if (_hasApiId) ...[
                      const SizedBox(height: 8),
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

                    SizedBox(height: Responsive.h(context, 100)),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Builder(builder: (context) {
                final isDirectBooking =
                    _detail?.bookingType == 'direct_booking';
                final showPrice = isDirectBooking && widget.event.price != null;
                return Row(
                  children: [
                    if (showPrice)
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(text: '₹${widget.event.price!.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          TextSpan(text: '/mo', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey)),
                        ]),
                      ),
                    if (showPrice) const Spacer(),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isDirectBooking) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelectBatchScreen(
                                  event: _eventForSheets,
                                  batches: _detail?.batches ?? [],
                                ),
                              ),
                            );
                          } else {
                            showInquireNow(context,
                                listingId: _detail?.id ?? widget.event.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00),
                          foregroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          isDirectBooking ? 'Check Availability' : 'Enquire Now',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                  ),
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
                      Text('Cancellation Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Text(_detail!.cancellationPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.refundPolicy?.isNotEmpty == true) ...[
                      Text('Refund Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      Text(_detail!.refundPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.faqs.isNotEmpty == true) ...[
                      Text('FAQs', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
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
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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

  Widget _buildGallery(BuildContext context) {
    final mediaItems = _detail?.media.where((m) => m.mediaType != 'cover').toList() ?? [];
    if (mediaItems.isEmpty) {
      // Fallback: show cover image repeated
      return SizedBox(
        height: Responsive.h(context, 100, min: 80),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
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
    return SizedBox(
      height: Responsive.h(context, 100, min: 80),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mediaItems.length,
        itemBuilder: (context, index) {
          final m = mediaItems[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: Responsive.w(context, 120, min: 90),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(m.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
            ),
          );
        },
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
    final accentPaint = Paint()..color = const Color(0xFFC8E0C8)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 12, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 16, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 10, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
