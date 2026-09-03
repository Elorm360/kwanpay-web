import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kwanpay_lockup.dart';
import '../auth/presentation/email_verification_screen.dart';
import '../navigation/main_navigation_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      final user = Supabase.instance.client.auth.currentUser;

      _navigate(user);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Failed to start app: $e";
      });
    }
  }

  void _navigate(User? user) {
    if (!mounted) return;
    if (_navigated) return;
    _navigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (user != null && !AuthService().isEmailVerified(user)) {
            return EmailVerificationScreen(email: user.email ?? '');
          }
          if (user != null) {
            return const MainNavigationScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/kwanpay_lockup.png',
                width: 320,
                errorBuilder: (_, _, _) {
                  return const KwanPayLockup(
                    onDark: true,
                    showTagline: true,
                    markSize: 88,
                    wordmarkSize: 40,
                  );
                },
              ),
              const SizedBox(height: 40),
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
