import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; 
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const SettingsScreen({super.key, this.onBackToHome});

  // প্রিমিয়াম হাই-কন্ট্রেস্ট ট্যালি কালার সোয়াচ তালিকা
  static const List<Map<String, dynamic>> themeColors = [
    {"color": Color(0xFFC5A059), "name": "Classic Gold"},
    {"color": Color(0xFF00E5FF), "name": "Neon Cyan"},
    {"color": Color(0xFFFFD700), "name": "Champagne"},
    {"color": Color(0xFF2E7D32), "name": "Deep Mint"},
    {"color": Color(0xFF1565C0), "name": "Sapphire"},
    {"color": Color(0xFFE91E63), "name": "Vibrant Pink"},
    {"color": Color(0xFF9C27B0), "name": "Purple Bright"},
    {"color": Color(0xFFFF5722), "name": "Flame Orange"},
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

  Future<void> _launchRateUs(BuildContext context) async {
    const appId = 'com.rifat.tasbihpro';
    final Uri playStoreMarketUri = Uri.parse("market://details?id=$appId");
    final Uri playStoreWebUri = Uri.parse("https://play.google.com/store/apps/details?id=$appId");

    try {
      if (await canLaunchUrl(playStoreMarketUri)) {
        await launchUrl(playStoreMarketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (await canLaunchUrl(playStoreWebUri)) {
        await launchUrl(playStoreWebUri, mode: LaunchMode.externalApplication);
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
    final selectedColor = tp.selectedThemeColor;
    final currentThemeType = tp.currentThemeType; 

    final themeData = Theme.of(context);
    final bg = themeData.scaffoldBackgroundColor;
    final cardBg = themeData.cardColor; // আপডেটেড থিমসার্ভিসের সাথে মিল রেখে এলিভেটেড সারফেস
    
    final textPrimary = themeData.brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = textPrimary.withOpacity(0.65);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SettingsBgPainter(
                gold: selectedColor, 
                isDark: themeData.brightness == Brightness.dark,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, selectedColor, textPrimary, onBackToHome),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      // --- APPEARANCE SECTION ---
                      _SectionHeader(title: 'APPEARANCE', gold: selectedColor),
                      const SizedBox(height: 12),

                      // থিম প্রিসেট সিলেক্টর ড্রপডাউন কার্ড
                      _GlassCard(
                        color: cardBg,
                        gold: selectedColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedColor.withOpacity(0.15),
                                ),
                                child: Icon(Icons.palette_rounded, color: selectedColor, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Theme Style',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
                                    ),
                                    Text(
                                      'Choose overall environment',
                                      style: TextStyle(fontSize: 12, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownButton<AppThemeType>(
                                value: currentThemeType,
                                dropdownColor: cardBg,
                                underline: const SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: selectedColor),
                                items: AppThemeType.values.map((AppThemeType type) {
                                  return DropdownMenuItem<AppThemeType>(
                                    value: type,
                                    child: Text(
                                      ThemeService.getThemeName(type),
                                      style: TextStyle(
                                        color: textPrimary, 
                                        fontSize: 14, 
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (AppThemeType? newType) {
                                  if (newType != null) {
                                    tp.updateThemeType(newType); // main.dart এর থিম প্রিসেট পরিবর্তন করবে
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // কালার সোয়াচ গ্রিড কার্ড (ট্যালি ও কাউন্টার এলিমেন্ট স্পষ্ট করার জন্য)
                      _GlassCard(
                        color: cardBg,
                        gold: selectedColor,
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
                                      color: selectedColor.withOpacity(0.15),
                                    ),
                                    child: Icon(Icons.color_lens_outlined, color: selectedColor, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Tally Color',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: selectedColor.withOpacity(0.15),
                                    ),
                                    child: Text(
                                      _selectedColorName(selectedColor),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: selectedColor,
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
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1,
                                ),
                                itemCount: themeColors.length,
                                itemBuilder: (_, i) {
                                  final c = themeColors[i]['color'] as Color;
                                  final name = themeColors[i]['name'] as String;
                                  final isSelected = selectedColor.value == c.value;
                                  return GestureDetector(
                                    onTap: () => tp.updateThemeColor(c),
                                    child: _ColorSwatch(
                                      color: c,
                                      name: name,
                                      isSelected: isSelected,
                                      isDark: themeData.brightness == Brightness.dark,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --- FEEDBACK & RATING SECTION ---
                      _SectionHeader(title: 'FEEDBACK & RATING', gold: selectedColor),
                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: selectedColor,
                        child: Column(
                          children: [
                            _SupportTile(
                              icon: Icons.star_rate_rounded,
                              title: 'Rate Our App',
                              subtitle: 'Support us on Google Play Store',
                              color: const Color(0xFFFFB300),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onTap: () => _launchRateUs(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --- LEGAL SECTION ---
                      _SectionHeader(title: 'LEGAL', gold: selectedColor),
                      const SizedBox(height: 12),

                      _GlassCard(
                        color: cardBg,
                        gold: selectedColor,
                        child: Column(
                          children: [
                            _SupportTile(
                              icon: Icons.privacy_tip_rounded,
                              title: 'Privacy Policy',
                              subtitle: 'Read our data privacy & terms',
                              color: selectedColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onTap: () => _launch(
                                context,
                                'https://www.termsfeed.com/live/9fa77608-4757-4d54-bc29-f027ba1902a3',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- BRANDING FOOTER ---
                      Center(
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (b) => LinearGradient(
                                colors: [selectedColor, selectedColor.withOpacity(0.5)],
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
                              'Version 1.0.4',
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
      if ((item['color'] as Color).value == c.value) {
        return item['name'] as String;
      }
    }
    return 'Custom';
  }

  Widget _buildAppBar(BuildContext context, Color gold, Color textColor, VoidCallback? onBackToHome) {
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
                color: gold.withOpacity(0.1),
                border: Border.all(color: gold.withOpacity(0.25), width: 1.2),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
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
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: gold.withOpacity(0.8),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color gold;
  const _GlassCard({required this.child, required this.color, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
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
    final double luminance = color.computeLuminance();
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? (luminance > 0.5 ? Colors.black87 : Colors.white)
              : Colors.black12,
          width: isSelected ? 3 : 1.2, // এখানে 'i' পরিবর্তন করে '1.2' করে দেওয়া হয়েছে।
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: isSelected
          ? Center(
              child: Icon(
                Icons.check,
                color: luminance > 0.5 ? Colors.black87 : Colors.white,
                size: 20,
                weight: 3,
              ),
            )
          : null,
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: textSecondary),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: textSecondary.withOpacity(0.4),
      ),
    );
  }
}

class _SettingsBgPainter extends CustomPainter {
  final Color gold;
  final bool isDark;

  const _SettingsBgPainter({required this.gold, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold.withOpacity(isDark ? 0.04 : 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i < 6; i++) {
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.05), i * 65, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}