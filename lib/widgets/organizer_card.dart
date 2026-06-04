import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../models/api_provider_model.dart';
import '../screens/organizer_profile_screen.dart';
import '../services/events_listing_service.dart';
import 'partner_follow_button.dart';

/// Reusable organizer/provider card used across all detail screens.
/// Fetches provider data from /api/v1/listings/{id}/provider/ and displays
/// avatar, name, bio, stats (listings, rating, experience), and a follow button.
class OrganizerCard extends StatefulWidget {
  final String listingId;
  final String? partnerId;
  final String? initialName;
  final String? initialLogoUrl;

  /// Label shown above the name. Defaults to 'ORGANIZED BY'.
  final String label;

  const OrganizerCard({
    super.key,
    required this.listingId,
    this.partnerId,
    this.initialName,
    this.initialLogoUrl,
    this.label = 'ORGANIZED BY',
  });

  @override
  State<OrganizerCard> createState() => _OrganizerCardState();
}

class _OrganizerCardState extends State<OrganizerCard> {
  ApiProvider? _provider;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.listingId.isNotEmpty) _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final p = await EventsListingService.fetchProvider(widget.listingId);
      if (!mounted) return;
      setState(() {
        _provider = p;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _name => _provider?.name ?? widget.initialName ?? 'Partner';
  String? get _logoUrl => _provider?.logoUrl ?? widget.initialLogoUrl;
  String? get _bio =>
      (_provider?.bio?.isNotEmpty == true) ? _provider!.bio : null;
  String? get _effectivePartnerId =>
      (widget.partnerId?.isNotEmpty == true) ? widget.partnerId : _provider?.id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrganizerProfileScreen(
            listingId: widget.listingId,
            initialName: _name,
            initialLogoUrl: _logoUrl,
            provider: _provider,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header strip ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  // Avatar + verified badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(child: _buildAvatar()),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.check,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 10),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFF5A623),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _loading && _provider == null
                            ? Container(
                                width: 110,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                            : Text(
                                _name,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 15),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                        if (_bio != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  PartnerFollowButton(partnerId: _effectivePartnerId),
                ],
              ),
            ),

            // ── Stats row ────────────────────────────────────────────────
            if (_provider != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    _statTile(
                      Icons.collections_bookmark_outlined,
                      _provider!.totalListings > 0
                          ? '${_provider!.totalListings}+'
                          : '–',
                      'Listings',
                    ),
                    const SizedBox(width: 8),
                    _statTile(
                      Icons.star_rounded,
                      _provider!.averageRating > 0
                          ? _provider!.averageRating.toStringAsFixed(1)
                          : '–',
                      'Rating',
                    ),
                    const SizedBox(width: 8),
                    _statTile(
                      Icons.workspace_premium_outlined,
                      _provider!.experienceYears > 0
                          ? '${_provider!.experienceYears}+ yrs'
                          : '–',
                      'Experience',
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFF5A623)),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 9),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = _logoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initial(_name),
      );
    }
    return _initial(_name);
  }

  Widget _initial(String name) => Container(
        color: const Color(0xFFFEF3C7),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF5A623),
            ),
          ),
        ),
      );
}
