import 'dart:async';
import 'package:flutter/material.dart';
import '../core/responsive.dart';

/// A gently rotating, cursive "quote of the moment" shown just above the
/// footer. A new quote fades/slides/scales in every 10 seconds.
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small golden accent above the quote.
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0x00CFA53A), Color(0xFFCFA53A), Color(0x00CFA53A)],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 750),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.28),
                    end: Offset.zero,
                  ).animate(animation),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
              );
            },
            child: Text(
              FooterQuoteCarousel.quotes[_index],
              key: ValueKey<int>(_index),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DancingScript',
                fontSize: Responsive.sp(context, 18),
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A4632), // warm bronze-brown
              ),
            ),
          ),
        ],
      ),
    );
  }
}
