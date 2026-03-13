import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import '../core/saved_events_state.dart';
import '../models/event_model.dart';
import '../core/auth_state.dart';
import '../screens/login_sheet.dart';

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
  });

  final EventModel event;

  /// Outer white circle diameter.
  final double containerSize;

  /// [LikeButton] tap‑target size.
  final double buttonSize;

  final double iconSize;

  /// Whether to use a heart or bookmark icon.
  final WishlistIconType iconType;

  /// Add a subtle drop‑shadow behind the circle.
  final bool showShadow;

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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: showShadow
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: LikeButton(
                    padding: EdgeInsets.zero,
                    size: containerSize, // Make LikeButton tap area fill the container
                    isLiked: isSaved,
                    circleColor: const CircleColor(
                      start: Color(0xFFFF5252),
                      end: Colors.red,
                    ),
                    bubblesColor: const BubblesColor(
                      dotPrimaryColor: Colors.red,
                      dotSecondaryColor: Colors.redAccent,
                    ),
                    onTap: (bool isLiked) async {
                      if (!isLoggedIn) return isLiked;
                      final success = SavedEventsState.toggle(event, context);
                      return success ? !isLiked : isLiked;
                    },
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? iconType.filled : iconType.outlined,
                        color: isLiked ? Colors.red : const Color(0xFF1A1A2E),
                        size: iconSize,
                      );
                    },
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
