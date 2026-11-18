import 'package:flutter/material.dart';

import '../../Core/theme/app_colors.dart';
import '../../Core/widgets/kwanpay_lockup.dart';
import '../auth/presentation/welcome_screen.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _nextPage() {
    if (currentPage == onboardingPages.length - 1) {
      _openWelcome();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = onboardingPages[currentPage];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const KwanPayLockup(
                    axis: Axis.horizontal,
                    onDark: false,
                    showTagline: false,
                    markSize: 36,
                    wordmarkSize: 21,
                  ),
                  TextButton(
                    onPressed: _openWelcome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 6,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  itemBuilder: (context, index) {
                    final item = onboardingPages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primary,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.landscape_outlined,
                                    color: AppColors.accent,
                                    size: 72,
                                  ),
                                );
                              },
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x220D1228),
                                    Color(0x000D1228),
                                    Color(0xCC0D1228),
                                  ],
                                  stops: [0, 0.42, 1],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 18,
                              left: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Text(
                                  '0${index + 1}  /  0${onboardingPages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 22,
                              right: 22,
                              bottom: 22,
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'MADE FOR THE JOURNEY',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                child: Column(
                  key: ValueKey(currentPage),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      page.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Row(
                    children: List.generate(onboardingPages.length, (index) {
                      final selected = currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.only(right: 6),
                        width: selected ? 25 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.accent : AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  Text(
                    '${currentPage + 1} of ${onboardingPages.length}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentPage == onboardingPages.length - 1
                            ? 'Get started'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
