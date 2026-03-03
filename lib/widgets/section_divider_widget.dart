import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionDividerWidget extends StatelessWidget {
  final String title;

  const SectionDividerWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLine(isLeft: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ),
          _buildLine(isLeft: false),
        ],
      ),
    );
  }

  Widget _buildLine({required bool isLeft}) {
    return Container(
      width: 40,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? [Colors.transparent, const Color(0xFFE4CD89)]
              : [const Color(0xFFE4CD89), Colors.transparent],
        ),
      ),
    );
  }
}
