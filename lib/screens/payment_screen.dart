import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatelessWidget {
  final EventModel event;
  final int amount;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Amount Payable Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF9E6),
                  const Color(0xFFFFECB3).withOpacity(0.5),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Payable',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '₹${amount > 0 ? amount.toStringAsFixed(2) : "0.00"}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Preferred Payments ──
                  _buildSectionHeader('PREFERRED PAYMENTS'),
                  _buildPaymentTile(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF6366F1),
                    iconBg: const Color(0xFFEEF2FF),
                    title: 'CRED UPI',
                    subtitle:
                        'Get assured cashback upto ₹200 on this transaction, T&Cs apply',
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _processPayment(context),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  const SizedBox(height: 8),

                  // ── Other Payment Options ──
                  _buildSectionHeader('OTHER PAYMENT OPTIONS'),
                  _buildPaymentTile(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    iconBg: const Color(0xFFE8F5E9),
                    title: 'Pay by any UPI App',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFFFF9800),
                    iconBg: const Color(0xFFFFF3E0),
                    title: 'Debit/Credit Card',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.account_balance_wallet,
                    iconColor: const Color(0xFF2196F3),
                    iconBg: const Color(0xFFE3F2FD),
                    title: 'Mobile Wallets',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.card_giftcard,
                    iconColor: const Color(0xFFE91E63),
                    iconBg: const Color(0xFFFCE4EC),
                    title: 'Gift Voucher',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.laptop_mac,
                    iconColor: const Color(0xFF607D8B),
                    iconBg: const Color(0xFFECEFF1),
                    title: 'Net Banking',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.currency_rupee,
                    iconColor: const Color(0xFF9C27B0),
                    iconBg: const Color(0xFFF3E5F5),
                    title: 'Pay Later',
                    onTap: () => _processPayment(context),
                  ),
                  _buildPaymentDivider(),
                  _buildPaymentTile(
                    icon: Icons.pin_outlined,
                    iconColor: const Color(0xFFFF5722),
                    iconBg: const Color(0xFFFBE9E7),
                    title: 'Redeem Points',
                    onTap: () => _processPayment(context),
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ──
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline, size: 28, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text(
                          'Secure Payment',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Show a brief loading indicator, then navigate to confirmation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // close dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmedScreen(event: event),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      color: const Color(0xFFF5F5F5),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
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
                  ...(subtitle != null
                      ? [
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          )
                        ]
                      : []),
                ],
              ),
            ),
            ...(trailing != null ? [trailing] : []),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDivider() {
    return Divider(height: 1, indent: 70, endIndent: 16, color: Colors.grey.shade200);
  }
}
