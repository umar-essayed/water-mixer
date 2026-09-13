import 'package:flutter/material.dart';
import '../core/utils/persistence_manager.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  String _activeTubeTheme = 'classic';

  bool get isDarkMode => _isDarkMode;
  String get activeTubeTheme => _activeTubeTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTubeTheme(String theme) {
    _activeTubeTheme = theme;
    PersistenceManager.unlockTheme(theme);
    notifyListeners();
  }
}
