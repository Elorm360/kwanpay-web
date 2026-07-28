import 'package:flutter/material.dart';

import '../home/presentation/home_screen.dart';
import '../pay/presentation/pay_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../send/presentation/send_screen.dart';
import '../home/widgets/premium_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const PayScreen(),

    const SendScreen(),

    const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              "No activity yet.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Your payment history will appear\nonce you begin using KwanPay.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: PremiumBottomNav(
        selectedIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

