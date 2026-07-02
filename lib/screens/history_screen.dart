import 'package:flutter/material.dart';
import '../services/storage_service.dart';
// তারিখ সুন্দর করার জন্য (না থাকলে pubspec-এ যোগ করুন)

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ডিলিট কনফার্মেশন ডায়ালগ
  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF142920),
        title: const Text("Delete Record?", style: TextStyle(color: Colors.white)),
        content: Text("Do you want to delete '${item['name']}'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.deleteRecord(item['id'] ?? "");
              Navigator.pop(context);
              setState(() {}); // পেজ রিফ্রেশ করা
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09120E),
      appBar: AppBar(
        title: const Text("Daily Insights", style: TextStyle(color: Color(0xFFC5A059), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: StorageService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC5A059)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No history found", style: TextStyle(color: Colors.white38)));
          }

          // ডাটা গ্রুপ করা (Date অনুযায়ী)
          Map<String, List<Map<String, dynamic>>> groupedData = {};
          for (var item in snapshot.data!) {
            String date = item['date'];
            if (groupedData[date] == null) groupedData[date] = [];
            groupedData[date]!.add(item);
          }

          var sortedDates = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String dateKey = sortedDates[index];
              List<Map<String, dynamic>> sessions = groupedData[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // তারিখের হেডার
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      dateKey == DateTime.now().toString().split(' ')[0] ? "Today" : dateKey,
                      style: const TextStyle(color: Color(0xFFC5A059), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  // ওই তারিখের জিকির লিস্ট
                  ...sessions.map((item) => GestureDetector(
                    onLongPress: () => _showDeleteDialog(item), // ট্যাপ করে ধরলে ডিলিট অপশন
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142920),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF09120E),
                          child: Icon(Icons.history, color: Color(0xFFC5A059)),
                        ),
                        title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        subtitle: Text(item['time'], style: const TextStyle(color: Colors.white38)),
                        trailing: Text("${item['count']}", style: const TextStyle(color: Color(0xFFC5A059), fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}