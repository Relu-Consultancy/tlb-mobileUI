import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: Responsive.h(context, 50, min: 30),
        bottom: Responsive.h(context, 30, min: 20),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.6, 1.0],
          colors: [
            Color(0xFFFFCC00), // Solid golden/yellow at bottom
            Color(0xFFFFE580), // Lighter mid-transition
            Color(0xFFFFF8EE), // Fades perfectly into page background
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TLB Logo
          Image.asset(
            'resources- tlb-ui/tlbAppIcon.png',
            width: Responsive.w(context, 75, min: 55),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'the little broadway',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
