import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// A "quote of the moment" card shown just above the footer: a rounded
/// bordered panel with gold quote-marks top & bottom and the quote in a clean
/// sans font between. A new quote cross-fades in every 10 seconds.
class FooterQuoteCarousel extends StatefulWidget {
  const FooterQuoteCarousel({super.key});

  /// Relatable quotes about kids — their energy, playful chaos and
  /// growing-up moments. Rotated one at a time.
  static const List<String> quotes = [
    '“Children don’t walk into a room — they arrive like a full energy storm.”',
    '“A child’s battery works differently — somehow 1% energy still means running everywhere.”',
    '“Silence around kids usually means either magic… or trouble.”',
    '“Children turn ordinary days into unexpected adventures.”',
    '“Their energy says ‘one more game’ even when the whole world says bedtime.”',
    '“Kids can be tired, sleepy, hungry — and still somehow have energy to jump around.”',
    '“A child’s imagination can turn a sofa into a spaceship in seconds.”',
    '“Growing up means learning; being a child means learning while running.”',
    '“Children don’t count memories — they create them loudly.”',
    '“The louder the laughter, the better the childhood.”',
    '“Children carry endless questions and unlimited energy.”',
    '“Every child is a tiny bundle of chaos mixed with wonder.”',
    '“Their happiness is simple: snacks, fun, and one more hour outside.”',
    '“Children remind us that joy doesn’t need a reason.”',
    '“They fall, laugh, get up, and run again — that’s childhood.”',
    '“A child’s day isn’t complete without turning something normal into a game.”',
    '“High energy today, unforgettable memories tomorrow.”',
    '“Kids don’t believe in limits — only in ‘let me try once more.’”',
    '“Childhood is powered by curiosity and unlimited imagination.”',
    '“Their tiny feet somehow create the loudest footsteps in the house.”',
    '“Children are proof that happiness often comes running at full speed.”',
    '“One child can fill an entire home with laughter, noise, and life.”',
    '“Being around children means never knowing what adventure starts next.”',
    '“The energy of childhood is the closest thing to magic.”',
    '“Children may grow older, but the playful spark never truly disappears.”',
    '“A kid’s superpower? Turning five minutes into five hours of fun.”',
    '“Childhood is messy, loud, energetic — and absolutely beautiful.”',
    '“Young hearts run faster because life still feels like an adventure.”',
    '“Children teach us that excitement can exist in the smallest things.”',
    '“Behind every energetic child is a heart full of dreams and curiosity.”',
  ];

  @override
  State<FooterQuoteCarousel> createState() => _FooterQuoteCarouselState();
}

class _FooterQuoteCarouselState extends State<FooterQuoteCarousel> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % FooterQuoteCarousel.quotes.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Warm gold used for the quote marks and divider lines.
  static const Color _gold = Color(0xFFE8B11E);

  /// Strip the surrounding curly quotes from a quote (the card now shows
  /// explicit quote-mark symbols at the top and bottom).
  String _clean(String q) =>
      q.replaceAll('“', '').replaceAll('”', '').replaceAll('"', '').trim();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x14000000)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top: gold line — opening quote — gold line ──
            _markRow(opening: true),
            const SizedBox(height: 14),
            // ── Quote in a simple sans font, fading between entries ──
            SizedBox(
              height: Responsive.h(context, 96, min: 88),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    _clean(FooterQuoteCarousel.quotes[_index]),
                    key: ValueKey<int>(_index),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2B2B2B),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // ── Bottom: gold line — closing quote — gold line ──
            _markRow(opening: false),
          ],
        ),
      ),
    );
  }

  /// A centred filled quote mark flanked by gold divider lines. [opening] = true
  /// rotates the glyph 180° so it reads as an opening (top) quote.
  Widget _markRow({required bool opening}) {
    Widget line() => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
    return Row(
      children: [
        line(),
        Transform.rotate(
          angle: opening ? math.pi : 0,
          child: const Icon(Icons.format_quote, size: 46, color: _gold),
        ),
        line(),
      ],
    );
  }
}
