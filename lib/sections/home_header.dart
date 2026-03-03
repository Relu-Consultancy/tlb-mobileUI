import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/auth_state.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_sheet.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Header background image — no rounded corners, blends into page
        Positioned.fill(
          child: Transform.flip(
            flipY: true, // Clouds at top
            child: Image.asset(
              'assets/images/header.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        // Golden overlay that fades to page background color at the bottom
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 0.8, 1.0],
                colors: [
                  const Color(0xFFFFF3E0).withOpacity(0.95), // Extra light orange/whitish at top (Orange 50)
                  const Color(0xFFFFB74D).withOpacity(0.85), // Light orange (Orange 300)
                  const Color(0xFFFFCC80).withOpacity(0.90), // Lighter orange transition (Orange 200)
                  const Color(0xFFFFF8EE), // Fades beautifully into page background
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 88, 16, 36),
            child: Column(
              children: [
                _buildGreetingRow(context),
                const SizedBox(height: 20),
                _buildSearchBar(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello World',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  'assets/images/wave_hand.png',
                  width: 22,
                  height: 22,
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Location row — tappable
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'The Palm Springs, DLF ...',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Bell icon — Notifications
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 26,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Profile avatar
            GestureDetector(
              onTap: () {
                if (AuthState.isLoggedIn.value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                } else {
                  showLoginSheet(context);
                }
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/new_home/profilepic.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFCF5E8), // Very light yellow/off-white
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            const Icon(Icons.search, color: Color(0xFF1A1A2E), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ),
            const Icon(Icons.tune, color: Color(0xFF1A1A2E), size: 22), // Filter icon
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
