import 'package:flutter/material.dart';
import '../widgets/app_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_state.dart';
import '../providers/location_state.dart';
import '../core/responsive.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/review_sheet.dart';
import '../models/event_model.dart';
import '../models/api_venue_model.dart';
import '../services/events_listing_service.dart';
import '../services/review_service.dart';
import '../models/api_review_model.dart';
import '../widgets/login_sheet.dart';
import 'plan_party_screen.dart';
import 'gallery_screen.dart';
import 'organizer_profile_screen.dart';

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
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
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
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
              // ── Cover image header ──
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
                    child: WishlistButton(event: _eventForWidgets, containerSize: 40, showShadow: false),
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
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ── Title ──
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

                    // ── Location ──
                    if (_locationText.isNotEmpty)
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

                    // ── First availability slot ──
                    if (_firstSlot != null) ...[
                      const SizedBox(height: 12),
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
                                '${_formatDate(_firstSlot!.date)}, ${_formatTime(_firstSlot!.startTime)} – ${_formatTime(_firstSlot!.endTime)}',
                                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF1A1A2E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── About Venue ──
                    if (_description?.isNotEmpty == true) ...[
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
                            Text('About Venue',
                                style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                            const SizedBox(height: 8),
                            Text(
                              _description!,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Things to Know ──
                    if (_ageGroupText != null || _capacityText != null || _locationTypeText != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Things to Know',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                      ),
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
                      const SizedBox(height: 24),
                    ],

                    // ── Packages ──
                    if (_detail != null && _detail!.packages.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Packages',
                            style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                      ),
                      const SizedBox(height: 12),
                      ..._detail!.packages.map((pkg) => _buildPackageCard(pkg)),
                      const SizedBox(height: 24),
                    ],

                    // ── Gallery ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gallery',
                              style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => GalleryScreen(event: _eventForWidgets))),
                            child: Text('See All >',
                                style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Sneak peek into what awaits you!',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                    ),
                    const SizedBox(height: 12),
                    if (_galleryMedia.isNotEmpty)
                      SizedBox(
                        height: Responsive.h(context, 100, min: 80),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _galleryMedia.length,
                          itemBuilder: (_, i) => Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: Responsive.w(context, 120, min: 90),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _galleryMedia[i].url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (_isCoverNetwork && _coverUrl.isNotEmpty)
                      SizedBox(
                        height: Responsive.h(context, 100, min: 80),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_coverUrl,
                                width: Responsive.w(context, 120, min: 90), fit: BoxFit.cover),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Location map ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Location',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
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
                          const Positioned(
                            top: 12, left: 0, right: 0,
                            child: Icon(Icons.location_on, size: 36, color: Colors.red),
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
                                  _address ?? _locationText,
                                  style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: Colors.white),
                                ),
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
                                      final loc = _address ?? _locationText;
                                      final destination = Uri.encodeComponent(loc);
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
                                    label: Text('Get Direction',
                                        style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 12),
                                            fontWeight: FontWeight.w600)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFCC00),
                                      foregroundColor: const Color(0xFF1A1A2E),
                                      elevation: 0,
                                      minimumSize: const Size(0, 46),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
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

                    // ── Organizer ──
                    if (_detail?.organizer != null) ...[
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
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(27),
                                  child: _detail!.organizer!.logoUrl != null
                                      ? Image.network(
                                          _detail!.organizer!.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildOrgInitial(),
                                        )
                                      : _buildOrgInitial(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('MANAGED BY',
                                        style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 10),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFF5A623),
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text(_detail!.organizer!.businessName,
                                        style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 15),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A1A2E))),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                ),
                                child: Text('Follow',
                                    style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 13),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E)),
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
                            fontWeight: FontWeight.w700,
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
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => PlanPartyScreen(event: _eventForWidgets)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text('Plan Event',
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700)),
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
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildPackageCard(ApiVenuePackage pkg) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.name,
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                if (pkg.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(pkg.description!,
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11.5), color: Colors.grey.shade600, height: 1.4)),
                ],
                if (pkg.durationMinutes != null || pkg.maxGuests != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (pkg.durationMinutes != null) ...[
                        const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${pkg.durationMinutes} min',
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                      ],
                      if (pkg.maxGuests != null) ...[
                        const Icon(Icons.people_outline, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Up to ${pkg.maxGuests} guests',
                            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('₹${pkg.price.toInt()}',
              style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 15), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildOrgInitial() {
    final name = _detail?.organizer?.businessName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFFFFCC00),
      child: Center(
        child: Text(initial,
            style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
      ),
    );
  }

}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE8F0E8));
    final road = Paint()
      ..color = const Color(0xFFD0D8D0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
    final accent = Paint()
      ..color = const Color(0xFFC8E0C8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 12, accent);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 16, accent);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 10, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
