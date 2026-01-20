class CategoryModel {
  final String name;
  final int iconId;

  const CategoryModel({
    required this.name,
    required this.iconId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.name == name &&
        other.iconId == iconId;
  }

  @override
  int get hashCode => name.hashCode ^ iconId.hashCode;
}
