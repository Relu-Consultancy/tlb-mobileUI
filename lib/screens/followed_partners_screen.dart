import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_followed_partner_model.dart';
import '../models/api_provider_model.dart';
import '../providers/auth_state.dart';
import '../providers/follow_state.dart';
import '../services/partner_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_refresh_indicator.dart';
import 'organizer_profile_screen.dart';

class FollowedPartnersScreen extends StatefulWidget {
  const FollowedPartnersScreen({super.key});

  @override
  State<FollowedPartnersScreen> createState() => _FollowedPartnersScreenState();
}

class _FollowedPartnersScreenState extends State<FollowedPartnersScreen> {
  List<ApiFollowedPartner> _partners = [];
  bool _loading = true;
  String? _error;

  // locally-tracked unfollow set (UI optimistic update)
  final Set<String> _unfollowed = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final token = AuthState.accessToken;
    if (token == null) {
      setState(() { _loading = false; _error = 'Not logged in.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final list = await PartnerService.fetchFollowed(token: token);
      if (!mounted) return;
      setState(() { _partners = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _confirmUnfollow(ApiFollowedPartner p) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Unfollow?',
      message:
          'Stop following ${p.profile.businessName}? You can follow them again anytime.',
      confirmLabel: 'Unfollow',
      icon: Icons.person_remove_outlined,
    );
    if (ok) {
      HapticFeedback.mediumImpact();
      _unfollow(p);
    }
  }

  void _openProfile(ApiFollowedPartner p) {
    HapticFeedback.selectionClick();
    final ext = p.extendedProfile;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizerProfileScreen(
          listingId: '',
          // Pre-fetched from the followed-partner data so the profile opens
          // instantly (no listing context to fetch stats from).
          provider: ApiProvider(
            id: p.partnerId,
            name: p.profile.businessName,
            bio: ext?.bio,
            logoUrl: ext?.logoUrl,
            totalListings: 0,
            averageRating: 0,
            totalReviews: 0,
            experienceYears: 0,
            totalFollowers: p.followerCount,
          ),
        ),
      ),
    );
  }

  Future<void> _unfollow(ApiFollowedPartner p) async {
    final token = AuthState.accessToken;
    if (token == null) return;

    setState(() => _unfollowed.add(p.partnerId));
    try {
      await PartnerService.unfollow(token: token, partnerId: p.partnerId);
      FollowState.set(p.partnerId, following: false).catchError((_) {});
      if (mounted) AppSnackBar.show(context, 'Unfollowed ${p.profile.businessName}.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _unfollowed.remove(p.partnerId));
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Followed Partners',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const AppLoader();

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFCCCCCC)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                ),
                child: Text('Retry',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
    }

    // Only show partners not yet unfollowed in this session
    final visible = _partners.where((p) => !_unfollowed.contains(p.partnerId)).toList();

    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded,
                    size: 44, color: Color(0xFFFF7A00)),
              ),
              const SizedBox(height: 20),
              Text(
                'No Followed Partners',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partners you follow will appear here.\nExplore events and tap Follow on any organizer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppRefreshIndicator(
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _PartnerCard(
          partner: visible[i],
          onUnfollow: () => _confirmUnfollow(visible[i]),
          onTap: () => _openProfile(visible[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PartnerCard extends StatefulWidget {
  final ApiFollowedPartner partner;
  final VoidCallback onUnfollow;
  final VoidCallback onTap;

  const _PartnerCard({
    required this.partner,
    required this.onUnfollow,
    required this.onTap,
  });

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final partner = widget.partner;
    final p = partner.profile;
    final ext = partner.extendedProfile;
    final logoUrl = ext?.logoUrl;
    final bio = ext?.bio;
    final name = p.businessName;
    final city = p.baseCity;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.02 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            splashColor: const Color(0xFFFF7A00).withOpacity(0.08),
            highlightColor: const Color(0xFFFF7A00).withOpacity(0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Vibrant orange→gold stripe at top ──────────────────
                Container(
                  height: 7,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFFB300)],
                    ),
                  ),
                ),

                // ── Card body ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(logoUrl: logoUrl, name: name),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 15),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111111),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (partner.isVerified) ...[
                                const SizedBox(width: 4),
                                const _VerifiedBadge(),
                              ],
                            ],
                          ),
                          if (city != null && city.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    city,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 11),
                                      color: const Color(0xFF444444),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _UnfollowButton(onUnfollow: widget.onUnfollow),
                  ],
                ),

                // Bio
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      color: const Color(0xFF2D2D2D),
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Categories + follower count
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: partner.categories
                            .take(3)
                            .map((c) => _CategoryChip(label: c.name))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_outlined,
                            size: 13, color: Color(0xFFFF7A00)),
                        const SizedBox(width: 3),
                        Text(
                          '${_formatCount(partner.followerCount)} followers',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
                            color: const Color(0xFF444444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Interactive "View Profile" pill ─────────────────
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7A00), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8A00).withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Profile',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12.5),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                  ],
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? logoUrl;
  final String name;

  const _Avatar({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initial(context, name),
              )
            : _initial(context, name),
      ),
    );
  }

  Widget _initial(BuildContext context, String name) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD27A), Color(0xFFFFB300)],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 22),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 10, color: Colors.white),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC078)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 10),
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFF7A00),
        ),
      ),
    );
  }
}

class _UnfollowButton extends StatelessWidget {
  final VoidCallback onUnfollow;

  const _UnfollowButton({required this.onUnfollow});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onUnfollow,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade600,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Unfollow',
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
