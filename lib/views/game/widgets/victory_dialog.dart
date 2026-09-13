import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/audio_manager.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../shop/shop_screen.dart';

class VictoryDialog extends StatefulWidget {
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;

  const VictoryDialog({
    super.key,
    required this.onNextLevel,
    required this.onReplay,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _star1Controller;
  late AnimationController _star2Controller;
  late AnimationController _star3Controller;
  late AnimationController _coinScaleController;
  late Animation<double> _star1Scale;
  late Animation<double> _star2Scale;
  late Animation<double> _star3Scale;
  late Animation<double> _coinScale;

  int _displayedCoins = 0;
  Timer? _coinCounterTimer;
  bool _claimedDouble = false;
  late int _baseReward;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();

    // 3 Sequential Bouncy Star Animations
    _star1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _star2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _star3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    _star1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _star1Controller, curve: Curves.elasticOut),
    );
    _star2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _star2Controller, curve: Curves.elasticOut),
    );
    _star3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _star3Controller, curve: Curves.elasticOut),
    );

    // Coin Scale Punch Controller
    _coinScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.15,
    );
    _coinScale = CurvedAnimation(parent: _coinScaleController, curve: Curves.easeOut);
    _coinScaleController.value = 1.0;

    // Schedule star pop sequences
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _star1Controller.forward();
      AudioManager().playSelect();
      HapticFeedback.lightImpact();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _star2Controller.forward();
      AudioManager().playSelect();
      HapticFeedback.mediumImpact();
    });

    Future.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      _star3Controller.forward();
      AudioManager().playTubeDone();
      HapticFeedback.heavyImpact();
      _startCoinCountUp();
    });
  }

  void _startCoinCountUp() {
    int target = _baseReward;
    int current = 0;
    _coinCounterTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (current < target) {
        current += 2;
        setState(() {
          _displayedCoins = current.clamp(0, target);
        });
        AudioManager().playCoin();
        _coinScaleController.forward().then((_) {
          if (mounted) _coinScaleController.reverse();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showProLockedDialog(BuildContext context) {
    AudioManager().playInvalid();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'ميزة PRO الحصرية 👑',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'مضاعفة مكافآت المستويات 2X محجوزة للاعبي PRO! احصل على عضوية PRO من المتجر للحصول على ضعف العملات دائماً وفتح الأنابيب الإضافية.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 22),
              CustomButton(
                text: 'فتح المتجر وترقية PRO',
                icon: Icons.storefront_rounded,
                height: 50,
                fontSize: 15,
                baseColor: const Color(0xFFF59E0B),
                shadowColor: const Color(0xFFB45309),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShopScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('لاحقاً', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _star1Controller.dispose();
    _star2Controller.dispose();
    _star3Controller.dispose();
    _coinScaleController.dispose();
    _coinCounterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    _baseReward = game.hasDoubleCoins ? 50 : 25;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Explosive Confetti Blast
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: const [
              Color(0xFFFF3366),
              Color(0xFF00E5FF),
              Color(0xFF10E078),
              Color(0xFFFFD700),
              Color(0xFFB388FF),
              Color(0xFFFF9100),
            ],
            numberOfParticles: 35,
            gravity: 0.2,
          ),
        ),

        // Dark Glassmorphic Victory Popup Card
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3 Sequential Bouncy Animated Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _star1Scale,
                      child: SvgPicture.string(AppAssets.starFilledSvg, width: 46, height: 46),
                    ),
                    const SizedBox(width: 8),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: ScaleTransition(
                        scale: _star2Scale,
                        child: SvgPicture.string(AppAssets.starFilledSvg, width: 64, height: 64),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScaleTransition(
                      scale: _star3Scale,
                      child: SvgPicture.string(AppAssets.starFilledSvg, width: 46, height: 46),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Victory Title (Clean, Majestic Arabic Typography)
                const Text(
                  'انتصار رائع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تم إكمال المستوى ${game.currentLevel} في ${game.moveCount} حركة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Animated Scale-Punch Coin Count-up Badge
                ScaleTransition(
                  scale: _coinScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          const Color(0xFFD97706).withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.string(AppAssets.coinSvg, width: 28, height: 28),
                        const SizedBox(width: 8),
                        Text(
                          '+$_displayedCoins ذهب',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (game.hasDoubleCoins || game.isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO 2X',
                              style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 2X Double Reward Button with PRO Lock
                if (!_claimedDouble)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomButton(
                      text: 'مضاعفة المكافأة (2X)',
                      icon: game.isPro ? Icons.auto_awesome_rounded : Icons.lock_rounded,
                      leading: !game.isPro
                          ? Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            )
                          : null,
                      height: 50,
                      fontSize: 16,
                      baseColor: game.isPro ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                      shadowColor: game.isPro ? const Color(0xFFB45309) : const Color(0xFF1E293B),
                      onPressed: () {
                        if (!game.isPro) {
                          _showProLockedDialog(context);
                        } else {
                          setState(() {
                            _claimedDouble = true;
                            _displayedCoins = _baseReward * 2;
                          });
                          HapticFeedback.heavyImpact();
                          AudioManager().playBuy();
                          game.doubleReward(_baseReward);
                        }
                      },
                    ),
                  ),

                // Next Level Button
                CustomButton(
                  text: 'المستوى التالي',
                  icon: Icons.play_arrow_rounded,
                  height: 54,
                  fontSize: 18,
                  baseColor: const Color(0xFF10B981),
                  shadowColor: const Color(0xFF059669),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onNextLevel();
                  },
                ),
                const SizedBox(height: 10),

                // Replay Button
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onReplay();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

