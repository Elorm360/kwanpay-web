import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../navigation/main_navigation_screen.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    void show(String message) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      show('Please complete all fields.');
      return;
    }
    if (!AuthService.looksLikeEmail(email)) {
      show('Enter a valid email address.');
      return;
    }
    final suggestion = AuthService.suggestEmailFix(email);
    if (suggestion != null) {
      final useFix = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Check your email'),
          content: Text('Did you mean $suggestion?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep as typed'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use suggestion'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (useFix == null) return;
      if (useFix) {
        emailController.text = suggestion;
        return signUp();
      }
    }
    final passwordProblem = AuthService.passwordProblem(password);
    if (passwordProblem != null) {
      show(passwordProblem);
      return;
    }

    try {
      setState(() {
        isLoading = true; 
      });

      final authService = AuthService();
      final response = await authService.signUp(
        email: email,
        password: password,
        fullName: name,
      );

      if (!mounted) return;

      final user = response.user;
      if (user != null &&
          response.session != null &&
          authService.isEmailVerified(user)) {
        await ProfileService().createProfile(
          fullName: name,
          email: email,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
        );
        return;
      }

      // Supabase answers a sign-up for an existing account with a fake
      // success (no identities, no email) so attackers cannot probe which
      // emails are registered. Tell the user plainly instead of sending them
      // to wait for a code that will never arrive.
      if (!authService.isNewSignup(response)) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('You already have an account'),
            content: Text(
              '$email is already registered. Sign in, or reset your password if you have forgotten it.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialEmail: email)),
                  );
                },
                child: const Text('Reset password'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Sign in'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
              Text(
                'Create your\nKwanPay account',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              const Text(
                "We'll email you a 6-digit code to confirm it's you.",
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 32),
              KwanTextField(
                label: 'Full Name',
                icon: Icons.person_outline,
                controller: nameController,
              ),
              const SizedBox(height: 20),
              KwanTextField(
                label: 'Email Address',
                icon: Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                controller: passwordController,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 8),
              Text(
                'At least ${AuthService.minPasswordLength} characters, with a letter and a number.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PrimaryButton(
                      text: 'Create Account',
                      onPressed: () {
                        signUp();
                      },
                    ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Sign In'),
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

