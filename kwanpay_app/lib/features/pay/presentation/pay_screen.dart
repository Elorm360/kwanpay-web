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
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Pay a tourism business in Ghana cedis from your KwanPay wallet. TransVista Africa Ltd is the first live operator.',
                style: AppTextStyles.caption.copyWith(
                  color: context.colorTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SearchSection(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            CategorySection(
              selectedCategory: _selectedCategory,
              onSelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Operators',
                style: AppTextStyles.title,
              ),
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
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
