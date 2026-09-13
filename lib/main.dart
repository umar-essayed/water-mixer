import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/utils/audio_manager.dart';
import 'core/utils/persistence_manager.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal puzzle UX
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style (translucent glassmorphism)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  // Initialize offline storage & audio cache
  await PersistenceManager.init();
  await AudioManager().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const WaterMixerApp(),
    ),
  );
}

class WaterMixerApp extends StatelessWidget {
  const WaterMixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Mixer Puzzle',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [AppRoutes.observer],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
    );
  }
}
