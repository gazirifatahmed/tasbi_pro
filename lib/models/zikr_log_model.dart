class ZikrLogModel {
  final int? id;
  final String name;
  final int count;
  final String date; // Format: YYYY-MM-DD

  ZikrLogModel({
    this.id,
    required this.name,
    required this.count,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'date': date,
    };
  }

  factory ZikrLogModel.fromMap(Map<String, dynamic> map) {
    return ZikrLogModel(
      id: map['id'],
      name: map['name'],
      count: map['count'],
      date: map['date'],
    );
  }
}