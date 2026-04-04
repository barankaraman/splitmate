import '../../data/models/expense_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/expense_repository.dart';

// ─── Value objects ────────────────────────────────────────────────────────────

/// A single suggested payment: [fromMember] should pay [amount] to [toMember].
class PaymentSuggestion {
  final MemberModel fromMember;
  final MemberModel toMember;
  final double amount;

  const PaymentSuggestion({
    required this.fromMember,
    required this.toMember,
    required this.amount,
  });

  @override
  String toString() =>
      '${fromMember.name} → ${toMember.name}: ₺${amount.toStringAsFixed(2)}';
}

/// Summary information per member.
class MemberBalance {
  final MemberModel member;

  /// Positive = is owed money; Negative = owes money.
  final double netBalance;

  /// Total amount this member paid across all expenses.
  final double totalPaid;

  /// Total share this member owes across all expenses.
  final double totalOwed;

  const MemberBalance({
    required this.member,
    required this.netBalance,
    required this.totalPaid,
    required this.totalOwed,
  });

  bool get isSettled => netBalance.abs() < 0.01;
  bool get isCreditor => netBalance > 0.01;
  bool get isDebtor => netBalance < -0.01;
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// Encapsulates all expense-splitting and settlement calculation logic.
class SettlementService {
  final ExpenseRepository _expenseRepository;

  SettlementService({ExpenseRepository? expenseRepository})
      : _expenseRepository =
            expenseRepository ?? ExpenseRepository();

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Computes per-member balances for [members] given [expenses] in a group.
  ///
  /// For each expense:
  ///   - The payer's balance increases by the full amount.
  ///   - Every participant's balance decreases by (amount / participantCount).
  Future<List<MemberBalance>> computeBalances({
    required List<MemberModel> members,
    required List<ExpenseModel> expenses,
  }) async {
    // Map from memberId → { totalPaid, totalOwed }
    final Map<String, double> paid = {for (final m in members) m.id: 0.0};
    final Map<String, double> owed = {for (final m in members) m.id: 0.0};

    for (final expense in expenses) {
      final participantIds =
          await _expenseRepository.getParticipantIds(expense.id);

      if (participantIds.isEmpty) continue;

      final share = expense.amount / participantIds.length;

      // Credit the payer.
      if (paid.containsKey(expense.payerId)) {
        paid[expense.payerId] = paid[expense.payerId]! + expense.amount;
      }

      // Debit every participant.
      for (final pid in participantIds) {
        if (owed.containsKey(pid)) {
          owed[pid] = owed[pid]! + share;
        }
      }
    }

    return members.map((m) {
      final totalPaid = paid[m.id] ?? 0.0;
      final totalOwed = owed[m.id] ?? 0.0;
      return MemberBalance(
        member: m,
        netBalance: totalPaid - totalOwed,
        totalPaid: totalPaid,
        totalOwed: totalOwed,
      );
    }).toList();
  }

  /// Produces the minimum set of payments to settle all debts.
  ///
  /// Uses a greedy two-pointer approach on sorted creditor/debtor lists.
  List<PaymentSuggestion> computeSettlements(
      List<MemberBalance> balances) {
    // Separate into creditors (net > 0) and debtors (net < 0).
    final creditors = balances
        .where((b) => b.isCreditor)
        .map((b) => _MutableBalance(b.member, b.netBalance))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount)); // largest first

    final debtors = balances
        .where((b) => b.isDebtor)
        .map((b) => _MutableBalance(b.member, b.netBalance.abs()))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount)); // largest first

    final suggestions = <PaymentSuggestion>[];

    int ci = 0; // creditor pointer
    int di = 0; // debtor pointer

    while (ci < creditors.length && di < debtors.length) {
      final creditor = creditors[ci];
      final debtor = debtors[di];

      // The payment amount is the minimum of the two outstanding amounts.
      final payment =
          creditor.amount < debtor.amount ? creditor.amount : debtor.amount;

      if (payment > 0.005) {
        // Ignore tiny floating-point noise.
        suggestions.add(PaymentSuggestion(
          fromMember: debtor.member,
          toMember: creditor.member,
          amount: _round(payment),
        ));
      }

      creditor.amount -= payment;
      debtor.amount -= payment;

      if (creditor.amount < 0.005) ci++;
      if (debtor.amount < 0.005) di++;
    }

    return suggestions;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  /// Rounds to 2 decimal places to avoid floating-point drift.
  static double _round(double v) => (v * 100).round() / 100;
}

/// Mutable helper used during the greedy settlement algorithm.
class _MutableBalance {
  final MemberModel member;
  double amount;

  _MutableBalance(this.member, this.amount);
}
