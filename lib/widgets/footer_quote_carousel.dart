import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/responsive.dart';

/// A "quote of the moment" shown at the top of the starry black footer: a
/// large gold opening quote-mark, the quote in white between, and a gold
/// closing quote-mark. A new quote cross-fades in every 10 seconds.
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

  /// Warm gold used for the quote marks.
  static const Color _gold = Color(0xFFE8B11E);

  /// Strip the surrounding curly quotes from a quote (explicit quote-mark
  /// glyphs are shown above and below instead).
  String _clean(String q) =>
      q.replaceAll('“', '').replaceAll('”', '').replaceAll('"', '').trim();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 6, 30, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Opening (top) quote mark ──
          Transform.rotate(
            angle: math.pi,
            child: const Icon(Icons.format_quote, size: 44, color: _gold),
          ),
          const SizedBox(height: 6),
          // ── Quote in white, cross-fading between entries ──
          SizedBox(
            height: Responsive.h(context, 92, min: 84),
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
                  // Elegant italic serif to match the footer reference. Uses the
                  // platform serif family (runtime Google-font fetching is off,
                  // so a GoogleFonts serif wouldn't load).
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: Responsive.sp(context, 18),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // ── Closing (bottom) quote mark ──
          const Icon(Icons.format_quote, size: 44, color: _gold),
        ],
      ),
    );
  }
}
