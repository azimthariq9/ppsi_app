import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper interaktif untuk memberi efek "hidup" di setiap menu/tombol:
/// - Saat kursor mouse hover di atasnya (web/desktop) -> sedikit membesar
///   dan mendapat glow lembut.
/// - Saat disentuh/diklik (mobile & web) -> mengecil sedikit (tactile feedback).
///
/// Dipakai untuk membungkus quick action, tombol hero, item drawer, dsb,
/// supaya semua interaksi di seluruh app terasa konsisten "premium".
class HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double pressScale;
  final BorderRadius? borderRadius;
  final bool enableHoverGlow;
  final Color glowColor;

  const HoverScale({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.035,
    this.pressScale = 0.96,
    this.borderRadius,
    this.enableHoverGlow = false,
    this.glowColor = const Color(0xFF74E29B),
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;
  bool _pressed = false;

  double get _scale {
    if (_pressed) return widget.pressScale;
    if (_hovering) return widget.hoverScale;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: widget.enableHoverGlow && _hovering
              ? BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: -2,
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            scale: _scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
