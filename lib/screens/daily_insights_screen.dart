import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tasbih_pro/controllers/insights_controller.dart';

class DailyInsightsScreen extends StatelessWidget {
  const DailyInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InsightsController controller = Get.put(InsightsController());

    // একটি গ্ল্যামারাস প্রিমিয়াম লাক্সারি গোল্ডেন ও শ্যাম্পেন কালার প্যালেট
    final List<Color> colorPalette = [
      const Color(0xFFD4AF37), // Pure Metallic Gold
      const Color(0xFFF3E5AB), // Vanilla / Soft Gold
      const Color(0xFFAA7C11), // Deep Rich Gold
      const Color(0xFFE6CA65), // Bright Shimmer Gold
      const Color(0xFFCEA247), // Champagne Gold
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060F0C), // আল্ট্রা ডার্ক লাক্সারি গ্রিন ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: const Text(
          'Daily Insights',
          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        return Column(
          children: [
            // ১. কাস্টম নিও-মরফিক ফিল্টার ট্যাব
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F221B),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: ['Today', 'Weekly', 'Monthly', 'Lifetime'].map((filter) {
                    final isSelected = controller.selectedFilter.value == filter;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.changeFilter(filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: isSelected
                                ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                : [],
                          ),
                          child: Text(
                            filter,
                            textAlign: TextAlign.center, // ফিক্সড: চাইনিজ ক্যারেক্টার '忠' রিমুভ করে সঠিক TextAlign দেওয়া হয়েছে
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ২. ডাইনামিক পাই চার্ট এবং ইন্টারেক্টিভ লিজেন্ড কার্ড
            if (controller.chartData.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline, size: 60, color: Colors.white24),
                      SizedBox(height: 12),
                      Text('No Zikr logs recorded for this period.', style: TextStyle(color: Colors.white30, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F221B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15), width: 1),
                ),
                child: Column(
                  children: [
                    // মডার্ন পাই চার্ট উইজেট
                    SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                controller.touchedIndex.value = -1;
                                return;
                              }
                              controller.touchedIndex.value = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            },
                          ),
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: List.generate(controller.chartData.length, (index) {
                            final item = controller.chartData[index];
                            final isTouched = index == controller.touchedIndex.value;
                            final double radius = isTouched ? 45 : 38;
                            final double fontSize = isTouched ? 15 : 12;

                            return PieChartSectionData(
                              color: colorPalette[index % colorPalette.length],
                              value: double.parse(item['total_count'].toString()),
                              title: isTouched ? '${item['total_count']}' : '', 
                              radius: radius,
                              titleStyle: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // চার্টের ঘিঞ্জি দূর করার জন্য প্রিমিয়াম কালার কোডেড লিজেন্ড গ্রিড
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(controller.chartData.length, (index) {
                        final item = controller.chartData[index];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorPalette[index % colorPalette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${item['name']} (${item['total_count']})',
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ৩. গ্রুপড দিনভিত্তিক প্রিমিয়াম হিস্ট্রি সেকশন
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration( // ফিক্সড: borderRadius-কে সঠিকভাবে BoxDecoration-এর ভেতরে আনা হয়েছে
                  color: Color(0xFF0A1813), 
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: controller.groupedHistory.isEmpty
                    ? const Center(child: Text('History Empty', style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 24),
                        itemCount: controller.groupedHistory.keys.length,
                        itemBuilder: (context, index) {
                          String dateKey = controller.groupedHistory.keys.elementAt(index);
                          List<Map<String, dynamic>> logs = controller.groupedHistory[dateKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // স্টাইলিশ ডেট হেডার সেকশন
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF142D23),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        dateKey,
                                        style: const TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Colors.white10, indent: 10)),
                                  ],
                                ),
                              ),
                              
                              // ওই নির্দিষ্ট দিনের জিকিরের লিস্ট মেম্বারস
                              ...logs.map((log) {
                                DateTime logTime = DateTime.parse(log['date']);
                                String formattedTime = DateFormat('hh:mm a').format(logTime);

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F221B),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.03)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF163227),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.access_time_rounded, color: Color(0xFFD4AF37), size: 20),
                                    ),
                                    title: Text(
                                      log['name'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        formattedTime, 
                                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                                      ),
                                    ),
                                    trailing: Text(
                                      log['count'].toString(),
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}