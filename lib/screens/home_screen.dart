import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // ThemeProvider এর জন্য সঠিক পাথ
import 'counter_screen.dart';
import 'daily_insights_screen.dart'; // নতুন ইনসাইটস স্ক্রিনটি ইম্পোর্ট করা হলো
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _switchToTab(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).selectedThemeColor;

    // UI অক্ষুণ্ণ রেখে হিস্ট্রির জায়গায় চার্ট স্ক্রিন কানেক্ট করা হলো
    final List<Widget> screens = [
      const CounterScreen(),
      const DailyInsightsScreen(), 
      SettingsScreen(
        onBackToHome: () => _switchToTab(0),
      ),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
        selectedItemColor: themeColor, // অ্যাপের ডাইনামিক থিম কালার অ্যাসাইন করা হলো
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Counter'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}