import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/location_screen.dart';
import '../core/app_colors.dart';

class EmptyLocationWidget extends StatelessWidget {
  const EmptyLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Illustration (Using a stylized icon composition as placeholder for the specific asset)
            Stack(
              alignment: Alignment.center,
              children: [
                // Background decorative elements
                Icon(Icons.music_note, color: Colors.pink.shade200, size: 40),
                Transform.translate(
                  offset: const Offset(60, -40),
                  child: Icon(Icons.star, color: Colors.yellow.shade300, size: 30),
                ),
                Transform.translate(
                  offset: const Offset(-70, 20),
                  child: Icon(Icons.close, color: Colors.grey.shade300, size: 24),
                ),
                
                // Central Clipboard Icon
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade300, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade200,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(4, (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        height: 4,
                        color: Colors.indigo.shade100,
                      )),
                    ],
                  ),
                ),

                // Foreground Clouds
                Transform.translate(
                  offset: const Offset(30, 70),
                  child: Icon(Icons.cloud, color: Colors.grey.shade200, size: 80),
                ),
                Transform.translate(
                  offset: const Offset(-20, 80),
                  child: Icon(Icons.cloud, color: Colors.grey.shade100, size: 60),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Heading
            Text(
              'No events or bookings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              "We're not currently serving this location.\nTry choosing a different city.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LocationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Change Location',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
