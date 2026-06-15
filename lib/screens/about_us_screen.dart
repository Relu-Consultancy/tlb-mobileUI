import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

/// About Us — a simple list linking to the Privacy Policy and Terms of
/// Service documents.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F5),
        surfaceTintColor: const Color(0xFFF2F3F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFECECEC)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(
                context,
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                ),
              ),
              const Divider(
                  height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
              _row(
                context,
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 21, color: const Color(0xFF1A1A2E)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 22, color: AppColors.seeAllBlue),
            ],
          ),
        ),
      ),
    );
  }
}
