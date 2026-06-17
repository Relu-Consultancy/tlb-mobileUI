import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/preview_mode.dart';

class PreviewToggleButton extends StatefulWidget {
  const PreviewToggleButton({super.key});

  @override
  State<PreviewToggleButton> createState() => _PreviewToggleButtonState();
}

class _PreviewToggleButtonState extends State<PreviewToggleButton> {
  static const double _size = 44;
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    _position ??= Offset(screen.width - _size - 12, padding.top + 12);
    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            final next = _position! + d.delta;
            _position = Offset(
              next.dx.clamp(0.0, screen.width - _size),
              next.dy.clamp(0.0, screen.height - _size),
            );
          });
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: PreviewMode.enabled,
          builder: (_, isOn, __) {
            return Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: PreviewMode.toggle,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: isOn
                        ? AppColors.primaryLight
                        : Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isOn ? Icons.phone_iphone : Icons.devices,
                    color: isOn ? Colors.black : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
