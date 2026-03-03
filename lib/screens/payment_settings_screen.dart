import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSettingsScreen extends StatelessWidget {
  const PaymentSettingsScreen({super.key});

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
          'Payment Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saved UPI IDs ──
              _buildSectionHeader('Saved UPI IDs'),
              const SizedBox(height: 12),
              _buildUpiCard(
                upiId: 'laxman@oksbi',
                bankName: 'State Bank of India',
                icon: Icons.account_balance,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 10),
              _buildUpiCard(
                upiId: 'laxman@okaxis',
                bankName: 'Axis Bank',
                icon: Icons.account_balance,
                color: const Color(0xFF880E4F),
              ),
              const SizedBox(height: 10),
              _buildAddButton('Add UPI ID'),

              const SizedBox(height: 28),

              // ── Saved Bank Details ──
              _buildSectionHeader('Saved Bank Details'),
              const SizedBox(height: 12),
              _buildBankCard(
                bankName: 'State Bank of India',
                accountNumber: '•••• •••• •••• 4521',
                ifsc: 'SBIN0001234',
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 10),
              _buildBankCard(
                bankName: 'HDFC Bank',
                accountNumber: '•••• •••• •••• 8734',
                ifsc: 'HDFC0009876',
                color: const Color(0xFF004D40),
              ),
              const SizedBox(height: 10),
              _buildAddButton('Add Bank Account'),

              const SizedBox(height: 28),

              // ── Transaction History ──
              _buildSectionHeader('Transaction History'),
              const SizedBox(height: 12),
              ..._dummyTransactions.map((t) => _buildTransactionTile(t)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildUpiCard({
    required String upiId,
    required String bankName,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upiId,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bankName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
        ],
      ),
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String accountNumber,
    required String ifsc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                bankName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            accountNumber,
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'IFSC: $ifsc',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFFFC107),
          style: BorderStyle.solid,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFC107),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> t) {
    Color statusColor;
    IconData statusIcon;
    switch (t['status']) {
      case 'Success':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      case 'Failed':
        statusColor = const Color(0xFFE53935);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFFFA726);
        statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['event'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  t['date'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${t['amount']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    t['status'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _dummyTransactions => [
        {
          'event': 'Halloween Party 2025',
          'amount': '1,200',
          'date': 'Feb 28, 2025',
          'status': 'Success',
        },
        {
          'event': 'Kids Storytelling Day',
          'amount': '800',
          'date': 'Feb 25, 2025',
          'status': 'Success',
        },
        {
          'event': 'World Music Festival',
          'amount': '2,500',
          'date': 'Feb 20, 2025',
          'status': 'Failed',
        },
        {
          'event': 'Art & Craft Workshop',
          'amount': '600',
          'date': 'Feb 15, 2025',
          'status': 'Success',
        },
        {
          'event': 'Summer Dance Camp',
          'amount': '1,500',
          'date': 'Feb 10, 2025',
          'status': 'Pending',
        },
      ];
}
