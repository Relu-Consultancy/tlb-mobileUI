import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/share_helper.dart';
import '../providers/auth_state.dart';
import '../providers/location_state.dart';
import '../widgets/login_sheet.dart';
import '../core/responsive.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/review_sheet.dart';
import '../widgets/organizer_card.dart';
import '../widgets/detail_sections.dart';
import '../widgets/upcoming_events_section.dart';
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
  /// True when there is anything to put in the Terms & Conditions sheet.
  /// The API returns a single `terms` object; `cancellation_policy` and
  /// `refund_policy` are only present on classes, so both are checked.
  bool get _hasTerms =>
      (_detail?.terms?.hasContent ?? false) ||
      (_detail?.cancellationPolicy?.isNotEmpty == true) ||
      (_detail?.refundPolicy?.isNotEmpty == true);

  String get _title => _detail?.title ?? widget.event.title;
  String get _tag => _detail?.subcategory?.name ?? _detail?.category.name ?? widget.event.tag ?? 'Class';
  String get _coverUrl => _detail?.coverUrl ?? widget.event.imagePath;
  bool get _isCoverNetwork => _coverUrl.startsWith('http');

  /// Image URLs for the gallery row — real media if present, else the cover.
  List<String> get _galleryImages {
    final media =
        _detail?.media.where((m) => m.mediaType != 'cover').toList() ?? [];
    if (media.isNotEmpty) return media.map((m) => m.url).toList();
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
    // The full street address, not the area/city summary: it routes to the
    // actual door rather than the middle of the neighbourhood.
    final destination = Uri.encodeComponent(_addressText);
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not open map.');
    }
  }
  String? get _description => _detail?.description ?? widget.event.description;

  String get _locationText {
    if (_detail == null) return widget.event.venue;
    if (_detail!.mode == 'online') return 'Online';
    final parts = <String>[];
    if (_detail!.area != null && _detail!.area!.isNotEmpty) parts.add(_detail!.area!);
    if (_detail!.city.isNotEmpty) parts.add(_detail!.city);
    return parts.isEmpty ? 'Location TBA' : parts.join(', ');
  }

  bool get _isOnline => _detail?.mode == 'online';

  /// Languages the partner set on the listing, or null when they set none —
  /// in which case the row is left off rather than shown blank.
  String? get _languageText => _detail?.languageLabel;

  /// What the location row shows. Prefers the full street address — the map
  /// card that used to carry it is gone, so this row is now its only home —
  /// and falls back to the area/city summary (or "Online") otherwise.
  String get _addressText {
    if (_isOnline) return _locationText;
    final address = _detail?.address?.trim();
    return (address != null && address.isNotEmpty) ? address : _locationText;
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
    price: _detail?.price ?? widget.event.price,
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
          ElevatedButton(onPressed: _fetchDetail, style: ElevatedButton.styleFrom(backgroundColor: AppColors.textSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)), child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500))),
        ])),
      );
    }
    return Scaffold(
      backgroundColor: kDetailBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: kDetailBg,
                surfaceTintColor: kDetailBg,
                expandedHeight: Responsive.h(context, 250, min: 210),
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
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
                      icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                      onPressed: () => ShareHelper.shareListing(
                        context,
                        type: 'class',
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
                    if (_tag.isNotEmpty) DetailCategoryTag(_tag),

                    const SizedBox(height: 12),

                    // Title
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
                    DetailLocationRow(
                      text: _addressText,
                      icon: _isOnline
                          ? Icons.videocam_outlined
                          : Icons.location_on_outlined,
                      // Online classes have no address to route to.
                      onNavigate: _isOnline ? null : _openDirections,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 24, thickness: 1, color: kRowDivider),
                    ),

                    // Schedule
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const DetailRowIcon(Icons.calendar_today_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _scheduleText,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // About Class
                    if ((_description ?? '').isNotEmpty)
                      ExpandableAboutCard(
                        title: 'About Class',
                        text: _description!,
                      ),

                    const SizedBox(height: 32),

                    // Things to Know
                    const DetailSectionTitle('Things to Know'),
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
                          if (_languageText != null) ...[
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildInfoRow(
                                Icons.translate, 'Language', _languageText!),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Gallery
                    DetailGallery(
                      images: _galleryImages,
                      onSeeAll: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => GalleryScreen(event: _eventForSheets))),
                    ),

                    const SizedBox(height: 32),

                    // Organizer
                    OrganizerCard(
                      listingId: widget.event.id,
                      partnerId: _detail?.organizer?.partnerId,
                      initialName: _detail?.organizer?.businessName,
                      initialLogoUrl: _detail?.organizer?.logoUrl,
                      listingType: 'class',
                    ),

                    const SizedBox(height: 32),


                    // Terms & Conditions
                    if (_hasTerms) DetailTermsRow(
                      onTap: () => _showTermsBottomSheet(context),
                    ),

                    // FAQs
                    if (_detail != null && _detail!.faqs.isNotEmpty && _hasTerms)
                      const SizedBox(height: 16),
                    if (_detail != null && _detail!.faqs.isNotEmpty)
                      DetailTermsRow(
                        title: 'FAQs',
                        icon: Icons.help_outline,
                        onTap: () =>
                            showListingFaqsSheet(context, _detail!.faqs),
                      ),

                    const SizedBox(height: 32),

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
                final price = _detail?.price ?? widget.event.price;
                final showPrice = isDirectBooking && price != null;
                return Row(
                  children: [
                    if (showPrice)
                      // No `from:` — a class fee is exact, not a floor.
                      DetailPriceLabel('₹${price.toStringAsFixed(0)}'),
                    // Fixed gap, not a Spacer with a flex:2 button: that
                    // split the leftover 1:2 and could starve the CTA.
                    if (showPrice) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_hasApiId) {
                            AppSnackBar.show(
                              context,
                              'This is a featured highlight, not a bookable class yet. Browse Classes to find one you can book.',
                            );
                            return;
                          }
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
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          isDirectBooking ? 'Check Availability' : 'Enquire Now',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w600),
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
          Text(value, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
