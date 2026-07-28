import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/supabase_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter your email address."),
        ),
      );
      return;
    }

    try {

      setState(() {
        isLoading = true;
      });

      await SupabaseService.client.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset link sent. Check your email.",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: AppSpacing.pagePadding,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 30),

              Text(
                "Forgot Password",
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: 12),

              const Text(
                "Enter your email and we'll send you a password reset link.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 40),

              KwanTextField(
                label: "Email Address",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 40),

              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PrimaryButton(
                      text: "Send Reset Link",
                      onPressed: resetPassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}