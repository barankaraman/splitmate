/// Represents a member belonging to a specific group.
class MemberModel {
  final String id;
  final String groupId;
  final String name;
  final DateTime joinedAt;

  const MemberModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'joined_at': joinedAt.toIso8601String(),
      };

  factory MemberModel.fromMap(Map<String, dynamic> map) => MemberModel(
        id: map['id'] as String,
        groupId: map['group_id'] as String,
        name: map['name'] as String,
        joinedAt: DateTime.parse(map['joined_at'] as String),
      );

  MemberModel copyWith({
    String? id,
    String? groupId,
    String? name,
    DateTime? joinedAt,
  }) =>
      MemberModel(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        name: name ?? this.name,
        joinedAt: joinedAt ?? this.joinedAt,
      );

  @override
  String toString() => 'MemberModel(id: $id, name: $name, groupId: $groupId)';
}
