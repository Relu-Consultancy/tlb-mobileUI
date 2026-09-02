import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'auto_scroll_list.dart';

// Shared building blocks for the Event / Program / Class / Venue detail
// screens so they stay visually consistent. Background is greyish, cards are
// white with a slim black border, and section titles are bold.

const Color kDetailBg = Color(0xFFFAFAFC); // lighter, near-white background
const Color kDetailText = AppColors.textSecondary;
const Color kCardBorder = Color(0x14000000); // black @ ~8% — very light slim border
const Color kRowDivider = Color(0x0F000000); // black @ ~6% — hairline between rows

/// Bold section heading used across the detail screens.
class DetailSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const DetailSectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w600,
              color: kDetailText,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The category / subcategory label that sits above a detail screen's title.
///
/// Deliberately quiet. It used to be a solid `primaryLight` block, which made
/// it the loudest element on the screen: it out-shouted the title it exists to
/// introduce, and it wore the same saturated yellow as the "Book Now" CTA,
/// which blunts the one fill that should mean "tap me". A soft wash with a
/// hairline edge still reads as a tag without competing for the eye.
///
/// Follows the tinted-chip treatment already used by the booking status badge:
/// fill at 12% of the accent, hairline at 28%.
class DetailCategoryTag extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const DetailCategoryTag(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withOpacity(0.28)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 11.5),
            fontWeight: FontWeight.w500,
            // Dark neutral rather than amber-on-amber: amber text over this
            // wash measures ~2.4:1 against the page, well under the 4.5:1
            // that 11.5sp needs to stay readable.
            color: kDetailText,
          ),
        ),
      ),
    );
  }
}

/// The circled leading glyph on a detail screen's info rows (the address pin,
/// the date calendar).
///
/// Both the ground and the glyph are a step stronger than the grey-100 /
/// grey-500 pair these rows used to carry, which measured ~2.5:1 against the
/// page and read as disabled rather than quiet. This lands near 5:1 — clearly
/// present, still subordinate to the values it labels.
///
/// Shared so the pin and the calendar cannot drift apart: they sit one above
/// the other and any difference between them is immediately visible.
class DetailRowIcon extends StatelessWidget {
  final IconData icon;

  const DetailRowIcon(this.icon, {super.key});

  /// Outer diameter. The navigate button matches it so the two ends of the
  /// address row balance.
  static const double diameter = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: Colors.grey.shade700),
    );
  }
}

/// White "About" card with a slim black border. Clamps the body to 3 lines
/// and reveals the rest behind a "See more" / "See less" toggle when it
/// overflows.
class ExpandableAboutCard extends StatefulWidget {
  final String title;
  final String text;

  const ExpandableAboutCard({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  State<ExpandableAboutCard> createState() => _ExpandableAboutCardState();
}

class _ExpandableAboutCardState extends State<ExpandableAboutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.poppins(
      fontSize: Responsive.sp(context, 13),
      // Full black, slim weight (w400 — the lightest bundled Poppins).
      color: Colors.black,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.w700,
              color: kDetailText,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final tp = TextPainter(
                text: TextSpan(text: widget.text, style: bodyStyle),
                maxLines: 3,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);
              final overflows = tp.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    style: bodyStyle,
                    maxLines: _expanded ? null : 3,
                    overflow:
                        _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (overflows) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? 'See less' : 'See more',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Horizontal gallery of wide image cards (network or asset URLs auto-detected).
class DetailGallery extends StatelessWidget {
  final List<String> images;
  final VoidCallback? onSeeAll;
  final String subtitle;

  const DetailGallery({
    super.key,
    required this.images,
    this.onSeeAll,
    this.subtitle = 'Sneak peek into what awaits you!',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailSectionTitle(
          'Gallery',
          trailing: onSeeAll == null
              ? null
              : GestureDetector(
                  onTap: onSeeAll,
                  child: Row(
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
                ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12),
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          // Longer + wider cards than before, matching the reference.
          height: Responsive.h(context, 140, min: 120),
          child: AutoScrollList(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.isEmpty ? 1 : images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: Responsive.w(context, 168, min: 140),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade200,
                  border: Border.all(color: kCardBorder, width: 0.7),
                ),
                clipBehavior: Clip.antiAlias,
                child: images.isEmpty
                    ? const SizedBox.shrink()
                    : _img(images[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _img(String url) {
    Widget fallback() => Container(color: Colors.grey.shade200);
    if (url.startsWith('http')) {
      return Image.network(url,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
    }
    if (url.isEmpty) return fallback();
    return Image.asset(url,
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
  }
}

/// "Location" card with a stylised map-art background, the venue name, an
/// optional note, and a gold "Get Direction" button — matches the reference.
class DetailDirectionsCard extends StatelessWidget {
  final String locationText;
  final String? note;
  final VoidCallback onGetDirection;

  const DetailDirectionsCard({
    super.key,
    required this.locationText,
    this.note,
    required this.onGetDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DetailSectionTitle('Location'),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: Responsive.h(context, 190, min: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder, width: 0.7),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MapArtPainter()),
              // Centre pin.
              const Align(
                alignment: Alignment(0.35, -0.25),
                child: Icon(Icons.location_on, size: 38, color: Color(0xFFD32F2F)),
              ),
              // Left-to-right dark gradient for text legibility.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.82),
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 80,
                top: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationText,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    if ((note ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note!,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 11.5),
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: ElevatedButton.icon(
                  onPressed: onGetDirection,
                  icon: const Icon(Icons.directions, size: 16),
                  label: Text(
                    'Get Direction',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: kDetailText,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple "Terms & Conditions" row card with a slim black border.
class DetailTermsRow extends StatelessWidget {
  final VoidCallback onTap;

  /// Row title — defaults to "Terms & Conditions". Pass "FAQs" (etc.) to reuse
  /// this row for other tappable popup sections.
  final String title;

  /// Leading icon — defaults to the T&C document icon.
  final IconData icon;

  const DetailTermsRow({
    super.key,
    required this.onTap,
    this.title = 'Terms & Conditions',
    this.icon = Icons.description_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kCardBorder, width: 0.7),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: kDetailText),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w600,
                      color: kDetailText,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.blue, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared FAQs bottom sheet used by every detail screen — same look as the
/// Terms & Conditions sheet, but lists question / answer pairs.
void showListingFaqsSheet(
  BuildContext context,
  List<Map<String, dynamic>> faqs,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('FAQs',
                    style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 17),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final faq in faqs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(faq['question']?.toString() ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text(faq['answer']?.toString() ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  color: Colors.grey.shade700,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Paints a detailed stylised street-map background — land, water, parks,
/// city blocks, a layered road network (with casings), a highlighted route,
/// and POI dots. Deterministic so it doesn't flicker on repaint.
class _MapArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    Rect rel(double l, double t, double rw, double rh) =>
        Rect.fromLTWH(l * w, t * h, rw * w, rh * h);

    // ── Land base ──
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFFEEEBE3));

    // ── Water: a bay in the top-right + a thin river feeding it ──
    final water = Paint()..color = const Color(0xFFA9C6E2);
    final bay = Path()
      ..moveTo(w * 0.70, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.30)
      ..quadraticBezierTo(w * 0.88, h * 0.26, w * 0.82, h * 0.12)
      ..quadraticBezierTo(w * 0.78, h * 0.04, w * 0.70, 0)
      ..close();
    canvas.drawPath(bay, water);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.80, h * 0.16)
        ..quadraticBezierTo(w * 0.66, h * 0.30, w * 0.60, h * 0.5)
        ..quadraticBezierTo(w * 0.56, h * 0.7, w * 0.46, h),
      Paint()
        ..color = const Color(0xFFA9C6E2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // ── Parks (green) ──
    final park = Paint()..color = const Color(0xFFC4DCA4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rel(0.03, 0.60, 0.24, 0.30), const Radius.circular(7)), park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rel(0.62, 0.66, 0.22, 0.26), const Radius.circular(7)), park);

    // ── City blocks (buildings) in a loose grid, skipping water/parks ──
    final block = Paint()..color = const Color(0xFFE2DED3);
    final blockEdge = Paint()
      ..color = const Color(0xFFD2CCBE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cols = [0.05, 0.27, 0.49];
    const rows = [0.07, 0.26, 0.45];
    for (final cx in cols) {
      for (final ry in rows) {
        // Skip the bay region (top-right) — handled by water.
        if (cx >= 0.49 && ry <= 0.26) continue;
        final r = RRect.fromRectAndRadius(
            rel(cx, ry, 0.17, 0.13), const Radius.circular(3));
        canvas.drawRRect(r, block);
        canvas.drawRRect(r, blockEdge);
      }
    }
    // A couple of blocks on the right-lower land.
    for (final ry in [0.45, 0.62]) {
      final r = RRect.fromRectAndRadius(
          rel(0.70, ry, 0.17, 0.12), const Radius.circular(3));
      canvas.drawRRect(r, block);
      canvas.drawRRect(r, blockEdge);
    }

    // ── Roads — draw a darker casing first, then the lighter fill on top ──
    void road(List<Offset> pts, double width, Color fill) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFCDC8BC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width + 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = fill
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Minor grid roads (thin, white).
    for (final y in [0.20, 0.42, 0.62, 0.84]) {
      road([Offset(0, y * h), Offset(w, (y - 0.03) * h)], 3.5, Colors.white);
    }
    for (final x in [0.22, 0.46, 0.70]) {
      road([Offset(x * w, 0), Offset((x - 0.04) * w, h)], 3.5, Colors.white);
    }

    // Major arterials (wider, white with casing).
    road([Offset(0, h * 0.50), Offset(w * 0.5, h * 0.46), Offset(w, h * 0.40)],
        9, Colors.white);
    road([Offset(w * 0.44, 0), Offset(w * 0.40, h * 0.5), Offset(w * 0.36, h)],
        9, Colors.white);
    // A warm avenue running diagonally.
    road([Offset(0, h * 0.94), Offset(w * 0.5, h * 0.5), Offset(w, h * 0.08)],
        6, const Color(0xFFF6D690));

    // ── Highlighted route towards the pin (blue) ──
    final routePath = Path()
      ..moveTo(w * 0.12, h * 0.90)
      ..lineTo(w * 0.32, h * 0.64)
      ..lineTo(w * 0.52, h * 0.52)
      ..lineTo(w * 0.63, h * 0.40);
    canvas.drawPath(
      routePath,
      Paint()
        ..color = const Color(0xFF4C8DF6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── POI dots ──
    final poi = Paint()..color = const Color(0xFFEF7C57);
    for (final o in [
      Offset(w * 0.18, h * 0.30),
      Offset(w * 0.40, h * 0.78),
      Offset(w * 0.78, h * 0.58),
    ]) {
      canvas.drawCircle(o, 3.5, poi);
      canvas.drawCircle(
          o, 3.5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
