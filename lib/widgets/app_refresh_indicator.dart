import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../providers/connectivity_state.dart';
import '../screens/network_error_screen.dart';
import 'app_loader.dart';

/// Branded pull-to-refresh indicator — replaces the default Material spinner
/// with TLB's golden bouncing-dots loader ([AppLoader]).
///
/// Drop-in replacement for `RefreshIndicator(onRefresh:, child:)`. The dots
/// fade/scale in as the user pulls and keep animating while the refresh runs;
/// the content slides down to make room, then springs back.
class AppRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  /// How far (px) the user pulls before the refresh arms/fires.
  final double offsetToArmed;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.offsetToArmed = 90,
  });

  /// Every pull-to-refresh in the app goes through here, so this is where
  /// "offline" is caught: rather than spinning and failing (or quietly
  /// keeping stale content), the customer gets the No-internet screen. When
  /// it closes because the connection is back, the refresh runs.
  Future<void> _refresh(BuildContext context) async {
    if (await ConnectivityState.checkNow()) return onRefresh();
    if (!context.mounted) return;
    // Not awaited: the spinner should settle now, not sit under the screen.
    NetworkErrorScreen.show(context).then((backOnline) {
      if (backOnline) onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () => _refresh(context),
      offsetToArmed: offsetToArmed,
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final double pct = controller.value.clamp(0.0, 1.0);
            final double revealH = offsetToArmed * pct;
            return Stack(
              children: [
                // The branded dots, revealed at the top as you pull.
                if (!controller.isIdle)
                  SizedBox(
                    height: revealH,
                    width: double.infinity,
                    child: Center(
                      child: Opacity(
                        opacity: pct,
                        child: Transform.scale(
                          scale: 0.7 + 0.3 * pct,
                          child: const AppLoaderInline(
                            dotSize: 9,
                            spacing: 5,
                            color: AppColors.primaryLight, // golden palette
                          ),
                        ),
                      ),
                    ),
                  ),
                // The scrollable content, pushed down by the same amount.
                Transform.translate(
                  offset: Offset(0, revealH),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
