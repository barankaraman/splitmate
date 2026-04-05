import '../database/database_helper.dart';
import '../models/group_model.dart';

/// All database operations for the [GroupModel] entity.
class GroupRepository {
  final DatabaseHelper _db;

  GroupRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  // ─── Read ────────────────────────────────────────────────────────────────────

  /// Returns all groups in the database.
  Future<List<GroupModel>> getAllGroups() async {
    final rows = await _db.query(
      DatabaseHelper.tableGroups,
      orderBy: 'created_at DESC',
    );
    return rows.map(GroupModel.fromMap).toList();
  }

  /// Returns all groups for a specific owner, ordered by newest first.
  Future<List<GroupModel>> getGroupsByOwner(String ownerId) async {
    final rows = await _db.query(
      DatabaseHelper.tableGroups,
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(GroupModel.fromMap).toList();
  }

  /// Returns all groups where the user is a member or owner.
  Future<List<GroupModel>> getGroupsForUser(String username) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT g.* FROM ${DatabaseHelper.tableGroups} g
      LEFT JOIN ${DatabaseHelper.tableMembers} m ON g.id = m.group_id
      WHERE g.owner_id = ? OR m.name = ?
      ORDER BY g.created_at DESC
    ''', [username, username]);
    
    return rows.map(GroupModel.fromMap).toList();
  }

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

  Future<GroupModel> insertGroup(GroupModel group) async {
    await _db.insert(DatabaseHelper.tableGroups, group.toMap());
    return group;
  }

  Future<void> updateGroup(GroupModel group) async {
    await _db.update(
      DatabaseHelper.tableGroups,
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteGroup(String id) async {
    await _db.delete(
      DatabaseHelper.tableGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
