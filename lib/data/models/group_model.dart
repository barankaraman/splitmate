/// Represents a group of people sharing expenses (e.g. "Bali Trip").
class GroupModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  /// Serialize to a SQLite-compatible map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  /// Deserialize from a SQLite row.
  factory GroupModel.fromMap(Map<String, dynamic> map) => GroupModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) =>
      GroupModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'GroupModel(id: $id, name: $name)';
}
