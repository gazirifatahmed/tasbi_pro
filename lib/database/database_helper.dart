import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zikr_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE zikr_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        count INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertOrUpdateZikr(String name, int count) async {
    final db = await instance.database;
    final nowStr = DateTime.now().toIso8601String(); 
    final todayDate = nowStr.split('T')[0];

    // date() ফাংশন দিয়ে ISO স্ট্রিং থেকে শুধু YYYY-MM-DD তুলনা করা হচ্ছে
    final List<Map<String, dynamic>> maps = await db.query(
      'zikr_logs',
      where: 'name = ? AND date(date) = date(?)',
      whereArgs: [name, todayDate],
    );

    if (maps.isNotEmpty) {
      int currentCount = maps.first['count'];
      await db.update(
        'zikr_logs',
        {
          'count': currentCount + count,
          'date': nowStr // লেটেস্ট টাইম আপডেট
        },
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    } else {
      await db.insert('zikr_logs', {
        'name': name,
        'count': count,
        'date': nowStr,
      });
    }
  }

  // পাই চার্টের সামারি ডাটার জন্য কুয়েরি
  Future<List<Map<String, dynamic>>> getZikrStats(String startDate, String endDate) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT name, SUM(count) as total_count 
      FROM zikr_logs 
      WHERE date(date) >= date(?) AND date(date) <= date(?)
      GROUP BY name
    ''', [startDate, endDate]);
  }

  // দিনভিত্তিক বিস্তারিত হিস্ট্রি দেখানোর জন্য কুয়েরি
  Future<List<Map<String, dynamic>>> getDetailedHistory(String startDate, String endDate) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT id, name, count, date 
      FROM zikr_logs 
      WHERE date(date) >= date(?) AND date(date) <= date(?)
      ORDER BY date DESC
    ''', [startDate, endDate]);
  }

  // রেকর্ড ডিলিট করার মেথড
  Future<int> deleteZikrRecord(int id) async {
    final db = await instance.database;
    return await db.delete('zikr_logs', where: 'id = ?', whereArgs: [id]);
  }
}