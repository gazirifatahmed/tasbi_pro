import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasbih_pro/database/database_helper.dart';

class InsightsController extends GetxController {
  var selectedFilter = 'Today'.obs;
  var chartData = <Map<String, dynamic>>[].obs;
  var groupedHistory = <String, List<Map<String, dynamic>>>{}.obs; // দিনভিত্তিক গ্রুপিং
  var isLoading = false.obs;
  var touchedIndex = (-1).obs; // চার্ট অ্যানিমেশন টাচ ট্র্যাকিং

  @override
  void onInit() {
    fetchStats();
    super.onInit();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    DateTime now = DateTime.now();
    String startDate = DateFormat('yyyy-MM-dd').format(now);
    String endDate = DateFormat('yyyy-MM-dd').format(now);

    if (selectedFilter.value == 'Today') {
      startDate = DateFormat('yyyy-MM-dd').format(now);
    } else if (selectedFilter.value == 'Weekly') {
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
    } else if (selectedFilter.value == 'Monthly') {
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
    } else if (selectedFilter.value == 'Lifetime') {
      startDate = "2000-01-01";
    }

    try {
      // ১. পাই চার্টের সামারি ডাটা
      final summaryData = await DatabaseHelper.instance.getZikrStats(startDate, endDate);
      chartData.value = summaryData;

      // ২. বিস্তারিত হিস্ট্রি ডাটা রিড করা
      final rawHistory = await DatabaseHelper.instance.getDetailedHistory(startDate, endDate);
      
      // তারিখ অনুযায়ী জিকিরগুলোকে গ্রুপ করা
      Map<String, List<Map<String, dynamic>>> tempGroup = {};
      for (var item in rawHistory) {
        DateTime itemDateTime = DateTime.parse(item['date']);
        String groupKey = _getFormattedGroupKey(itemDateTime);

        if (tempGroup[groupKey] == null) {
          tempGroup[groupKey] = [];
        }
        tempGroup[groupKey]!.add(item);
      }
      groupedHistory.value = tempGroup;
    } catch (e) {
      print("Error fetching stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getFormattedGroupKey(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMMM yyyy').format(dateTime);
    }
  }
}