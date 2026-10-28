import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/responsive.dart';
import '../models/help_ticket_model.dart';
import '../providers/auth_state.dart';
import 'new_ticket_screen.dart';
import 'tickets_list_screen.dart';

/// Help & Support landing screen.
///
/// Restored in Session 49 with the original layout wired to real backend
/// ticketing endpoints (POST/GET `/api/v1/help/tickets/...`). Tapping a
/// Common Topic opens a new-ticket form pre-set to that category; the
/// "My Tickets" tile takes the user to their ticket list.
class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});

  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  void _openNewTicket({HelpCategory? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewTicketScreen(initialCategory: category),
      ),
    );
  }

  void _openMyTickets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TicketsListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting banner ────────────────────────────────────────
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
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
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
                  width: 110,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.headphones,
                    size: 64,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Common Topics ──────────────────────────────────────────
            Text(
              'Common Topics',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a topic to open a new support ticket.',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTopic(
                    context,
                    icon: Icons.calendar_today_outlined,
                    iconBg: const Color(0xFFEDF4FF),
                    iconColor: AppColors.accentBlue,
                    title: 'Booking Issues',
                    subtitle: 'Trouble with a booking or cancellation?',
                    onTap: () =>
                        _openNewTicket(category: const HelpCategory(value: 'booking_issue', label: 'Booking Issues')),
                    isFirst: true,
                  ),
                  const Divider(
                      height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                  _buildTopic(
                    context,
                    icon: Icons.credit_card_outlined,
                    iconBg: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFB45309),
                    title: 'Payment Problems',
                    subtitle: 'Payment failed or not reflected?',
                    onTap: () =>
                        _openNewTicket(category: const HelpCategory(value: 'payment_problem', label: 'Payment Problems')),
                  ),
                  const Divider(
                      height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                  _buildTopic(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF059669),
                    title: 'Refund Status',
                    subtitle: 'Check refund or cancellation status.',
                    onTap: () =>
                        _openNewTicket(category: const HelpCategory(value: 'refund_status', label: 'Refund Status')),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── My Tickets + Chat with support ─────────────────────────
            Text(
              'Talk to us',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildAction(
                    context,
                    icon: Icons.receipt_long_outlined,
                    iconBg: const Color(0xFFEDF4FF),
                    iconColor: AppColors.accentBlue,
                    title: 'My Tickets',
                    subtitle: 'View ongoing conversations with support',
                    onTap: _openMyTickets,
                    isFirst: true,
                  ),
                  const Divider(
                      height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                  _buildAction(
                    context,
                    icon: Icons.chat_bubble_outline,
                    iconBg: const Color(0xFFEDF4FF),
                    iconColor: AppColors.accentBlue,
                    title: 'Chat with support',
                    subtitle: "Start a new conversation — we'll respond soon",
                    onTap: () => _openNewTicket(),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Support Hours ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.starAmber,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.schedule, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support Hours',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Mon – Sun · 9:00 AM – 9:00 PM IST',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopic(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        fontSize: Responsive.sp(context, 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 11.5),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.accentBlue),
            ],
          ),
        ),
      ),
    );
  }

  // Same shape as _buildTopic — kept separate so future tweaks (e.g.
  // unread badge on My Tickets) don't bleed across topic rows.
  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) =>
      _buildTopic(
        context,
        icon: icon,
        iconBg: iconBg,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        isFirst: isFirst,
        isLast: isLast,
      );
}
