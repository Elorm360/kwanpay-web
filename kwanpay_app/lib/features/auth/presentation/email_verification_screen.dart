import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../navigation/main_navigation_screen.dart';
import '../widgets/otp_code_field.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  final _authService = AuthService();

  StreamSubscription<AuthState>? _authSubscription;
  Timer? _resendTimer;

  bool _isVerifying = false;
  bool _isResending = false;
  bool _completed = false;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && _authService.isEmailVerified(session.user)) {
        unawaited(_completeVerifiedSignup(session.user));
      }
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      if (mounted) setState(() => _resendSeconds -= 1);
    });
  }

  Future<void> _verifyCode([String? value]) async {
    final token = (value ?? _codeController.text).trim();
    if (token.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code from your email.')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await _authService.verifySignupOtp(
        email: widget.email,
        token: token,
      );

      final user = response.user ?? Supabase.instance.client.auth.currentUser;
      if (user == null || !_authService.isEmailVerified(user)) {
        throw Exception('Email is not verified yet.');
      }

      await _completeVerifiedSignup(user);
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
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0) return;

    setState(() => _isResending = true);

    try {
      await _authService.resendSignupOtp(email: widget.email);
      if (!mounted) return;

      _startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code was sent to your email.'),
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

  Future<void> _completeVerifiedSignup(User user) async {
    if (_completed) return;
    _completed = true;
    await ProfileService().createProfileIfNotExists();
    _navigateToDashboard();
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
    _resendTimer?.cancel();
    _codeController.dispose();
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 50,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Verify Your Email',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter the 6-digit code we sent to:',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 32),
              OtpCodeField(
                controller: _codeController,
                onCompleted: _verifyCode,
              ),
              const SizedBox(height: 32),
              _isVerifying
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Verify Email',
                      onPressed: _verifyCode,
                    ),
              const SizedBox(height: 16),
              _isResending
                  ? const Center(child: CircularProgressIndicator())
                  : SecondaryButton(
                      text: _resendSeconds > 0
                          ? 'Resend code in ${_resendSeconds}s'
                          : 'Resend Code',
                      onPressed: _resendCode,
                    ),
              const SizedBox(height: 40),
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
