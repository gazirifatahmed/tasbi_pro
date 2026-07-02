import 'package:flutter/material.dart';
import 'counter_screen.dart';
import 'history_screen.dart';
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
    // এখানে পেজগুলোকে লিস্টে রাখা হয়েছে যাতে প্রতিবার সুইচ করার সময় রিফ্রেশ হয়
    final List<Widget> screens = [
      const CounterScreen(),
      const HistoryScreen(), // এটি এখন ডাটা সেভ করার পর নতুন ডাটা দেখাবে
      SettingsScreen(
        onBackToHome: () => _switchToTab(0),
      ),
    ];

    return Scaffold(
      // IndexedStack এর বদলে সরাসরি বডি ব্যবহার করা হয়েছে ডাটা রিফ্রেশ নিশ্চিত করতে
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
        selectedItemColor: Colors.green,
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