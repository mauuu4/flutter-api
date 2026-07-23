class Ingredient {
  final int? ingId;
  final String ingName;
  final double ingCalories;
  final bool ingState;

  Ingredient({
    this.ingId,
    required this.ingName,
    required this.ingCalories,
    this.ingState = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'ing_name': ingName,
      'ing_calories': ingCalories,
      'ing_state': ingState,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingId: json['ing_id'] as int?,
      ingName: json['ing_name'] as String,
      ingCalories: (json['ing_calories'] as num).toDouble(),
      ingState: json['ing_state'] as bool? ?? true,
    );
  }
}
