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
  Timer? _floodTicker;

  int _wave = 1;
  int _score = 0;
  int _tubesCleared = 0;
  double _floodPressure = 0.0; // 0.0 to 1.0 (1.0 = Overflow Game Over)
  bool _isGameOver = false;

  // Active tubes in survival mode
  List<TubeModel> _tubes = [];
  String? _selectedTubeId;
  String? _shakingTubeId;

  // Pour animation state
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

  final Map<String, GlobalKey> _tubeKeys = {};

  @override
  void initState() {
    super.initState();
    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _startSurvivalGame();
  }

  @override
  void dispose() {
    _floodTicker?.cancel();
    _pourController.dispose();
    super.dispose();
  }

  GlobalKey _getKeyForTube(String id) => _tubeKeys.putIfAbsent(id, () => GlobalKey());

  void _startSurvivalGame() {
    _wave = 1;
    _score = 0;
    _tubesCleared = 0;
    _floodPressure = 0.15;
    _isGameOver = false;
    _generateWaveTubes();
    _startPressureTicker();
  }

  void _generateWaveTubes() {
    final levelData = LevelGenerator.generateLevel(min(5 + _wave, 35));
    // Pick 5 tubes for fast intense sorting
    setState(() {
      _tubes = levelData.initialTubes.take(min(5 + (_wave ~/ 3), 7)).toList();
      _selectedTubeId = null;
    });
  }

  void _startPressureTicker() {
    _floodTicker?.cancel();
    _floodTicker = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (_isGameOver || !mounted) return;
      setState(() {
        // Pressure rises steadily, accelerating with wave number
        final riseRate = 0.006 + (_wave * 0.0015);
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
    final stackBox = context.findRenderObject() as RenderBox?;
    final srcBox = _tubeKeys[source.id]?.currentContext?.findRenderObject() as RenderBox?;
    final tgtBox = _tubeKeys[target.id]?.currentContext?.findRenderObject() as RenderBox?;

    if (stackBox == null || srcBox == null || tgtBox == null) {
      _finishPour(source.id, target.id, units, color);
      return;
    }

    final srcPos = stackBox.globalToLocal(srcBox.localToGlobal(Offset.zero));
    final tgtPos = stackBox.globalToLocal(tgtBox.localToGlobal(Offset.zero));
    _isTargetToRight = tgtPos.dx > srcPos.dx;
    final double targetLipX = tgtPos.dx + (68.0 / 2) + (_isTargetToRight ? -22.0 : 22.0);
    final double targetLipY = tgtPos.dy + 8.0;

    setState(() {
      _isPouring = true;
      _activeSourceTube = source;
      _activeTargetTube = target;
      _activeUnits = units;
      _streamColor = color;
      _sourcePos = srcPos;
      _flightDelta = Offset(targetLipX - srcPos.dx, (targetLipY - 32.0) - srcPos.dy);
      _pourTiltAngle = _isTargetToRight ? 0.72 : -0.72;
      _streamStart = Offset(targetLipX + (_isTargetToRight ? 10.0 : -10.0), targetLipY - 14.0);
      _streamEnd = Offset(tgtPos.dx + (68.0 / 2), tgtPos.dy + (190.0 * 0.75));
    });

    AudioManager().playPour();
    _pourController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 750));

    _finishPour(source.id, target.id, units, color);
  }

  void _finishPour(String srcId, String tgtId, int units, Color color) {
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
          return tube.copyWith(layers: newLayers);
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
        _tubesCleared += solvedTubes.length;
        _score += 250 * _wave;
        // Relieve 30% flood pressure per solved tube!
        _floodPressure = (_floodPressure - (0.30 * solvedTubes.length)).clamp(0.05, 1.0);
        context.read<GameProvider>().addCoins(15 * _wave);

        // Check Wave Progression
        if (_tubesCleared >= 3) {
          _tubesCleared = 0;
          _wave++;
          _generateWaveTubes();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final highScore = PersistenceManager.getSurvivalHighScore();

    return Scaffold(
      body: GameAtmosphereBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgIconButton(
                          svgString: '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
  <path d="M 20 8 L 10 16 L 20 24" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                          size: 42,
                          iconSize: 20,
                          baseColor: const Color(0xFF334155),
                          shadowColor: const Color(0xFF1E293B),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        // Wave Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                          ),
                          child: Text(
                            '🌊 موجة الطوفان $_wave',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Score Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Water Pressure Meter (Critical Thrill Gauge)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _floodPressure > 0.75
                                  ? '⚠️ خطر! المعمل يفيض بالسوائل!'
                                  : 'مستوى ضغط مياه المعمل:',
                              style: TextStyle(
                                color: _floodPressure > 0.75
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(_floodPressure * 100).toInt()}%',
                              style: TextStyle(
                                color: _floodPressure > 0.75
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF38BDF8),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _floodPressure,
                            minHeight: 12,
                            backgroundColor: const Color(0xFF1E293B),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _floodPressure > 0.75
                                  ? const Color(0xFFEF4444)
                                  : (_floodPressure > 0.50
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF06B6D4)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                ],
              ),

              // Pouring stream animation
              if (_isPouring)
                PouringStreamWidget(
                  start: _streamStart,
                  end: _streamEnd,
                  color: _streamColor,
                  progress: 0.9,
                  streamWidth: 18.0,
                ),

              // Game Over Modal
              if (_isGameOver)
                Container(
                  color: Colors.black.withValues(alpha: 0.75),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(28),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFF0284C7), width: 2.2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌊', style: TextStyle(fontSize: 50)),
                          const SizedBox(height: 12),
                          const Text(
                            'فاض المعمل بالسوائل!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                              fontSize: 14,
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
