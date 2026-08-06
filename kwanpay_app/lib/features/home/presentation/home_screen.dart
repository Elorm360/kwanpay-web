import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/wallet_model.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/services/wallet_service.dart';
import '../../auth/widgets/dashboard_header.dart';
import '../../auth/widgets/wallet_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activity.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  ProfileModel? profile;
  bool isLoadingProfile = true;

  WalletModel? wallet;
  bool isLoadingWallet = true;

  List<TransactionModel> transactions = [];
  bool isLoadingTransactions = true;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    loadProfile();
    loadWallet();
    loadTransactions();

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

  Future<void> loadProfile() async {
    try {
      final profileService = ProfileService();
      final fetched = await profileService.getProfile();
      if (mounted) {
        setState(() {
          profile = fetched;
          isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> loadWallet() async {
    try {
      final result = await WalletService().getWallet();
      if (mounted) {
        setState(() {
          wallet = result;
          isLoadingWallet = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingWallet = false;
        });
      }
    }
  }

  Future<void> loadTransactions() async {
    try {
      final result = await TransactionService().getTransactions();
      if (!mounted) return;
      setState(() {
        transactions = result;
        isLoadingTransactions = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTransactions = false;
        });
      }
    }
  }

  Future<void> simulateTopUp() async {
    if (wallet == null) return;

    final newBalance = wallet!.balance + 100;

    await WalletService().updateBalance(newBalance);
    await TransactionService().createTransaction(
      type: "Top Up",
      amount: 100,
      currency: "USD",
      description: "Wallet Top Up",
    );

    await loadWallet();
    await loadTransactions();
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
    final userName = profile?.fullName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
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
                  balance: wallet?.balance ?? 0,
                  walletId: wallet?.walletId ?? "Loading...",
                  status: wallet?.status ?? "Active",
                  currency: wallet?.currency ?? "USD",
                  onAddMoney: () async {
                    await simulateTopUp();
                  },
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
                child: RecentActivity(
                  transactions: transactions,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

