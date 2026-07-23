import '../models/ingredient.dart';
import 'api_client.dart';

class IngredientService {
  static Future<List<Ingredient>> getIngredients() async {
    final data = await ApiClient.get('/ingredients') as List<dynamic>;
    return data.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Ingredient> createIngredient(Ingredient ingredient) async {
    final data = await ApiClient.post('/ingredients', ingredient.toMap());
    return Ingredient.fromJson(data as Map<String, dynamic>);
  }

  static Future<Ingredient> updateIngredient(int id, Ingredient ingredient) async {
    final data = await ApiClient.put('/ingredients/$id', ingredient.toMap());
    return Ingredient.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteIngredient(int id) async {
    await ApiClient.delete('/ingredients/$id');
  }
}
