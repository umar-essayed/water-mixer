import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/game/game_screen.dart';
import '../../views/level_map/level_map_screen.dart';
import '../../views/shop/shop_screen.dart';
import '../../views/survival/survival_screen.dart';
import '../../views/lab/lab_renovation_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String game = '/game';
  static const String levelSelection = '/level-selection';
  static const String shop = '/shop';
  static const String survival = '/survival';
  static const String lab = '/lab';

  static final RouteObserver<PageRoute> observer = RouteObserver<PageRoute>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';

    Widget page;
    switch (routeName) {
      case splash:
        page = const SplashScreen();
        break;
      case menu:
        page = const HomeScreen();
        break;
      case game:
        page = const GameScreen();
        break;
      case levelSelection:
        page = const LevelMapScreen();
        break;
      case shop:
        page = const ShopScreen();
        break;
      case survival:
        page = const SurvivalScreen();
        break;
      case lab:
        page = const LabRenovationScreen();
        break;
      default:
        page = const HomeScreen();
        break;
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }
}