class PosCategory {
  final int id;
  final String name;

  const PosCategory({
    required this.id,
    required this.name,
  });

  factory PosCategory.fromJson(Map<String, dynamic> json) {
    return PosCategory(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}