import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/api_provider_model.dart';
import '../services/events_listing_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/partner_follow_button.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String listingId;
  final String? initialName;
  final String? initialLogoUrl;

  const OrganizerProfileScreen({
    super.key,
    required this.listingId,
    this.initialName,
    this.initialLogoUrl,
  });

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  ApiProvider? _provider;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.listingId.isNotEmpty) _fetchProvider();
  }

  Future<void> _fetchProvider() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final p = await EventsListingService.fetchProvider(widget.listingId);
      if (!mounted) return;
      setState(() {
        _provider = p;
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

  String get _name => _provider?.name ?? widget.initialName ?? 'Partner';
  String? get _logoUrl => _provider?.logoUrl ?? widget.initialLogoUrl;
  String get _bio =>
      (_provider?.bio?.isNotEmpty == true)
          ? _provider!.bio!
          : 'We bring unique and memorable experiences to the community.';
  String get _totalListingsLabel {
    final n = _provider?.totalListings ?? 0;
    return n > 0 ? '$n+' : '–';
  }

  String get _ratingLabel {
    if (_provider == null) return '–';
    return _provider!.averageRating > 0
        ? _provider!.averageRating.toStringAsFixed(1)
        : '–';
  }

  String get _experienceLabel {
    final y = _provider?.experienceYears ?? 0;
    return y > 0 ? '$y+' : '–';
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: AppLoader(),
      );
    }

    // Static placeholder upcoming events — no provider-filtered API available yet
    final upcomingEvents = [
      {'title': 'Creative Color Workshop', 'venue': 'The Arts Studio, Mumbai', 'image': 'assets/images/kids_party.png'},
      {'title': 'Creative Storytime', 'venue': 'The Arts Studio, Mumbai', 'image': 'assets/images/story_telling.png'},
      {'title': 'Weekend Fun Fest', 'venue': 'City Park, Mumbai', 'image': 'assets/images/halloween_party.png'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Gradient Header ───────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5A623), Color(0xFFFBD786), Colors.white],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Nav bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1A2E)),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.share_outlined, size: 16, color: Color(0xFF1A1A2E)),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Avatar with verified badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ClipOval(child: _buildAvatar()),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                        ),
                        child: const Icon(Icons.check, size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Text(
                  _name,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                if (_provider != null)
                  Text(
                    '${_formatCount(_provider!.totalReviews)} Reviews',
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600),
                  )
                else if (widget.initialName != null)
                  Text(
                    'Partner',
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 12),
                PartnerFollowButton(partnerId: _provider?.id),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── Scrollable Body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Error banner (non-fatal — header still shows initialName)
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.orange.shade800),
                            ),
                          ),
                          TextButton(
                            onPressed: _fetchProvider,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              foregroundColor: Colors.orange.shade700,
                            ),
                            child: Text('Retry', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── About ─────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _bio,
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), height: 1.6, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Stats Row ─────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(context, _totalListingsLabel, 'EVENTS HOSTED'),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _buildStatItem(context, _ratingLabel, 'RATING', showStar: true),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _buildStatItem(context, _experienceLabel, 'EXPERIENCE'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Upcoming Events ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Events',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                      ),
                      Text(
                        'See All >',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Shouldn't miss these wonderful experiences!",
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: Responsive.h(context, 260, min: 200),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final e = upcomingEvents[index];
                        return _buildEventCard(context, e['image']!, e['title']!, e['venue']!);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    final url = _logoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialAvatar(),
      );
    }
    return _initialAvatar();
  }

  Widget _initialAvatar() {
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFFFFF5E0),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 32), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, {bool showStar = false}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              if (showStar) ...[
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, size: 17, color: Colors.amber),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 10),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String image, String title, String venue) {
    final cardW = Responsive.cardWidth(context, fraction: 0.46, max: 180);
    final imgH = Responsive.h(context, 160, min: 120);
    return Container(
      width: cardW,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              image,
              height: imgH,
              width: cardW,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: imgH,
                width: cardW,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  venue,
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Limited Seats',
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600, color: const Color(0xFFFF6B6B)),
          ),
        ],
      ),
    );
  }
}
