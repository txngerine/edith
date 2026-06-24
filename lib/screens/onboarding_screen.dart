import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final _features = [
    {
      'icon': Icons.person_outline,
      'title': 'Your identity changes daily',
      'subtitle': 'New name. New avatar. New you. Every 24 hours.',
    },
    {
      'icon': Icons.timer_outlined,
      'title': 'Messages expire automatically',
      'subtitle': 'Chats and media disappear so nothing stays behind.',
    },
    {
      'icon': Icons.save_outlined,
      'title': 'Only what you save survives',
      'subtitle': 'Save important media with a secret code.',
    },
  ];

  Future<void> _continue() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (SupabaseService.isLoggedIn) {
        developer.log('[Onboarding] Already logged in — navigating home',
            name: 'EDITH');
        if (!mounted) return;
        _navigateToHome();
        return;
      }

      developer.log('[Onboarding] Signing in anonymously', name: 'EDITH');
      await SupabaseService.signUpAnonymous();
      developer.log(
          '[Onboarding] Anonymous sign-in succeeded — navigating home',
          name: 'EDITH');
      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      if (e.toString().contains('already logged in') ||
          e.toString().contains('already authenticated')) {
        if (!mounted) return;
        _navigateToHome();
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Could not sign in. Please check your connection and try again.'),
          backgroundColor: EdithColors.danger,
        ),
      );
    }
  }

  void _navigateToHome() {
    Get.off(() => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              const Text(
                'E D I T H',
                style: TextStyle(
                  color: EdithColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                  fontFamily: 'SpaceMono',
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              const Text(
                'Even dead im the hero',
                style: TextStyle(
                  color: EdithColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontFamily: 'SpaceMono',
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 56),
              // Features PageView
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _features.length,
                  itemBuilder: (ctx, i) {
                    final f = _features[i];
                    return Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: EdithColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(f['icon'] as IconData,
                              color: EdithColors.textSecondary, size: 28),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          f['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: EdithColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          f['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: EdithColors.textSecondary,
                            fontSize: 12,
                            height: 1.6,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentPage ? 24 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? EdithColors.accent
                          : EdithColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Spacer(),
              EdithButton(
                label: 'Continue',
                onTap: _continue,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
