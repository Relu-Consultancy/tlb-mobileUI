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

/// The address row near the top of a detail screen: a pin, the listing's full
/// street address, and a button that routes to it from wherever the user is.
///
/// This row replaced the "Location" map card. That card was the only place the
/// full street address appeared and the only way to reach directions, so the
/// row now carries both. The address is clamped to one line so the row stays
/// the same height as the date/time row beneath it, with "See more" sitting
/// inline after the ellipsis — putting the toggle on its own line would make
/// this row two lines tall and break that symmetry.
class DetailLocationRow extends StatefulWidget {
  /// Full street address when the API returned one, else the area/city
  /// summary the row used to show on its own.
  final String text;

  /// Leading glyph — a pin for physical listings, a camera for online ones.
  final IconData icon;

  /// Route-to-listing action, wired to the same handler the map card's
  /// "Get Direction" button used. Null for online listings, which have
  /// nowhere to navigate to; the button is then omitted rather than shown
  /// inert.
  final VoidCallback? onNavigate;

  const DetailLocationRow({
    super.key,
    required this.text,
    this.icon = Icons.location_on_outlined,
    this.onNavigate,
  });

  @override
  State<DetailLocationRow> createState() => _DetailLocationRowState();
}

class _DetailLocationRowState extends State<DetailLocationRow> {
  bool _expanded = false;

  Widget _toggle(BuildContext context, String label) => GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        behavior: HitTestBehavior.opaque,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 12),
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontSize: Responsive.sp(context, 13),
      color: AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        // Collapsed, the row is a single line and centres exactly like the
        // date/time row below it. Expanded, the pin and the button ride up to
        // the first line instead of floating beside a paragraph.
        crossAxisAlignment:
            _expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          DetailRowIcon(widget.icon),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Measured rather than assumed: "See more" must appear only
                // when the address genuinely does not fit the width it has.
                final overflows = (TextPainter(
                  text: TextSpan(text: widget.text, style: textStyle),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth))
                    .didExceedMaxLines;

                if (_expanded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.text, style: textStyle),
                      const SizedBox(height: 2),
                      _toggle(context, 'See less'),
                    ],
                  );
                }
                if (!overflows) return Text(widget.text, style: textStyle);
                return Row(
                  children: [
                    // Flexible, not Expanded: the address gives up width to
                    // the toggle so "See more" always lands right after the
                    // ellipsis on the same line.
                    Flexible(
                      child: Text(
                        widget.text,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _toggle(context, 'See more'),
                  ],
                );
              },
            ),
          ),
          if (widget.onNavigate != null) ...[
            const SizedBox(width: 8),
            _NavigateButton(onTap: widget.onNavigate!),
          ],
        ],
      ),
    );
  }
}

/// Round "navigate to this address" button that opens the map from the user's
/// position to the listing.
///
/// Sized to exactly match the leading pin (36px) so the two ends of the row
/// balance; the hit area is widened to 44px without growing the row's height,
/// which would otherwise push this row out of step with the date/time row.
class _NavigateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NavigateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Get directions',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.seeAllBlue.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              // Material's navigation arrow — the same up-right paper-plane
              // glyph as the reference design.
              Icons.near_me,
              size: 20,
              color: AppColors.seeAllBlue,
            ),
          ),
        ),
      ),
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
      // Fixed to the screen's 16px gutters rather than hugging its text: a
      // card that resized itself to whatever the description happened to say
      // sat out of line with every other block on the page, and changed width
      // between one listing and the next.
      width: double.infinity,
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
          // The floor moves with the base so the extra 5px survives on small
          // screens too, where the scaled value clamps to `min`.
          height: Responsive.h(context, 145, min: 125),
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
