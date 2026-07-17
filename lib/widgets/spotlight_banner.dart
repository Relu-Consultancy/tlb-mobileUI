import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import 'wishlist_button.dart';

/// The Home "Spotlight" section: a "✦ Spotlight ✦" header and a swipeable set of
/// poster cards on the black backdrop. Each card has a glowing gold border, a
/// tag badge + wishlist heart over the poster, a date/time/venue meta row and a
/// "Book Tickets" button.
class SpotlightBanner extends StatefulWidget {
  final List<EventModel> events;

  const SpotlightBanner({super.key, required this.events});

  static const Color _gold = Color(0xFFF5C042);

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
      // Warm golden radiance surrounding the spotlight card, fading into the
      // black at the section edges (matches the header glow).
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.02),
          radius: 1.0,
          colors: [
            Color(0xFF9A6E1E), // brighter golden glow behind the card
            Color(0xFF3A2A0E),
            Colors.black,
          ],
          stops: [0.0, 0.55, 0.95],
        ),
      ),
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Column(
        children: [
          _buildTitle(context),
          const SizedBox(height: 12),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.events.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) =>
                  _buildCard(context, widget.events[i]),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: _index,
            count: widget.events.length,
            effect: const WormEffect(
              dotHeight: 7,
              dotWidth: 7,
              spacing: 6,
              activeDotColor: SpotlightBanner._gold,
              dotColor: Color(0x40FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    Widget line() =>
        Container(width: 40, height: 1, color: const Color(0x66F5C042));
    Widget star() =>
        const Icon(Icons.auto_awesome, size: 14, color: SpotlightBanner._gold);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const SizedBox(width: 12),
        star(),
        const SizedBox(width: 10),
        Text(
          'Spotlight',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        star(),
        const SizedBox(width: 12),
        line(),
      ],
    );
  }

  Widget _buildCard(BuildContext context, EventModel e) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _openDetail(context, e),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF120D06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SpotlightBanner._gold, width: 1.8),
            boxShadow: [
              // Strong golden halo around the card — two layers: a wide soft
              // spread plus a tighter brighter ring right at the border.
              BoxShadow(
                color: const Color(0xFFFFB800).withOpacity(0.60),
                blurRadius: 44,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: const Color(0xFFFFCE14).withOpacity(0.40),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
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
  }

  Widget _buildPoster(BuildContext context, EventModel e) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          e.imagePath,
          fit: BoxFit.cover,
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
          child: WishlistButton(event: e, containerSize: 34, iconSize: 18),
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
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _openDetail(context, e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Center(
                    child: Text(
                      'Book Tickets',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
        Icon(icon, size: 13, color: SpotlightBanner._gold),
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
