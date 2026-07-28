import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'onboarding_data.dart';

import '../auth/presentation/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemCount: onboardingPages.length,
        itemBuilder: (context, index) {
          final page = onboardingPages[index];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          onboardingPages.length - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text("Skip"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SizedBox.expand(
                      child: Image.asset(
                        page.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load asset: ${page.image}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (currentPage == onboardingPages.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                          );
                          return;
                        }
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        currentPage == onboardingPages.length - 1
                            ? "Get Started"
                            : "Continue",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) {
                        final selected = currentPage == index;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 30 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

