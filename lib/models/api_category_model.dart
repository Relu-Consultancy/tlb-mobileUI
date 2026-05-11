class ApiSubcategory {
  final int id;
  final String slug;
  final String name;

  const ApiSubcategory({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory ApiSubcategory.fromJson(Map<String, dynamic> json) => ApiSubcategory(
        id: json['id'] as int,
        slug: json['slug'] as String,
        name: json['name'] as String,
      );
}

class ApiCategory {
  final int id;
  final String slug;
  final String name;
  final int sortOrder;
  final List<ApiSubcategory> subcategories;

  const ApiCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    required this.subcategories,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: json['id'] as int,
        slug: json['slug'] as String,
        name: json['name'] as String,
        sortOrder: json['sort_order'] as int,
        subcategories: (json['subcategories'] as List)
            .map((s) => ApiSubcategory.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
