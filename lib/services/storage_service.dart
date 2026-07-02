import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _historyKey = 'tasbih_history';

  // সেশন সেভ করা (প্রতিটি জিকিরকে ইউনিক টাইমস্ট্যাম্প দিয়ে সেভ করা হচ্ছে)
  static Future<void> saveSession(String dhikrName, int count) async {
    if (count == 0) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    
    // বর্তমান সময় এবং তারিখ সহ ডাটা অবজেক্ট
    Map<String, dynamic> newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': dhikrName,
      'count': count,
      'date': DateTime.now().toString().split(' ')[0], 
      'time': "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    };

    // নতুন ডাটা সবার উপরে যোগ হবে
    history.insert(0, jsonEncode(newRecord));
    await prefs.setStringList(_historyKey, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    history.removeWhere((item) => jsonDecode(item)['id'] == id);
    await prefs.setStringList(_historyKey, history);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final history = await getHistory();
    int total = 0;
    int todayCount = 0;
    String todayStr = DateTime.now().toString().split(' ')[0];
    List<double> weeklyData = List.filled(7, 0.0);
    DateTime now = DateTime.now();

    for (var item in history) {
      int countValue = item['count'] as int;
      total += countValue;
      String dateStr = item['date'];
      if (dateStr == todayStr) todayCount += countValue;

      DateTime recordDate = DateTime.parse(dateStr);
      int diff = now.difference(recordDate).inDays;
      if (diff >= 0 && diff < 7) {
        weeklyData[6 - diff] += countValue.toDouble();
      }
    }

    int streak = 0;
    Set<String> uniqueDates = history.map((e) => e['date'] as String).toSet();
    for (int i = 0; i < 365; i++) {
      String d = now.subtract(Duration(days: i)).toString().split(' ')[0];
      if (uniqueDates.contains(d)) {
        streak++;
      } else {
        if (i > 0) break;
      }
    }

    return {
      'total': total,
      'today': todayCount,
      'streak': streak,
      'weeklyData': weeklyData,
      'history': history,
    };
  }
}