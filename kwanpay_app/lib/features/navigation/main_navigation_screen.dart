import 'package:flutter/material.dart';

import '../home/presentation/activity_screen.dart';
import '../home/presentation/home_screen.dart';
import '../home/widgets/premium_bottom_nav.dart';
import '../pay/presentation/pay_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../send/presentation/send_money_screen.dart';

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

    const SendMoneyScreen(),
    const ActivityScreen(),
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

