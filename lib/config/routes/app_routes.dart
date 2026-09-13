// lib/config/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/menu_screen.dart';
import '../../presentation/pages/game/game_screen.dart';
import '../../presentation/pages/level_selection_screen.dart';
import '../../presentation/pages/shop/shop_screen.dart';
import '../../presentation/pages/leaderboard/leaderboard_screen.dart';
import '../../presentation/pages/settings/settings_screen.dart';
import '../../domain/entities/game_engine.dart';

class AppRoutes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String game = '/game';
  static const String levelSelection = '/level-selection';
  static const String leaderboard = '/leaderboard';
  static const String shop = '/shop';
  static const String settings = '/settings';

  static final RouteObserver<PageRoute> observer = RouteObserver<PageRoute>();

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final routeName = routeSettings.name ?? '/';
    final arguments = routeSettings.arguments as Map<String, dynamic>?;

    Widget page;

    switch (routeName) {
      case splash:
        page = const SplashScreen();
        break;
      case menu:
        page = const MenuScreen();
        break;
      case game:
        final levelNumber = arguments?['levelNumber'] as int? ?? 1;
        final mode = arguments?['mode'] as GameMode? ?? GameMode.classic;
        final streak = arguments?['streak'] as int? ?? 0;
        page = GameScreen(
          levelNumber: levelNumber,
          mode: mode,
          initialStreak: streak,
        );
        break;
      case levelSelection:
        page = const LevelSelectionScreen();
        break;
      case leaderboard:
        page = const LeaderboardScreen();
        break;
      case shop:
        page = const ShopScreen();
        break;
      case settings:
        page = const SettingsScreen();
        break;
      default:
        page = Scaffold(
          appBar: AppBar(title: const Text('خطأ')),
          body: const Center(child: Text('المسار غير موجود')),
        );
    }

    return MaterialPageRoute(builder: (_) => page, settings: routeSettings);
  }
}