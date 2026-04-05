/// Represents a group of people sharing expenses (e.g. "Bali Trip").
class GroupModel {
  final String id;
  final String ownerId; // Username of the creator
  final String name;
  final String description;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  factory GroupModel.fromMap(Map<String, dynamic> map) => GroupModel(
        id: map['id'] as String,
        ownerId: map['owner_id'] as String? ?? '',
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  GroupModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) =>
      GroupModel(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'GroupModel(id: $id, name: $name, owner: $ownerId)';
}
