import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Centre',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Top Help Topics',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // 2x2 grid of help topics
            Row(
              children: [
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.email_outlined,
                    iconColor: const Color(0xFF2196F3),
                    title: 'Payment &\nRefund',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.cancel_outlined,
                    iconColor: const Color(0xFFF44336),
                    title: 'Cancellation &\nExchange',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.workspace_premium_outlined,
                    iconColor: const Color(0xFFFFC107),
                    title: 'Classes Related\nQueries',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.groups_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Ticket Booking\nQueries',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // See All Help Topics
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'See All Help Topics',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF1A1A2E)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
