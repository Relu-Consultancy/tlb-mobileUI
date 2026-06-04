import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/share_helper.dart';
import '../models/api_provider_model.dart';
import '../services/events_listing_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/partner_follow_button.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String listingId;
  final String? initialName;
  final String? initialLogoUrl;

  /// Pre-fetched provider data. When supplied the screen skips the API call
  /// and displays immediately without a loading state.
  final ApiProvider? provider;

  const OrganizerProfileScreen({
    super.key,
    required this.listingId,
    this.initialName,
    this.initialLogoUrl,
    this.provider,
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
    if (widget.provider != null) {
      _provider = widget.provider;
    } else if (widget.listingId.isNotEmpty) {
      _fetchProvider();
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                        onPressed: () => ShareHelper.shareListing(
                          context,
                          type: 'partner',
                          title: _name,
                          id: _provider?.id,
                        ),
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
                          color: Color(0xFF22C55E),
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
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                if (_provider != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_provider!.averageRating > 0) ...[
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF5A623)),
                        const SizedBox(width: 3),
                        Text(
                          '${_provider!.averageRating.toStringAsFixed(1)} · ',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade700),
                        ),
                      ],
                      Text(
                        '${_formatCount(_provider!.totalReviews)} Reviews',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade700),
                      ),
                    ],
                  )
                else if (widget.initialName != null)
                  Text(
                    'Partner',
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 14),
                PartnerFollowButton(partnerId: _provider?.id),
                const SizedBox(height: 22),
              ],
            ),
          ),

          // ── Scrollable Body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Error banner
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
                            child: Text('Retry', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Stats grid ────────────────────────────────────────────
                  if (_provider != null) ...[
                    Row(
                      children: [
                        _statCard(
                          context,
                          Icons.collections_bookmark_outlined,
                          _provider!.totalListings > 0 ? '${_provider!.totalListings}+' : '–',
                          'Listings',
                          const Color(0xFFEEF2FF),
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          context,
                          Icons.star_rounded,
                          _provider!.averageRating > 0
                              ? _provider!.averageRating.toStringAsFixed(1)
                              : '–',
                          'Avg Rating',
                          const Color(0xFFFFFBEB),
                          const Color(0xFFF5A623),
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          context,
                          Icons.rate_review_outlined,
                          _formatCount(_provider!.totalReviews),
                          'Reviews',
                          const Color(0xFFF0FDF4),
                          const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          context,
                          Icons.workspace_premium_outlined,
                          _provider!.experienceYears > 0
                              ? '${_provider!.experienceYears} yrs'
                              : '–',
                          'Experience',
                          const Color(0xFFFFF1F2),
                          const Color(0xFFEF4444),
                        ),
                      ],
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
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _bio,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            height: 1.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 32), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color bg,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 9),
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
