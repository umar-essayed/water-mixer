import 'package:flutter/material.dart';
import '../core/utils/audio_manager.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final Color baseColor;
  final Color shadowColor;
  final double width;
  final double height;
  final double fontSize;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.leading,
    this.baseColor = const Color(0xFF00B4D8),
    this.shadowColor = const Color(0xFF0077B6),
    this.width = double.infinity,
    this.height = 58.0,
    this.fontSize = 18.0,
    this.isFullWidth = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevelDepth = 5.0;
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              AudioManager().playTap();
              widget.onPressed!();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.isFullWidth ? widget.width : null,
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? bevelDepth - 1 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: widget.shadowColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
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
                      color: widget.shadowColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: _isPressed ? 1.0 : bevelDepth),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(widget.baseColor, Colors.white, 0.28)!,
                  widget.baseColor,
                ],
              ),
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Gloss Reflection Oval
                Positioned(
                  top: 2,
                  left: 14,
                  right: 14,
                  height: widget.height * 0.30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Button Content (Single-line guaranteed with FittedBox)
                Row(
                  mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 8),
                    ] else if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: widget.fontSize + 4),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          widget.text,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
