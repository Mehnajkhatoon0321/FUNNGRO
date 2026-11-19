import 'dart:async';
import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Branded, high-aesthetic Splash Screen displaying the official Funngro visual identity.
/// Features ambient radial glow, scale-fade animations, and smooth transition into [HomeScreen].
class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    _timer = Timer(widget.duration, _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Color(0xFF063A21),
              Color(0xFF031E11),
              Color(0xFF010D07),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Center Ambient Emerald Glow
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.22),
                      blurRadius: 120,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            // Main Logo & Tagline Card
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Official Image Card with drop shadow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/funngro_splash.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Smart Teens Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF34D399),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Empowering 100,000+ Smart Teens',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Branding & Loading
            Positioned(
              left: 0,
              right: 0,
              bottom: 44,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF34D399),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'MOBILE ENGINEERING CANDIDATE DEMO',
                      style: TextStyle(
                        fontSize: 9.5,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6EE7B7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
