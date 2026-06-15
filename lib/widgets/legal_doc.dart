import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// Shared scaffold for legal documents (Privacy Policy / Terms of Service) —
/// TLB logo header, title, "last updated" line and a scrollable body built
/// from the [LegalHeading] / [LegalParagraph] / [LegalSubheading] /
/// [LegalBullets] helpers.
class LegalDocScaffold extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<Widget> children;

  const LegalDocScaffold({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand logo.
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: SvgPicture.asset(
                  'assets/icons/the_little_broadway_logo.svg',
                  width: MediaQuery.of(context).size.width * 0.30,
                ),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 22),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lastUpdated,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Bold section heading (e.g. "Acceptance of Terms").
class LegalHeading extends StatelessWidget {
  final String text;
  const LegalHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 16.5),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}

/// Smaller sub-heading (e.g. "Personal Information").
class LegalSubheading extends StatelessWidget {
  final String text;
  const LegalSubheading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 14),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}

/// Body paragraph.
class LegalParagraph extends StatelessWidget {
  final String text;
  const LegalParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 13.5),
          height: 1.6,
          color: const Color(0xFF555555),
        ),
      ),
    );
  }
}

/// Bulleted list.
class LegalBullets extends StatelessWidget {
  final List<String> items;
  const LegalBullets(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 9),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF999999),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        t,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          height: 1.55,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
