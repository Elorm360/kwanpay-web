import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/services/profile_service.dart';
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

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    loadProfile();

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
                  balance: 0.00,
                  onAddMoney: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fund wallet coming soon!"),
                      ),
                    );
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
                child: const RecentActivity(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

