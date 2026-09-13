import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/audio_manager.dart';
import '../../models/tube_model.dart';
import '../../providers/game_provider.dart';
import '../settings/settings_dialog.dart';
import 'widgets/game_header_widget.dart';
import 'widgets/tube_widget.dart';
import 'widgets/pouring_stream_widget.dart';
import 'widgets/victory_dialog.dart';
import 'widgets/game_atmosphere_background.dart';
import '../../widgets/game_3d_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final Map<String, GlobalKey> _tubeKeys = {};

  // Pouring dynamics animation controller
  late AnimationController _pourAnimationController;

  // Active pouring state variables
  bool _isPouring = false;
  TubeModel? _activeSourceTube;
  TubeModel? _activeTargetTube;
  int _activeUnits = 0;
  bool _isTargetToRight = true;
  double _sourceTubeWidth = 68.0;
  double _sourceTubeHeight = 190.0;
  Offset _sourcePos = Offset.zero;
  Offset _streamStart = Offset.zero;
  Offset _streamEnd = Offset.zero;
  Color _streamColor = Colors.transparent;
  double _pourTiltAngle = 0.0;
  Offset _flightDelta = Offset.zero;

  // Invalid move feedback state (Shake + Red Glow)
  String? _shakingTubeId;

  @override
  void initState() {
    super.initState();
    _pourAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
  }

  @override
  void dispose() {
    _pourAnimationController.dispose();
    super.dispose();
  }

  GlobalKey _getKeyForTube(String tubeId) {
    return _tubeKeys.putIfAbsent(tubeId, () => GlobalKey());
  }

  /// Trigger invalid move feedback: phone vibration + tube shake + red glowing border
  void _triggerInvalidMoveFeedback(String tubeId) {
    HapticFeedback.heavyImpact();
    setState(() {
      _shakingTubeId = tubeId;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (_shakingTubeId == tubeId) {
        setState(() {
          _shakingTubeId = null;
        });
      }
    });
  }

  /// Physical Pouring Dynamics Animation with Multi-Stage Realistic Arc & Tilt
  Future<void> _handlePourAnimation(
    TubeModel source,
    TubeModel target,
    int units,
    Color color,
  ) async {
    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    final RenderBox? sourceBox = _tubeKeys[source.id]?.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? targetBox = _tubeKeys[target.id]?.currentContext?.findRenderObject() as RenderBox?;

    if (stackBox == null || sourceBox == null || targetBox == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    final sourceLocal = stackBox.globalToLocal(sourceBox.localToGlobal(Offset.zero));
    final targetLocal = stackBox.globalToLocal(targetBox.localToGlobal(Offset.zero));

    final isTargetToRight = targetLocal.dx >= sourceLocal.dx;
    // Strong, realistic tilt angle: ~76 degrees (1.33 rad)
    final double tilt = isTargetToRight ? 1.33 : -1.33;

    // Position the source mouth directly above target tube mouth
    final double hoverOffsetX = isTargetToRight
        ? (targetLocal.dx - sourceLocal.dx) - (sourceBox.size.width * 0.48)
        : (targetLocal.dx - sourceLocal.dx) + (sourceBox.size.width * 0.48);
    final double hoverOffsetY = (targetLocal.dy - sourceLocal.dy) - (sourceBox.size.height * 0.28);

    final delta = Offset(hoverOffsetX, hoverOffsetY);

    final mouthCenterX = targetLocal.dx + (targetBox.size.width / 2);
    // Exact spout coordinate on the tilted source bottle lip
    final double spoutX = isTargetToRight
        ? mouthCenterX - 18.0
        : mouthCenterX + 18.0;
    final double spoutY = targetLocal.dy - 12.0;

    // Plunge point right down into the receiving bottle's liquid surface
    final double layerH = (targetBox.size.height - 38.0) / target.capacity;
    final double targetSurfaceY = (targetLocal.dy + targetBox.size.height - 14.0) - (target.layers.length * layerH);
    final double plungeY = (targetSurfaceY - 4.0).clamp(targetLocal.dy + 26.0, targetLocal.dy + targetBox.size.height - 16.0);

    final streamStartPos = Offset(spoutX, spoutY);
    final streamEndPos = Offset(mouthCenterX, plungeY);

    setState(() {
      _isPouring = true;
      _activeSourceTube = source;
      _activeTargetTube = target;
      _activeUnits = units;
      _isTargetToRight = isTargetToRight;
      _sourceTubeWidth = sourceBox.size.width;
      _sourceTubeHeight = sourceBox.size.height;
      _sourcePos = sourceLocal;
      _flightDelta = delta;
      _pourTiltAngle = tilt;
      _streamColor = color;
      _streamStart = streamStartPos;
      _streamEnd = streamEndPos;
    });

    // Run forward: Stage 1 (Flight) -> Stage 2 (Tilt) -> Stage 3 (Stream) -> Stage 4 (Return)
    AudioManager().playPour();
    await _pourAnimationController.forward(from: 0.0);
    AudioManager().stopPour();

    setState(() {
      _isPouring = false;
      _activeSourceTube = null;
      _activeTargetTube = null;
    });
  }

  bool _isDialogShowing = false;

  void _checkGameStatus(GameProvider game) {
    if (_isDialogShowing) return;

    if (game.isWon) {
      _isDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VictoryDialog(
            onNextLevel: () {
              _isDialogShowing = false;
              game.nextLevel();
            },
            onReplay: () {
              _isDialogShowing = false;
              game.resetCurrentLevel();
            },
          ),
        ).then((_) => _isDialogShowing = false);
      });
    } else if (game.isGameOver) {
      _isDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildGameOverDialog(game),
        ).then((_) => _isDialogShowing = false);
      });
    }
  }

  Widget _buildGameOverDialog(GameProvider game) {
    final isTimer = game.timeRemaining != null && game.timeRemaining! <= 0;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFEF4444), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTimer ? Icons.timer_off_rounded : Icons.block_rounded,
                size: 52,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isTimer ? 'انتهى الوقت!' : 'نفدت الحركات!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTimer
                  ? 'لم يتبق وقت كافٍ لفرز الألوان.'
                  : 'لقد استنفدت جميع الحركات المسموحة لهذا المستوى.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (game.canUndo) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        game.undoMove();
                      },
                      child: const Text(
                        'تراجع',
                        style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      game.resetCurrentLevel();
                    },
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _promptUnlockTube(TubeModel tube, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        title: const Text(
          'أنبوب مقفل 🔒',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد فك قفل هذا الأنبوب مقابل ${tube.unlockCost} عملة؟\nلديك الآن: ${game.coins} عملة',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final unlocked = game.unlockTube(tube.id);
              if (!unlocked) {
                _triggerInvalidMoveFeedback(tube.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ليس لديك عملات كافية لفك قفل هذا الأنبوب!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              'فتح (${tube.unlockCost} 🪙)',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    _checkGameStatus(game);

    return Scaffold(
      body: GameAtmosphereBackground(
        levelNumber: game.currentLevel,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header (Level, Coins, Settings, Back)
                GameHeaderWidget(
                  onSettingsTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const SettingsDialog(),
                    );
                  },
                  onBackTap: () => Navigator.of(context).pop(),
                ),

                // Dynamic Fast Combo & Fever Streak Banner
                if (game.comboCount > 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(top: 4, bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: game.isFeverMode
                            ? const [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF06B6D4)]
                            : const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (game.isFeverMode ? const Color(0xFFEC4899) : const Color(0xFFF59E0B)).withValues(alpha: 0.55),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          game.isFeverMode ? '⚡ FEVER MODE ⚡' : '🔥 COMBO STREAK 🔥',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'x${game.comboCount}',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tubes Play Area
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: _buildTubesGrid(game),
                      ),
                    ),
                  ),
                ),

                // Bottom Action Toolbar with Wide, Chunky 2D Cartoon Buttons
                _buildActionToolbar(game),
              ],
            ),

            // Realistic Multi-Phase Fluid Pouring Stream & 3D Ghost Bottle
            if (_isPouring && _activeSourceTube != null)
              AnimatedBuilder(
                animation: _pourAnimationController,
                builder: (context, _) {
                  final t = _pourAnimationController.value;
                  double flightProgress;
                  double tiltProgress;
                  double streamProgress;
                  double streamDrainProgress;

                  if (t < 0.28) {
                    // Stage 1: Fly and elevate in 3D space towards target mouth
                    final p = t / 0.28;
                    flightProgress = Curves.easeOutCubic.transform(p);
                    tiltProgress = 0.0;
                    streamProgress = 0.0;
                    streamDrainProgress = 0.0;
                  } else if (t < 0.44) {
                    // Stage 2: Rapid 3D tilt and pitch over receiving bottle rim
                    final p = (t - 0.28) / 0.16;
                    flightProgress = 1.0;
                    tiltProgress = Curves.easeInOutCubic.transform(p);
                    streamProgress = 0.0;
                    streamDrainProgress = 0.0;
                  } else if (t < 0.80) {
                    // Stage 3: Dynamic fluid transfer with splash ripples
                    final p = (t - 0.44) / 0.36;
                    flightProgress = 1.0;
                    tiltProgress = 1.0;
                    streamProgress = (p * 1.35).clamp(0.0, 1.0);
                    streamDrainProgress = p.clamp(0.0, 1.0);
                  } else {
                    // Stage 4: Straighten up and glide back to resting slot
                    final p = (t - 0.80) / 0.20;
                    flightProgress = 1.0 - Curves.easeInOutCubic.transform(p);
                    tiltProgress = (1.0 - p * 2.0).clamp(0.0, 1.0);
                    streamProgress = 0.0;
                    streamDrainProgress = 1.0;
                  }

                  // Cinema-grade 3D Perspective Matrix Transformation
                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0018) // Realistic depth perspective
                    ..setTranslationRaw(0.0, -12.0 * flightProgress, -35.0 * flightProgress) // Brings bottle forward towards camera
                    ..rotateZ(_pourTiltAngle * tiltProgress) // Main tilt towards receiving bottle
                    ..rotateY((_isTargetToRight ? 0.28 : -0.28) * tiltProgress) // 3D yaw: turns mouth towards camera
                    ..rotateX(-0.16 * tiltProgress); // 3D forward pitch

                  return Stack(
                    children: [
                      // Liquid Stream (Only visible during active pour stage)
                      if (streamProgress > 0.02)
                        PouringStreamWidget(
                          start: _streamStart,
                          end: _streamEnd,
                          color: _streamColor,
                          progress: streamProgress,
                          streamWidth: 20.0,
                        ),

                      // Ghost Source Bottle with 3D Perspective Projection
                      Positioned(
                        left: _sourcePos.dx + (_flightDelta.dx * flightProgress),
                        top: _sourcePos.dy + (_flightDelta.dy * flightProgress),
                        child: Transform(
                          alignment: _isTargetToRight ? const Alignment(0.4, -0.9) : const Alignment(-0.4, -0.9),
                          transform: matrix,
                          child: IgnorePointer(
                            child: TubeWidget(
                              tube: _activeSourceTube!,
                              width: _sourceTubeWidth,
                              height: _sourceTubeHeight,
                              skinId: game.activeTubeSkin,
                              tiltAngle: _pourTiltAngle * tiltProgress,
                              drainUnits: _activeUnits * streamDrainProgress,
                              onTap: () {},
                              isSelected: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a responsive grid/wrap layout for test tubes (supporting up to 12 tubes)
  Widget _buildTubesGrid(GameProvider game) {
    final tubes = game.tubes;
    final int count = tubes.length;

    // Distribute into 2 balanced rows if count > 4
    final int half = (count / 2).ceil();
    final topRowTubes = count > 4 ? tubes.sublist(0, half) : tubes;
    final bottomRowTubes = count > 4 ? tubes.sublist(half) : <TubeModel>[];

    // Responsive dimensions to ensure 6 tubes per row fit smoothly
    final double tubeWidth;
    final double tubeHeight;
    final double spacing;

    if (count <= 6) {
      tubeWidth = 68.0;
      tubeHeight = 190.0;
      spacing = 18.0;
    } else if (count <= 8) {
      tubeWidth = 60.0;
      tubeHeight = 175.0;
      spacing = 12.0;
    } else if (count <= 10) {
      tubeWidth = 54.0;
      tubeHeight = 165.0;
      spacing = 9.0;
    } else {
      // 11 to 12 tubes
      tubeWidth = 48.0;
      tubeHeight = 155.0;
      spacing = 7.0;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: 14,
          children: topRowTubes
              .map((tube) => _buildSingleTube(tube, game, width: tubeWidth, height: tubeHeight))
              .toList(),
        ),

        // Bottom Row
        if (bottomRowTubes.isNotEmpty) ...[
          SizedBox(height: count > 8 ? 24 : 34),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: 14,
            children: bottomRowTubes
                .map((tube) => _buildSingleTube(tube, game, width: tubeWidth, height: tubeHeight))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleTube(
    TubeModel tube,
    GameProvider game, {
    double width = 68.0,
    double height = 190.0,
  }) {
    final isSelected = game.selectedTubeId == tube.id;
    final isBeingAnimatedAsSource = _isPouring && _activeSourceTube?.id == tube.id;
    final isBeingAnimatedAsTarget = _isPouring && _activeTargetTube?.id == tube.id;
    final hasError = _shakingTubeId == tube.id;

    return AnimatedBuilder(
      animation: _pourAnimationController,
      builder: (context, child) {
        double incomingUnits = 0.0;
        if (isBeingAnimatedAsTarget) {
          final t = _pourAnimationController.value;
          if (t >= 0.44 && t < 0.80) {
            final p = (t - 0.44) / 0.36;
            incomingUnits = _activeUnits * ((p - 0.12) / 0.88).clamp(0.0, 1.0);
          } else if (t >= 0.80) {
            incomingUnits = _activeUnits.toDouble();
          }
        }

        return Opacity(
          opacity: isBeingAnimatedAsSource ? 0.0 : 1.0,
          child: TubeWidget(
            containerKey: _getKeyForTube(tube.id),
            tube: tube,
            width: width,
            height: height,
            skinId: game.activeTubeSkin,
            isSelected: isSelected,
            hasError: hasError,
            incomingUnits: incomingUnits,
            incomingColor: incomingUnits > 0 ? _streamColor : null,
            onTap: () {
              game.handleTubeTap(
                tube.id,
                onStartPour: _handlePourAnimation,
                onInvalidTarget: _triggerInvalidMoveFeedback,
                onLockedTubeTap: (lockedTube) => _promptUnlockTube(lockedTube, game),
              );
            },
          ),
        );
      },
    );
  }

  /// Responsive 3D Glassmorphic Action Toolbar (Undo, Reset, Add Tube, Hint)
  Widget _buildActionToolbar(GameProvider game) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 14, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Undo Button
            Expanded(
              child: _buildToolbarActionItem(
                svgString: AppAssets.undoSvg,
                label: game.freeUndos > 0 ? 'تراجع (${game.freeUndos})' : 'تراجع',
                accentColor: const Color(0xFF0284C7),
                isEnabled: game.canUndo,
                onTap: () => game.undoMove(),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Reset Button
            Expanded(
              child: _buildToolbarActionItem(
                svgString: AppAssets.resetSvg,
                label: 'إعادة',
                accentColor: const Color(0xFFEA580C),
                onTap: () => game.resetCurrentLevel(),
              ),
            ),
            const SizedBox(width: 8),

            // 3. Add Tube Button
            Expanded(
              child: _buildToolbarActionItem(
                svgString: AppAssets.addTubeSvg,
                label: '+ أنبوب',
                badgeText: game.unlockKeys > 0 ? '🔑' : '50',
                accentColor: const Color(0xFF059669),
                onTap: () {
                  final added = game.addExtraTube();
                  if (!added) {
                    _triggerInvalidMoveFeedback('');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تحتاج 50 عملة لإضافة أنبوب إضافي!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),

            // 4. Hint Button (With Smart Color Radar integration)
            Expanded(
              child: _buildToolbarActionItem(
                svgString: AppAssets.hintSvg,
                label: 'تلميح',
                badgeText: game.colorRadarCharges > 0 ? '📡${game.colorRadarCharges}' : null,
                accentColor: game.colorRadarCharges > 0 ? const Color(0xFF7C3AED) : const Color(0xFFD97706),
                onTap: () {
                  if (game.colorRadarCharges > 0 && game.tubes.any((t) => t.hasHiddenLayers)) {
                    game.useColorRadar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تفعيل رادار الألوان وكشف جميع الطبقات الغامضة! 📡✨'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  final hint = game.getHintMove();
                  if (hint != null) {
                    HapticFeedback.mediumImpact();
                    game.handleTubeTap(
                      hint['sourceId']!,
                      onStartPour: _handlePourAnimation,
                      onInvalidTarget: _triggerInvalidMoveFeedback,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لا توجد حركات واضحة، جرب التراجع أو إضافة أنبوب!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarActionItem({
    required String svgString,
    required String label,
    required Color accentColor,
    String? badgeText,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return Game3DButton(
      baseColor: accentColor,
      depth: 3.5,
      borderRadius: 14.0,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      onPressed: isEnabled ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.string(
                svgString,
                width: 22,
                height: 22,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (badgeText != null)
            Positioned(
              top: -12,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
