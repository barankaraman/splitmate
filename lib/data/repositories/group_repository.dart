import '../database/database_helper.dart';
import '../models/group_model.dart';

/// All database operations for the [GroupModel] entity.
class GroupRepository {
  final DatabaseHelper _db;

  GroupRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  // ─── Read ────────────────────────────────────────────────────────────────────

  /// Returns all groups ordered by newest first.
  Future<List<GroupModel>> getAllGroups() async {
    final rows = await _db.query(
      DatabaseHelper.tableGroups,
      orderBy: 'created_at DESC',
    );
    return rows.map(GroupModel.fromMap).toList();
  }

  /// Returns a single group by its [id], or null if not found.
  Future<GroupModel?> getGroupById(String id) async {
    final rows = await _db.query(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return GroupModel.fromMap(rows.first);
  }

  // ─── Write ───────────────────────────────────────────────────────────────────

  /// Inserts a new group. Returns the inserted model unchanged.
  Future<GroupModel> insertGroup(GroupModel group) async {
    await _db.insert(DatabaseHelper.tableGroups, group.toMap());
    return group;
  }

  /// Updates the [group]'s name and description.
  Future<void> updateGroup(GroupModel group) async {
    await _db.update(
      DatabaseHelper.tableGroups,
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  /// Deletes a group and all cascaded data (members, expenses, participants).
  Future<void> deleteGroup(String id) async {
    await _db.delete(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
