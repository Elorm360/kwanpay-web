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
import 'welcome_screen.dart';

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

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
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
      appBar: AppBar(
        title: const Text('Create Your Travel Wallet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Create Your\nTravel Wallet',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              const Text(
                'Create your secure KwanPay wallet and start sending, receiving and paying across Africa.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 40),
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
              ),
              const SizedBox(height: 40),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PrimaryButton(
                      text: 'Create My Wallet',
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
                        builder: (_) => const WelcomeScreen(),
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
    );
  }
}

