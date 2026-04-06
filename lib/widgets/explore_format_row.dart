import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';

class ExploreFormatRow extends StatelessWidget {
  const ExploreFormatRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: DummyData.exploreFormats.map((format) {
          final isMasterclass = format['label'] == 'MASTERCLASS';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: format['color'],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    format['label'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bangers(
                      fontSize: isMasterclass ? 12 : 14,
                      color: isMasterclass ? Colors.white : Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
