import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart'; 
import 'services/theme_service.dart';
import 'services/storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 
    'High Importance Notifications', 
    description: 'This channel is used for important notifications.', 
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );
    }
  });

  // লোকাল স্টোরেজ থেকে পূর্বে সেভ করা থিম সেটিংস লোড করা
  final String? savedTypeStr = await StorageService.getThemeType();
  final int? savedColorValue = await StorageService.getThemeColor();

  AppThemeType initialType = AppThemeType.emeraldGold;
  Color initialColor = const Color(0xFFC5A059);

  if (savedTypeStr != null) {
    initialType = AppThemeType.values.firstWhere(
      (e) => e.toString() == savedTypeStr,
      orElse: () => AppThemeType.emeraldGold,
    );
  }
  if (savedColorValue != null) {
    initialColor = Color(savedColorValue);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialType, initialColor),
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
      locale: themeProvider.locale, 
      theme: ThemeService.getTheme(themeProvider.currentThemeType, themeProvider.selectedThemeColor),
      home: const HomeScreen(),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  AppThemeType _currentThemeType;
  Color _selectedThemeColor;
  Locale _locale = const Locale('bn'); 

  ThemeProvider(this._currentThemeType, this._selectedThemeColor);

  AppThemeType get currentThemeType => _currentThemeType;
  Color get selectedThemeColor => _selectedThemeColor;
  Locale get locale => _locale;
  bool get isDarkMode => _currentThemeType != AppThemeType.softDawn;

  // 🛠️ UX উন্নত করতে আপডেট করা মেথড (যাতে থিম পরিবর্তনের সাথে ট্যালি কালারও হাই-লাইট হয়)
  void updateThemeType(AppThemeType type) {
    _currentThemeType = type;
    
    // থিম অনুযায়ী স্পেশাল হাই-কন্ট্রেস্ট প্রাইমারি কালার সিঙ্ক
    if (type == AppThemeType.midnightObsidian) {
      _selectedThemeColor = const Color(0xFF00E5FF); // উজ্জ্বল সাইয়ান/নিওন ব্লু
    } else if (type == AppThemeType.royalVelvet) {
      _selectedThemeColor = const Color(0xFFFFD700); // আকর্ষণীয় গোল্ডেন শাইন
    } else if (type == AppThemeType.softDawn) {
      _selectedThemeColor = const Color(0xFF0F766E); // ক্লিয়ার ডিপ টিল গ্রিন
    } else {
      _selectedThemeColor = const Color(0xFFC5A059); // ক্লাসিক লাক্সারি গোল্ড
    }
    
    StorageService.saveThemeType(type.toString());
    StorageService.saveThemeColor(_selectedThemeColor.value);
    notifyListeners();
  }

  void updateThemePreset(AppThemeType type) {
    updateThemeType(type);
  }

  void updateThemeColor(Color color) {
    _selectedThemeColor = color;
    StorageService.saveThemeColor(color.value);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}