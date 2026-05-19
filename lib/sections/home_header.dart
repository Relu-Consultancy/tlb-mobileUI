import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/responsive.dart';
import '../providers/auth_state.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/location_screen.dart';
import '../widgets/login_sheet.dart';
import '../providers/location_state.dart';
import '../helpers/walkthrough_keys.dart';

class HomeHeader extends StatelessWidget {
  final ShowcaseProfileConfig? profileShowcaseConfig;
  final ShowcaseProfileConfig? locationShowcaseConfig;

  const HomeHeader({
    super.key,
    this.profileShowcaseConfig,
    this.locationShowcaseConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Layer 1: Cloud image with screen-blend gradient mask ──────
        // screen brightens: golden(top)+pixel = warm bright result
        //                   white(bottom)+pixel = fully white fade
        Positioned.fill(
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

        // ── Layer 2: Content ────────────────────────────────────────────
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
                _buildGreetingRow(
                  context,
                  profileShowcaseConfig: profileShowcaseConfig,
                  locationShowcaseConfig: locationShowcaseConfig,
                ),
                const SizedBox(height: 16),
                _buildSearchBar(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingRow(
    BuildContext context, {
    ShowcaseProfileConfig? profileShowcaseConfig,
    ShowcaseProfileConfig? locationShowcaseConfig,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: greeting + location — Expanded so it never pushes the icons
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: AuthState.userName,
                      builder: (context, name, _) {
                        final greeting = name != null
                            ? 'Hello ${name.split(' ').first}'
                            : 'Hello There';
                        return Text(
                          greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/images/wave_hand.png',
                    width: Responsive.w(context, 24),
                    height: Responsive.w(context, 24),
                    errorBuilder: (_, __, ___) => Text('👋', style: TextStyle(fontSize: Responsive.sp(context, 20))),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildLocationRow(context, locationShowcaseConfig),
            ],
          ),
        ),

        // Right: bell + avatar — fixed width, always right-aligned
        const SizedBox(width: 8),
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
                  color: Colors.white.withOpacity(0.55),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB219).withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'resources- tlb-ui/alert.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<String?>(
              valueListenable: AuthState.avatarUrl,
              builder: (context, url, _) {
                final avatarGesture = GestureDetector(
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
                    ),
                    child: ClipOval(
                      child: (url != null && url.isNotEmpty)
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/new_home/profilepic.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/new_home/profilepic.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );

                if (profileShowcaseConfig == null) return avatarGesture;

                return Showcase(
                  key: profileShowcaseConfig.showcaseKey,
                  title: profileShowcaseConfig.title,
                  description: profileShowcaseConfig.description,
                  overlayOpacity: 0.78,
                  tooltipBackgroundColor: const Color(0xFF1A1A2E),
                  textColor: Colors.white,
                  scaleAnimationDuration: const Duration(milliseconds: 350),
                  scaleAnimationCurve: Curves.easeInOut,
                  movingAnimationDuration: const Duration(milliseconds: 350),
                  targetPadding: const EdgeInsets.all(8),
                  child: avatarGesture,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    ShowcaseProfileConfig? locationShowcaseConfig,
  ) {
    final locationRow = GestureDetector(
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
              final label =
                  city.length > 18 ? '${city.substring(0, 18)}...' : city;
              return Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12),
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
    );

    if (locationShowcaseConfig == null) return locationRow;

    return Showcase(
      key: locationShowcaseConfig.showcaseKey,
      title: locationShowcaseConfig.title,
      description: locationShowcaseConfig.description,
      overlayOpacity: 0.78,
      tooltipBackgroundColor: const Color(0xFF1A1A2E),
      textColor: Colors.white,
      scaleAnimationDuration: const Duration(milliseconds: 350),
      scaleAnimationCurve: Curves.easeInOut,
      movingAnimationDuration: const Duration(milliseconds: 350),
      targetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      // Tapping the location chip opens LocationScreen; tour advances on pop
      onTargetClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LocationScreen()),
        ).then((_) => ShowcaseView.get().next());
      },
      child: locationRow,
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
                  fontSize: Responsive.sp(context, 14),
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
