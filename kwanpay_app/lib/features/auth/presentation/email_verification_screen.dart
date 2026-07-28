import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/services/profile_service.dart';
import '../../navigation/main_navigation_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isResending = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final session = data.session;
      if (session != null && session.user.emailConfirmedAt != null) {
        _navigateToDashboard();
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent! Please check your inbox.'),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      // After email confirmation, the user can sign in.
      // Attempt sign-in; if successful, the email was confirmed.
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: widget.email,
        password: widget.password,
      );

      final user = response.user;
      if (user != null && user.emailConfirmedAt != null) {
        await _ensureProfileCreated(user);
        _navigateToDashboard();
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email not yet verified. Please check your inbox and click the confirmation link.',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message.contains('Invalid login credentials')
                ? 'Email not yet verified. Please check your inbox and click the confirmation link.'
                : e.message,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _ensureProfileCreated(User user) async {
    try {
      final profileService = ProfileService();
      await profileService.createProfileIfNotExists();
    } catch (_) {
      // Profile might already exist, that's okay
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Mail Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_rounded,
                  size: 50,
                  color: AppColors.accent,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Check Your Email',
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'We\'ve sent a verification email to:',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 12),

              // Email address
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Please click the confirmation link in the email to verify your account, then tap the button below.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 40),

              // Continue button
              _isChecking
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: "I've Verified My Email",
                      onPressed: _checkVerification,
                    ),

              const SizedBox(height: 16),

              // Resend button
              _isResending
                  ? const Center(child: CircularProgressIndicator())
                  : SecondaryButton(
                      text: 'Resend Email',
                      onPressed: _resendEmail,
                    ),

              const SizedBox(height: 40),

              // Back to sign in
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
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

