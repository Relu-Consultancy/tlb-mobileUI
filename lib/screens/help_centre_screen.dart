import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting banner ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi Laxman,',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'How can we help you today?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'resources- tlb-ui/tlbAppIcon.png',
                  width: 72,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.headphones,
                    size: 64,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Search bar ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Common Topics',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),

            // ── Topics list ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTopic(
                    icon: Icons.calendar_today_outlined,
                    iconBg: const Color(0xFFEDF4FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Booking Issues',
                    subtitle: 'Having trouble with the booking?',
                    isFirst: true,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildTopic(
                    icon: Icons.credit_card_outlined,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF16A34A),
                    title: 'Payment Problems',
                    subtitle: 'Payment failed or not reflected?',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildTopic(
                    icon: Icons.swap_horiz_rounded,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF059669),
                    title: 'Refund Status',
                    subtitle: 'Check your refund or cancellation status',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Need more help?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Our support team is ready to assist you.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),

            // ── Chat with support ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB), size: 20),
                ),
                title: Text(
                  'Chat with support',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                subtitle: Text(
                  'We usually reply in minutes',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
              ),
            ),

            const SizedBox(height: 10),

            // ── Support Hours (yellow bg) ──
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.access_time_outlined, color: Color(0xFFFFB902), size: 20),
                ),
                title: Text(
                  'Support Hours',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                subtitle: Text(
                  'Mon – Sun | 9:00 AM – 9:00 PM',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopic({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
            ],
          ),
        ),
      ),
    );
  }
}
