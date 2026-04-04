import '../database/database_helper.dart';
import '../models/member_model.dart';

/// All database operations for the [MemberModel] entity.
class MemberRepository {
  final DatabaseHelper _db;

  MemberRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  // ─── Read ────────────────────────────────────────────────────────────────────

  /// Returns all members for [groupId], ordered by join date.
  Future<List<MemberModel>> getMembersForGroup(String groupId) async {
    final rows = await _db.query(
      DatabaseHelper.tableMembers,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'joined_at ASC',
    );
    return rows.map(MemberModel.fromMap).toList();
  }

  /// Returns a single member by [id].
  Future<MemberModel?> getMemberById(String id) async {
    final rows = await _db.query(
      DatabaseHelper.tableMembers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return MemberModel.fromMap(rows.first);
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  Future<MemberModel> insertMember(MemberModel member) async {
    await _db.insert(DatabaseHelper.tableMembers, member.toMap());
    return member;
  }

  Future<void> updateMember(MemberModel member) async {
    await _db.update(
      DatabaseHelper.tableMembers,
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  /// Deletes a member. Cascades to expense_participants rows.
  Future<void> deleteMember(String id) async {
    await _db.delete(
      DatabaseHelper.tableMembers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
