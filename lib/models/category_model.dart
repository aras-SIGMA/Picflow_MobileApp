class CategoryModel {
  final int idCategory;
  final String name;
  final String? slug;
  final String? createdAt;

  const CategoryModel({
    required this.idCategory,
    required this.name,
    this.slug,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      idCategory: json['id_category'] is int
          ? json['id_category'] as int
          : int.tryParse(
                  json['id_category']?.toString() ??
                      json['id']?.toString() ??
                      '0',
                ) ??
                0,
      name: (json['name'] ?? '').toString(),
      slug: json['slug'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category': idCategory,
      'name': name,
      'slug': slug,
      'created_at': createdAt,
    };
  }
}
