import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';
import '../core/auth_state.dart';
import '../core/responsive.dart';
import '../core/saved_events_state.dart';
import '../core/booked_events_state.dart';
import 'bookings_screen.dart';
import 'saved_events_screen.dart';
import 'help_centre_screen.dart';
import 'account_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_settings_screen.dart';
import 'your_reviews_screen.dart';
import 'notification_screen.dart';
import 'reminders_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Profile header (centered layout matching Figma) ────────────
            Center(
              child: Column(
                children: [
                  // Avatar with camera badge
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 3),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/new_home/profilepic.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 15, color: Color(0xFF555555)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    'Laxman',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Email
                  Text(
                    'Laxmanartist@yahoo.com',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Edit Profile button (dark rounded pill)
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1F11),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 20, endIndent: 20),
            const SizedBox(height: 4),

            // ── Top menu block ──────────────────────────────────────────────
            _item(
              icon: Icons.confirmation_number_outlined,
              label: 'All Booking',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BookingsScreen())),
            ),
            _item(
              icon: Icons.favorite_border_rounded,
              label: 'Favorite',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SavedEventsScreen())),
            ),
            _item(
              icon: Icons.credit_card_outlined,
              label: 'Payment Settings',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PaymentSettingsScreen())),
            ),
            _item(
              icon: Icons.description_outlined,
              label: 'Your Reviews',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const YourReviewsScreen())),
            ),
            _item(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen())),
            ),
            _item(
              icon: Icons.alarm_outlined,
              label: 'Reminders',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RemindersScreen())),
            ),

            const SizedBox(height: 4),
            const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 20, endIndent: 20),
            const SizedBox(height: 4),

            // ── Bottom menu block ───────────────────────────────────────────
            _item(
              icon: Icons.settings_outlined,
              label: 'Account Settings',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccountSettingsScreen())),
            ),
            _item(
              icon: Icons.help_outline_rounded,
              label: 'Help',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpCentreScreen())),
            ),
            _item(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              iconColor: const Color(0xFFE53935),
              labelColor: const Color(0xFFE53935),
              hideChevron: true,
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _item({
    required IconData icon,
    required String label,
    Color iconColor = const Color(0xFF555555),
    Color labelColor = const Color(0xFF2D2D2D),
    bool hideChevron = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, size: 24, color: iconColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      trailing: hideChevron
          ? null
          : const Icon(Icons.chevron_right, color: Color(0xFF2196F3), size: 22),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.sp(context, 17))),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.poppins(
                fontSize: 14, color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final refresh = AuthState.refreshToken;
              if (refresh != null) {
                await AuthService.logout(refresh: refresh);
              }
              AuthState.logout();
              SavedEventsState.savedEvents.value = [];
              BookedEventsState.bookings.value = [];
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Text('Log Out',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
