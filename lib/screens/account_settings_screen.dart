import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: const AssetImage(
                                'resources- tlb-ui/tlbAppIcon.png',
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: ClipOval(
                                child: Image.asset(
                                  'resources- tlb-ui/tlbAppIcon.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
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
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                'Personal Info',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                'Laxmanartist@yahoo.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(icon: Icons.phone_outlined, label: 'Phone Number'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(icon: Icons.lock_outline, label: 'Change Password', isLast: true),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(icon: Icons.settings_outlined, label: 'Manage Permissions'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRow(icon: Icons.delete_outline, label: 'Delete Account', isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
                    fontSize: 14.5,
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
