import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/api_followed_partner_model.dart';
import '../providers/auth_state.dart';
import '../providers/follow_state.dart';
import '../services/partner_service.dart';
import '../widgets/app_loader.dart';

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Followed Partners',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
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
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: const Color(0xFF1A1A2E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                ),
                child: Text('Retry',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                    size: 44, color: Color(0xFFF5A623)),
              ),
              const SizedBox(height: 20),
              Text(
                'No Followed Partners',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
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

    return RefreshIndicator(
      onRefresh: _fetch,
      color: const Color(0xFFFFCC00),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _PartnerCard(
          partner: visible[i],
          onUnfollow: () => _unfollow(visible[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PartnerCard extends StatelessWidget {
  final ApiFollowedPartner partner;
  final VoidCallback onUnfollow;

  const _PartnerCard({required this.partner, required this.onUnfollow});

  @override
  Widget build(BuildContext context) {
    final p = partner.profile;
    final ext = partner.extendedProfile;
    final logoUrl = ext?.logoUrl;
    final bio = ext?.bio;
    final name = p.businessName;
    final city = p.baseCity;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Gradient banner ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF5A623).withOpacity(0.25),
                    const Color(0xFFFBD786).withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Card body ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
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
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
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
                                      color: Colors.grey.shade500,
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
                    _UnfollowButton(onUnfollow: onUnfollow),
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
                      color: Colors.grey.shade600,
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
                            size: 13, color: Color(0xFFF5A623)),
                        const SizedBox(width: 3),
                        Text(
                          '${_formatCount(partner.followerCount)} followers',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                errorBuilder: (_, __, ___) => _initial(name),
              )
            : _initial(name),
      ),
    );
  }

  Widget _initial(String name) => Container(
        color: const Color(0xFFFEF3C7),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF5A623),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0A0)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 10),
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF5A623),
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
