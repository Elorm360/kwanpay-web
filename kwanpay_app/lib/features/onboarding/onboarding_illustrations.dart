import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Onboarding illustrations built from the app's own UI, instead of
/// generated artwork: always crisp, on-brand, and no image weight.
enum OnboardingArt { payTrip, currencies, accounted }

class OnboardingIllustration extends StatelessWidget {
  final OnboardingArt art;

  const OnboardingIllustration({super.key, required this.art});

  @override
  Widget build(BuildContext context) {
    final child = switch (art) {
      OnboardingArt.payTrip => const _PayTrip(),
      OnboardingArt.currencies => const _Currencies(),
      OnboardingArt.accounted => const _Accounted(),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: child,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String meta;
  final String amount;

  const _Row({
    required this.icon,
    required this.title,
    required this.meta,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayTrip extends StatelessWidget {
  const _PayTrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'This trip',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 6),
              _Row(
                icon: Icons.account_balance_outlined,
                title: 'Castle tour',
                meta: 'Cape Coast · Tour',
                amount: 'GHS 350.00',
              ),
              _Row(
                icon: Icons.bed_outlined,
                title: 'Guesthouse',
                meta: 'Elmina · 2 nights',
                amount: 'GHS 780.00',
              ),
              _Row(
                icon: Icons.directions_bus_outlined,
                title: 'Shuttle',
                meta: 'Accra to Cape Coast · Ride',
                amount: 'GHS 120.00',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Currencies extends StatelessWidget {
  const _Currencies();

  @override
  Widget build(BuildContext context) {
    Widget chip(String code, bool selected) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : Colors.white,
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total balance',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        const Text(
          'GHS 1,240.00',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [chip('GHS', true), const SizedBox(width: 8), chip('USD', false), const SizedBox(width: 8), chip('NGN', false)]),
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Convert',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Text('GHS 152.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 18, color: AppColors.accent),
                  ),
                  Text('USD 10.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Rate shown before you confirm',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Accounted extends StatelessWidget {
  const _Accounted();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 34, color: Color(0xFF4ADE80)),
        ),
        const SizedBox(height: 14),
        const Text(
          'Payment confirmed',
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        const Text(
          'GHS 350.00',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 18),
        _Card(
          child: Column(
            children: const [
              _Detail(label: 'Paid to', value: 'Cape Coast Castle tour'),
              _Detail(label: 'Booking', value: 'BK-20431'),
              _Detail(label: 'Status', value: 'Matched to booking'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;

  const _Detail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
