import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/responsive.dart';
import '../core/avatar_image.dart';
import '../providers/auth_state.dart';
import '../providers/notifications_state.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/location_screen.dart';
import '../widgets/login_sheet.dart';
import '../providers/location_state.dart';
import '../helpers/walkthrough_keys.dart';

/// The greeting + search header shared across Home, Events, Classes,
/// Programs and Venues.
///
/// Two visual modes:
/// * [onDark] `true` — the Home screen's flat black backdrop styling: no cloud
///   texture, light text/icons, an outlined bell ring, a gold avatar ring and
///   a bigger dark translucent search field.
/// * [onDark] `false` (default) — the original light-cream styling used by the
///   other screens: a golden cloud texture behind the content, dark text and a
///   golden search bar.
class HomeHeader extends StatelessWidget {
  final ShowcaseProfileConfig? profileShowcaseConfig;
  final ShowcaseProfileConfig? locationShowcaseConfig;

  /// Renders the flat black-backdrop styling when true (see class docs).
  final bool onDark;

  /// Light-mode only: paints the screen's flat background tone over the cloud
  /// ShaderMask's 1px bottom fringe (the faint seam line). Ignored when
  /// [onDark] is true (no cloud is drawn there).
  final Color? seamCoverColor;

  const HomeHeader({
    super.key,
    this.profileShowcaseConfig,
    this.locationShowcaseConfig,
    this.onDark = false,
    this.seamCoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, onDark ? 20 : 16),
          // Dark header sits tight to the status bar so the logo row is high up.
          Responsive.h(context, onDark ? 2 : 14, min: onDark ? 0 : 10),
          Responsive.w(context, onDark ? 20 : 16),
          Responsive.h(context, onDark ? 18 : 20, min: onDark ? 14 : 16),
        ),
        child: onDark ? _buildDarkLayout(context) : _buildLightLayout(context),
      ),
    );

    // Dark mode paints nothing of its own — the black backdrop comes from the
    // parent container in HomeScreen.
    if (onDark) return content;

    // ── Light mode: golden cloud texture behind the content ──
    // ColorFiltered tints the cloud image golden (screen blend); ShaderMask
    // (dstIn) fades it to transparent toward the bottom so the screen's warm
    // gradient shows through. `bottom: 28` tucks the ShaderMask's 1px bottom
    // fringe behind the opaque search bar where it can't be seen.
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 28,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.35, 1.0],
            ).createShader(bounds),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFB219),
                BlendMode.screen,
              ),
              child: Transform.flip(
                flipY: true,
                child: Image.asset(
                  'resources- tlb-ui/header.jpg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),

        // Seam cover — paints the flat background tone over the cloud's bottom
        // fringe. Fades in from transparent so it never creates its own edge.
        if (seamCoverColor != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 56,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      seamCoverColor!.withOpacity(0.0),
                      seamCoverColor!,
                      seamCoverColor!,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

        content,
      ],
    );
  }

  /// Dark (Home) layout — matches the reference: a top row with the TLB logo on
  /// the left and the bell + avatar on the right, then the greeting, the
  /// location chip and the search bar stacked below.
  Widget _buildDarkLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/the_little_broadway_yellow.svg',
              height: Responsive.h(context, 42, min: 34),
              fit: BoxFit.contain,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: _buildBell(context),
            ),
            const SizedBox(width: 10),
            _buildAvatar(context),
          ],
        ),
        SizedBox(height: Responsive.h(context, 14, min: 10)),
        _buildGreetingText(context),
        const SizedBox(height: 6),
        _buildLocationRow(context, locationShowcaseConfig),
        SizedBox(height: Responsive.h(context, 16, min: 12)),
        _buildSearchBar(context),
      ],
    );
  }

  /// Light layout (Events/Classes/Programs/Venues) — greeting + location on the
  /// left, bell + avatar on the right, then the search bar.
  Widget _buildLightLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingText(context),
                  const SizedBox(height: 4),
                  _buildLocationRow(context, locationShowcaseConfig),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: _buildBell(context),
            ),
            const SizedBox(width: 10),
            _buildAvatar(context),
          ],
        ),
        SizedBox(height: Responsive.h(context, 16, min: 12)),
        _buildSearchBar(context),
      ],
    );
  }

  /// Greeting text + waving hand. Dark shows a brand greeting; light greets the
  /// signed-in user by name.
  Widget _buildGreetingText(BuildContext context) {
    final Color greetingColor = onDark ? Colors.white : AppColors.textPrimary;
    final TextStyle style = GoogleFonts.poppins(
      fontSize: Responsive.sp(context, onDark ? 21 : 20),
      fontWeight: FontWeight.w700,
      color: greetingColor,
    );
    final Widget greeting = onDark
        ? Text('Welcome to TLB',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: style)
        : ValueListenableBuilder<String?>(
            valueListenable: AuthState.userName,
            builder: (context, name, _) {
              final text = name != null
                  ? 'Hello ${name.split(' ').first}'
                  : 'Hello There';
              return Text(text,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
            },
          );

    return Row(
      children: [
        Flexible(child: greeting),
        const SizedBox(width: 8),
        Image.asset(
          'assets/images/wave_hand.png',
          width: Responsive.w(context, onDark ? 22 : 24),
          height: Responsive.w(context, onDark ? 22 : 24),
          errorBuilder: (_, __, ___) => Text('👋',
              style: TextStyle(fontSize: Responsive.sp(context, 22))),
        ),
      ],
    );
  }

  /// The circular profile avatar (with optional onboarding showcase).
  Widget _buildAvatar(BuildContext context) {
    return ValueListenableBuilder<String?>(
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
            width: Responsive.w(context, onDark ? 40 : 38),
            height: Responsive.w(context, onDark ? 40 : 38),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Gold ring on dark; white ring on light.
              border: Border.all(
                color: onDark ? AppColors.amber : Colors.white,
                width: 2.5,
              ),
              boxShadow: onDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipOval(
              child: Image(
                image: avatarImageProvider(
                  url,
                  fallback: const AssetImage(
                      'assets/images/new_home/profilepic.jpg'),
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/new_home/profilepic.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );

        if (profileShowcaseConfig == null) return avatarGesture;

        return Showcase(
          key: profileShowcaseConfig!.showcaseKey,
          title: profileShowcaseConfig!.title,
          description: profileShowcaseConfig!.description,
          overlayOpacity: 0.78,
          tooltipBackgroundColor: AppColors.textPrimary,
          textColor: Colors.white,
          scaleAnimationDuration: const Duration(milliseconds: 350),
          scaleAnimationCurve: Curves.easeInOut,
          movingAnimationDuration: const Duration(milliseconds: 350),
          targetPadding: const EdgeInsets.all(8),
          child: avatarGesture,
        );
      },
    );
  }

  /// The notification bell — an outlined ring on dark, a filled translucent
  /// circle on light. The unread dot only shows when there are unread items.
  Widget _buildBell(BuildContext context) {
    final Color iconColor = onDark ? Colors.white : AppColors.textPrimary;
    return Container(
      width: Responsive.w(context, onDark ? 40 : 40),
      height: Responsive.w(context, onDark ? 40 : 40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onDark ? null : Colors.white.withOpacity(0.55),
        border: onDark
            ? Border.all(color: Colors.white.withOpacity(0.22), width: 1.4)
            : null,
        boxShadow: onDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFFFB219).withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: NotificationsState.unreadCount,
        builder: (_, unread, __) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined,
                  size: onDark ? 19 : 22, color: iconColor),
              if (unread > 0)
                Positioned(
                  top: onDark ? -1 : 8,
                  right: onDark ? 0 : 9,
                  child: Container(
                    width: onDark ? 9 : 8,
                    height: onDark ? 9 : 8,
                    decoration: BoxDecoration(
                      color: onDark ? AppColors.amber : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: onDark ? Colors.black : Colors.white,
                        width: onDark ? 1.6 : 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    ShowcaseProfileConfig? locationShowcaseConfig,
  ) {
    final Color iconColor = onDark ? Colors.white : AppColors.textPrimary;
    final Color textColor = onDark ? Colors.white70 : AppColors.textPrimary;

    final locationRow = GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LocationScreen()),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              size: onDark ? 12 : 14, color: iconColor),
          const SizedBox(width: 3),
          ValueListenableBuilder<String>(
            valueListenable: LocationState().selectedCity,
            builder: (context, city, _) {
              final label =
                  city.length > 18 ? '${city.substring(0, 18)}...' : city;
              return Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, onDark ? 11 : 12),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              );
            },
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down,
              size: onDark ? 14 : 16, color: textColor),
        ],
      ),
    );

    if (locationShowcaseConfig == null) return locationRow;

    return Showcase(
      key: locationShowcaseConfig.showcaseKey,
      title: locationShowcaseConfig.title,
      description: locationShowcaseConfig.description,
      overlayOpacity: 0.78,
      tooltipBackgroundColor: AppColors.textPrimary,
      textColor: Colors.white,
      scaleAnimationDuration: const Duration(milliseconds: 350),
      scaleAnimationCurve: Curves.easeInOut,
      movingAnimationDuration: const Duration(milliseconds: 350),
      targetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      // Tapping the location chip opens LocationScreen. `disposeOnTap` is
      // required by showcaseview whenever `onTargetClick` is set; we dispose the
      // running showcase first so its dark overlay doesn't cover LocationScreen.
      // When the user returns we RESUME the tour from the navbar tabs through
      // the profile avatar (a plain `.next()` here would be a no-op because the
      // showcase was just disposed — which is what dropped those later steps).
      disposeOnTap: true,
      onTargetClick: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LocationScreen()),
        ).then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowcaseView.get()
                .startShowCase(WalkthroughKeys.afterLocationKeys);
          });
        });
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
      child: onDark ? _buildDarkSearchBar(context) : _buildLightSearchBar(context),
    );
  }

  /// Bigger dark translucent field with a hairline light border, used on the
  /// black backdrop.
  Widget _buildDarkSearchBar(BuildContext context) {
    return Container(
      height: Responsive.h(context, 48, min: 44),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        // Fully rounded (pill) — radius = half the bar height.
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search experiences, events...',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
          ),
          const Icon(Icons.tune_rounded, color: Colors.white70, size: 19),
          const SizedBox(width: 18),
        ],
      ),
    );
  }

  /// Golden gradient bar with a white border, used on the light cream header.
  Widget _buildLightSearchBar(BuildContext context) {
    return Container(
      height: Responsive.h(context, 43, min: 37),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFEDC4), Color(0xFFFFE0A6)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search...',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 22,
            color: AppColors.textPrimary.withOpacity(0.18),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}
