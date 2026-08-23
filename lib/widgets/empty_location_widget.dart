import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../providers/location_state.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/location_screen.dart';
import 'floating_navbar.dart';

class EmptyLocationWidget extends StatelessWidget {
  /// Names what is missing, so each tab says its own thing rather than every
  /// screen claiming there are no "events or bookings".
  final String title;

  const EmptyLocationWidget({
    super.key,
    this.title = 'No events or bookings',
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    // The floating navbar overlays the bottom of the screen — reserve that
    // space so the "Change Location" CTA always sits above it (it used to be
    // half-hidden behind the pill).
    final bottomClearance = FloatingNavbar.clearance(context);

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              // Fill the height handed down by the parent so the content
              // centres in the remaining viewport (no dead white strip) and
              // only scrolls if it genuinely doesn't fit.
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomClearance),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.asset(
                        'resources- tlb-ui/empty_screen.png',
                        width: sw * 0.62,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 19),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "We're not currently serving\nthis location.\nTry choosing a different city.",
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        color: const Color(0xFF9097AA),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LocationScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Change Location',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Wraps a tab's body so an unserviced city shows [EmptyLocationWidget]
/// instead of the tab's content.
///
/// Previously only the Home screen checked this, so switching to Events,
/// Classes, Programs or Venues in a city TLB does not serve showed those tabs
/// as though they simply had nothing on — with no explanation and no route to
/// fixing it.
///
/// Listens to the selected city, so changing it from anywhere updates every
/// tab without those screens each needing their own listener.
class LocationGate extends StatelessWidget {
  /// Shown when the city is not served. Name the tab's own content.
  final String emptyTitle;

  /// Kept above the empty state. Without it the screen loses its header —
  /// and with it the location chip, search and profile — leaving the customer
  /// with nothing but the CTA. Home always kept its header here.
  final Widget? header;

  /// Kept below the empty state, for the floating navbar. The tabs hold theirs
  /// in the same Stack as the body, so gating the body alone would strip the
  /// bottom navigation and trap the customer on the tab.
  final Widget? footer;

  final Widget child;

  const LocationGate({
    super.key,
    required this.emptyTitle,
    required this.child,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocationState().selectedCity,
      builder: (context, city, _) {
        if (LocationState().isLocationSupported(city)) return child;

        final empty = Column(
          children: [
            ?header,
            Expanded(child: EmptyLocationWidget(title: emptyTitle)),
          ],
        );

        if (footer == null) return empty;
        return Stack(children: [empty, footer!]);
      },
    );
  }
}
