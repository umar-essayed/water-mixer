import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/utils/audio_manager.dart';

class SvgIconButton extends StatefulWidget {
  final String svgString;
  final VoidCallback? onTap;
  final Color baseColor;
  final Color shadowColor;
  final double size;
  final double iconSize;
  final bool isEnabled;
  final String? badgeText;
  final String? label;
  final double? width;

  const SvgIconButton({
    super.key,
    required this.svgString,
    this.onTap,
    this.baseColor = const Color(0xFF3A86FF),
    this.shadowColor = const Color(0xFF1B55B8),
    this.size = 54.0,
    this.iconSize = 26.0,
    this.isEnabled = true,
    this.badgeText,
    this.label,
    this.width,
  });

  @override
  State<SvgIconButton> createState() => _SvgIconButtonState();
}

class _SvgIconButtonState extends State<SvgIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevelDepth = 5.0;
    final bool canTap = widget.isEnabled && widget.onTap != null;
    final double buttonWidth = widget.width ?? (widget.label != null ? 102.0 : widget.size);
    final double buttonHeight = widget.size;

    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: canTap ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: canTap
            ? (_) {
                setState(() => _isPressed = false);
                AudioManager().playTap();
                widget.onTap!();
              }
            : null,
        onTapCancel: canTap ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          width: buttonWidth,
          height: buttonHeight,
          transform: Matrix4.translationValues(0, _isPressed ? bevelDepth - 1 : 0, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bottom 3D Bevel Shadow Base
              Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: widget.shadowColor.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: _isPressed ? 1.0 : bevelDepth),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(widget.baseColor, Colors.white, 0.32)!,
                        widget.baseColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 2.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Top Gloss Shine
                      Positioned(
                        top: 2,
                        left: buttonWidth * 0.12,
                        right: buttonWidth * 0.12,
                        height: buttonHeight * 0.28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Button Content (Icon + Single Line Fitted Label)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.string(
                                widget.svgString,
                                width: widget.iconSize,
                                height: widget.iconSize,
                              ),
                              if (widget.label != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  widget.label!,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 2,
                                        offset: Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Golden Badge (e.g. +50 coins)
              if (widget.badgeText != null)
                Positioned(
                  top: -8,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFF78350F), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          widget.badgeText!,
                          style: const TextStyle(
                            color: Color(0xFF78350F),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
