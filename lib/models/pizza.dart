import 'pizza_ingredient.dart';

class Pizza {
  final int? pizId;
  final String pizName;
  final String pizOrigin;
  final bool pizState;
  final List<PizzaIngredient> ingredients;

  Pizza({
    this.pizId,
    required this.pizName,
    required this.pizOrigin,
    this.pizState = true,
    this.ingredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'piz_name': pizName,
      'piz_origin': pizOrigin,
      'piz_state': pizState,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
    };
  }

  factory Pizza.fromJson(Map<String, dynamic> json) {
    return Pizza(
      pizId: json['piz_id'] as int?,
      pizName: json['piz_name'] as String,
      pizOrigin: json['piz_origin'] as String,
      pizState: json['piz_state'] as bool? ?? true,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => PizzaIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
