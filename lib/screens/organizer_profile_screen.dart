import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/share_helper.dart';
import '../models/api_provider_model.dart';
import '../services/events_listing_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/partner_follow_button.dart';
import '../widgets/upcoming_events_section.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String listingId;
  final String? initialName;
  final String? initialLogoUrl;

  /// Pre-fetched provider data. When supplied the screen skips the API call
  /// and displays immediately without a loading state.
  final ApiProvider? provider;

  /// The kind of listing this profile was opened from — `'event'`, `'class'`,
  /// `'program'` or `'venue'`. When set, an "Upcoming Events" section is shown
  /// at the bottom, populated via that type's existing list API. Null when the
  /// profile is opened outside a detail screen (section hidden).
  final String? listingType;

  const OrganizerProfileScreen({
    super.key,
    required this.listingId,
    this.initialName,
    this.initialLogoUrl,
    this.provider,
    this.listingType,
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
  String get _bio => (_provider?.bio?.isNotEmpty == true)
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
      return const Scaffold(backgroundColor: Colors.white, body: AppLoader());
    }

    final topInset = MediaQuery.of(context).padding.top;
    final sheetTop = topInset + 96;
    const avatarSize = 100.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gold gradient band at the top ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sheetTop + 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF9B233), Color(0xFFFAD27A)],
                ),
              ),
            ),
          ),

          // ── White rounded sheet holding all the content ──
          Positioned.fill(
            top: sheetTop,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: avatarSize / 2 + 18, bottom: 32),
                child: Column(
                  children: [
                    // Name
                    Text(
                      _name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 19),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCount(_provider?.totalFollowers ?? 0)} Followers',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 18),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                        indent: 20,
                        endIndent: 20),

                    // Error banner
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: Colors.orange.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_error!,
                                    style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 12),
                                        color: Colors.orange.shade800)),
                              ),
                              TextButton(
                                onPressed: _fetchProvider,
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange.shade700),
                                child: Text('Retry',
                                    style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 12),
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // About
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Follow sits on the heading line rather than at
                            // the foot of the page: down there it was below
                            // the fold on any profile with events, so the
                            // primary action on this screen was the one thing
                            // you had to scroll to find.
                            Row(
                              children: [
                                Text(
                                  'About',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 17),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                PartnerFollowButton(partnerId: _provider?.id),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _bio,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                height: 1.6,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                        indent: 20,
                        endIndent: 20),
                    const SizedBox(height: 20),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _statColumn(
                            context,
                            _provider != null && _provider!.totalListings > 0
                                ? '${_provider!.totalListings}+'
                                : '0',
                            'EVENTS HOSTED',
                          ),
                          _statColumn(
                            context,
                            (_provider?.averageRating ?? 0) > 0
                                ? _provider!.averageRating.toStringAsFixed(1)
                                : '-',
                            'RATING',
                            showStar: true,
                          ),
                          _statColumn(
                            context,
                            _provider != null && _provider!.experienceYears > 0
                                ? '${_provider!.experienceYears}+'
                                : '0',
                            'EXPERIENCE',
                          ),
                        ],
                      ),
                    ),

                    // ── Upcoming Events (only when opened from a detail screen) ──
                    if (widget.listingType != null)
                      const UpcomingEventsSection(showDivider: true),

                  ],
                ),
              ),
            ),
          ),

          // ── Nav buttons on the gradient ──
          Positioned(
            top: topInset + 6,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                _circleIconButton(
                  Icons.share_outlined,
                  () => ShareHelper.shareListing(
                    context,
                    type: 'partner',
                    title: _name,
                    id: _provider?.id,
                  ),
                ),
              ],
            ),
          ),

          // ── Avatar straddling the sheet's top edge ──
          Positioned(
            top: sheetTop - avatarSize / 2,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(child: _buildAvatar()),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2.5)),
                      ),
                      child: const Icon(Icons.verified_outlined,
                          size: 14, color: Colors.white),
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

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _statColumn(
    BuildContext context,
    String value,
    String label, {
    bool showStar = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 22),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (showStar) ...[
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded,
                    size: 18, color: Color(0xFF22C55E)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 10),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

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
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 32),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}