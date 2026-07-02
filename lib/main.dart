import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart'; // নিশ্চিত করুন এই পাথটি ঠিক আছে

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TasbihApp(),
    ),
  );
}

class TasbihApp extends StatelessWidget {
  const TasbihApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasbih Pro',
      // ল্যাঙ্গুয়েজ লজিক
      locale: themeProvider.locale, 
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: themeProvider.selectedThemeColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.selectedThemeColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09120E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.selectedThemeColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF142920), 
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  Color _selectedThemeColor = const Color(0xFFC5A059);
  Locale _locale = const Locale('bn'); // ডিফল্ট ভাষা বাংলা

  bool get isDarkMode => _isDarkMode;
  Color get selectedThemeColor => _selectedThemeColor;
  Locale get locale => _locale;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void updateThemeColor(Color color) {
    _selectedThemeColor = color;
    notifyListeners();
  }

  // ভাষা পরিবর্তনের মেথড
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}