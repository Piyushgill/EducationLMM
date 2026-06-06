import 'dart:math';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Orb pulse
  late AnimationController _orbController;
  late Animation<double> _orbScale;
  late Animation<double> _orbOpacity;

  // Ring expand
  late AnimationController _ringController;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring2Opacity;

  // Logo pop-in
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Text slide-up
  late AnimationController _textController;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;

  // Shimmer on logo
  late AnimationController _shimmerController;

  // Progress bar
  late AnimationController _progressController;
  late Animation<double> _progressValue;

  // Particle rotation
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // ── Orb pulse (repeating) ──────────────────
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _orbScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
    _orbOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    // ── Rings ──────────────────────────────────
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _ring1Scale = Tween<double>(begin: 0.6, end: 1.6).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ring1Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 1),
    ]).animate(_ringController);

    _ring2Scale = Tween<double>(begin: 0.6, end: 1.6).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring2Opacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0), weight: 0.4),
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 0.0), weight: 0.6),
    ]).animate(_ringController);

    // ── Logo ──────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // ── Text ──────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    ));
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.3, 0.9, curve: Curves.easeIn)),
    );

    // ── Shimmer (repeating) ────────────────────
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // ── Progress bar ──────────────────────────
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // ── Particles (rotating) ──────────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // ── Sequence ──────────────────────────────
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _textController.forward();
      _progressController.forward();
    });

    // Navigate after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _ringController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080C1A),
      body: Stack(
        children: [
          // ── Background gradient ───────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A1060),
                    Color(0xFF080C1A),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating particles ────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) {
                return CustomPaint(
                  painter: ParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // ── Pulsing rings ─────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) {
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _ring1Scale.value,
                        child: Opacity(
                          opacity: _ring1Opacity.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7B61FF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: _ring2Scale.value,
                        child: Opacity(
                          opacity: _ring2Opacity.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00D4FF),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Glowing orb ───────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (_, __) {
                return Transform.scale(
                  scale: _orbScale.value,
                  child: Opacity(
                    opacity: _orbOpacity.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF9B80FF),
                            Color(0xFF5B3CDD),
                            Color(0xFF2A0F6E),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B61FF).withOpacity(0.6),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.2),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Logo + shimmer ────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (_, __) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (_, __) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            final shimmerX =
                                (_shimmerController.value * 2 - 0.5) *
                                    bounds.width;
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: const [
                                Colors.white,
                                Color(0xFFE0D8FF),
                                Colors.white,
                                Color(0xFFE0D8FF),
                                Colors.white,
                              ],
                              stops: [
                                0.0,
                                (shimmerX / bounds.width - 0.1).clamp(0.0, 1.0),
                                (shimmerX / bounds.width).clamp(0.0, 1.0),
                                (shimmerX / bounds.width + 0.1).clamp(0.0, 1.0),
                                1.0,
                              ],
                            ).createShader(bounds);
                          },
                          child: const Icon(
                            Icons.bolt_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Title + subtitle ──────────────────
          Positioned(
            bottom: size.height * 0.22,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (_, __) {
                return Column(
                  children: [
                    // Title
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: const Text(
                          'VOLTEX',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 12,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0xFF7B61FF),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle
                    SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleOpacity,
                        child: const Text(
                          'Power at your fingertips',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 3,
                            color: Color(0xFFAA9FD4),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Progress bar ──────────────────────
          Positioned(
            bottom: size.height * 0.1,
            left: size.width * 0.15,
            right: size.width * 0.15,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (_, __) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressValue.value,
                        minHeight: 3,
                        backgroundColor: const Color(0xFF1E1A40),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7B61FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        '${(_progressValue.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF7B61FF),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PARTICLE PAINTER
// ─────────────────────────────────────────────
class ParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = List.generate(
    28,
        (i) => _Particle(seed: i),
  );

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final angle = (progress * 2 * pi * p.speed) + p.angleOffset;
      final radius = p.orbitRadius * min(size.width, size.height) * 0.5;
      final cx = size.width / 2 + cos(angle) * radius;
      final cy = size.height / 2 + sin(angle) * radius * 0.55;

      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      canvas.drawCircle(Offset(cx, cy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => true;
}

class _Particle {
  final double angleOffset;
  final double orbitRadius;
  final double speed;
  final double size;
  final double opacity;
  final Color color;

  _Particle({required int seed})
      : angleOffset = seed * 0.7853 + seed * 0.31,
        orbitRadius = 0.25 + (seed % 5) * 0.07,
        speed = 0.3 + (seed % 4) * 0.2,
        size = 1.5 + (seed % 3) * 1.2,
        opacity = 0.3 + (seed % 5) * 0.1,
        color = seed % 3 == 0
            ? const Color(0xFF7B61FF)
            : seed % 3 == 1
            ? const Color(0xFF00D4FF)
            : const Color(0xFFFF6BBA);
}

// ─────────────────────────────────────────────
//  HOME SCREEN (destination after splash)
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt_rounded, size: 60, color: Color(0xFF7B61FF)),
            const SizedBox(height: 20),
            const Text(
              'Welcome to VOLTEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Power at your fingertips',
              style: TextStyle(
                color: Color(0xFFAA9FD4),
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              ),
              child: const Text(
                'Replay Splash →',
                style: TextStyle(color: Color(0xFF7B61FF), letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}