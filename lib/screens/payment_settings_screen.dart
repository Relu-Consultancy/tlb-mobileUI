import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_state.dart';

class PaymentSettingsScreen extends StatelessWidget {
  const PaymentSettingsScreen({super.key});

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
          'Payment Settings',
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
            // ── Greeting banner ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
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
                                fontSize: Responsive.sp(context, 20),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A2E),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage  and  secure your saved\npayment methods.',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12),
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'resources- tlb-ui/accounts_page/payments.png',
                    width: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Color(0xFFFFB902),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Coming Soon — saved methods + add-new aren't wired to a
            // backend yet, so the dummy Visa/UPI cards (and Add New Method
            // CTA) have been replaced with a clear under-development card.
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card_outlined,
                      color: Color(0xFFFFB902),
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
                    "We're building the saved-methods feature. "
                    'For now, payments still complete through the Razorpay '
                    'checkout during booking.',
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

            // ── Need more help ──
            Text(
              'Need more help?',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Our support team is ready to assist you.',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),
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
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                subtitle: Text(
                  'We usually reply in minutes',
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: Colors.grey.shade500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
                onTap: () =>
                    AppSnackBar.comingSoon(context, 'Chat with support'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
