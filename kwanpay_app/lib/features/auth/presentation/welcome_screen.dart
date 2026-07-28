import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import 'signup_screen.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                'assets/images/kwanpay_logo.png',
                width: 160,
              ),

              const SizedBox(height: 40),

              const Text(
                'Welcome to KwanPay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Send money, pay operators, and travel across Africa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

