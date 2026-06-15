class ProductTax {
  final int id;
  final String name;
  final double amount;

  const ProductTax({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory ProductTax.fromJson(Map<String, dynamic> json) {
    return ProductTax(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}