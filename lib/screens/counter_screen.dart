import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:in_app_review/in_app_review.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/storage_service.dart';
import '../main.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with TickerProviderStateMixin {
  int count = 0;
  String currentDhikr = "SubhanAllah";
  bool isSoundOn = true;
  late final AudioPlayer _audioPlayer;

  final List<Map<String, String>> dhikrList = [
    {"latin": "SubhanAllah",       "arabic": "سُبْحَانَ ٱللَّٰهِ"},
    {"latin": "Alhamdulillah",     "arabic": "ٱلْحَمْدُ لِلَّٰهِ"},
    {"latin": "La Ilaha Illallah", "arabic": "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ"},
    {"latin": "Allahu Akbar",      "arabic": "ٱللَّٰهُ أَكْبَرُ"},
    {"latin": "Astaghfirullah",    "arabic": "أَسْتَغْفِرُ ٱللَّٰهَ"},
    {"latin": "Durood Sharif",     "arabic": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ"},
  ];

  late final AnimationController _beadController;
  late final AnimationController _bgAnimationController;
  late final AnimationController _countBounceController;
  late Animation<double> _countBounceAnim;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _beadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _countBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _countBounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _countBounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _beadController.dispose();
    _bgAnimationController.dispose();
    _countBounceController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onDhikrChanged(String newDhikr) async {
    if (count > 0) await StorageService.saveSession(currentDhikr, count);
    setState(() {
      currentDhikr = newDhikr;
      count = 0;
    });
  }

  // ইন-অ্যাপ রিভিউ পপ-আপ দেখানোর সম্পূর্ণ আপডেটেড ও শক্তিশালী মেথড
  void _triggerInAppReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasRated = prefs.getBool('has_user_rated_tasbih') ?? false;

      debugPrint('=== ইন-অ্যাপ রিভিউ ট্রিগার লজিক শুরু হয়েছে ===');
      debugPrint('ব্যবহারকারী কি আগে রেটিং দিয়েছেন?: $hasRated');

      // টেস্টিং এর সুবিধার্থে এবং প্লে কনসোলের ক্যাশ এরর এড়াতে hasRated চেক সাময়িক শিথিল রাখতে পারেন
      final InAppReview inAppReview = InAppReview.instance;
      
      // গুগল প্লে সার্ভিস এভেইলেবল কিনা চেক করা হচ্ছে
      bool isAvailable = await inAppReview.isAvailable();
      debugPrint('গুগল প্লে ইন-অ্যাপ রিভিউ কি এই ডিভাইসে সচল?: $isAvailable');
      
      if (isAvailable) {
        debugPrint('গুগল প্লে স্টোরের কাছে পপ-আপের রিকোয়েস্ট পাঠানো হচ্ছে...');
        await inAppReview.requestReview();
        await prefs.setBool('has_user_rated_tasbih', true);
        debugPrint('রিকোয়েস্ট সফলভাবে পাঠানো হয়েছে!');
      } else {
        debugPrint('প্লে সার্ভিস রেডি নেই, ব্যাকআপ হিসেবে স্টোর লিস্টিং ট্রাই করা হচ্ছে...');
        // যদি পপ-আপ কোনোভাবেই সাপোর্ট না করে, ইউজারকে সরাসরি প্লে-স্টোর পেজে নিয়ে যাবে (বিকল্প পথ)
        // await inAppReview.openStoreListing(appStoreId: 'com.rifat.tasbihpro');
      }
    } catch (e) {
      debugPrint('In-App Review Error: $e');
    }
  }

  void _increment() async {
    setState(() => count++);
    _countBounceController.forward(from: 0).then((_) => _countBounceController.reverse());
    _beadController.forward(from: 0);

    if (isSoundOn) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }

    // ৩৩ বার হলে স্পেশাল ভাইব্রেশন এবং রেটিং পপ-আপ ট্রিগার হবে
    if (count == 33) {
      debugPrint('কাউন্টার ঠিক ৩৩ এ পৌঁছেছে! রিভিউ মেথড কল করা হচ্ছে...');
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
      } else {
        HapticFeedback.heavyImpact();
      }
      
      _triggerInAppReview();
    } else {
      HapticFeedback.selectionClick();
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 40);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    final gold = tp.selectedThemeColor;
    final isDark = tp.isDarkMode;
    final bgBase = isDark ? const Color(0xFF050B08) : const Color(0xFFF5F0E8);

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          // Background Animation Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) => CustomPaint(
                painter: PremiumBackgroundPainter(
                  animationValue: _bgAnimationController.value,
                  baseColor: gold,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          // Tasbih Beads Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _beadController,
              builder: (context, child) => CustomPaint(
                painter: RealisticTasbihPainter(
                  progress: _beadController.value,
                  color: gold,
                ),
              ),
            ),
          ),

          // UI Layer
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _buildTopBar(gold, isDark),
                      const Spacer(flex: 2),
                      _buildArabicDisplay(gold),
                      const SizedBox(height: 16),
                      _buildLCDDisplay(gold, isDark),
                      const Spacer(),
                      _buildMainControls(gold),
                      const SizedBox(height: 20),
                      _buildSaveButton(gold),
                      const SizedBox(height: 14),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color gold, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: gold,
              size: 28,
            ),
            onPressed: () => setState(() => isSoundOn = !isSoundOn),
          ),
          _DhikrSelector(
            allDhikrs: dhikrList,
            selected: currentDhikr,
            gold: gold,
            isDark: isDark,
            onChanged: _onDhikrChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildArabicDisplay(Color gold) {
    final arabic = dhikrList.firstWhere(
      (e) => e['latin'] == currentDhikr,
      orElse: () => dhikrList.first,
    )['arabic']!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: Text(
        arabic,
        key: ValueKey(arabic),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 44,
          color: gold,
          fontWeight: FontWeight.bold,
          height: 1.5,
          letterSpacing: 1.5,
          shadows: [Shadow(color: gold.withValues(alpha: 0.4), blurRadius: 12)],
        ),
      ),
    );
  }

  Widget _buildLCDDisplay(Color gold, bool isDark) {
    return ScaleTransition(
      scale: _countBounceAnim,
      child: Container(
        width: 155,
        height: 155,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: gold.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(color: gold.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 78, color: gold, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildMainControls(Color gold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _smallBtn(Icons.remove, Colors.redAccent, () {
          if (count > 0) setState(() => count--);
        }),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: _increment,
          child: Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  gold,
                  gold.withAlpha(200),
                ],
              ),
              boxShadow: [
                BoxShadow(color: gold.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(-5, -5), spreadRadius: -2),
              ],
            ),
            child: const Center(child: Icon(Icons.touch_app, size: 68, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 28),
        _smallBtn(Icons.refresh_rounded, gold, () => setState(() => count = 0)),
      ],
    );
  }

  Widget _smallBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          color: color.withValues(alpha: 0.06),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildSaveButton(Color gold) {
    final goldLight = Color.lerp(gold, Colors.white, 0.3)!;
    final goldDark = Color.lerp(gold, Colors.black, 0.4)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: InkWell(
        onTap: () async {
          if (count > 0) {
            await StorageService.saveSession(currentDhikr, count);
            setState(() => count = 0);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text("Progress Saved!"), backgroundColor: gold),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(36),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [goldLight, gold, goldDark],
            ),
            boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8))],
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  "SAVE PROGRESS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final bool isDark;

  PremiumBackgroundPainter({
    required this.animationValue,
    required this.baseColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: isDark
              ? [baseColor.withValues(alpha: 0.14), Colors.transparent]
              : [baseColor.withValues(alpha: 0.06), Colors.transparent],
        ).createShader(Offset.zero & size),
    );

    final configs = <List<double>>[
      [230, 52, 0.15, 0.10, 0.00, 1.00],
      [180, 42, 0.80, 0.18, 0.33, 0.90],
      [270, 60, 0.10, 0.62, 0.17, 0.75],
      [200, 46, 0.78, 0.70, 0.50, 0.85],
      [150, 38, 0.50, 0.32, 0.67, 0.65],
      [310, 68, 0.35, 0.85, 0.83, 0.55],
      [120, 30, 0.65, 0.50, 0.25, 0.70],
    ];

    for (int i = 0; i < configs.length; i++) {
      final cfg = configs[i];
      final phase = (animationValue + cfg[4]) % 1.0;

      final cx = cfg[2] * size.width  + 24 * math.sin(phase * 2 * math.pi + i * 1.2);
      final cy = cfg[3] * size.height + 32 * math.cos(phase * 2 * math.pi * 0.65 + i);
      final s  = cfg[0] * (1.0 + 0.07 * math.sin(phase * 2 * math.pi));
      final r  = cfg[1];

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: s, height: s),
        Radius.circular(r),
      );

      final angle = phase * 2 * math.pi * 0.07 * (i.isEven ? 1 : -1);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.translate(-cx, -cy);

      final baseOpacity = (isDark ? 0.095 : 0.042) * cfg[5];

      canvas.drawRRect(rrect, Paint()
        ..style = PaintingStyle.fill
        ..color = baseColor.withValues(alpha: baseOpacity));

      canvas.drawRRect(rrect, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = baseColor.withValues(alpha: baseOpacity * 2.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      canvas.restore();
    }

    final rng = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final x  = rng.nextDouble() * size.width;
      final y  = (rng.nextDouble() * size.height + animationValue * 85) % size.height;
      final ps = rng.nextDouble() * 2.5 + 0.8;
      canvas.drawCircle(
        Offset(x, y),
        ps,
        Paint()
          ..color = baseColor.withValues(alpha: rng.nextDouble() * (isDark ? 0.28 : 0.12))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PremiumBackgroundPainter old) => true;
}

class RealisticTasbihPainter extends CustomPainter {
  final double progress;
  final Color color;
  RealisticTasbihPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(-40, size.height * 0.28)
      ..cubicTo(
        size.width * 0.08, size.height * 0.72,
        size.width * 0.92, size.height * 0.72,
        size.width + 40, size.height * 0.28,
      );

    canvas.drawPath(path, Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke);

    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;

    for (int i = 0; i < 12; i++) {
      final t   = ((i / 11) + progress * 0.091) % 1.0;
      final pos = metrics.getTangentForOffset(totalLen * t)!.position;

      canvas.drawCircle(pos + const Offset(3, 6), 18, Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

      canvas.drawCircle(pos, 18, Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [
            Colors.white.withValues(alpha: 0.85),
            color,
            Color.lerp(color, Colors.black, 0.45)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: 18)));
    }
  }

  @override
  bool shouldRepaint(covariant RealisticTasbihPainter old) =>
      old.progress != progress || old.color != color;
}

class _DhikrSelector extends StatelessWidget {
  final List<Map<String, String>> allDhikrs;
  final String selected;
  final Color gold;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _DhikrSelector({
    required this.allDhikrs,
    required this.selected,
    required this.gold,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        dropdownColor: isDark ? const Color(0xFF142920) : Colors.white,
        icon: Icon(Icons.arrow_drop_down_rounded, color: gold),
        items: allDhikrs.map((d) {
          return DropdownMenuItem(
            value: d['latin'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d['latin']!,
                  style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  d['arabic']!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: gold.withValues(alpha: 0.72), fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}