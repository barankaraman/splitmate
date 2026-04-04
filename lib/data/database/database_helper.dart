import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton database helper.
/// Manages the SQLite connection, schema creation, and migrations.
class DatabaseHelper {
  // ─── Singleton ──────────────────────────────────────────────────────────────

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  // ─── Constants ───────────────────────────────────────────────────────────────

  static const String _dbName = 'splitmate.db';
  static const int _dbVersion = 1;

  // Table names
  static const String tableGroups = 'groups';
  static const String tableMembers = 'members';
  static const String tableExpenses = 'expenses';
  static const String tableExpenseParticipants = 'expense_participants';

  // ─── Initialisation ──────────────────────────────────────────────────────────

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // Enable foreign-key constraints on every connection.
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  /// Creates all tables on first launch.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGroups (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        description  TEXT NOT NULL DEFAULT '',
        created_at   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMembers (
        id         TEXT PRIMARY KEY,
        group_id   TEXT NOT NULL,
        name       TEXT NOT NULL,
        joined_at  TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES $tableGroups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableExpenses (
        id              TEXT PRIMARY KEY,
        group_id        TEXT NOT NULL,
        title           TEXT NOT NULL,
        amount          REAL NOT NULL,
        payer_id        TEXT NOT NULL,
        created_at      TEXT NOT NULL,
        latitude        REAL,
        longitude       REAL,
        location_label  TEXT,
        FOREIGN KEY (group_id)  REFERENCES $tableGroups(id)  ON DELETE CASCADE,
        FOREIGN KEY (payer_id)  REFERENCES $tableMembers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableExpenseParticipants (
        expense_id  TEXT NOT NULL,
        member_id   TEXT NOT NULL,
        PRIMARY KEY (expense_id, member_id),
        FOREIGN KEY (expense_id) REFERENCES $tableExpenses(id) ON DELETE CASCADE,
        FOREIGN KEY (member_id)  REFERENCES $tableMembers(id)  ON DELETE CASCADE
      )
    ''');
  }

  /// Called when _dbVersion is bumped; add ALTER TABLE statements here.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will go here.
  }

  // ─── Generic helpers ─────────────────────────────────────────────────────────

  /// Insert a row; returns the row id.
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Query all rows for [table] that match optional [where] / [whereArgs].
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  /// Update rows in [table] matching [where].
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Delete rows from [table] matching [where].
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Run multiple operations atomically.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// Close the database (used in tests / app shutdown).
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
