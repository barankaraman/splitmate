/// Represents a single expense within a group.
class ExpenseModel {
  final String id;
  final String groupId;
  final String title;
  final double amount;

  /// ID of the member who paid.
  final String payerId;

  final DateTime createdAt;

  /// Optional latitude of the location where the expense occurred.
  final double? latitude;

  /// Optional longitude of the location where the expense occurred.
  final double? longitude;

  /// Human-readable location label (set by reverse geocoding or user).
  final String? locationLabel;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'amount': amount,
        'payer_id': payerId,
        'created_at': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'location_label': locationLabel,
      };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id: map['id'] as String,
        groupId: map['group_id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        payerId: map['payer_id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        latitude: map['latitude'] != null
            ? (map['latitude'] as num).toDouble()
            : null,
        longitude: map['longitude'] != null
            ? (map['longitude'] as num).toDouble()
            : null,
        locationLabel: map['location_label'] as String?,
      );

  ExpenseModel copyWith({
    String? id,
    String? groupId,
    String? title,
    double? amount,
    String? payerId,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        payerId: payerId ?? this.payerId,
        createdAt: createdAt ?? this.createdAt,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        locationLabel: locationLabel ?? this.locationLabel,
      );

  @override
  String toString() =>
      'ExpenseModel(id: $id, title: $title, amount: $amount)';
}
