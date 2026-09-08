// lib/presentation/pages/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/game_providers.dart';
import '../../widgets/game_header.dart';
import '../../widgets/test_tube_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelNumber;

  const GameScreen({
    Key? key,
    required this.levelNumber,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late Timer _timer;
  int _selectedTubeId = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Get levels from provider
    ref.read(availableLevelsProvider).whenData((levels) {
      if (levels.isNotEmpty && widget.levelNumber <= levels.length) {
        final level = levels[widget.levelNumber - 1];
        ref.read(gameEngineProvider.notifier).initializeGame(level);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final gameState = ref.read(gameEngineProvider);
      
      if (!gameState.isGameWon && !gameState.isGameOver) {
        ref.read(timerProvider.notifier).state = gameState.elapsedTime + 1;
      } else {
        _timer.cancel();
      }
    });
  }

  void _handleTubeTap(int tubeId) {
    if (_selectedTubeId == -1) {
      // First selection
      setState(() => _selectedTubeId = tubeId);
    } else if (_selectedTubeId == tubeId) {
      // Deselect
      setState(() => _selectedTubeId = -1);
    } else {
      // Move water
      final success = ref.read(gameEngineProvider.notifier).moveWater(
        _selectedTubeId,
        tubeId,
      );

      if (success) {
        setState(() => _selectedTubeId = -1);
      }
    }
  }

  void _undo() {
    ref.read(gameEngineProvider.notifier).undo();
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين'),
        content: const Text('هل تريد بدء المستوى من جديد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameEngineProvider.notifier).reset();
              setState(() => _selectedTubeId = -1);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(bool won) {
    final gameState = ref.read(gameEngineProvider);
    final finalScore = ref
        .read(gameEngineProvider.notifier)
        .calculateFinalScore(gameState.elapsedTime);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '🎉 مبروك!' : '❌ انتهت اللعبة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? 'لقد فزت بهذا المستوى!' : 'لم تتمكن من إكمال المستوى'),
            const SizedBox(height: 20),
            Text('النقاط: $finalScore'),
            const SizedBox(height: 10),
            Text('الحركات: ${gameState.moves}'),
            const SizedBox(height: 10),
            Text('الوقت: ${_formatTime(gameState.elapsedTime)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to menu
            },
            child: const Text('الرجوع'),
          ),
          if (won)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Move to next level
              },
              child: const Text('المستوى التالي'),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameEngineProvider);
    final elapsedTime = ref.watch(timerProvider);

    // Check for game over conditions
    if (gameState.isGameWon || gameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(gameState.isGameWon);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى ${widget.levelNumber}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(_formatTime(elapsedTime)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with info
            GameHeader(
              levelNumber: widget.levelNumber,
              moves: gameState.moves,
              maxMoves: ref.read(gameEngineProvider.notifier).getMaxMoves(),
              elapsedTime: elapsedTime,
            ),

            const SizedBox(height: 20),

            // Game tubes grid
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: gameState.tubes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tube = entry.value;

                    return GestureDetector(
                      onTap: () => _handleTubeTap(index),
                      child: TestTubeWidget(
                        tube: tube,
                        isSelected: _selectedTubeId == index,
                        onTap: () => _handleTubeTap(index),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _undo,
                    icon: const Icon(Icons.undo),
                    label: const Text('تراجع'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة تعيين'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: gameState.moves / ref.read(gameEngineProvider.notifier).getMaxMoves(),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(
                    gameState.moves > ref.read(gameEngineProvider.notifier).getMaxMoves()
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
