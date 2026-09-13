// lib/presentation/pages/game/game_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mixer_new/domain/entities/game_engine.dart';
import 'package:water_mixer_new/domain/services/level_generator.dart';
import 'package:water_mixer_new/presentation/providers/game_providers.dart';
import 'package:water_mixer_new/presentation/widgets/game_header.dart';
import 'package:water_mixer_new/presentation/widgets/test_tube_widget.dart';
import 'package:water_mixer_new/presentation/widgets/confetti_widget.dart';
import 'package:water_mixer_new/core/local_storage/game_storage.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelNumber;
  final GameMode mode;
  final int initialStreak;

  const GameScreen({
    Key? key,
    required this.levelNumber,
    this.mode = GameMode.classic,
    this.initialStreak = 0,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _timer;
  int _selectedTubeId = -1;
  int _currentLevelNum = 1;
  int _currentStreak = 0;
  bool _isPouringAnim = false;
  int? _pouringFromId;
  int? _pouringToId;
  double _pourAngle = 0.0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentLevelNum = widget.levelNumber;
    _currentStreak = widget.initialStreak;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadLevel() {
    _dialogShown = false;
    _selectedTubeId = -1;
    _isPouringAnim = false;

    GameLevel level;
    if (widget.mode == GameMode.endless) {
      level = LevelGenerator.generateEndlessLevel(_currentStreak);
    } else if (widget.mode == GameMode.timeRush) {
      level = LevelGenerator.generateLevel(_currentLevelNum, mode: GameMode.timeRush);
    } else if (widget.mode == GameMode.dailyChallenge) {
      level = LevelGenerator.generateDailyChallenge(DateTime.now());
    } else {
      level = LevelGenerator.generateLevel(_currentLevelNum, mode: GameMode.classic);
    }

    ref.read(gameEngineProvider.notifier).initializeGame(
      level,
      streak: _currentStreak,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(gameEngineProvider.notifier).tickTimer();
    });
  }

  void _handleTubeTap(int tubeId) {
    final gameState = ref.read(gameEngineProvider);
    if (gameState.isGameWon || gameState.isGameOver || _isPouringAnim) return;

    final targetTube = gameState.tubes.firstWhere((t) => t.id == tubeId);
    if (targetTube.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(targetTube.unlockCondition ?? 'هذا الأنبوب مقفل!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedTubeId == -1) {
      // الاختيار الأول: لا يمكن اختيار أنبوب فارغ كمصدر
      if (targetTube.isEmpty()) return;
      setState(() => _selectedTubeId = tubeId);
    } else if (_selectedTubeId == tubeId) {
      // إلغاء التحديد
      setState(() => _selectedTubeId = -1);
    } else {
      // محاولة الصب مع تشغيل أنيميشن الإمالة
      _triggerPour(_selectedTubeId, tubeId);
    }
  }

  void _triggerPour(int fromId, int toId) {
    final fromIdx = ref.read(gameEngineProvider).tubes.indexWhere((t) => t.id == fromId);
    final toIdx = ref.read(gameEngineProvider).tubes.indexWhere((t) => t.id == toId);
    final isTargetToRight = toIdx > fromIdx;

    setState(() {
      _isPouringAnim = true;
      _pouringFromId = fromId;
      _pouringToId = toId;
      _pourAngle = isTargetToRight ? 0.35 : -0.35;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final success = ref.read(gameEngineProvider.notifier).moveWater(fromId, toId);

      if (GameStorage.isHapticEnabled()) {
        if (success) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
        }
      }

      setState(() {
        _isPouringAnim = false;
        _pourAngle = 0.0;
        _selectedTubeId = -1;
        _pouringFromId = null;
        _pouringToId = null;
      });
    });
  }

  void _handleUndo() {
    final success = ref.read(gameEngineProvider.notifier).undo();
    if (success) {
      if (GameStorage.isHapticEnabled()) HapticFeedback.lightImpact();
      setState(() => _selectedTubeId = -1);
    }
  }

  void _handleSmartHint() {
    final hint = ref.read(gameEngineProvider.notifier).getSmartHint();
    if (hint != null) {
      if (GameStorage.isHapticEnabled()) HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💡 حركة مقترحة: صب من الأنبوب ${hint.$1 + 1} إلى ${hint.$2 + 1}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ لم يتم العثور على حركة واضحة، جرب خلط السوائل أو إضافة أنبوب!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleAddExtraTube() async {
    final coins = GameStorage.getCoins();
    if (coins < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ تحتاج إلى 50 عملة لإضافة أنبوب إضافي'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await GameStorage.spendCoins(50);
    ref.read(playerCoinsProvider.notifier).state = GameStorage.getCoins();
    ref.read(gameEngineProvider.notifier).addExtraTube();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 تم شراء وإضافة أنبوب إضافي بنجاح! (-50 عملة)'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShuffle() {
    final success = ref.read(gameEngineProvider.notifier).shuffleRemaining();
    if (success) {
      if (GameStorage.isHapticEnabled()) HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔀 تم إعادة خلط السوائل بطريقة ذكية!'),
          backgroundColor: Colors.deepPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة البدء'),
        content: const Text('هل أنت متأكد من رغبتك في إعادة بدء هذا المستوى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(gameEngineProvider.notifier).reset();
              setState(() => _selectedTubeId = -1);
            },
            child: const Text('إعادة'),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog(GameState gameState) {
    if (_dialogShown) return;
    _dialogShown = true;

    final coinsAwarded = 50 + (gameState.stars * 25) + (gameState.streak * 20);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E293B),
        title: Center(
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              const Text(
                'نصر ساحق!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // النجوم الثلاثة مع أنيميشن بصري
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final hasStar = index < gameState.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    hasStar ? Icons.star : Icons.star_border,
                    color: hasStar ? Colors.amber : Colors.white24,
                    size: 38,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _dialogStatRow('النقاط المحققة:', '${gameState.score} نقطة'),
                  const SizedBox(height: 8),
                  _dialogStatRow('عدد الحركات:', '${gameState.moves} حركة'),
                  const SizedBox(height: 8),
                  _dialogStatRow('مكافأة العملات:', '+$coinsAwarded 🪙'),
                  if (gameState.streak > 0) ...[
                    const SizedBox(height: 8),
                    _dialogStatRow('سلسلة الانتصارات:', '🔥 ${gameState.streak + 1}'),
                  ],
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('القائمة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _currentLevelNum++;
                      if (widget.mode == GameMode.endless) {
                        _currentStreak++;
                      }
                    });
                    _loadLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.mode == GameMode.endless
                        ? 'اللغز التالي 🔥'
                        : 'المستوى التالي ➡️',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(GameState gameState) {
    if (_dialogShown) return;
    _dialogShown = true;

    String reasonText = 'لم تتمكن من إكمال المستوى';
    if (gameState.gameOverReason == 'bomb_exploded') {
      reasonText = '💥 انفجرت القنبلة الموقوتة قبل فرز الأنبوب!';
    } else if (gameState.gameOverReason == 'time_up') {
      reasonText = '⏱️ انتهى الوقت المخصص لسباق السرعة!';
    } else if (gameState.gameOverReason == 'out_of_moves') {
      reasonText = '⚠️ نفدت جميع الحركات المسموحة!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E293B),
        title: Center(
          child: Column(
            children: const [
              Text('💀', style: TextStyle(fontSize: 44)),
              SizedBox(height: 8),
              Text(
                'انتهت اللعبة!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reasonText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final coins = GameStorage.getCoins();
                if (coins >= 30) {
                  await GameStorage.spendCoins(30);
                  ref.read(playerCoinsProvider.notifier).state = GameStorage.getCoins();
                  Navigator.pop(ctx);
                  _dialogShown = false;
                  // إضافة أنبوب جديد وفرصة استئناف
                  ref.read(gameEngineProvider.notifier).addExtraTube();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا توجد عملات كافية')),
                  );
                }
              },
              icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
              label: const Text('استئناف بـ 30 عملة (+أنبوب)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('القائمة الرئيسية'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(gameEngineProvider.notifier).reset();
              _dialogShown = false;
              setState(() => _selectedTubeId = -1);
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _dialogStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameEngineProvider);
    final level = ref.read(gameEngineProvider.notifier).getLevel();

    // التحقق من شروط النهاية
    if (gameState.isGameWon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(gameState);
      });
    } else if (gameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(gameState);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // ثيم فخم وداكن
      body: ConfettiWidget(
        isPlaying: gameState.isGameWon,
        child: SafeArea(
          child: Column(
            children: [
              // 1. شريط معلومات اللعبة
              GameHeader(
                levelNumber: _currentLevelNum,
                mode: widget.mode,
                moves: gameState.moves,
                maxMoves: ref.read(gameEngineProvider.notifier).getMaxMoves(),
                elapsedTime: gameState.elapsedTime,
                remainingTime: gameState.remainingTime,
                streak: gameState.streak,
                worldName: level.worldName,
                specialRule: level.specialRule,
              ),

              // زر الخروج السريع في الزاوية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _handleReset,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          tooltip: 'إعادة البدء',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. ساحة الأنابيب (أنبوب الاختبار المنسكب)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: gameState.tubes.map((tube) {
                          final isSelected = _selectedTubeId == tube.id;
                          final isHint = gameState.hintMove != null &&
                              (gameState.hintMove!.$1 == tube.id ||
                                  gameState.hintMove!.$2 == tube.id);
                          final isPouringThis = _isPouringAnim && _pouringFromId == tube.id;

                          return TestTubeWidget(
                            tube: tube,
                            isSelected: isSelected,
                            isHinted: isHint,
                            isPouring: isPouringThis,
                            pourAngle: _pourAngle,
                            onTap: () => _handleTubeTap(tube.id),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. شريط القوى والمساعدات الخارقة (Power-ups Bar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPowerUpButton(
                      icon: Icons.undo,
                      label: 'تراجع',
                      color: Colors.amber,
                      onTap: _handleUndo,
                    ),
                    _buildPowerUpButton(
                      icon: Icons.lightbulb,
                      label: 'تلميح ذكي',
                      color: Colors.cyanAccent,
                      onTap: _handleSmartHint,
                    ),
                    _buildPowerUpButton(
                      icon: Icons.add_circle,
                      label: '+1 أنبوب',
                      color: Colors.greenAccent,
                      badge: '50 🪙',
                      onTap: _handleAddExtraTube,
                    ),
                    _buildPowerUpButton(
                      icon: Icons.shuffle,
                      label: 'خلط',
                      color: Colors.purpleAccent,
                      onTap: _handleShuffle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (GameStorage.isHapticEnabled()) HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.7), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
