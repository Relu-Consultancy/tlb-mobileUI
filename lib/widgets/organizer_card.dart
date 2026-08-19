import 'package:flutter/material.dart';
import '../core/app_colors.dart';
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

  /// The kind of listing this card sits on — `'event'`, `'class'`,
  /// `'program'` or `'venue'`. Forwarded to the organizer profile so it can
  /// show an "Upcoming Events" section sourced from that type's list API.
  final String? listingType;

  const OrganizerCard({
    super.key,
    required this.listingId,
    this.partnerId,
    this.initialName,
    this.initialLogoUrl,
    this.label = 'ORGANIZED BY',
    this.listingType,
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
            listingType: widget.listingType,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x14000000), width: 0.7),
        ),
        // Minimal design per reference: avatar + "ORGANIZED BY" + name + Follow.
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(child: _buildAvatar()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 10),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PartnerFollowButton(partnerId: _effectivePartnerId),
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
              color: AppColors.primary,
            ),
          ),
        ),
      );
}
