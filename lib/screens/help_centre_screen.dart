import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_state.dart';

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
            fontSize: Responsive.sp(context, 18),
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
            // ── Greeting banner (kept — generic, no false promises) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: AuthState.userName,
                        builder: (context, _, __) {
                          return Text(
                            'Hi ${AuthState.firstName},',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 22),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A2E),
                            ),
                          );
                        },
                      ),
                      Text(
                        'How can we help you today?',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'resources- tlb-ui/accounts_page/support.png',
                  width: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.headphones,
                    size: 64,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Coming Soon card (Help is not backed by an API yet) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF2563EB),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Currently being developed',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We're building the in-app help centre and live chat. "
                    'In the meantime, please reach our team directly at '
                    'support@thelittlebroadway.com.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12.5),
                      color: Colors.grey.shade600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /* ────────────────────────────────────────────────────────────
             * ORIGINAL DESIGN — kept commented out so it can be reinstated
             * the moment the Help Centre / Chat APIs are ready. Restore by
             * uncommenting this block and removing the Coming-Soon card
             * + `_buildTopic` helper at the bottom of the file.
             *
             * Search bar
             * Container(
             *   decoration: BoxDecoration(
             *     color: Colors.white,
             *     borderRadius: BorderRadius.circular(30),
             *     boxShadow: [
             *       BoxShadow(
             *         color: Colors.black.withOpacity(0.04),
             *         blurRadius: 6,
             *         offset: const Offset(0, 2),
             *       ),
             *     ],
             *   ),
             *   child: TextField(
             *     decoration: InputDecoration(
             *       hintText: 'Search for help...',
             *       hintStyle: GoogleFonts.poppins(
             *         fontSize: Responsive.sp(context, 13),
             *         color: Colors.grey.shade400,
             *       ),
             *       prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
             *       border: InputBorder.none,
             *       contentPadding: const EdgeInsets.symmetric(vertical: 14),
             *     ),
             *   ),
             * ),
             *
             * Common Topics — Booking Issues, Payment Problems, Refund Status
             * Container(
             *   decoration: BoxDecoration(
             *     color: Colors.white,
             *     borderRadius: BorderRadius.circular(16),
             *   ),
             *   child: Column(
             *     children: [
             *       _buildTopic(context,
             *         icon: Icons.calendar_today_outlined,
             *         iconBg: const Color(0xFFEDF4FF),
             *         iconColor: const Color(0xFF2563EB),
             *         title: 'Booking Issues',
             *         subtitle: 'Having trouble with the booking?',
             *         isFirst: true,
             *       ),
             *       const Divider(height: 1, indent: 16, endIndent: 16),
             *       _buildTopic(context,
             *         icon: Icons.credit_card_outlined,
             *         iconBg: const Color(0xFFF0FDF4),
             *         iconColor: const Color(0xFF16A34A),
             *         title: 'Payment Problems',
             *         subtitle: 'Payment failed or not reflected?',
             *       ),
             *       const Divider(height: 1, indent: 16, endIndent: 16),
             *       _buildTopic(context,
             *         icon: Icons.swap_horiz_rounded,
             *         iconBg: const Color(0xFFF0FDF4),
             *         iconColor: const Color(0xFF059669),
             *         title: 'Refund Status',
             *         subtitle: 'Check your refund or cancellation status',
             *         isLast: true,
             *       ),
             *     ],
             *   ),
             * ),
             *
             * Chat with support — ListTile with chat bubble icon
             * Support Hours — yellow card, Mon-Sun 9 AM - 9 PM
             *
             * (Full original markup preserved in git history before
             * Session 48's payment-settings / help-centre rework.)
             * ────────────────────────────────────────────────────────── */
          ],
        ),
      ),
    );
  }

  /* ──────────────────────────────────────────────────────────────────────
   * Topic-row builder for the commented-out Common Topics card. Kept here
   * so the block above can be uncommented as-is once the Help APIs ship.
   *
   * Widget _buildTopic(BuildContext context, {
   *   required IconData icon,
   *   required Color iconBg,
   *   required Color iconColor,
   *   required String title,
   *   required String subtitle,
   *   bool isFirst = false,
   *   bool isLast = false,
   * }) {
   *   return Material(
   *     color: Colors.transparent,
   *     child: InkWell(
   *       onTap: () => AppSnackBar.comingSoon(context, title),
   *       borderRadius: BorderRadius.vertical(
   *         top: isFirst ? const Radius.circular(16) : Radius.zero,
   *         bottom: isLast ? const Radius.circular(16) : Radius.zero,
   *       ),
   *       child: Padding(
   *         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
   *         child: Row(
   *           children: [
   *             Container(
   *               width: 42,
   *               height: 42,
   *               decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
   *               child: Icon(icon, color: iconColor, size: 20),
   *             ),
   *             const SizedBox(width: 14),
   *             Expanded(
   *               child: Column(
   *                 crossAxisAlignment: CrossAxisAlignment.start,
   *                 children: [
   *                   Text(
   *                     title,
   *                     style: GoogleFonts.poppins(
   *                       fontSize: Responsive.sp(context, 14),
   *                       fontWeight: FontWeight.w600,
   *                       color: const Color(0xFF1A1A2E),
   *                     ),
   *                   ),
   *                   Text(
   *                     subtitle,
   *                     style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: Colors.grey.shade500),
   *                   ),
   *                 ],
   *               ),
   *             ),
   *             const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
   *           ],
   *         ),
   *       ),
   *     ),
   *   );
   * }
   * ────────────────────────────────────────────────────────────────────── */
}
