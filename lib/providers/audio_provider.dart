import 'package:flutter/material.dart';
import '../core/utils/audio_manager.dart';
import '../core/utils/persistence_manager.dart';

class AudioProvider extends ChangeNotifier {
  late bool _isSoundEnabled;
  late bool _isVibrationEnabled;

  AudioProvider() {
    _isSoundEnabled = PersistenceManager.getSoundEnabled();
    _isVibrationEnabled = PersistenceManager.getVibrationEnabled();
    _applySettings();
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  void _applySettings() {
    AudioManager().updateSoundSettings(_isSoundEnabled, _isVibrationEnabled);
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    _applySettings();
    await PersistenceManager.saveSoundEnabled(_isSoundEnabled);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    _applySettings();
    await PersistenceManager.saveVibrationEnabled(_isVibrationEnabled);
    notifyListeners();
  }
}
