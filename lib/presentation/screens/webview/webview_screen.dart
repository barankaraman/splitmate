import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/theme_provider.dart';

/// WebView screen that shows local financial tips using a Flutter ListView instead of WebView to avoid bugs.
class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final bgColor = isDark ? const Color(0xFF121218) : const Color(0xFFF0F0F8);
    final cardColor = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(AppStrings.financialTips),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF4B44CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Text('💡', style: TextStyle(fontSize: 40)),
                SizedBox(height: 10),
                Text(
                  'Financial Tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Practical suggestions for a\nhealthier financial future',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildTipCard(
            context,
            '💰',
            '50 / 30 / 20 Rule',
            'Allocate 50% of your income to needs, 30% to wants, and 20% to savings & investments.',
            'This rule is the most common way to balance your budget easily.',
            cardColor,
            textColor,
            subTextColor,
          ),
          _buildTipCard(
            context,
            '🏦',
            'Emergency Fund',
            'Build an emergency fund covering 3–6 months of living expenses for unexpected situations.',
            'Transfer 10% of your income to a separate savings account every month.',
            cardColor,
            textColor,
            subTextColor,
            isPriority: true,
          ),
          _buildTipCard(
            context,
            '📊',
            'Track Your Expenses',
            'Record every expense. It\'s hard to save without knowing where the money goes. SplitMate makes group expenses transparent.',
            '5 minutes of tracking daily can save you thousands of liras a year.',
            cardColor,
            textColor,
            subTextColor,
          ),
          _buildTipCard(
            context,
            '💳',
            'Debt Management',
            'Pay off high-interest debts first. Try to pay the full balance instead of the minimum payment.',
            'Avalanche method: Highest interest first; Snowball method: Lowest balance first.',
            cardColor,
            textColor,
            subTextColor,
          ),
          _buildTipCard(
            context,
            '📈',
            'Invest Early',
            'Start investing as early as possible to benefit from compound interest. Even small amounts make a difference.',
            'Small monthly investments can grow significantly over decades.',
            cardColor,
            textColor,
            subTextColor,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Prepared by SplitMate 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    String emoji,
    String title,
    String desc,
    String tip,
    Color cardColor,
    Color textColor,
    Color subTextColor, {
    bool isPriority = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPriority)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'Priority',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(desc, style: TextStyle(color: subTextColor, fontSize: 13.5, height: 1.65)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              '💡 $tip',
              style: const TextStyle(color: AppColors.primary, fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
