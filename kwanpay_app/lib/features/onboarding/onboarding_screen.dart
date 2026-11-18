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
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  IconData _iconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.flight_takeoff_rounded;
      case 1:
        return Icons.storefront_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = onboardingPages[currentPage];
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const KwanPayLockup(
                    axis: Axis.horizontal,
                    onDark: false,
                    showTagline: false,
                    markSize: 38,
                    wordmarkSize: 21,
                  ),
                  TextButton(
                    onPressed: _openWelcome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 6,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -70,
                                right: -50,
                                child: Container(
                                  width: 230,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.markTile.withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -90,
                                left: -70,
                                child: Container(
                                  width: 230,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.15),
                                      width: 28,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: size.width * 0.52,
                                        height: size.width * 0.52,
                                        constraints: const BoxConstraints(
                                          maxWidth: 240,
                                          maxHeight: 240,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.markTile,
                                          borderRadius: BorderRadius.circular(36),
                                          border: Border.all(
                                            color: AppColors.accent.withValues(alpha: 0.35),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.12),
                                              blurRadius: 24,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _iconForPage(index),
                                          size: 104,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.circle, size: 8, color: AppColors.accent),
                                          const SizedBox(width: 8),
                                          Icon(Icons.circle, size: 5, color: Colors.white.withValues(alpha: 0.45)),
                                          const SizedBox(width: 8),
                                          Icon(Icons.circle, size: 5, color: Colors.white.withValues(alpha: 0.45)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(currentPage),
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(onboardingPages.length, (index) {
                  final selected = currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
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
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentPage == onboardingPages.length - 1 ? 'Get Started' : 'Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 19),
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
