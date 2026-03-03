import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bookings_screen.dart';
import 'saved_events_screen.dart';
import 'help_centre_screen.dart';
import 'account_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_settings_screen.dart';
import 'your_reviews_screen.dart';
import 'offers_screen.dart';
import 'notification_screen.dart';

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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=Laxman&background=random&size=200',
                            ), // Placeholder avatar
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laxman',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Laxmanartist@yahoo.com',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A1F11), // Dark greenish black
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            // Top Menu Block
            _buildMenuItem(
              icon: Icons.confirmation_num_outlined,
              title: 'All Booking',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: 'Favorite',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedEventsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment Settings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentSettingsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.book_outlined,
              title: 'Your Reviews',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const YourReviewsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.local_offer_outlined,
              title: 'Offers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OffersScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.alarm,
              title: 'Reminders',
              onTap: () {},
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            // Bottom Menu Block
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Account Settings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCentreScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.logout,
              iconColor: const Color(0xFFE53935), // Red
              title: 'Log Out',
              hideChevron: true,
              onTap: () {
                // Log out action
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    Color iconColor = const Color(0xFF424242), // Dark grey
    required String title,
    bool hideChevron = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF424242),
        ),
      ),
      trailing: hideChevron
          ? null
          : const Icon(Icons.chevron_right, color: Color(0xFF2196F3), size: 22), // Blue chevron
      onTap: onTap,
    );
  }
}
