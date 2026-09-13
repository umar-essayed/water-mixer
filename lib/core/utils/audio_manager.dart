import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Ultra-Reliable, Low-Latency Game Audio Architecture
/// Uses pre-cached asset URIs, stable MediaPlayer wrappers, and dual-channel ping-pong playback.
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Dual-channel SFX players for seamless overlapping playback without collision
  AudioPlayer? _sfx1;
  AudioPlayer? _sfx2;
  bool _useFirstSfx = true;

  // Dedicated channels for long streams and jingles
  AudioPlayer? _pourPlayer;
  AudioPlayer? _jinglePlayer;
  AudioPlayer? _bgmPlayer;

  bool isSoundEnabled = true;
  bool isVibrationEnabled = true;
  bool _initialized = false;

  // Throttle map to prevent platform-channel buffer underruns from micro-spam
  final Map<String, int> _lastPlayTimes = {};

  static const List<String> _audioAssets = [
    'audio/tap.mp3',
    'audio/select.mp3',
    'audio/pour.mp3',
    'audio/invalid.mp3',
    'audio/tube_done.mp3',
    'audio/victory.mp3',
    'audio/coin.mp3',
    'audio/undo.mp3',
    'audio/buy.mp3',
  ];

  Future<void> init() async {
    if (_initialized) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _initialized = true;
      return;
    }
    try {
      // 1. Preload audio files into AudioCache memory/disk cache ONCE
      for (final asset in _audioAssets) {
        try {
          await AudioCache.instance.load(asset);
        } catch (_) {}
      }

      // 2. Instantiate dedicated players with stable MediaPlayer mode
      _sfx1 = _createPlayer();
      _sfx2 = _createPlayer();
      _pourPlayer = _createPlayer();
      _jinglePlayer = _createPlayer();
      _bgmPlayer = _createPlayer();

      _bgmPlayer?.setReleaseMode(ReleaseMode.loop).catchError((_) {});
      _bgmPlayer?.setVolume(0.35).catchError((_) {});

      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  AudioPlayer _createPlayer() {
    final player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
    return player;
  }

  /// Plays SFX using alternating dual channels with spam throttle and self-healing
  void _playSfx(String assetName, {double volume = 1.0, int throttleMs = 50}) {
    if (!isSoundEnabled) return;

    // Throttle identical rapid-fire sounds within throttleMs
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastPlayTimes[assetName] ?? 0;
    if (now - lastTime < throttleMs) return;
    _lastPlayTimes[assetName] = now;

    try {
      // Alternate between Channel 1 and Channel 2 for smooth overlap
      final player = _useFirstSfx ? _sfx1 : _sfx2;
      _useFirstSfx = !_useFirstSfx;

      if (player != null) {
        player.stop().then((_) {
          player.setVolume(volume).catchError((_) {});
          player.play(AssetSource(assetName), volume: volume).catchError((_) {
            // Self-healing fallback to system sound
            SystemSound.play(SystemSoundType.click);
          });
        }).catchError((_) {
          SystemSound.play(SystemSoundType.click);
        });
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  // 1. Button / General Tap
  void playTap() {
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    _playSfx('audio/tap.mp3', volume: 0.75, throttleMs: 40);
  }

  // 2. Select / Lift Tube (Glass Ping)
  void playSelect() {
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSfx('audio/select.mp3', volume: 0.90, throttleMs: 60);
  }

  // 3. Realistic Liquid Pouring Sound (Dedicated channel)
  void playPour() {
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    if (!isSoundEnabled) return;
    try {
      _pourPlayer?.stop().then((_) {
        _pourPlayer?.setVolume(1.0).catchError((_) {});
        _pourPlayer?.play(AssetSource('audio/pour.mp3')).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  void stopPour() {
    try {
      _pourPlayer?.stop().catchError((_) {});
    } catch (_) {}
  }

  // 4. Invalid Move / Error Shake (Muffled Glass Bonk)
  void playInvalid() {
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    _playSfx('audio/invalid.mp3', volume: 0.95, throttleMs: 120);
  }

  // 5. Tube Completed / Solved (Sparkling Chime)
  void playTubeDone() {
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (!isSoundEnabled) return;
    try {
      _jinglePlayer?.stop().then((_) {
        _jinglePlayer?.setVolume(0.95).catchError((_) {});
        _jinglePlayer?.play(AssetSource('audio/tube_done.mp3')).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  // 6. Level Victory Fanfare
  void playWin() {
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (!isSoundEnabled) return;
    try {
      _jinglePlayer?.stop().then((_) {
        _jinglePlayer?.setVolume(1.0).catchError((_) {});
        _jinglePlayer?.play(AssetSource('audio/victory.mp3')).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  void playVictory() => playWin();

  // 7. Coin Pickup Sparkle
  void playCoin() {
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSfx('audio/coin.mp3', volume: 0.85, throttleMs: 30);
  }

  // 8. Undo Move Whoosh
  void playUndo() {
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    _playSfx('audio/undo.mp3', volume: 0.90, throttleMs: 80);
  }

  // 9. Shop Buy / Booster Unlock Chime
  void playBuy() {
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (!isSoundEnabled) return;
    try {
      _jinglePlayer?.stop().then((_) {
        _jinglePlayer?.setVolume(0.95).catchError((_) {});
        _jinglePlayer?.play(AssetSource('audio/buy.mp3')).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  // 10. Ambient Background Music (Looping)
  void startBgm() {
    if (!isSoundEnabled) return;
    try {
      _bgmPlayer?.stop().then((_) {
        _bgmPlayer?.play(AssetSource('audio/bgm.mp3')).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  void stopBgm() {
    try {
      _bgmPlayer?.stop().catchError((_) {});
    } catch (_) {}
  }

  void updateSoundSettings(bool soundOn, bool vibrationOn) {
    isSoundEnabled = soundOn;
    isVibrationEnabled = vibrationOn;
    if (!isSoundEnabled) {
      stopBgm();
      stopPour();
    } else {
      startBgm();
    }
  }

  void dispose() {
    _sfx1?.dispose().catchError((_) {});
    _sfx2?.dispose().catchError((_) {});
    _pourPlayer?.dispose().catchError((_) {});
    _jinglePlayer?.dispose().catchError((_) {});
    _bgmPlayer?.dispose().catchError((_) {});
  }
}

