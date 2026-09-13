import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/tube_model.dart';
import 'bottle_3d_painter.dart';
import 'tube_solved_vfx.dart';

class TubeWidget extends StatefulWidget {
  final TubeModel tube;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String skinId;
  final GlobalKey? containerKey;
  final double tiltAngle;
  final double drainUnits;
  final double incomingUnits;
  final Color? incomingColor;

  const TubeWidget({
    super.key,
    required this.tube,
    this.isSelected = false,
    this.hasError = false,
    required this.onTap,
    this.width = 68.0,
    this.height = 190.0,
    this.skinId = 'classic',
    this.containerKey,
    this.tiltAngle = 0.0,
    this.drainUnits = 0.0,
    this.incomingUnits = 0.0,
    this.incomingColor,
  });

  @override
  State<TubeWidget> createState() => _TubeWidgetState();
}

class _TubeWidgetState extends State<TubeWidget> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _waveController;
  final Stopwatch _waveStopwatch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant TubeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _waveController.dispose();
    _waveStopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shakeX = widget.hasError ? _shakeAnimation.value : 0.0;
          return AnimatedContainer(
            key: widget.containerKey,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(
              shakeX,
              widget.isSelected ? -24 : 0,
              0,
            ),
            width: widget.width,
            height: widget.height,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Red Error Glow (When invalid move is triggered)
            if (widget.hasError)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

            // 2. Solved Glow Halo (When tube is monochromatic full)
            if (widget.tube.isSolved && widget.tube.isFull)
              Positioned(
                bottom: 6,
                child: Container(
                  width: widget.width * 0.85,
                  height: widget.height * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.tube.topColor ?? AppColors.accentGold).withValues(alpha: 0.6),
                        blurRadius: 22,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),

            // 3. 3D Sculpted Glass Bottle & Volumetric Liquid
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  final double elapsed = _waveStopwatch.elapsedMicroseconds / 1000000.0;
                  final double speedMultiplier = widget.isSelected
                      ? 3.6
                      : (widget.tiltAngle.abs() > 0.01 ? 4.5 : 1.8);
                  final double surfaceWobble = elapsed * speedMultiplier;
                  final double bubblePhase = elapsed * 0.35;

                  return CustomPaint(
                    painter: Bottle3DPainter(
                      layers: widget.tube.layers,
                      capacity: widget.tube.capacity,
                      hiddenCount: widget.tube.hiddenCount,
                      skinId: widget.skinId,
                      bubblePhase: bubblePhase,
                      surfaceWobble: surfaceWobble,
                      tiltAngle: widget.tiltAngle,
                      drainUnits: widget.drainUnits,
                      incomingUnits: widget.incomingUnits,
                      incomingColor: widget.incomingColor,
                      isSelected: widget.isSelected,
                      isSolved: widget.tube.isSolved && widget.tube.isFull,
                    ),
                  );
                },
              ),
            ),

            // 4. 3D Wooden Cork Stopper & Sparkling Confetti Burst (When tube is solved)
            if (widget.tube.isSolved && widget.tube.isFull)
              Positioned.fill(
                child: TubeSolvedVfx(
                  isSolved: true,
                  tubeWidth: widget.width,
                  tubeHeight: widget.height,
                  fluidColor: widget.tube.topColor ?? AppColors.accentGold,
                ),
              ),

            // 4b. Locked Tube Overlay
            if (widget.tube.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.string(
                        AppAssets.lockSvg,
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.string(AppAssets.coinSvg, width: 14, height: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.tube.unlockCost}',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            // 4c. Active Unstable Liquid Bomb Badge
            if (widget.tube.isBomb && !widget.tube.isSolved)
              Positioned(
                top: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.tube.bombCountdown! <= 3
                          ? const [Color(0xFFEF4444), Color(0xFF991B1B)]
                          : const [Color(0xFFF97316), Color(0xFFC2410C)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tube.bombCountdown! <= 3
                            ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                            : const Color(0xFFF97316).withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '💣',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.tube.bombCountdown}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Selection Indicator Cute Bouncing Badge
            if (widget.isSelected)
              Positioned(
                top: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
