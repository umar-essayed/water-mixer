import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/audio_manager.dart';

/// Tactile, Chunky 3D Game Button with Glossy Bevel and Physical Depression
class Game3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color baseColor;
  final Color? highlightColor;
  final Color? shadowColor;
  final double depth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isCircle;

  const Game3DButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.baseColor = const Color(0xFF0284C7),
    this.highlightColor,
    this.shadowColor,
    this.depth = 4.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.width,
    this.height,
    this.isCircle = false,
  });

  @override
  State<Game3DButton> createState() => _Game3DButtonState();
}

class _Game3DButtonState extends State<Game3DButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    AudioManager().playTap();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final double activeDepth = enabled ? (_isPressed ? 0.0 : widget.depth) : 2.0;

    // Derived 3D colors
    final Color primaryColor = enabled ? widget.baseColor : const Color(0xFF334155);
    final Color topHighlight = widget.highlightColor ??
        Color.lerp(primaryColor, Colors.white, 0.35)!;
    final Color bottomExtrusion = widget.shadowColor ??
        Color.lerp(primaryColor, Colors.black, 0.45)!;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          padding: EdgeInsets.only(top: _isPressed ? widget.depth : 0.0),
          child: Container(
            decoration: BoxDecoration(
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
              color: bottomExtrusion,
              boxShadow: [
                if (!_isPressed && enabled)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 8,
                    offset: Offset(0, activeDepth + 2),
                  ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.only(bottom: activeDepth),
              padding: widget.padding,
              decoration: BoxDecoration(
                shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    topHighlight,
                    primaryColor,
                    Color.lerp(primaryColor, Colors.black, 0.15)!,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.4,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Upper Gloss Sheen
                  if (!widget.isCircle)
                    Positioned(
                      top: 1,
                      left: 4,
                      right: 4,
                      height: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius / 2),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.55),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Button Content
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
