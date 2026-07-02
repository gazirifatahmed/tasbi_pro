import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const SettingsScreen({super.key, this.onBackToHome});

  static const List<Map<String, dynamic>> themeColors = [
    {"color": Color(0xFFC5A059), "name": "Gold"},
    {"color": Color(0xFF2E7D32), "name": "Emerald"},
    {"color": Color(0xFF1565C0), "name": "Sapphire"},
    {"color": Color(0xFF212121), "name": "Onyx"},
    {"color": Color(0xFF6A1B9A), "name": "Amethyst"},
    {"color": Color(0xFF00695C), "name": "Jade"},
    {"color": Color(0xFFBF360C), "name": "Amber"},
    {"color": Color(0xFF37474F), "name": "Steel"},
  ];

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link")),
        );
      }
    }
  }

  // প্লে স্টোরে সরাসরি রেটিং ওপেন করার জন্য ফাংশন
  Future<void> _launchRateUs(BuildContext context) async {
    const appId = 'com.rifat.tasbihpr';
    // অ্যান্ড্রয়েড ডিভাইসের জন্য মার্কেট স্কিম (সরাসরি প্লে স্টোর অ্যাপ ওপেন করবে)
    final marketUri = Uri.parse("market://details?id=$appId");
    // কোনো কারণে মার্কেট স্কিম ফেইল করলে ব্রাউজার লিংক ওপেন করবে
    final webUri = Uri.parse("https://play.google.com/store/apps/details?id=$appId");

    try {
      if (!await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
        // ফেইল সেফ হিসেবে ব্রাউজার লিঙ্কে ব্যাকআপ
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Play Store")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    final gold = tp.selectedThemeColor;
    final isDark = tp.isDarkMode;

    final bg = isDark ? const Color(0xFF09120E) : const Color(0xFFF5F0E8);
    final cardBg = isDark ? const Color(0xFF0F1A14) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1208);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.45);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SettingsBgPainter(gold, isDark),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, gold, isDark, textPrimary, onBackToHome),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _SectionHeader(title: 'APPEARANCE', gold: gold),
                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: gold,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: gold.withValues(alpha: 0.12),
                                ),
                                child: Icon(Icons.nightlight_round,
                                    color: gold, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Night Mode',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Switch between light & dark theme',
                                      style: TextStyle(
                                          fontSize: 12, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: isDark,
                                onChanged: (val) => tp.toggleTheme(val),
                                activeColor: gold,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: gold,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: gold.withValues(alpha: 0.12),
                                    ),
                                    child: Icon(Icons.palette_outlined,
                                        color: gold, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Tally Color',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: gold.withValues(alpha: 0.12),
                                    ),
                                    child: Text(
                                      _selectedColorName(tp.selectedThemeColor),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: gold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1,
                                ),
                                itemCount: themeColors.length,
                                itemBuilder: (_, i) {
                                  final c = themeColors[i]['color'] as Color;
                                  final name = themeColors[i]['name'] as String;
                                  final isSelected = tp.selectedThemeColor == c;
                                  return GestureDetector(
                                    onTap: () => tp.updateThemeColor(c),
                                    child: _ColorSwatch(
                                      color: c,
                                      name: name,
                                      isSelected: isSelected,
                                      isDark: isDark,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _SectionHeader(title: 'DEVELOPER SUPPORT', gold: gold),
                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: gold,
                        child: Column(
                          children: [
                            _SupportTile(
                              icon: Icons.alternate_email_rounded,
                              title: 'Email Us',
                              subtitle: 'Official communication',
                              color: const Color(0xFFEA4335),
                              isDark: isDark,
                              onTap: () => _launch(context,
                                  'mailto:gazirifatahmed@gmail.com'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // নতুন যুক্ত করা সেকশন: Feedback & Rating
                      _SectionHeader(title: 'FEEDBACK & RATING', gold: gold),
                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: gold,
                        child: Column(
                          children: [
                            _SupportTile(
                              icon: Icons.star_rate_rounded,
                              title: 'Rate Our App',
                              subtitle: 'Support us on Google Play Store',
                              color: const Color(0xFFFFB300), // গোল্ডেন/স্টার কালার
                              isDark: isDark,
                              onTap: () => _launchRateUs(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (b) => LinearGradient(
                                colors: [gold, gold.withValues(alpha: 0.5)],
                              ).createShader(b),
                              child: const Text(
                                '☽  TASBIH PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _selectedColorName(Color c) {
    for (final item in themeColors) {
      if ((item['color'] as Color).toARGB32() == c.toARGB32()) return item['name'] as String;
    }
    return 'Custom';
  }

  Widget _buildAppBar(
      BuildContext context, Color gold, bool isDark, Color textColor,
      VoidCallback? onBackToHome) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (onBackToHome != null) {
                onBackToHome();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.08),
                border: Border.all(color: gold.withValues(alpha: 0.22), width: 1),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: gold, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color gold;
  const _SectionHeader({required this.title, required this.gold});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 3, height: 14,
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: gold.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color gold;
  const _GlassCard({required this.child, required this.color, required this.gold});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.10), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      );
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String name;
  final bool isSelected;
  final bool isDark;

  const _ColorSwatch({
    required this.color,
    required this.name,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 1)]
                : [],
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.40)
                : Colors.black.withValues(alpha: 0.45),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF1A1208),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? Colors.white.withValues(alpha: 0.40)
              : Colors.black.withValues(alpha: 0.45),
        ),
      ),
      trailing: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.08),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
      ),
    );
  }
}

class _SettingsBgPainter extends CustomPainter {
  final Color gold;
  final bool isDark;
  _SettingsBgPainter(this.gold, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(Offset(size.width, 0), i * 45.0, paint);
    }
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(0, size.height), i * 55.0, paint);
    }
  }

  @override
  bool shouldRepaint(_SettingsBgPainter old) =>
      old.gold != gold || old.isDark != isDark;
}