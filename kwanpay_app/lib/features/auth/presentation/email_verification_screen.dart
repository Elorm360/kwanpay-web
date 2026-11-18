import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Core/services/auth_service.dart';
import '../../../Core/services/profile_service.dart';
import '../../../Core/theme/app_colors.dart';
import '../../../Core/theme/app_spacing.dart';
import '../../../Core/theme/app_text_styles.dart';
import '../../../Core/widgets/primary_button.dart';
import '../../../Core/widgets/secondary_button.dart';
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
    if (!RegExp(r'^\d{6}$').hasMatch(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code from your email.')),
      );
      return;
    }

    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final response = await _authService.verifySignupOtp(
        email: widget.email,
        token: token,
      );

      final user = response.user ?? Supabase.instance.client.auth.currentUser;
      if (user == null || !_authService.isEmailVerified(user)) {
        throw Exception('Email is not verified yet. Please try again.');
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
    if (_resendSeconds > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await _authService.resendSignupOtp(email: widget.email);
      if (!mounted) return;

      _codeController.clear();
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
    if (_completed || !mounted) return;
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
              const SizedBox(height: 42),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'EMAIL VERIFICATION',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 34,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Check your inbox',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a 6-digit verification code to',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the code below to confirm your email and finish setting up your account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 30),
              OtpCodeField(
                controller: _codeController,
                onCompleted: _verifyCode,
              ),
              const SizedBox(height: 24),
              _isVerifying
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Verify email',
                      onPressed: _verifyCode,
                    ),
              const SizedBox(height: 14),
              _isResending
                  ? const Center(child: CircularProgressIndicator())
                  : SecondaryButton(
                      text: _resendSeconds > 0
                          ? 'Resend code in ${_resendSeconds}s'
                          : 'Resend code',
                      onPressed: _resendCode,
                    ),
              const SizedBox(height: 18),
              const Text(
                "Can't find the email? Check your spam or junk folder.",
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 26),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to sign in',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
