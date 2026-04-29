import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../core/auth_state.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_sheet.dart';
import '../core/location_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Layer 1: Cloud image with screen-blend gradient mask ──────
        // screen brightens: golden(top)+pixel = warm bright result
        //                   white(bottom)+pixel = fully white fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ShaderMask(
            blendMode: BlendMode.screen,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFB219), Colors.white],
            ).createShader(bounds),
            child: Transform.flip(
              flipY: true,
              child: Image.asset(
                'resources- tlb-ui/header.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),

        // ── Layer 3: Content ────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 16),
              Responsive.h(context, 14, min: 10),
              Responsive.w(context, 16),
              Responsive.h(context, 20, min: 16),
            ),
            child: Column(
              children: [
                _buildGreetingRow(context),
                const SizedBox(height: 16),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: greeting + location
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: AuthState.isLoggedIn,
                  builder: (context, loggedIn, _) {
                    final name = loggedIn && AuthState.userName != null
                        ? 'Hello ${AuthState.userName}'
                        : 'Hello There';
                    return Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 20),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Image.asset(
                  'assets/images/wave_hand.png',
                  width: Responsive.w(context, 24),
                  height: Responsive.w(context, 24),
                  errorBuilder: (_, __, ___) => const Text('👋', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF1A1A2E)),
                  const SizedBox(width: 3),
                  ValueListenableBuilder<String>(
                    valueListenable: LocationState().selectedCity,
                    builder: (context, city, _) {
                      final label = city.length > 18
                          ? '${city.substring(0, 18)}...'
                          : city;
                      return Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Color(0xFF1A1A2E)),
                ],
              ),
            ),
          ],
        ),

        // Right: bell + avatar
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (AuthState.isLoggedIn.value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                } else {
                  showLoginSheet(context);
                }
              },
              child: Container(
                width: Responsive.w(context, 38),
                height: Responsive.w(context, 38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
        height: Responsive.h(context, 48, min: 42),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 22,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.tune_rounded, color: Color(0xFF1A1A2E), size: 20),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
