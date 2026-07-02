class TasbihModel {
  final String name;
  final int count;

  TasbihModel({required this.name, required this.count});

  static List<String> defaultDhikrList = [
    "SubhanAllah",
    "Alhamdulillah",
    "Allahu Akbar",
    "La ilaha illallah",
    "Astaghfirullah",
    "SubhanAllahi wa bihamdihi",
    "La hawla wala quwwata illa billah",
    "Subhanallahi wal hamdulillahi",
  ];
}