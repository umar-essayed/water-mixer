// lib/presentation/widgets/test_tube_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_mixer_new/domain/entities/game_engine.dart';
import 'package:water_mixer_new/core/local_storage/game_storage.dart';

class TestTubeWidget extends StatefulWidget {
  final TestTube tube;
  final bool isSelected;
  final bool isHinted;
  final bool isPouring;
  final double pourAngle; // زاوية الإمالة عند الصب
  final VoidCallback onTap;

  const TestTubeWidget({
    Key? key,
    required this.tube,
    required this.isSelected,
    this.isHinted = false,
    this.isPouring = false,
    this.pourAngle = 0.0,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TestTubeWidget> createState() => _TestTubeWidgetState();
}

class _TestTubeWidgetState extends State<TestTubeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return const Color(0xFFE53935);
      case 'blue':
        return const Color(0xFF1E88E5);
      case 'green':
        return const Color(0xFF43A047);
      case 'yellow':
        return const Color(0xFFFDD835);
      case 'purple':
        return const Color(0xFF8E24AA);
      case 'orange':
        return const Color(0xFFFB8C00);
      case 'pink':
        return const Color(0xFFE91E63);
      case 'cyan':
        return const Color(0xFF00ACC1);
      case 'mystery':
        return const Color(0xFF455A64);
      case 'transparent':
        return Colors.transparent;
      default:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tube = widget.tube;
    final isSelected = widget.isSelected;
    final isHinted = widget.isHinted;

    // إزاحة عمودية عند التحديد لتأثير الرفع الحركي
    final translateY = isSelected ? -16.0 : 0.0;
    final rotation = widget.isPouring ? widget.pourAngle : 0.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final hintGlow = isHinted
            ? BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6 + _pulseController.value * 0.4),
                blurRadius: 18,
                spreadRadius: 4,
              )
            : null;

        final selectGlow = isSelected
            ? BoxShadow(
                color: Colors.amberAccent.withOpacity(0.7 + _pulseController.value * 0.3),
                blurRadius: 16,
                spreadRadius: 3,
              )
            : null;

        final bombGlow = tube.isBomb && (tube.bombCountdown ?? 0) <= 5
            ? BoxShadow(
                color: Colors.redAccent.withOpacity(0.6 + _pulseController.value * 0.4),
                blurRadius: 14,
                spreadRadius: 3,
              )
            : null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, translateY)
            ..rotateZ(rotation),
          child: GestureDetector(
            onTap: () {
              if (GameStorage.isHapticEnabled()) {
                HapticFeedback.lightImpact();
              }
              widget.onTap();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. جسم الأنبوب الزجاجي
                Container(
                  width: 68,
                  height: 168,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: isSelected
                          ? Colors.amberAccent
                          : (isHinted
                              ? Colors.greenAccent
                              : Colors.white.withOpacity(0.65)),
                      width: isSelected || isHinted ? 3.5 : 2.0,
                    ),
                    boxShadow: [
                      if (selectGlow != null) selectGlow,
                      if (hintGlow != null) hintGlow,
                      if (bombGlow != null) bombGlow,
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        // طبقات السائل الملون
                        Column(
                          verticalDirection: VerticalDirection.up,
                          children: tube.layers.asMap().entries.map((entry) {
                            final layer = entry.value;
                            final isTransparent = layer.color == 'transparent';
                            final isMystery = layer.isMystery && !layer.isRevealed;

                            return Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: isTransparent
                                      ? null
                                      : (isMystery
                                          ? const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFF546E7A),
                                                Color(0xFF37474F),
                                              ],
                                            )
                                          : (layer.color == 'rainbow'
                                              ? const LinearGradient(
                                                  colors: [
                                                    Colors.red,
                                                    Colors.yellow,
                                                    Colors.green,
                                                    Colors.blue,
                                                  ],
                                                )
                                              : LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    _getColor(layer.color).withOpacity(0.85),
                                                    _getColor(layer.color),
                                                    _getColor(layer.color).withOpacity(0.9),
                                                  ],
                                                ))),
                                  border: Border(
                                    top: !isTransparent
                                        ? BorderSide(
                                            color: Colors.white.withOpacity(0.25),
                                            width: 1.0,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                                child: isMystery
                                    ? const Center(
                                        child: Text(
                                          '?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),

                        // انعكاس زجاجي ثلاثي الأبعاد على جانب الأنبوب
                        Positioned(
                          left: 6,
                          top: 8,
                          bottom: 24,
                          child: Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. قفل الأنبوب إذا كان مقفلاً
                if (tube.isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.lock,
                            color: Colors.amber,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'مقفل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3. شارة القنبلة الموقوتة إن وجدت
                if (tube.isBomb && tube.bombCountdown != null)
                  Positioned(
                    top: -12,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: (tube.bombCountdown ?? 0) <= 5
                            ? Colors.red
                            : Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💣 ', style: TextStyle(fontSize: 11)),
                          Text(
                            '${tube.bombCountdown}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. مؤشر اكتمال الأنبوب بالكامل (نجمة النجاح)
                if (tube.isSorted() && !tube.isEmpty())
                  Positioned(
                    bottom: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
