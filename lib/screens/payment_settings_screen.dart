import 'package:flutter/material.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_state.dart';
import '../services/payment_method_service.dart';
import '../models/api_payment_method_model.dart';
import '../services/token_storage.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  List<ApiPaymentMethod>? _methods;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMethods();
  }

  Future<void> _fetchMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tokens = await TokenStorage.loadTokens();
      final token = tokens['access'];
      if (token == null) throw Exception('Not authenticated');
      final methods = await PaymentMethodService.listPaymentMethods(token: token);
      setState(() {
        _methods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            _error ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 13),
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _fetchMethods,
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF1A1A2E)),
            label: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC00),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMethod(ApiPaymentMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method?'),
        content: Text('Are you sure you want to remove this ${method.methodType == 'card' ? 'card' : 'UPI ID'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final tokens = await TokenStorage.loadTokens();
      final token = tokens['access'];
      if (token == null) return;
      await PaymentMethodService.deletePaymentMethod(token: token, id: method.id);
      if (mounted) AppSnackBar.success(context, 'Payment method removed');
      _fetchMethods();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString());
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
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
              color: const Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved payment methods',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your saved cards and UPI IDs will appear here. You can save them during your next booking checkout.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 12.5),
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(ApiPaymentMethod method) {
    final isCard = method.methodType == 'card';
    String title = '';
    String subtitle = '';
    IconData iconData = Icons.payment;
    Color iconBg = const Color(0xFFEDF4FF);
    Color iconColor = const Color(0xFF2563EB);

    if (isCard) {
      final network = method.cardNetwork ?? 'Card';
      final type = method.cardType != null ? '${method.cardType![0].toUpperCase()}${method.cardType!.substring(1)}' : '';
      title = '$network $type ···${method.cardLast4 ?? 'XXXX'}';
      subtitle = method.cardIssuer ?? '';
      iconData = Icons.credit_card;
    } else if (method.methodType == 'upi') {
      title = 'UPI';
      subtitle = method.upiVpaMasked ?? '';
      iconData = Icons.account_balance_wallet_outlined;
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
    } else {
      title = method.methodType.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: () => _deleteMethod(method),
            tooltip: 'Remove payment method',
          ),
        ],
      ),
    );
  }

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
            fontWeight: FontWeight.w500,
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
                                fontWeight: FontWeight.w500,
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

            const SizedBox(height: 24),

            // ── Saved Methods ──
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildError()
            else if (_methods == null || _methods!.isEmpty)
              _buildEmptyState()
            else ...[
              Text(
                'Saved Methods',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              ..._methods!.map(_buildMethodCard),
            ],

            const SizedBox(height: 32),

            // ── Need more help ──
            Text(
              'Need more help?',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
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
                    fontWeight: FontWeight.w500,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
