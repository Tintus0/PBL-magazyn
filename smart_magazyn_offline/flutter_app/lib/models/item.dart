class WarehouseItem {
  final int id;
  final String code;
  final String name;
  final String? description;
  final int? familyId;
  final String? familyName;
  final int familyCount;
  final int ownerUserId;
  final String ownerName;
  final int? lastUserId;
  final String? lastUserName;
  final String? location;
  final String status;
  final String? createdAt;

  WarehouseItem({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.familyId,
    this.familyName,
    required this.familyCount,
    required this.ownerUserId,
    required this.ownerName,
    this.lastUserId,
    this.lastUserName,
    this.location,
    required this.status,
    this.createdAt,
  });

  factory WarehouseItem.fromMap(Map<String, Object?> map) => WarehouseItem(
        id: map['id'] as int,
        code: map['code'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        familyId: map['family_id'] as int?,
        familyName: map['family_name'] as String?,
        familyCount: (map['family_count'] as int?) ?? 0,
        ownerUserId: map['owner_user_id'] as int,
        ownerName: map['owner_name'] as String,
        lastUserId: map['last_user_id'] as int?,
        lastUserName: map['last_user_name'] as String?,
        location: map['location'] as String?,
        status: map['status'] as String,
        createdAt: map['created_at'] as String?,
      );
}
