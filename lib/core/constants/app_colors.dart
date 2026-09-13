import 'package:flutter/material.dart';

class AppColors {
  // Dark Minimalist & Cosmic Glassmorphism Palette
  static const Color darkBgStart = Color(0xFF0F172A); // Deep Night Blue
  static const Color darkBgEnd = Color(0xFF1E293B);   // Charcoal Slate
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF141E33);
  static const Color glassBorder = Color(0x33FFFFFF); // rgba(255, 255, 255, 0.20)
  static const Color glassFill = Color(0x1AFFFFFF);   // rgba(255, 255, 255, 0.10)

  // Hyper-Saturated Glowing Neon Gem Tone Liquids (Milky, Radiant & High Luminosity)
  static const Color gemCyan = Color(0xFF00F0FF);     // نيون فيروزي كهربائي
  static const Color gemRuby = Color(0xFFFF007A);     // وردي نيون متوهج
  static const Color gemEmerald = Color(0xFF00E676);  // زمردي نيون فائق الإشراق
  static const Color gemAmber = Color(0xFFFF9100);    // كهرماني برتقالي ساطع
  static const Color gemAmethyst = Color(0xFFA855F7); // بنفسجي ألترا فيوليت
  static const Color gemSapphire = Color(0xFF2979FF); // أزرق ملكي كهربائي
  static const Color gemGold = Color(0xFFFFEA00);     // أصفر شمسي متقد
  static const Color gemFuchsia = Color(0xFFF50057);  // فوشيا ماجنتا كهربائي
  static const Color gemLime = Color(0xFF76FF03);     // ليموني نيون مشع
  static const Color gemTeal = Color(0xFF1DE9B6);     // تيل مائي مضيء
  static const Color gemCrimson = Color(0xFFFF1744);  // قرمزي ياقوتي فاقع
  static const Color gemIndigo = Color(0xFF651FFF);   // نيلي سديمي عميق

  static const List<Color> liquidPalette = [
    gemCyan,
    gemRuby,
    gemEmerald,
    gemAmber,
    gemAmethyst,
    gemSapphire,
    gemGold,
    gemFuchsia,
    gemLime,
    gemTeal,
    gemCrimson,
    gemIndigo,
  ];

  static Color getLiquidColor(int index) {
    return liquidPalette[index % liquidPalette.length];
  }

  // Modern UI Accents
  static const Color primary = Color(0xFF38BDF8); // Electric Sky
  static const Color secondary = Color(0xFF818CF8);
  static const Color accentGold = Color(0xFFFBBF24);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // Hidden Layer Mask Color
  static const Color hiddenLayerColor = Color(0xFF334155);
  static const Color hiddenLayerBorder = Color(0xFF475569);

  // Action Button Tones
  static const Color undoBlue = Color(0xFF0284C7);
  static const Color blueDark = Color(0xFF0369A1);
  static const Color resetOrange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color greenDark = Color(0xFF059669);

  // Glass & Theme Helpers
  static const Color glassWhite = Color(0x1FFFFFFF);
  static const Color lightBgStart = Color(0xFF0F172A);
  static const Color lightBgEnd = Color(0xFF1E293B);
  static const Color lightSurface = Color(0xFF1E293B);
}
