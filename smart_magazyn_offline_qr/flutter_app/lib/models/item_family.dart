class ItemFamily {
  final int id;
  final String name;
  final String? description;

  ItemFamily({required this.id, required this.name, this.description});

  factory ItemFamily.fromMap(Map<String, Object?> map) => ItemFamily(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String?,
      );
}
