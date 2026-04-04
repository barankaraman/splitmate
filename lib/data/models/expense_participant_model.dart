/// Join table between expenses and the members sharing that expense.
/// Each row means "memberId participated in expenseId".
class ExpenseParticipantModel {
  final String expenseId;
  final String memberId;

  const ExpenseParticipantModel({
    required this.expenseId,
    required this.memberId,
  });

  Map<String, dynamic> toMap() => {
        'expense_id': expenseId,
        'member_id': memberId,
      };

  factory ExpenseParticipantModel.fromMap(Map<String, dynamic> map) =>
      ExpenseParticipantModel(
        expenseId: map['expense_id'] as String,
        memberId: map['member_id'] as String,
      );

  @override
  String toString() =>
      'ExpenseParticipantModel(expenseId: $expenseId, memberId: $memberId)';
}
