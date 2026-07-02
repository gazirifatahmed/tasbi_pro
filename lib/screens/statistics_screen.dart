import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09120E),
      appBar: AppBar(
        title: const Text("Statistics", style: TextStyle(color: Color(0xFFC5A059))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: StorageService.getStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFC5A059)));

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overview", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(title: "Total Count", value: "${data['total']}", icon: Icons.apps, color: Colors.blue),
                    StatCard(title: "Today", value: "${data['today']}", icon: Icons.today, color: Colors.lightBlueAccent),
                    const StatCard(title: "Daily Avg", value: "43", icon: Icons.trending_up, color: Colors.blue), // স্যাম্পল ডাটা
                    const StatCard(title: "Streak", value: "2 days", icon: Icons.local_fire_department, color: Colors.blueAccent),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Progress Over Time", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF142920), borderRadius: BorderRadius.circular(20)),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: true),
                      barGroups: [
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 15)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 12, color: Colors.blue, width: 15)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 15)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}