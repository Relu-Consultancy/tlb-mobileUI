import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// About Us — branded header with the TLB logo, placeholder body copy, and a
/// Terms & Conditions button that opens a popup.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
      'aliquip ex ea commodo consequat.\n\n'
      'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
      'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
      'proident, sunt in culpa qui officia deserunt mollit anim id est '
      'laborum.\n\n'
      'Sed ut perspiciatis unde omnis iste natus error sit voluptatem '
      'accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae '
      'ab illo inventore veritatis et quasi architecto beatae vitae dicta '
      'sunt explicabo.';

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        // Highlighted title chip so it pops on the golden gradient.
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'About Us',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Branded logo header (warm golden tint → white) ──
            // Extends up behind the transparent AppBar so the gradient
            // covers the whole top (no white bar).
            Container(
              padding: EdgeInsets.only(
                top: topInset + kToolbarHeight + 18,
                bottom: 36,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFD893), // warm golden tint at top
                    Color(0xFFFFF0D0), // cream
                    Colors.white, // blends into the page
                  ],
                  stops: [0.0, 0.62, 1.0],
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/the_little_broadway_logo.svg',
                  width: MediaQuery.of(context).size.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ── Body copy ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Who We Are',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 17),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lorem,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13.5),
                      height: 1.6,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),

            // ── Terms & Conditions button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showTermsDialog(context),
                  icon: const Icon(Icons.description_outlined, size: 20),
                  label: Text(
                    'Terms & Conditions',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: const Color(0xFF1A1A2E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 22, color: Color(0xFF1A1A2E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Terms & Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16.5),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, size: 22, color: Color(0xFF888888)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    '$_lorem\n\n$_lorem',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 13),
                      height: 1.6,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: const Color(0xFF1A1A2E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
