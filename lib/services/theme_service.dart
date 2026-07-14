import 'package:flutter/material.dart';

enum AppThemeType { emeraldGold, midnightObsidian, royalVelvet, softDawn }

class ThemeService {
  static ThemeData getTheme(AppThemeType type, Color primaryColor) {
    final isDark = type != AppThemeType.softDawn;
    
    Color scaffoldBg;
    Color surfaceColor;

    switch (type) {
      case AppThemeType.midnightObsidian:
        scaffoldBg = const Color(0xFF0F172A); // প্রফেশনাল ডিপ স্লেট ব্লু
        surfaceColor = const Color(0xFF1E293B); // উন্নত ব্যাকগ্রাউন্ড সারফেস কার্ড
        break;
      case AppThemeType.royalVelvet:
        scaffoldBg = const Color(0xFF1E1B4B); // প্রিমিয়াম ডিপ ইন্ডিগো/রয়্যাল পার্পল
        surfaceColor = const Color(0xFF312E81); 
        break;
      case AppThemeType.softDawn:
        scaffoldBg = const Color(0xFFF8FAFC); // একদম ক্লিন সফিস্টিকেটেড লাইট গ্রে
        surfaceColor = Colors.white;
        break;
      case AppThemeType.emeraldGold:
      default:
        scaffoldBg = const Color(0xFF042F1A); // রিচ ও লাক্সারিয়াস ডার্ক এমারেল্ড গ্রিন
        surfaceColor = const Color(0xFF064E3B);
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: surfaceColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        surface: surfaceColor,
        error: Colors.redAccent,
      ),
      // টেক্সটের কন্ট্রেস্ট রেশিও বাড়ানোর জন্য গ্লোবাল থিম টেক্সট কনফিগারেশন
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
      ),
    );
  }

  static String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.emeraldGold:
        return "Emerald Gold";
      case AppThemeType.midnightObsidian:
        return "Midnight Obsidian";
      case AppThemeType.royalVelvet:
        return "Royal Velvet";
      case AppThemeType.softDawn:
        return "Soft Dawn";
    }
  }
}