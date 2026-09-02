import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../providers/auth_state.dart';
import '../providers/follow_state.dart';
import '../services/partner_service.dart';
import 'login_sheet.dart';

class PartnerFollowButton extends StatefulWidget {
  final String? partnerId;

  const PartnerFollowButton({super.key, required this.partnerId});

  @override
  State<PartnerFollowButton> createState() => _PartnerFollowButtonState();
}

class _PartnerFollowButtonState extends State<PartnerFollowButton> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final pid = widget.partnerId;
    if (pid != null && pid.isNotEmpty) {
      _isFollowing = FollowState.isFollowing(pid);
    }
  }

  @override
  void didUpdateWidget(PartnerFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // partnerId can change when OrganizerCard loads provider data late
    if (oldWidget.partnerId != widget.partnerId) {
      final pid = widget.partnerId;
      if (pid != null && pid.isNotEmpty) {
        setState(() => _isFollowing = FollowState.isFollowing(pid));
      }
    }
  }

  Future<void> _onTap() async {
    if (!AuthState.isLoggedIn.value) {
      showLoginSheet(context);
      return;
    }

    final token = AuthState.accessToken;
    final pid = widget.partnerId;
    if (token == null || pid == null || pid.isEmpty) return;

    final wasFollowing = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
      _isLoading = true;
    });

    try {
      if (!wasFollowing) {
        await PartnerService.follow(token: token, partnerId: pid);
        FollowState.set(pid, following: true).catchError((_) {});
        if (mounted) AppSnackBar.success(context, 'You are now following this partner.');
      } else {
        await PartnerService.unfollow(token: token, partnerId: pid);
        FollowState.set(pid, following: false).catchError((_) {});
        if (mounted) AppSnackBar.show(context, 'Unfollowed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFollowing = wasFollowing);
      AppSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pid = widget.partnerId;
    if (pid == null || pid.isEmpty) return const SizedBox.shrink();

    if (_isLoading) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _isFollowing ? AppColors.textPrimary : Colors.grey,
        ),
      );
    }

    if (_isFollowing) {
      return ElevatedButton.icon(
        onPressed: _onTap,
        style: ElevatedButton.styleFrom(
          // Near-black rather than the brand yellow. A saturated fill on a
          // secondary control competed with the yellow "Book Now" CTA and,
          // on the profile screen, was the loudest thing on an otherwise
          // white page.
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.check, size: 14),
        label: Text(
          'Following',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: _onTap,
      style: OutlinedButton.styleFrom(
        // The unfollowed twin of the filled state, so the two read as one
        // control in two positions rather than two different buttons.
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.textPrimary.withOpacity(0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Follow',
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
