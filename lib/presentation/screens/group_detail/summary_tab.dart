import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../domain/services/settlement_service.dart';
import '../settlement/settlement_screen.dart';

/// Tab showing per-member balances and a button to open the full settlement.
class SummaryTab extends StatefulWidget {
  final GroupModel group;
  const SummaryTab({super.key, required this.group});

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab>
    with AutomaticKeepAliveClientMixin {
  final _memberRepo = MemberRepository();
  final _expenseRepo = ExpenseRepository();
  final _settlementService = SettlementService();

  List<MemberBalance> _balances = [];
  double _groupTotal = 0;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final members =
        await _memberRepo.getMembersForGroup(widget.group.id);
    final expenses =
        await _expenseRepo.getExpensesForGroup(widget.group.id);
    final total = await _expenseRepo.getTotalForGroup(widget.group.id);

    final balances = await _settlementService.computeBalances(
      members: members,
      expenses: expenses,
    );

    if (mounted) {
      setState(() {
        _balances = balances;
        _groupTotal = total;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TotalCard(total: _groupTotal),
          const SizedBox(height: 16),

          Text(AppStrings.balances, style: AppTextStyles.titleLarge),
          const SizedBox(height: 10),

          if (_balances.isEmpty)
            Center(
              child: Text(
                'Add members and expenses to see balances.',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._balances
                .map((b) => _BalanceRow(balance: b))
                ,

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettlementScreen(
                  group: widget.group,
                  balances: _balances,
                ),
              ),
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text(AppStrings.settlement),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: Colors.white70, size: 32),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.totalExpenses,
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                'TRY ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final MemberBalance balance;
  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance.netBalance >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final label = isPositive ? 'is owed' : 'owes';
    final sign = isPositive ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Text(
                balance.member.name.isNotEmpty
                    ? balance.member.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(balance.member.name,
                      style: AppTextStyles.titleMedium),
                  Text('Paid: TRY ${balance.totalPaid.toStringAsFixed(2)} · '
                      'Share: TRY ${balance.totalOwed.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign TRY ${balance.netBalance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(label,
                    style: AppTextStyles.caption.copyWith(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
