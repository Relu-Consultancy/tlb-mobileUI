import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/avatar_image.dart';
import '../core/responsive.dart';
import '../providers/auth_state.dart';
import '../services/auth_service.dart';
import '../widgets/app_loader.dart';
import '../widgets/login_sheet.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

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
          'Account Settings',
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
          children: [
            // ── Profile card ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Personal Info row
                  ValueListenableBuilder<String?>(
                    valueListenable: AuthState.avatarUrl,
                    builder: (context, url, _) {
                      final email = AuthState.userEmail ?? 'No email provided';
                      final profile = AuthState.userData?['profile']
                          as Map<String, dynamic>?;
                      final initial = Uri.encodeComponent(
                        (profile?['first_name'] as String? ?? '').isNotEmpty
                            ? profile!['first_name'] as String
                            : (AuthState.userEmail
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U'),
                      );
                      final fallbackUrl =
                          'https://ui-avatars.com/api/?name=$initial&background=FFCC00&color=1A1A2E&size=200';

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: avatarImageProvider(
                                    url,
                                    fallback: NetworkImage(fallbackUrl),
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A2E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personal',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 11),
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    'Personal Info',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 15),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      color: Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    isLast: true,
                    onTap: () =>
                        AppSnackBar.comingSoon(context, 'Phone Number edit'),
                  ),
                  // Change Password row removed — auth is OTP-only, users
                  // never set a password, so the option was a dead end.
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Privacy card ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      'Privacy',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Manage Permissions',
                    onTap: () => AppSnackBar.comingSoon(
                        context, 'Manage Permissions'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(
                    context,
                    icon: Icons.delete_outline,
                    label: 'Delete Account',
                    isLast: true,
                    onTap: () => _confirmDeleteAccount(context),
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

  // ── Delete account ────────────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete account?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: Responsive.sp(context, 17),
          ),
        ),
        content: Text(
          'Your account will be deactivated immediately and you will be signed out. Your booking history is retained for legal records. This action cannot be undone from the app.',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 13.5),
            color: Colors.grey.shade700,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: Responsive.sp(context, 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.w500,
                fontSize: Responsive.sp(context, 14),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _performDelete(context);
  }

  Future<void> _performDelete(BuildContext context) async {
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in again.');
      return;
    }

    // Blocking spinner while the request runs — root navigator so it lives
    // above the screen Stack and we can pop it from anywhere.
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(
        child: SizedBox(width: 56, height: 56, child: AppLoader()),
      ),
    );

    final result = await AuthService.deleteAccount(accessToken: token);

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close spinner

    if (result['success'] == true) {
      AuthState.logout();
      if (!context.mounted) return;
      AppSnackBar.success(context, 'Your account has been deleted.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      AppSnackBar.error(
        context,
        result['message']?.toString() ??
            'Could not delete your account. Please try again.',
      );
    }
  }

  Widget _buildRow(BuildContext context, {
    required IconData icon,
    required String label,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14.5),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
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
