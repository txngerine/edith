import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import '../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _lockController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _progress = i / 100);
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    developer.log('[SplashScreen] Waiting for session recovery', name: 'EDITH');
    final user = await SupabaseService.waitForSession();
    developer.log('[SplashScreen] Session user: ${user?.id ?? "none"}', name: 'EDITH');
    if (!mounted) return;
    final isLoggedIn = user != null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Text(
              'E D I T H',
              style: TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 16,
                fontFamily: 'SpaceMono',
              ),
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 8),
            const Text(
              'EVEN DEAD IM THE HERO',
              style: TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 10,
                letterSpacing: 4,
                fontFamily: 'SpaceMono',
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            const SizedBox(height: 60),
            // Lock icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: EdithColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: EdithColors.textDim,
                size: 24,
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 32),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: EdithColors.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: EdithColors.accent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Initializing secure session...',
                    style: const TextStyle(
                      color: EdithColors.textDim,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
