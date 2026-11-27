import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/wallet_dashboard_provider.dart';
import '../home/presentation/activity_screen.dart';
import '../home/presentation/home_screen.dart';
import '../home/widgets/premium_bottom_nav.dart';
import '../pay/presentation/pay_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../send/presentation/send_money_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends ConsumerState<MainNavigationScreen> {

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
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: PremiumBottomNav(
        selectedIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0 || index == 3) {
            ref.read(walletDashboardProvider.notifier).refresh();
          }
        },
      ),
    );
  }
}
