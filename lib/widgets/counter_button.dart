import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CounterScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with TickerProviderStateMixin {
  int _count = 0;

  // Pulse ring animation
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Press scale animation
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  // Counter number pop animation
  late final AnimationController _numCtrl;
  late final Animation<double> _numScale;

  // Ripple bursts
  final List<_RippleDot> _ripples = [];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.55).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );

    _numCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _numScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _numCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pressCtrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count++;
      _ripples.add(_RippleDot());
    });
    _numCtrl.forward(from: 0);
    _pressCtrl.forward().then((_) => _pressCtrl.reverse());

    // Remove ripple after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _ripples.removeAt(0));
    });
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() => _count = 0);
    _numCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Ambient background blobs ──────────────────────
          Positioned(
            top: -80,
            left: -60,
            child: _AmbientBlob(
              color: const Color(0xFF00FFD1).withValues(alpha: 0.12),
              size: 300,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -80,
            child: _AmbientBlob(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.10),
              size: 280,
            ),
          ),

          // ── Main content ──────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COUNTER',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              letterSpacing: 6,
                              color: const Color(0xFF00FFD1).withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap to\nIncrement',
                            style: TextStyle(
                              fontSize: 28,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Reset pill button
                      GestureDetector(
                        onTap: _reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Animated counter number ──
                AnimatedBuilder(
                  animation: _numScale,
                  builder: (_, __) => Transform.scale(
                    scale: _numScale.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FFD1), Color(0xFF6C63FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 110,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _count == 0
                      ? 'Start tapping!'
                      : _count == 1
                          ? '1 tap so far'
                          : '$_count taps so far',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.35),
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(),

                // ── TAP BUTTON ────────────────────────────────
                CounterButton(onTap: _handleTap, ripples: _ripples),

                const Spacer(),

                // ── Stats row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(
                          label: 'SESSION',
                          value: '$_count',
                          icon: Icons.touch_app_outlined),
                      _StatDivider(),
                      const _StatChip(
                          label: 'RECORD',
                          value: '—',
                          icon: Icons.emoji_events_outlined),
                      _StatDivider(),
                      const _StatChip(
                          label: 'STREAK',
                          value: '—',
                          icon: Icons.local_fire_department_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COUNTER BUTTON  (upgraded)
// ─────────────────────────────────────────────
class CounterButton extends StatelessWidget {
  final VoidCallback onTap;
  final List<_RippleDot> ripples;

  const CounterButton({
    super.key,
    required this.onTap,
    required this.ripples,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple bursts
          for (final r in ripples) _RippleWidget(dot: r),

          // Outer glow ring
          _PulseRing(),

          // Button body
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFD1), Color(0xFF00C9A7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFD1).withValues(alpha: 0.30),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00FFD1).withValues(alpha: 0.15),
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner glass sheen
                  Positioned(
                    top: 18,
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.30),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF003D2E),
                        size: 30,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TAP',
                        style: TextStyle(
                          color: const Color(0xFF003D2E).withValues(alpha: 0.85),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PULSE RING
// ─────────────────────────────────────────────
class _PulseRing extends StatefulWidget {
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + _ctrl.value * 0.65;
        final opacity = (1 - _ctrl.value) * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00FFD1).withValues(alpha: opacity),
                width: 2.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  RIPPLE BURST
// ─────────────────────────────────────────────
class _RippleDot {
  final double angle = Random().nextDouble() * 2 * pi;
}

class _RippleWidget extends StatefulWidget {
  final _RippleDot dot;
  const _RippleWidget({required this.dot});

  @override
  State<_RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<_RippleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dist;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _dist = Tween<double>(begin: 0, end: 110)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final x = cos(widget.dot.angle) * _dist.value;
        final y = sin(widget.dot.angle) * _dist.value;
        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: _fade.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF00FFD1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  AMBIENT BLOB
// ─────────────────────────────────────────────
class _AmbientBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AmbientBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: const BackdropFilter(
        filter: ColorFilter.mode(Colors.transparent, BlendMode.src),
        child: SizedBox(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00FFD1).withValues(alpha: 0.6)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 2,
            color: Colors.white.withValues(alpha: 0.30),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}