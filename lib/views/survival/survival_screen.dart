import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/audio_manager.dart';
import '../../core/utils/level_generator.dart';
import '../../core/utils/persistence_manager.dart';
import '../../models/tube_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/svg_icon_button.dart';
import '../game/widgets/game_atmosphere_background.dart';
import '../game/widgets/tube_widget.dart';
import '../game/widgets/pouring_stream_widget.dart';

class SurvivalScreen extends StatefulWidget {
  const SurvivalScreen({super.key});

  @override
  State<SurvivalScreen> createState() => _SurvivalScreenState();
}

class _SurvivalScreenState extends State<SurvivalScreen> with TickerProviderStateMixin {
  late AnimationController _pourController;
  late AnimationController _waveAnimController;
  Timer? _floodTicker;

  int _wave = 1;
  int _score = 0;
  double _floodPressure = 0.10; // 0.0 to 1.0 (1.0 = Overflow Game Over)
  bool _isGameOver = false;

  // Active tubes in survival mode
  List<TubeModel> _tubes = [];
  String? _selectedTubeId;
  String? _shakingTubeId;

  // 4-Phase Pour animation state
  bool _isPouring = false;
  TubeModel? _activeSourceTube;
  TubeModel? _activeTargetTube;
  int _activeUnits = 0;
  Color _streamColor = Colors.transparent;
  Offset _sourcePos = Offset.zero;
  Offset _streamStart = Offset.zero;
  Offset _streamEnd = Offset.zero;
  double _pourTiltAngle = 0.0;
  Offset _flightDelta = Offset.zero;
  bool _isTargetToRight = true;
  double _sourceTubeWidth = 66.0;
  double _sourceTubeHeight = 185.0;

  final Map<String, GlobalKey> _tubeKeys = {};

  @override
  void initState() {
    super.initState();
    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _startSurvivalGame();
  }

  @override
  void dispose() {
    _floodTicker?.cancel();
    _pourController.dispose();
    _waveAnimController.dispose();
    super.dispose();
  }

  GlobalKey _getKeyForTube(String id) => _tubeKeys.putIfAbsent(id, () => GlobalKey());

  void _startSurvivalGame() {
    _wave = 1;
    _score = 0;
    _floodPressure = 0.12;
    _isGameOver = false;
    _isPouring = false;
    _activeSourceTube = null;
    _activeTargetTube = null;
    _selectedTubeId = null;
    _generateWaveTubes();
    _startPressureTicker();
  }

  void _generateWaveTubes() {
    // 100% Solvable compact wave tailored for mobile screen
    final newTubes = LevelGenerator.generateSurvivalWave(_wave);
    setState(() {
      _tubes = newTubes;
      _selectedTubeId = null;
    });
  }

  void _startPressureTicker() {
    _floodTicker?.cancel();
    _floodTicker = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (_isGameOver || !mounted) return;
      setState(() {
        // Pressure rises steadily, accelerating gently with wave number
        final riseRate = 0.004 + (_wave * 0.0010);
        _floodPressure = (_floodPressure + riseRate).clamp(0.0, 1.0);
        if (_floodPressure >= 1.0) {
          _triggerGameOver();
        }
      });
    });
  }

  void _triggerGameOver() {
    _isGameOver = true;
    _floodTicker?.cancel();
    AudioManager().playInvalid();
    PersistenceManager.saveSurvivalHighScore(_score);
    PersistenceManager.saveSurvivalBestWave(_wave);
  }

  void _onTubeTap(String tubeId) {
    if (_isGameOver || _isPouring) return;
    final tapped = _tubes.firstWhere((t) => t.id == tubeId);

    if (_selectedTubeId == null) {
      if (tapped.isEmpty) {
        AudioManager().playInvalid();
        _triggerShake(tubeId);
        return;
      }
      setState(() => _selectedTubeId = tubeId);
      AudioManager().playSelect();
    } else if (_selectedTubeId == tubeId) {
      setState(() => _selectedTubeId = null);
      AudioManager().playSelect();
    } else {
      final source = _tubes.firstWhere((t) => t.id == _selectedTubeId);
      if (source.canPourInto(tapped)) {
        final units = source.transferableUnitsTo(tapped);
        if (units > 0) {
          _executePour(source, tapped, units, source.topColor!);
          return;
        }
      }
      AudioManager().playInvalid();
      _triggerShake(tubeId);
    }
  }

  void _triggerShake(String id) {
    setState(() => _shakingTubeId = id);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted && _shakingTubeId == id) {
        setState(() => _shakingTubeId = null);
      }
    });
  }

  Future<void> _executePour(TubeModel source, TubeModel target, int units, Color color) async {
    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    final RenderBox? srcBox = _tubeKeys[source.id]?.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? tgtBox = _tubeKeys[target.id]?.currentContext?.findRenderObject() as RenderBox?;

    if (stackBox == null || srcBox == null || tgtBox == null) {
      _finishPour(source.id, target.id, units, color);
      return;
    }

    final sourceLocal = stackBox.globalToLocal(srcBox.localToGlobal(Offset.zero));
    final targetLocal = stackBox.globalToLocal(tgtBox.localToGlobal(Offset.zero));

    final isTargetToRight = targetLocal.dx >= sourceLocal.dx;
    final double tilt = isTargetToRight ? 1.33 : -1.33;

    final double hoverOffsetX = isTargetToRight
        ? (targetLocal.dx - sourceLocal.dx) - (srcBox.size.width * 0.48)
        : (targetLocal.dx - sourceLocal.dx) + (srcBox.size.width * 0.48);
    final double hoverOffsetY = (targetLocal.dy - sourceLocal.dy) - (srcBox.size.height * 0.28);

    final delta = Offset(hoverOffsetX, hoverOffsetY);

    final mouthCenterX = targetLocal.dx + (tgtBox.size.width / 2);
    final double spoutX = isTargetToRight ? mouthCenterX - 18.0 : mouthCenterX + 18.0;
    final double spoutY = targetLocal.dy - 12.0;

    final double layerH = (tgtBox.size.height - 38.0) / target.capacity;
    final double targetSurfaceY = (targetLocal.dy + tgtBox.size.height - 14.0) - (target.layers.length * layerH);
    final double plungeY = (targetSurfaceY - 4.0).clamp(targetLocal.dy + 26.0, targetLocal.dy + tgtBox.size.height - 16.0);

    setState(() {
      _isPouring = true;
      _activeSourceTube = source;
      _activeTargetTube = target;
      _activeUnits = units;
      _isTargetToRight = isTargetToRight;
      _sourceTubeWidth = srcBox.size.width;
      _sourceTubeHeight = srcBox.size.height;
      _sourcePos = sourceLocal;
      _flightDelta = delta;
      _pourTiltAngle = tilt;
      _streamColor = color;
      _streamStart = Offset(spoutX, spoutY);
      _streamEnd = Offset(mouthCenterX, plungeY);
    });

    AudioManager().playPour();
    await _pourController.forward(from: 0.0);
    AudioManager().stopPour();

    _finishPour(source.id, target.id, units, color);
  }

  void _finishPour(String srcId, String tgtId, int units, Color color) {
    if (!mounted) return;

    setState(() {
      _isPouring = false;
      _activeSourceTube = null;
      _activeTargetTube = null;
      _selectedTubeId = null;

      _tubes = _tubes.map((tube) {
        if (tube.id == srcId) {
          final newLayers = List<Color>.from(tube.layers);
          for (int i = 0; i < units; i++) {
            if (newLayers.isNotEmpty) newLayers.removeLast();
          }
          // Decrement bomb countdown if present
          int? newBomb = tube.bombCountdown;
          if (newBomb != null) {
            newBomb -= 1;
            if (newBomb <= 0) {
              _triggerGameOver();
              return tube;
            }
          }
          return tube.copyWith(layers: newLayers, bombCountdown: newBomb);
        } else if (tube.id == tgtId) {
          final newLayers = List<Color>.from(tube.layers);
          for (int i = 0; i < units; i++) {
            newLayers.add(color);
          }
          return tube.copyWith(layers: newLayers);
        }
        return tube;
      }).toList();

      // Check if target is solved
      final solvedTubes = _tubes.where((t) => t.isSolved && t.isFull).toList();
      if (solvedTubes.isNotEmpty) {
        AudioManager().playTubeDone();
        _score += 150 * _wave;
        // Relieve 35% flood pressure per solved tube!
        _floodPressure = (_floodPressure - 0.35).clamp(0.04, 1.0);
        context.read<GameProvider>().addCoins(10 * _wave);
      }

      // Check if all non-empty tubes in the wave are fully solved
      final remainingUnsolved = _tubes.where((t) => t.isNotEmpty && (!t.isSolved || !t.isFull)).toList();
      if (remainingUnsolved.isEmpty) {
        // Complete wave cleared!
        AudioManager().playVictory();
        _score += 500 * _wave;
        _wave++;
        _floodPressure = (_floodPressure - 0.40).clamp(0.04, 1.0);
        context.read<GameProvider>().addCoins(25);
        _generateWaveTubes();
      }
    });
  }

  /// Emergency Valve to release water pressure
  void _useFloodSiphonValve() {
    if (_isGameOver || _floodPressure <= 0.05) return;
    setState(() {
      _floodPressure = (_floodPressure - 0.45).clamp(0.02, 1.0);
    });
    AudioManager().playTap();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final highScore = PersistenceManager.getSurvivalHighScore();
    final isCritical = _floodPressure > 0.72;

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Dynamic Rising Water Flood Filling Animation at the bottom of the screen
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveAnimController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: FloodWaterPainter(
                        pressure: _floodPressure,
                        wavePhase: _waveAnimController.value * 2 * pi,
                        isCritical: isCritical,
                      ),
                    );
                  },
                ),
              ),

              // 2. Critical Emergency Pulsing Vignette Border
              if (isCritical)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _waveAnimController,
                      builder: (context, _) {
                        final alpha = (sin(_waveAnimController.value * 4 * pi) * 0.18 + 0.22).clamp(0.0, 0.45);
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: alpha),
                              width: 8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 3. Main Gameplay Column
              Column(
                children: [
                  // Top Status Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgIconButton(
                          svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                          size: 40,
                          iconSize: 18,
                          baseColor: const Color(0xFF334155),
                          shadowColor: const Color(0xFF1E293B),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        // Wave Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCritical
                                  ? const [Color(0xFFDC2626), Color(0xFF991B1B)]
                                  : const [Color(0xFF0284C7), Color(0xFF0369A1)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCritical ? const Color(0xFFFCA5A5) : const Color(0xFF38BDF8),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '🌊 موجة الطوفان $_wave',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Score Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accentGold, width: 1.5),
                          ),
                          child: Text(
                            '$_score نقطة',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Water Pressure Meter (Critical Thrill Gauge)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCritical ? '⚠️ خطر! المعمل يفيض بالسوائل!' : 'مستوى منسوب طوفان الماء:',
                              style: TextStyle(
                                color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(_floodPressure * 100).toInt()}%',
                              style: TextStyle(
                                color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _floodPressure,
                            minHeight: 11,
                            backgroundColor: const Color(0xFF1E293B),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCritical
                                  ? const Color(0xFFEF4444)
                                  : (_floodPressure > 0.45 ? const Color(0xFFF59E0B) : const Color(0xFF06B6D4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tubes Field
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 14,
                            children: _tubes.map((tube) {
                              final isSelected = _selectedTubeId == tube.id;
                              final hasError = _shakingTubeId == tube.id;
                              final isSource = _isPouring && _activeSourceTube?.id == tube.id;
                              return Opacity(
                                opacity: isSource ? 0.0 : 1.0,
                                child: TubeWidget(
                                  containerKey: _getKeyForTube(tube.id),
                                  tube: tube,
                                  width: 66,
                                  height: 185,
                                  skinId: game.activeTubeSkin,
                                  isSelected: isSelected,
                                  hasError: hasError,
                                  onTap: () => _onTubeTap(tube.id),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Siphon Release Valve
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          onPressed: _useFloodSiphonValve,
                          icon: const Icon(Icons.water_drop_rounded, size: 20),
                          label: const Text(
                            'تفريغ ضغط الطوفان 🚰',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 4. Multi-Phase Physical Fluid Pouring Stream & 3D Ghost Bottle
              if (_isPouring && _activeSourceTube != null)
                AnimatedBuilder(
                  animation: _pourController,
                  builder: (context, _) {
                    final t = _pourController.value;
                    double flightProgress;
                    double tiltProgress;
                    double streamProgress;
                    double streamDrainProgress;

                    if (t < 0.28) {
                      final p = t / 0.28;
                      flightProgress = Curves.easeOutCubic.transform(p);
                      tiltProgress = 0.0;
                      streamProgress = 0.0;
                      streamDrainProgress = 0.0;
                    } else if (t < 0.44) {
                      final p = (t - 0.28) / 0.16;
                      flightProgress = 1.0;
                      tiltProgress = Curves.easeInOutCubic.transform(p);
                      streamProgress = 0.0;
                      streamDrainProgress = 0.0;
                    } else if (t < 0.80) {
                      final p = (t - 0.44) / 0.36;
                      flightProgress = 1.0;
                      tiltProgress = 1.0;
                      streamProgress = (p * 1.35).clamp(0.0, 1.0);
                      streamDrainProgress = p.clamp(0.0, 1.0);
                    } else {
                      final p = (t - 0.80) / 0.20;
                      flightProgress = 1.0 - Curves.easeInOutCubic.transform(p);
                      tiltProgress = (1.0 - p * 2.0).clamp(0.0, 1.0);
                      streamProgress = 0.0;
                      streamDrainProgress = 1.0;
                    }

                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.0018)
                      ..setTranslationRaw(0.0, -12.0 * flightProgress, -35.0 * flightProgress)
                      ..rotateZ(_pourTiltAngle * tiltProgress)
                      ..rotateY((_isTargetToRight ? 0.28 : -0.28) * tiltProgress)
                      ..rotateX(-0.16 * tiltProgress);

                    return Stack(
                      children: [
                        if (streamProgress > 0.02)
                          PouringStreamWidget(
                            start: _streamStart,
                            end: _streamEnd,
                            color: _streamColor,
                            progress: streamProgress,
                            streamWidth: 20.0,
                          ),
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

              // 5. Game Over Modal
              if (_isGameOver)
                Container(
                  color: Colors.black.withValues(alpha: 0.82),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFEF4444), width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌊', style: TextStyle(fontSize: 54)),
                          const SizedBox(height: 12),
                          const Text(
                            'فاض المعمل بالسوائل!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'النقاط المحققة: $_score',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'أعلى رقم قياسي: $highScore',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'إعادة المحاولة 🔄',
                            onPressed: _startSurvivalGame,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'العودة للرئيسية',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
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

/// CustomPainter for dynamic rising flood water filling animation
class FloodWaterPainter extends CustomPainter {
  final double pressure;
  final double wavePhase;
  final bool isCritical;

  FloodWaterPainter({
    required this.pressure,
    required this.wavePhase,
    required this.isCritical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pressure <= 0.01) return;

    final double w = size.width;
    final double h = size.height;
    // Calculate water level: rises up to 92% of screen height at max pressure
    final double waterHeight = h * (pressure * 0.92);
    final double waterTop = h - waterHeight;

    final Path wavePath = Path();
    wavePath.moveTo(0, h);
    wavePath.lineTo(0, waterTop);

    const int steps = 40;
    final double dx = w / steps;
    final double amp = 8.0 + (pressure * 10.0);

    for (int i = 0; i <= steps; i++) {
      final double x = i * dx;
      final double normalized = i / steps;
      final double y = waterTop +
          sin((normalized * 4 * pi) + wavePhase) * amp +
          cos((normalized * 2 * pi) + wavePhase * 1.4) * (amp * 0.4);
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(w, h);
    wavePath.close();

    // Deep water translucent gradient
    final Paint waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isCritical
            ? [
                const Color(0xBBEF4444),
                const Color(0xDD7F1D1D),
                const Color(0xFA450A0A),
              ]
            : [
                const Color(0x9906B6D4),
                const Color(0xCC0284C7),
                const Color(0xF00369A1),
              ],
      ).createShader(Rect.fromLTWH(0, waterTop, w, waterHeight));

    canvas.drawPath(wavePath, waterPaint);

    // Frothing surface highlight line
    final Paint surfaceGlint = Paint()
      ..color = Colors.white.withValues(alpha: isCritical ? 0.75 : 0.60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final Path glintPath = Path();
    for (int i = 0; i <= steps; i++) {
      final double x = i * dx;
      final double normalized = i / steps;
      final double y = waterTop +
          sin((normalized * 4 * pi) + wavePhase) * amp +
          cos((normalized * 2 * pi) + wavePhase * 1.4) * (amp * 0.4);
      if (i == 0) {
        glintPath.moveTo(x, y);
      } else {
        glintPath.lineTo(x, y);
      }
    }
    canvas.drawPath(glintPath, surfaceGlint);

    // Rising animated bubbles
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    final random = Random(42);
    for (int b = 0; b < 12; b++) {
      final double rx = (b * 31.0 + wavePhase * 15.0) % w;
      final double progress = ((wavePhase * 0.15 + b * 0.12) % 1.0);
      final double ry = h - (progress * waterHeight);
      if (ry > waterTop) {
        final double radius = 2.0 + (b % 3) * 1.5;
        canvas.drawCircle(Offset(rx, ry), radius, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FloodWaterPainter oldDelegate) {
    return oldDelegate.pressure != pressure ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isCritical != isCritical;
  }
}
