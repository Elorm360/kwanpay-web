import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/wallet_dashboard_provider.dart';
import '../../auth/widgets/dashboard_header.dart';
import '../../auth/widgets/wallet_card.dart';
import '../../pay/presentation/pay_screen.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activity.dart';
import 'add_funds_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddFunds() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFundsScreen(),
      ),
    );

    await ref.read(walletDashboardProvider.notifier).refresh();
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required double beginInterval,
    required double endInterval,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Interval(
          beginInterval,
          endInterval,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              beginInterval,
              endInterval,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(walletDashboardProvider);
    final userName = dashboard.profile?.fullName ?? '';

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () {
            return ref.read(walletDashboardProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              bottom: AppSpacing.xxl,
            ),
            child: Column(
              children: [
                _buildAnimatedSection(
                  beginInterval: 0.00,
                  endInterval: 0.20,
                  child: DashboardHeader(
                    userName: userName,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildAnimatedSection(
                  beginInterval: 0.15,
                  endInterval: 0.40,
                  child: WalletCard(
                    balance: dashboard.availableBalance,
                    walletId: dashboard.wallet?.walletId ?? "Loading...",
                    status: dashboard.wallet?.status ?? "Active",
                    currency: dashboard.selectedCurrency,
                    pendingAmount: dashboard.pendingAmountFor(),
                    balanceMatched: dashboard.isBalanceMatched(),
                    hasDisplayRate: dashboard.hasDisplayRate,
                    homeBalanceLabel: dashboard.selectedCurrency ==
                            dashboard.homeCurrency
                        ? null
                        : "Held as ${dashboard.homeCurrency} ${dashboard.canonicalBalance.toStringAsFixed(2)}",
                    onCurrencySelected: (code) {
                      ref
                          .read(walletDashboardProvider.notifier)
                          .selectCurrency(code);
                    },
                    onPay: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PayScreen(),
                        ),
                      );
                    },
                    onAddMoney: _openAddFunds,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildAnimatedSection(
                  beginInterval: 0.30,
                  endInterval: 0.60,
                  child: const QuickActions(),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildAnimatedSection(
                  beginInterval: 0.50,
                  endInterval: 1.00,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: RecentActivity(
                      transactions: dashboard.transactions,
                      limit: 5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
