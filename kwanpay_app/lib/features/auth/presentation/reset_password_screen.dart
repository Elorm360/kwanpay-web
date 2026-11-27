import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'login_screen.dart';

/// Step 2 of password reset: emailed code + new password.
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isSaving = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    try {
      await _authService.sendPasswordResetCode(email: widget.email);
      _startResendTimer();
      _show('A new code is on its way.');
    } on AuthException catch (e) {
      _show(AuthService.friendlyError(e));
    } catch (_) {
      _show('Could not resend the code. Try again shortly.');
    }
  }

  Future<void> _save() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;

    if (code.length < 6 || code.length > 8) {
      _show('Enter the code from your email.');
      return;
    }
    final problem = AuthService.passwordProblem(password);
    if (problem != null) {
      _show(problem);
      return;
    }
    if (password != _confirmController.text) {
      _show('The two passwords do not match.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _authService.resetPasswordWithCode(
        email: widget.email,
        code: code,
        newPassword: password,
      );
      if (!mounted) return;
      _show('Password updated. Sign in with your new password.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => route.isFirst,
      );
    } on AuthException catch (e) {
      _show(AuthService.friendlyError(e));
    } catch (_) {
      _show('Could not update the password. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Set a new password', style: AppTextStyles.headline),
                const SizedBox(height: 12),
                Text(
                  'Enter the code we sent to ${widget.email}, then choose a new password.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Code from email',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
                PasswordTextField(
                  controller: _passwordController,
                  label: 'New password',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 8),
                Text(
                  'At least ${AuthService.minPasswordLength} characters, with a letter and a number.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),
                PasswordTextField(
                  controller: _confirmController,
                  label: 'Confirm new password',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 32),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(text: 'Update password', onPressed: _save),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _resendSeconds > 0 ? null : _resend,
                    child: Text(
                      _resendSeconds > 0 ? 'Resend code in ${_resendSeconds}s' : 'Resend code',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
