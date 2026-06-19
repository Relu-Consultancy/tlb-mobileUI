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
import '../models/api_program_model.dart';
import '../services/programs_listing_service.dart';
import '../services/review_service.dart';
import '../models/api_review_model.dart';
import '../widgets/app_loader.dart';
import 'gallery_screen.dart';
import 'select_program_batch_screen.dart';
import '../widgets/inquire_now_sheet.dart';

class ProgramDetailScreen extends StatefulWidget {
  final EventModel event;

  const ProgramDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  ApiProgramDetail? _detail;
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
      final detail = await ProgramsListingService.fetchProgramDetail(widget.event.id);
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
  
  String get _tag {
    if (_detail == null) return widget.event.tag ?? 'Program';
    return _detail!.subcategory?.name ?? _detail!.category?.name ?? 'Program';
  }

  String get _locationText {
    if (_detail == null) return widget.event.venue;
    
    if (_detail!.deliveryMode == 'online') return 'Online';
    
    final parts = <String>[];
    final area = _detail!.area;
    final city = _detail!.city;
    
    if (area != null && area.isNotEmpty) parts.add(area);
    if (city != null && city.isNotEmpty) parts.add(city);
    return parts.isEmpty ? 'Location TBA' : parts.join(', ');
  }

  String get _scheduleText {
    if (_detail == null) {
      return widget.event.eventDate ?? 'Schedule TBA';
    }
    
    final batches = _detail!.batches;
        
    if (batches.isNotEmpty) {
      final b = batches.first;
      final days = b.daysOfWeek.join(', ');
      if (b.startTime != null && b.endTime != null) {
        return '$days • ${b.startTime} - ${b.endTime}';
      }
      return days.isNotEmpty ? days : 'Schedule TBA';
    }
    return 'Schedule TBA';
  }

  String? get _description => _detail?.description ?? widget.event.description;

  String get _coverUrl {
    if (_detail == null) return widget.event.imagePath;
    return _detail!.cover ?? widget.event.imagePath;
  }
  
  bool get _isCoverNetwork => _coverUrl.startsWith('http');

  String get _priceDisplay {
    if (_detail?.feeFrom != null) return '₹${_detail!.feeFrom}';
    return widget.event.price != null ? '₹${widget.event.price!.toStringAsFixed(0)}' : 'Price TBA';
  }

  List<ApiProgramMedia> get _galleryMedia {
    if (_detail == null) return [];
    return _detail!.media.where((m) => m.mediaType != 'cover').toList();
  }

  /// Image URLs for the gallery row — real media if present, else the cover.
  List<String> get _galleryImages {
    final media = _galleryMedia;
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
    final destination = Uri.encodeComponent(_locationText);
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destination');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Could not open map.');
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  bool get _isDirectBooking => _detail?.bookingType == 'direct_booking';

  EventModel get _eventForSheets => EventModel(
        id: _detail?.id ?? widget.event.id,
        title: _title,
        venue: _locationText,
        imagePath: _coverUrl,
        tag: _tag.isNotEmpty ? _tag : null,
        price: widget.event.price,
        rating: _detail != null ? _detail!.averageRating : widget.event.rating,
        reviewCount: _detail != null
            ? (_detail!.totalReviews > 0 ? '${_detail!.totalReviews} reviews' : null)
            : widget.event.reviewCount,
      );

  String? get _ageGroupText {
    if (_detail == null) return null;
    final text = _detail!.displayAgeRange;
    return text.isEmpty ? null : text;
  }

  String? get _formatText {
    if (_detail == null) return null;
    return _detail!.programFormat;
  }

  String? get _modeText {
    if (_detail == null) return null;
    return _detail!.deliveryMode;
  }

  String? get _cancellationPolicy => _detail?.cancellationPolicy;
  String? get _refundPolicy => _detail?.refundPolicy;

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
                  backgroundColor: AppColors.textSecondary,
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
                        type: 'program',
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

                    // Tag
                    if (_tag.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _tag,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                              4,
                              (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
                            ),
                          ),
                          const Icon(Icons.star_half, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _detail != null && _detail!.totalReviews > 0
                                ? '${_detail!.averageRating} (${_detail!.totalReviews} reviews)'
                                : widget.event.reviewCount ?? '(124 reviews)',
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
                              _modeText == 'online' ? Icons.videocam_outlined : Icons.location_on_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locationText,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _scheduleText,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (_detail != null && _detail!.batches.length > 1)
                                  GestureDetector(
                                    onTap: () => _showBatchesBottomSheet(context, _detail!.batches),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'View all ${_detail!.batches.length} batches',
                                        style: GoogleFonts.poppins(
                                          fontSize: Responsive.sp(context, 12),
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // About Program
                    if ((_description ?? '').isNotEmpty)
                      ExpandableAboutCard(
                        title: 'About Program',
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
                          if (_ageGroupText != null && _ageGroupText!.isNotEmpty) ...[
                            _buildThingsToKnowRow(Icons.group_outlined, 'Age Group', _ageGroupText!),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                          ],
                          if (_detail != null) ...[
                            if (_formatText != null && _formatText!.isNotEmpty) ...[
                              _buildThingsToKnowRow(Icons.style_outlined, 'Format', _capitalize(_formatText!)),
                              const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_modeText != null && _modeText!.isNotEmpty) ...[
                              _buildThingsToKnowRow(
                                _modeText == 'online' ? Icons.videocam_outlined : Icons.place_outlined,
                                'Mode',
                                _capitalize(_modeText!),
                              ),
                              const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_detail!.maxCapacity != null) ...[
                              _buildThingsToKnowRow(Icons.event_seat_outlined, 'Capacity', '${_detail!.maxCapacity} Students'),
                              const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_detail!.totalHours != null) ...[
                              _buildThingsToKnowRow(Icons.timer_outlined, 'Duration', '${_detail!.totalHours} Hours'),
                              const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            ],
                            if (_detail!.moduleCount != null) ...[
                              _buildThingsToKnowRow(Icons.list_alt_outlined, 'Modules', '${_detail!.moduleCount} Modules'),
                            ],
                          ] else ...[
                            _buildThingsToKnowRow(Icons.group_outlined, 'Age Group', '6 - 16 yrs'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildThingsToKnowRow(Icons.translate, 'Language', 'English'),
                            const Divider(height: 16, color: Color(0xFFEEEEEE)),
                            _buildThingsToKnowRow(Icons.event_seat_outlined, 'Slots Available', '12 Slots available'),
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

                    // Location map (Only if not online entirely)
                    if (_modeText != 'online') ...[
                      DetailDirectionsCard(
                        locationText: _locationText,
                        note: _detail?.address,
                        onGetDirection: _openDirections,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Organizer
                    OrganizerCard(
                      listingId: widget.event.id,
                      partnerId: _detail?.organizer?.partnerId,
                      initialName: _detail?.organizer?.businessName,
                      initialLogoUrl: _detail?.organizer?.logoUrl,
                      listingType: 'program',
                    ),

                    const SizedBox(height: 32),

                    if (_detail != null && (
                      (_cancellationPolicy?.isNotEmpty == true) ||
                      (_refundPolicy?.isNotEmpty == true) ||
                      (_detail!.faqs.isNotEmpty)
                    )) ...[
                      DetailTermsRow(
                        onTap: () => _showTermsBottomSheet(context),
                      ),
                      const SizedBox(height: 32),
                    ],

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
                      const SizedBox(height: 16),
                    ],

                    // ── Upcoming Events ───────────────────────────────────
                    const UpcomingEventsSection(),

                    SizedBox(height: Responsive.h(context, 100)),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom bar with Check Availability
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_priceDisplay != 'Price TBA') ...[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _priceDisplay,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 20),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: ' onwards',
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final label = _isDirectBooking
                            ? 'Check Availability'
                            : 'Enquire Now';
                        return ElevatedButton(
                          onPressed: () {
                            if (!_hasApiId) {
                              AppSnackBar.show(
                                context,
                                'This is a featured highlight, not a bookable program yet. Browse Programs to find one you can book.',
                              );
                              return;
                            }
                            if (_isDirectBooking) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SelectProgramBatchScreen(
                                    event: _eventForSheets,
                                    batches: _detail?.batches ?? [],
                                  ),
                                ),
                              );
                            } else {
                              showInquireNow(context,
                                  listingId: widget.event.id, isProgram: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
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
        child: const Center(child: Icon(Icons.school, size: 60, color: Colors.grey)),
      );


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
                    if (_cancellationPolicy?.isNotEmpty == true) ...[
                      Text('Cancellation Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text(_cancellationPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_refundPolicy?.isNotEmpty == true) ...[
                      Text('Refund Policy', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text(_refundPolicy!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade700, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (_detail?.faqs.isNotEmpty == true) ...[
                      Text('FAQs', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
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
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
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
          Text(value, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildThingsToKnowRow(IconData icon, String label, String value) {
    return _buildInfoRow(icon, label, value);
  }

  void _showBatchesBottomSheet(BuildContext context, List<ApiProgramBatch> batches) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Batches',
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: batches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = batches[index];
                  final days = b.daysOfWeek.join(', ');
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: Responsive.sp(context, 15))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(days, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
                          ],
                        ),
                        if (b.startTime != null && b.endTime != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('${b.startTime} - ${b.endTime}', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
