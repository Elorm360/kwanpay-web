import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../widgets/search_section.dart';
import '../widgets/category_section.dart';
import '../widgets/section_title.dart';
import '../widgets/payment_quote_card.dart';
import '../widgets/empty_operator_state.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorPaper,
      appBar: AppBar(
        title: const Text(
          "Pay",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  "Find who you want to pay. Operator checkout is not live yet.",
                  style: AppTextStyles.caption.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SearchSection(),
              const SizedBox(height: AppSpacing.xl),
              const CategorySection(),
              const SizedBox(height: AppSpacing.xl),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SectionTitle(
                  title: "Operators",
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const EmptyOperatorState(),
              const SizedBox(height: AppSpacing.xl),
              const PaymentQuoteCard(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

