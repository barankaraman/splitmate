import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../domain/services/settlement_service.dart';

/// Screen displaying the minimum set of payments to settle all debts.
class SettlementScreen extends StatelessWidget {
  final GroupModel group;
  final List<MemberBalance> balances;

  const SettlementScreen({
    super.key,
    required this.group,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    final service = SettlementService();
    final suggestions = service.computeSettlements(balances);

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} · ${AppStrings.settlement}'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Balances summary ──────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.account_balance_outlined,
            title: AppStrings.balances,
          ),
          const SizedBox(height: 8),
          ...balances.map((b) => _BalanceTile(balance: b)),
          const SizedBox(height: 20),

          // ── Suggested payments ────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.swap_horiz_outlined,
            title: AppStrings.suggestedPayments,
          ),
          const SizedBox(height: 8),

          if (suggestions.isEmpty)
            _SettledCard()
          else
            ...suggestions.map(
              (s) => _PaymentCard(suggestion: s),
            ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final MemberBalance balance;
  const _BalanceTile({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPos = balance.netBalance >= 0;
    final color = isPos ? AppColors.success : AppColors.error;
    final statusText = isPos ? 'is owed' : 'owes';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Text(
            balance.member.name.isNotEmpty
                ? balance.member.name[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(balance.member.name,
            style: AppTextStyles.titleMedium),
        subtitle: Text(
          'Paid TRY ${balance.totalPaid.toStringAsFixed(2)} · '
          'Share TRY ${balance.totalOwed.toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TRY ${balance.netBalance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(statusText,
                style:
                    AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentSuggestion suggestion;
  const _PaymentCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // From
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        AppColors.error.withOpacity(0.12),
                    child: Text(
                      suggestion.fromMember.name.isNotEmpty
                          ? suggestion.fromMember.name[0]
                              .toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(suggestion.fromMember.name,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            // Arrow + amount
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'TRY ${suggestion.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.amountMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('will pay',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),

            // To
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        AppColors.success.withOpacity(0.12),
                    child: Text(
                      suggestion.toMember.name.isNotEmpty
                          ? suggestion.toMember.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(suggestion.toMember.name,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettledCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 48),
            const SizedBox(height: 10),
            Text(AppStrings.noDebts,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.success)),
          ],
        ),
      ),
    );
  }
}
