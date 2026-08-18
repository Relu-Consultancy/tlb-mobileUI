import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/responsive.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import 'dark_category_section.dart';
import 'four_point_star.dart';
import 'primary_cta_button.dart';
import 'wishlist_button.dart';

/// The Home "Spotlight" section: a "✦ Spotlight ✦" header and a swipeable set of
/// poster cards on the black backdrop. Each card has a glowing gold border, a
/// tag badge + wishlist heart over the poster, a date/time/venue meta row and a
/// "Book Tickets" button.
class SpotlightBanner extends StatefulWidget {
  final List<EventModel> events;

  const SpotlightBanner({super.key, required this.events});

  @override
  State<SpotlightBanner> createState() => _SpotlightBannerState();
}

class _SpotlightBannerState extends State<SpotlightBanner> {
  late final PageController _controller;
  Timer? _auto;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.events.length > 1) {
      _auto = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_index + 1) % widget.events.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    // The card flexes to fill whatever height this widget is given (it lives in
    // an Expanded on the Home hero), so Spotlight + Explore the Stage both fit
    // one screen without scrolling.
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      padding: const EdgeInsets.only(top: 9, bottom: 10),
      child: Column(
        children: [
          // Nudge the title up 10px (card position unchanged).
          Transform.translate(
            offset: const Offset(0, -10),
            child: _buildTitle(context),
          ),
          const SizedBox(height: 12),
          Expanded(
            // Nudge the poster card down 10px from its prior -20 offset
            // (title above unaffected). The gap below (was 10px, now 0)
            // is folded into the Expanded box, growing the card 10px taller.
            child: Transform.translate(
              offset: const Offset(0, -10),
              // Clip.none so the golden glow behind each card can spill past
              // the page edges instead of being cut off at the viewport.
              child: PageView.builder(
                controller: _controller,
                clipBehavior: Clip.none,
                itemCount: widget.events.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) =>
                    _buildCard(context, widget.events[i]),
              ),
            ),
          ),
          AnimatedSmoothIndicator(
            activeIndex: _index,
            count: widget.events.length,
            effect: const WormEffect(
              dotHeight: 7,
              dotWidth: 7,
              spacing: 6,
              activeDotColor: kDarkSectionGold,
              dotColor: Color(0x40FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    // A long gold rule that fills the width and fades to transparent at the
    // outer (screen) edge — bright gold sits next to the sparkle, dissolving
    // into the black toward the sides (matches the reference).
    Widget line({required bool outerIsLeft}) => Container(
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: outerIsLeft
                  ? const [Colors.transparent, kDarkSectionGold]
                  : const [kDarkSectionGold, Colors.transparent],
              stops: const [0.0, 1.0],
            ),
          ),
        );
    // A single clean 4-point star (Icons.auto_awesome renders a star *plus* a
    // small secondary sparkle, which read as a cluster — the reference has one).
    Widget star() =>
        const FourPointStar(size: 15, color: kDarkSectionGold);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(child: line(outerIsLeft: true)),
          const SizedBox(width: 12),
          star(),
          const SizedBox(width: 11),
          Text(
            'Spotlight',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 11),
          star(),
          const SizedBox(width: 12),
          Expanded(child: line(outerIsLeft: false)),
        ],
      ),
    );
  }

  /// Golden light behind the card — strong on the left & right and across the
  /// top, biased UPWARD (negative-y offsets) so the glow sits high and does not
  /// pool at the bottom. There is no bottom shadow at all.
  List<BoxShadow> _cardGlow() => [
        BoxShadow(
          color: kDarkSectionGold.withOpacity(0.52),
          blurRadius: 30,
          spreadRadius: -8,
          offset: const Offset(-12, -16),
        ),
        BoxShadow(
          color: kDarkSectionGold.withOpacity(0.52),
          blurRadius: 30,
          spreadRadius: -8,
          offset: const Offset(12, -16),
        ),
        BoxShadow(
          color: kDarkSectionGold.withOpacity(0.20),
          blurRadius: 22,
          spreadRadius: -12,
          offset: const Offset(0, -14),
        ),
      ];

  Widget _buildCard(BuildContext context, EventModel e) {
    final Widget card = GestureDetector(
      onTap: () => _openDetail(context, e),
      child: Container(
        // Gradient "frame": the border is drawn as a 1.8px gold gradient that
        // is bright across the top & upper sides and dims to a dark brown at
        // the bottom edge (matches the reference, where the frame fades low).
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kDarkSectionGold,
              kDarkSectionGold,
              Color(0xFF3A2B0E),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: _cardGlow(),
        ),
        padding: const EdgeInsets.all(1.8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF120D06),
            borderRadius: BorderRadius.circular(16.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                Expanded(child: _buildPoster(context, e)),
                _buildFooter(context, e),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: card,
    );
  }

  Widget _buildPoster(BuildContext context, EventModel e) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          e.imagePath,
          fit: BoxFit.cover,
          // Anchor near the top so the poster's header isn't cropped and its
          // content sits lower in the frame (looks nicer under the badge).
          alignment: const Alignment(0.0, -0.75),
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1E1710),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              color: Colors.white24,
              size: 48,
            ),
          ),
        ),
        // Tag badge (top-left)
        if ((e.tag ?? '').isNotEmpty)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.45)),
              ),
              child: Text(
                e.tag!,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 9.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        // Wishlist heart (top-right)
        Positioned(
          top: 12,
          right: 12,
          child: WishlistButton(
            event: e,
            containerSize: 34,
            iconSize: 18,
            // Dark translucent circle so it blends into the card (per design),
            // with a hairline border and a light heart.
            backgroundColor: Colors.black.withOpacity(0.35),
            borderColor: Colors.white.withOpacity(0.45),
            unlikedColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, EventModel e) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _metaItem(
                context,
                Icons.calendar_today_rounded,
                e.eventDate ?? '',
              ),
              const SizedBox(width: 12),
              _metaItem(context, Icons.access_time_rounded, e.eventTime ?? ''),
              const SizedBox(width: 12),
              Flexible(
                child: _metaItem(
                  context,
                  Icons.location_on_outlined,
                  e.venue,
                  flexible: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryCtaButton(
            label: 'Book Tickets',
            onTap: () => _openDetail(context, e),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(
    BuildContext context,
    IconData icon,
    String text, {
    bool flexible = false,
  }) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: Responsive.sp(context, 10.5),
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.72),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: kDarkSectionGold),
        const SizedBox(width: 4),
        flexible ? Flexible(child: label) : label,
      ],
    );
  }

  void _openDetail(BuildContext context, EventModel e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
    );
  }
}
