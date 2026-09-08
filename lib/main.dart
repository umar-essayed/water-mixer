import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive - SAFE, No Firebase
  try {
    await Hive.initFlutter();
    print('✅ Hive initialized successfully');
  } catch (e) {
    print('❌ Hive initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: WaterMixerApp(),
    ),
  );
}

class WaterMixerApp extends ConsumerWidget {
  const WaterMixerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
