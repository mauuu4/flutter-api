class PizzaIngredient {
  final int ingId;
  final String ingName;
  final int ingQuantity;

  PizzaIngredient({
    required this.ingId,
    required this.ingName,
    required this.ingQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'ing_id': ingId,
      'ing_quantity': ingQuantity,
    };
  }

  factory PizzaIngredient.fromJson(Map<String, dynamic> json) {
    return PizzaIngredient(
      ingId: json['ing_id'] as int,
      ingName: json['ing_name'] as String,
      ingQuantity: (json['pizzaIngredient']?['ing_quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
