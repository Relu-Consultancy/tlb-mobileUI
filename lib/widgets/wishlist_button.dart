import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:like_button/like_button.dart';
import '../providers/saved_events_state.dart';
import '../models/event_model.dart';
import '../providers/auth_state.dart';
import 'login_sheet.dart';

/// Reusable wishlist (like / save) button used on event cards and detail pages.
///
/// Wraps [LikeButton] inside a white circular container with a red
/// disperse animation. Pass [iconType] to switch between a heart
/// (`Icons.favorite`) and a bookmark (`Icons.bookmark`).
class WishlistButton extends StatelessWidget {
  const WishlistButton({
    super.key,
    required this.event,
    this.containerSize = 36,
    this.buttonSize = 24,
    this.iconSize = 20,
    this.iconType = WishlistIconType.favorite,
    this.showShadow = false,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.unlikedColor,
  });

  final EventModel event;

  /// Outer circle diameter.
  final double containerSize;

  /// [LikeButton] tap‑target size.
  final double buttonSize;

  final double iconSize;

  /// Whether to use a heart or bookmark icon.
  final WishlistIconType iconType;

  /// Add a subtle drop‑shadow behind the circle.
  final bool showShadow;

  /// Fill of the circular container. Defaults to white; pass a dark/translucent
  /// colour to blend the button into a dark card (e.g. the Spotlight banner).
  final Color backgroundColor;

  /// Optional hairline border around the circle.
  final Color? borderColor;

  /// Icon colour when NOT saved. Defaults to [AppColors.textPrimary]; pass a
  /// light colour when the button sits on a dark background.
  final Color? unlikedColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthState.isLoggedIn,
      builder: (context, isLoggedIn, __) {
        return ValueListenableBuilder<List<EventModel>>(
          valueListenable: SavedEventsState.savedEvents,
          builder: (context, _, __) {
            final isSaved = SavedEventsState.isSaved(event);
            return GestureDetector(
              onTap: !isLoggedIn
                  ? () {
                      showLoginSheet(context);
                    }
                  : null, // Let LikeButton handle the tap if logged in
              child: AbsorbPointer(
                absorbing: !isLoggedIn, // Prevent LikeButton from receiving taps if not logged in
                child: Container(
                  width: containerSize,
                  height: containerSize,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: borderColor != null
                        ? Border.all(color: borderColor!, width: 1)
                        : null,
                    boxShadow: showShadow
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  // A fixed-size box (smaller than the circle) holds the
                  // LikeButton, centered by the Container's alignment. This
                  // keeps the heart evenly inset on all sides and prevents the
                  // LikeButton from overflowing the circle (the old "OVERFLOWED"
                  // stripe). No OverflowBox — that gave the button infinite
                  // width and pushed the heart off-centre.
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: LikeButton(
                      padding: EdgeInsets.zero,
                      // Remove the package's default 3px left-padding on the
                      // (empty) like-count widget — it was offsetting the heart
                      // to the left inside the centered Row, leaving uneven
                      // spacing around it in the circle.
                      likeCountPadding: EdgeInsets.zero,
                      size: buttonSize,
                      mainAxisAlignment: MainAxisAlignment.center,
                      isLiked: isSaved,
                      circleColor: const CircleColor(
                        start: Color(0xFFFF5252),
                        end: Colors.red,
                      ),
                      bubblesColor: const BubblesColor(
                        dotPrimaryColor: Colors.red,
                        dotSecondaryColor: Colors.redAccent,
                      ),
                      onTap: (bool isLiked) =>
                          SavedEventsState.toggle(event, context),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          isLiked ? iconType.filled : iconType.outlined,
                          color: isLiked
                              ? Colors.red
                              : (unlikedColor ?? AppColors.textPrimary),
                          size: iconSize,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Icon style for [WishlistButton].
enum WishlistIconType {
  favorite(Icons.favorite, Icons.favorite_border),
  bookmark(Icons.bookmark, Icons.bookmark_border);

  const WishlistIconType(this.filled, this.outlined);
  final IconData filled;
  final IconData outlined;
}
