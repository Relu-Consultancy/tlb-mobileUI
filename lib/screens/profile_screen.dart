import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_snackbar.dart';
import '../core/avatar_image.dart';
import '../services/auth_service.dart';
import '../services/avatar_storage.dart';
import '../providers/auth_state.dart';
import '../core/responsive.dart';
import '../providers/saved_events_state.dart';
import '../providers/booked_events_state.dart';
import '../providers/user_reviews_state.dart';
import 'bookings_screen.dart';
import 'saved_events_screen.dart';
import 'help_centre_screen.dart';
import 'account_settings_screen.dart';
import 'about_us_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_settings_screen.dart';
import 'your_reviews_screen.dart';
import 'followed_partners_screen.dart';
import 'notification_screen.dart';
import '../widgets/login_sheet.dart';
import '../widgets/app_dialog.dart';
// import 'reminders_screen.dart'; // Reminders entry temporarily hidden — restore when the feature is ready.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _calculateCompletion() {
    final profile = AuthState.userData?['profile'] as Map<String, dynamic>?;
    // Mirror the actual fields collected by EditProfileScreen — Session 12
    // renamed several fields and dropped guardian/institution entirely.
    // Email + locally-picked avatar also count toward "complete".
    const fields = [
      'first_name',
      'last_name',
      'phone_number',
      'gender',
      'birthdate',
      'region',
    ];
    int filled = 0;
    int total = fields.length;
    if (profile != null) {
      for (final f in fields) {
        if ((profile[f] as String?)?.trim().isNotEmpty == true) filled++;
      }
    }
    // Email is always present after signup, count it as a +1 baseline so
    // a brand-new account isn't stuck at 0 %.
    total++;
    if ((AuthState.userEmail ?? '').trim().isNotEmpty) filled++;
    // Profile picture (local or remote) counts too.
    total++;
    if ((AuthState.avatarUrl.value ?? '').trim().isNotEmpty) filled++;
    return total == 0 ? 0 : filled / total;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild on either name OR avatar change so the completion tracker
    // and avatar render stay in sync when EditProfileScreen pops back.
    return ValueListenableBuilder<String?>(
      valueListenable: AuthState.userName,
      builder: (context, _, __) {
        return ValueListenableBuilder<String?>(
          valueListenable: AuthState.avatarUrl,
          builder: (context, _, __) => _buildScaffold(context),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final profile = AuthState.userData?['profile'] as Map<String, dynamic>?;
    final userName = AuthState.userName.value ?? 'User';
    final userEmail = AuthState.userEmail ?? 'No email provided';

    String avatarUrl;
    // Prefer the live ValueNotifier — _pickAvatar writes the local file path
    // there, and AvatarStorage.load() repopulates it on cold start. The
    // userData['profile']['avatar_url'] copy is only updated by API refreshes
    // and won't reflect a freshly picked photo.
    final liveAvatar = AuthState.avatarUrl.value;
    final rawAvatar = profile?['avatar_url'] as String?;
    if (liveAvatar != null && liveAvatar.trim().isNotEmpty) {
      avatarUrl = liveAvatar;
    } else if (rawAvatar != null && rawAvatar.isNotEmpty) {
      avatarUrl = rawAvatar;
    } else {
      final firstChar = AuthState.userEmail?.isNotEmpty == true
          ? AuthState.userEmail!.substring(0, 1).toUpperCase()
          : 'U';
      final initials = Uri.encodeComponent(
        ((profile?['first_name'] as String? ?? '').isNotEmpty
            ? profile!['first_name'] as String
            : firstChar),
      );
      avatarUrl = 'https://ui-avatars.com/api/?name=$initials&background=FFCC00&color=1A1A2E&size=200';
    }

    final completion = _calculateCompletion();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Profile header — big avatar on the left, details on the right ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Big avatar with camera badge (bottom-right)
                  GestureDetector(
                    onTap: () => _showAvatarOptions(context, avatarUrl),
                    child: Stack(
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 3),
                          ),
                          child: ClipOval(
                            child: Image(
                              image: avatarImageProvider(
                                avatarUrl,
                                fallback: const AssetImage(
                                    'assets/images/new_home/profilepic.jpg'),
                              ),
                              fit: BoxFit.cover,
                              width: 128,
                              height: 128,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/new_home/profilepic.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                size: 16, color: Color(0xFF555555)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Name + email + Edit Profile, stacked to the right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 20),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          userEmail,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12.5),
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Edit Profile button (dark green pill)
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen()),
                            ).then((_) => setState(() {})),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A1F11),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13.5),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Profile Completion Progress (full width) ───────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Completion',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${(completion * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completion,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                      minHeight: 6,
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
              icon: Icons.people_alt_outlined,
              label: 'Followed Partners',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FollowedPartnersScreen())),
            ),
            _item(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen())),
            ),
            // Reminders entry temporarily hidden — restore when the feature is ready.
            // _item(
            //   icon: Icons.alarm_outlined,
            //   label: 'Reminders',
            //   onTap: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (_) => const RemindersScreen())),
            // ),

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
              icon: Icons.info_outline_rounded,
              label: 'About Us',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen())),
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
          fontSize: Responsive.sp(context, 15),
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

  Future<void> _showLogoutDialog(BuildContext context) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!ok) return;

    final refresh = AuthState.refreshToken;
    if (refresh != null) {
      await AuthService.logout(refresh: refresh);
    }
    AuthState.logout();
    SavedEventsState.savedEvents.value = [];
    BookedEventsState.bookings.value = [];
    await UserReviewsState.clear();
    if (!context.mounted) return;
    // Send the user to the login screen rather than a guest HomeScreen —
    // matches the cold-start behaviour (Session 47) and avoids a second
    // HomeScreen racing the ShowcaseView register/unregister lifecycle.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) return; // user cancelled

      final saved = await AvatarStorage.saveFromPickedFile(file.path);
      if (!mounted) return;

      if (saved != null) {
        // Triggers ValueListenableBuilders in home_header, profile, account.
        AuthState.avatarUrl.value = saved;
        setState(() {});
        AppSnackBar.success(context, 'Profile picture updated.');
      } else {
        AppSnackBar.error(context, 'Could not save the picture. Try again.');
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not open the picker.');
    }
  }

  void _showAvatarOptions(BuildContext context, String avatarUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined, color: AppColors.textPrimary),
                title: Text(
                  'View Profile Picture',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewAvatar(context, avatarUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textPrimary),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.textPrimary),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              if (AuthState.avatarUrl.value != null &&
                  AuthState.avatarUrl.value!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: Color(0xFFE53935)),
                  title: Text(
                    'Remove Profile Picture',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AvatarStorage.clear();
                    AuthState.avatarUrl.value = null;
                    setState(() {});
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _viewAvatar(BuildContext context, String avatarUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: avatarImageProvider(
                  avatarUrl,
                  fallback: const AssetImage(
                      'assets/images/new_home/profilepic.jpg'),
                ),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/new_home/profilepic.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
