import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/expense_model.dart';
import '../models/expense_participant_model.dart';

/// All database operations for expenses and their participants.
class ExpenseRepository {
  final DatabaseHelper _db;

  ExpenseRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  // ─── Expenses ────────────────────────────────────────────────────────────────

  /// Returns all expenses for [groupId], newest first.
  Future<List<ExpenseModel>> getExpensesForGroup(String groupId) async {
    final rows = await _db.query(
      DatabaseHelper.tableExpenses,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final rows = await _db.query(
      DatabaseHelper.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return ExpenseModel.fromMap(rows.first);
  }

  // ─── Participants ─────────────────────────────────────────────────────────────

  /// Returns the member IDs participating in [expenseId].
  Future<List<String>> getParticipantIds(String expenseId) async {
    final rows = await _db.query(
      DatabaseHelper.tableExpenseParticipants,
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return rows
        .map((r) => r['member_id'] as String)
        .toList();
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  /// Inserts an expense together with its participant rows atomically.
  Future<ExpenseModel> insertExpenseWithParticipants(
    ExpenseModel expense,
    List<String> participantIds,
  ) async {
    await _db.transaction((txn) async {
      await txn.insert(
        DatabaseHelper.tableExpenses,
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final memberId in participantIds) {
        await txn.insert(
          DatabaseHelper.tableExpenseParticipants,
          ExpenseParticipantModel(
            expenseId: expense.id,
            memberId: memberId,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    return expense;
  }

  /// Deletes an expense and its participant rows (cascade handles this automatically).
  Future<void> deleteExpense(String id) async {
    await _db.delete(
      DatabaseHelper.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Aggregates ───────────────────────────────────────────────────────────────

  /// Calculates the total amount spent in a group.
  Future<double> getTotalForGroup(String groupId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseHelper.tableExpenses} WHERE group_id = ?',
      [groupId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
