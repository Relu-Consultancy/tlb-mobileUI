import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/listing_schedule.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import '../services/events_listing_service.dart';
import '../screens/event_detail_screen.dart';

/// "Upcoming Events" section — a horizontal rail of event cards sourced from
/// the public Events list API (GET /api/v1/listings/events/). Self-contained:
/// fetches on init and shows loading / empty(+retry) / cards. Used at the
/// bottom of the organizer profile and every listing detail screen.
class UpcomingEventsSection extends StatefulWidget {
  /// Draws a thin divider above the header (used on the organizer profile to
  /// separate it from the stats).
  final bool showDivider;

  /// Listing this section is embedded in, so it can leave itself out.
  ///
  /// Without it a detail screen advertised the very listing being viewed:
  /// tapping it pushed an identical screen, and Back returned to what looked
  /// like the same page — a loop with no way to tell how deep you were.
  final String? excludeListingId;

  const UpcomingEventsSection({
    super.key,
    this.showDivider = false,
    this.excludeListingId,
  });

  @override
  State<UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
  List<_UpcomingItem> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final page = await EventsListingService.fetchEvents(pageSize: 10);
      final exclude = widget.excludeListingId;
      final results = page.results
          .where((e) => e.id != exclude)
          // A section titled "Upcoming Events" showing one that has already
          // ended is a direct contradiction of its own label.
          .where((e) => !ListingSchedule.hasEnded(e.endDatetime))
          .toList();
      final items = results.map((e) {
        final badge = e.subcategory?.name ??
            (e.category.name.isNotEmpty ? e.category.name : 'Limited Seats');
        return _UpcomingItem(
          title: e.title,
          location: e.city,
          imageUrl: e.coverUrl,
          badge: badge,
          model: EventModel(
            id: e.id,
            title: e.title,
            venue: e.city,
            imagePath: e.coverUrl ?? '',
            tag: e.subcategory?.name ?? e.category.name,
            price: e.priceFrom != null ? double.tryParse(e.priceFrom!) : null,
          ),
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _open(_UpcomingItem item) {
    // Replace rather than push: hopping between related listings otherwise
    // stacks a detail screen per tap, so Back walks the whole chain instead of
    // returning to wherever the customer entered from.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: item.model)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDivider) ...[
          const SizedBox(height: 22),
          Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
              indent: 20,
              endIndent: 20),
          const SizedBox(height: 18),
        ] else
          const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Events',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.seeAllBlue,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.seeAllBlue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "shouldn't miss wonder fun experience!",
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12),
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          )
        else if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'No upcoming events right now.',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _fetch,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: AppColors.blue,
                  ),
                  child: Text('Retry',
                      style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: Responsive.h(context, 258, min: 250),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              itemBuilder: (_, i) => _card(context, _items[i]),
            ),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, _UpcomingItem item) {
    Widget image() {
      final url = item.imageUrl;
      Widget fallback() => Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.image_outlined,
                color: Colors.grey.shade400, size: 30),
          );
      if (url == null || url.isEmpty) return fallback();
      if (url.startsWith('http')) {
        return Image.network(url,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
      }
      return Image.asset(url,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
    }

    return GestureDetector(
      onTap: () => _open(item),
      child: Container(
        width: 304,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x8A000000), width: 0.7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dominates the card — Expanded fills whatever height is
            // left after the (natural-height) content, so there's no empty
            // gap at the bottom.
            Expanded(
              child: SizedBox(width: double.infinity, child: image()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location.isEmpty ? 'TBA' : item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingItem {
  final String title;
  final String location;
  final String? imageUrl;
  final String badge;
  final EventModel model;

  const _UpcomingItem({
    required this.title,
    required this.location,
    this.imageUrl,
    required this.badge,
    required this.model,
  });
}
