import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../expense/add_expense_screen.dart';

/// Tab showing all recorded expenses for the group.
///
/// NOTE: This widget does NOT contain a Scaffold or FAB.
/// The parent [GroupDetailScreen] owns the single Scaffold and calls
/// [triggerAddExpense] via a GlobalKey when the FAB is tapped.
class ExpensesTab extends StatefulWidget {
  final GroupModel group;
  const ExpensesTab({super.key, required this.group});

  @override
  // Public state class so GroupDetailScreen can hold a GlobalKey<ExpensesTabState>.
  State<ExpensesTab> createState() => ExpensesTabState();
}

class ExpensesTabState extends State<ExpensesTab>
    with AutomaticKeepAliveClientMixin {
  final _expenseRepo = ExpenseRepository();
  final _memberRepo = MemberRepository();

  List<ExpenseModel> _expenses = [];
  Map<String, MemberModel> _memberMap = {};
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final expenses =
          await _expenseRepo.getExpensesForGroup(widget.group.id);
      final members =
          await _memberRepo.getMembersForGroup(widget.group.id);

      if (mounted) {
        setState(() {
          _expenses = expenses;
          _memberMap = {for (final m in members) m.id: m};
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Called by [GroupDetailScreen]'s FAB via GlobalKey.
  Future<void> triggerAddExpense() async => _navigateToAddExpense();

  Future<void> _navigateToAddExpense() async {
    if (!mounted) return;

    final members =
        await _memberRepo.getMembersForGroup(widget.group.id);

    if (!mounted) return;

    if (members.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.addAtLeastTwoMembers),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          group: widget.group,
          members: members,
        ),
      ),
    );
    if (added == true && mounted) _load();
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Harcamayı Sil'),
        content: Text('"${expense.title}" silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    await _expenseRepo.deleteExpense(expense.id);
    if (mounted) _load();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _expenses.length,
        itemBuilder: (_, i) => _ExpenseCard(
          key: ValueKey(_expenses[i].id),
          expense: _expenses[i],
          payer: _memberMap[_expenses[i].payerId],
          onDelete: () => _deleteExpense(_expenses[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(
              AppStrings.noExpenses,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Card ─────────────────────────────────────────────────────────────

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final MemberModel? payer;
  final VoidCallback onDelete;

  const _ExpenseCard({
    super.key,
    required this.expense,
    required this.payer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y').format(expense.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Ödeyen: ${payer?.name ?? "?"} • $dateStr',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (expense.hasLocation) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.info),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            expense.locationLabel ?? 'Konum eklendi',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.info),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${expense.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.amountMedium,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
