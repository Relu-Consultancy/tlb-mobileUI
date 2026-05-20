import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/location_screen.dart';

class EmptyLocationWidget extends StatelessWidget {
  const EmptyLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
          // No gap at top to attach it to header

          // Illustration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(
              'resources- tlb-ui/empty_screen.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'No events or bookings',
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 19),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
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
                    MaterialPageRoute(builder: (_) => const LocationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: const Color(0xFF1A1A2E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Change Location',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
        ),
      ),
    );
  }
}
