import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../models/operator_model.dart';
import '../widgets/category_section.dart';
import '../widgets/empty_operator_state.dart';
import '../widgets/operator_card.dart';
import '../widgets/search_section.dart';
import 'pay_bill_screen.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TourismOperator> get _operators {
    final query = _query.trim().toLowerCase();

    return TourismOperators.all.where((operator) {
      final matchesCategory =
          _selectedCategory == null || operator.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          operator.name.toLowerCase().contains(query) ||
          operator.category.toLowerCase().contains(query) ||
          operator.accountLabel.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final operators = _operators;

    return Scaffold(
      backgroundColor: context.colorPaper,
      appBar: AppBar(
        title: const Text(
          'Pay',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colorSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pay for your trip', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Find a tourism business and pay from your KwanPay wallet. You will review the amount before anything is confirmed.',
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SearchSection(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            CategorySection(
              selectedCategory: _selectedCategory,
              onSelected: (category) =>
                  setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Tourism businesses', style: AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.md),
            if (operators.isEmpty)
              const EmptyOperatorState()
            else
              ...operators.map(
                (operator) => OperatorCard(
                  operatorModel: operator,
                  onPay: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PayBillScreen(operator: operator),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
