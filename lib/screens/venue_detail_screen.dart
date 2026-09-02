import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/share_helper.dart';
import '../providers/auth_state.dart';
import '../providers/location_state.dart';
import '../core/responsive.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/review_sheet.dart';
import '../widgets/organizer_card.dart';
import '../widgets/detail_sections.dart';
import '../widgets/upcoming_events_section.dart';
import '../widgets/inquire_now_sheet.dart';
import '../models/event_model.dart';
import '../models/api_venue_model.dart';
import '../services/events_listing_service.dart';
import '../services/review_service.dart';
import '../models/api_review_model.dart';
import '../widgets/login_sheet.dart';
import 'plan_party_screen.dart';
import 'gallery_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  final EventModel event;

  const VenueDetailScreen({super.key, required this.event});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  ApiVenueDetail? _detail;
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
      final detail = await EventsListingService.fetchVenueDetail(widget.event.id);
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

  // ── Data getters ──────────────────────────────────────────────────────────

  /// True when there is anything to put in the Terms & Conditions sheet.
  /// The API returns a single `terms` object; `cancellation_policy` and
  /// `refund_policy` are only present on classes, so both are checked.
  bool get _hasTerms =>
      (_detail?.terms?.hasContent ?? false) ||
      (_detail?.cancellationPolicy?.isNotEmpty == true) ||
      (_detail?.refundPolicy?.isNotEmpty == true);

  String get _title => _detail?.title ?? widget.event.title;

  String get _tag {
    if (_detail != null) {
      final sub = _detail!.subcategory?.name;
      if (sub != null && sub.isNotEmpty) return sub;
      final cat = _detail!.category.name;
      if (cat.isNotEmpty) return cat;
    }
    return widget.event.tag ?? '';
  }

  String get _locationText {
    if (_detail != null) {
      return [_detail!.area, _detail!.city]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
    }
    return widget.event.venue;
  }

  String? get _address => _detail?.address;

  /// What the location row shows. Prefers the full street address — the map
  /// card that used to carry it is gone, so this row is now its only home.
  String get _addressText {
    final address = _address?.trim();
    return (address != null && address.isNotEmpty) ? address : _locationText;
  }

  String? get _description => _detail?.description ?? widget.event.description;

  String get _coverUrl {
    if (_detail?.cover?.isNotEmpty == true) return _detail!.cover!;
    return widget.event.imagePath;
  }

  bool get _isCoverNetwork => _coverUrl.startsWith('http');

  String? get _ageGroupText {
    final d = _detail;
    if (d == null) return null;
    if (d.minAge != null && d.maxAge != null) return '${d.minAge}–${d.maxAge} years';
    if (d.minAge != null) return '${d.minAge}+ years';
    return null;
  }

  String? get _capacityText {
    final d = _detail;
    if (d == null) return null;
    if (d.minCapacity != null && d.maxCapacity != null) return '${d.minCapacity}–${d.maxCapacity} guests';
    if (d.maxCapacity != null) return 'Up to ${d.maxCapacity} guests';
    return null;
  }

  String? get _locationTypeText {
    final lt = _detail?.locationType;
    if (lt == null || lt.isEmpty) return null;
    return lt[0].toUpperCase() + lt.substring(1);
  }

  double? get _lowestPackagePrice {
    final pkgs = _detail?.packages;
    if (pkgs == null || pkgs.isEmpty) return widget.event.price;
    if (pkgs.isEmpty) return null;
    return pkgs.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  List<ApiVenueMedia> get _galleryMedia =>
      _detail?.galleryMedia ?? [];

  /// Image URLs for the gallery row — real media if present, else the cover.
  List<String> get _galleryImages {
    if (_galleryMedia.isNotEmpty) {
      return _galleryMedia.map((m) => m.url).toList();
    }
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
    final destination = Uri.encodeComponent(_addressText);
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not open map.');
    }
  }

  // First upcoming availability slot
  ApiVenueAvailability? get _firstSlot {
    final av = _detail?.availability;
    if (av == null || av.isEmpty) return null;
    return av.first;
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  EventModel get _eventForWidgets => EventModel(
        id: widget.event.id,
        title: _title,
        venue: _locationText,
        imagePath: _isCoverNetwork ? '' : _coverUrl,
        tag: _tag.isNotEmpty ? _tag : null,
        price: _lowestPackagePrice,
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const AppLoader(),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFB0B0B0)),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
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
              // ── Cover image header ──
              SliverAppBar(
                backgroundColor: kDetailBg,
                surfaceTintColor: kDetailBg,
                expandedHeight: Responsive.h(context, 250, min: 210),
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: WishlistButton(event: _eventForWidgets, containerSize: 40, showShadow: false),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                      onPressed: () => ShareHelper.shareListing(
                        context,
                        type: 'venue',
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
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(child: Icon(Icons.place, size: 60, color: Colors.grey)),
                            ),
                          )
                        : _coverUrl.isNotEmpty
                            ? Image.asset(
                                _coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.place, size: 60, color: Colors.grey)),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.place, size: 60, color: Colors.grey)),
                              ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Category tag ──
                    if (_tag.isNotEmpty) DetailCategoryTag(_tag),

                    const SizedBox(height: 12),

                    // ── Title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _title,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 20),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Location ──
                    if (_addressText.isNotEmpty)
                      DetailLocationRow(
                        text: _addressText,
                        onNavigate: _openDirections,
                      ),

                    // ── First availability slot ──
                    if (_firstSlot != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 24, thickness: 1, color: kRowDivider),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const DetailRowIcon(Icons.calendar_today_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_formatDate(_firstSlot!.date)}, ${_formatTime(_firstSlot!.startTime)} – ${_formatTime(_firstSlot!.endTime)}',
                                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── About Venue ──
                    if (_description?.isNotEmpty == true) ...[
                      ExpandableAboutCard(
                        title: 'About Venue',
                        text: _description!,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── Things to Know ──
                    if (_ageGroupText != null || _capacityText != null || _locationTypeText != null) ...[
                      const DetailSectionTitle('Things to Know'),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            if (_ageGroupText != null) ...[
                              _buildInfoRow(Icons.group_outlined, 'Age Group', _ageGroupText!),
                              if (_capacityText != null || _locationTypeText != null)
                                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_capacityText != null) ...[
                              _buildInfoRow(Icons.people_outline, 'Capacity', _capacityText!),
                              if (_locationTypeText != null)
                                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_locationTypeText != null)
                              _buildInfoRow(Icons.home_outlined, 'Venue Type', _locationTypeText!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── Gallery ──
                    DetailGallery(
                      images: _galleryImages,
                      onSeeAll: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => GalleryScreen(event: _eventForWidgets))),
                    ),

                    const SizedBox(height: 32),

                    // ── Organizer ──
                    OrganizerCard(
                      listingId: widget.event.id,
                      partnerId: _detail?.organizer?.partnerId,
                      initialName: _detail?.organizer?.businessName,
                      initialLogoUrl: _detail?.organizer?.logoUrl,
                      label: 'MANAGED BY',
                      listingType: 'venue',
                    ),
                    const SizedBox(height: 32),


                    // ── Terms & Conditions ────────────────────────────────
                    if (_hasTerms) ...[
                      DetailTermsRow(
                        onTap: () => _showTermsBottomSheet(context),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── FAQs ──────────────────────────────────────────────
                    if (_detail != null && _detail!.faqs.isNotEmpty) ...[
                      DetailTermsRow(
                        title: 'FAQs',
                        icon: Icons.help_outline,
                        onTap: () =>
                            showListingFaqsSheet(context, _detail!.faqs),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── Reviews ───────────────────────────────────────────
                    if (_hasApiId) ...[
                      const SizedBox(height: 8),
                      buildReviewInlineSection(
                        context,
                        listingId: widget.event.id,
                        listingTitle: _title,
                        listingImage: _coverUrl.isNotEmpty ? _coverUrl : null,
                        reviewPage: _reviewPage,
                        isLoading: _reviewLoading,
                        onRefresh: _fetchReviews,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // ── Related Venues — commented out until multiple venues available ──
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: Text('Related Venues', ...),
                    // ),

                    // ── Upcoming Events ───────────────────────────────────
                    UpcomingEventsSection(
                      // Never advertise the listing being viewed.
                      excludeListingId: widget.event.id,
                    ),

                    SizedBox(height: Responsive.h(context, 100)),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky bottom bar ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  if (_lowestPackagePrice != null && _lowestPackagePrice! > 0)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${_lowestPackagePrice!.toInt()}',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 20),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary),
                          ),
                          TextSpan(
                              text: '/',
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    Text('Free',
                        style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF16A34A))),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!AuthState.isLoggedIn.value) {
                          showLoginSheet(context);
                          return;
                        }
                        if (!_hasApiId) {
                          AppSnackBar.show(
                            context,
                            'This is a featured highlight, not a bookable venue yet. Browse Venues to find one you can book.',
                          );
                          return;
                        }
                        // Enquiry-only venues open the enquiry sheet; direct
                        // booking venues proceed to the booking flow.
                        if (_detail?.isEnquiry == true) {
                          showInquireNow(
                            context,
                            listingId: widget.event.id,
                            isVenue: true,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlanPartyScreen(
                              event: _eventForWidgets,
                              venueDetail: _detail,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                          _detail?.isEnquiry == true
                              ? 'Send Enquiry'
                              : 'Check Availability',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // A shade darker than the label beside it, so the left rail of
          // glyphs reads as present rather than disabled.
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
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
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 17), fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
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
                    if (_detail?.terms?.content?.trim().isNotEmpty == true) ...[
                      Text(_detail!.terms!.content!.trim(), style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.cancellationPolicy?.isNotEmpty == true) ...[
                      Text('Cancellation Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text(_detail!.cancellationPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.refundPolicy?.isNotEmpty == true) ...[
                      Text('Refund Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text(_detail!.refundPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
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

}
