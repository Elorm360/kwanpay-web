import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("KwanPay"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 30),

            const Text(
              "🎉 Welcome!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              user?.email ?? "",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "You are successfully authenticated.",
            ),

            const SizedBox(height: 12),

            const Text(
              "Next Sprint we'll build your Wallet Dashboard.",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                 await Supabase.instance.client.auth.signOut();

if (!context.mounted) return;

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const WelcomeScreen(),
  ),
  (route) => false,
);

                },

                child: const Text("Logout"),

              ),

            ),

          ],

        ),

      ),

    );

  }
}