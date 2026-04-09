class Category {
  final int? id;
  final String name;
  final String icon;
  final String sport;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.sport,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'sport': sport,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      sport: map['sport'] as String,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? sport,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sport: sport ?? this.sport,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name, sport: $sport)';
}
