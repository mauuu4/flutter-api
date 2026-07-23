import '../models/pizza.dart';
import 'api_client.dart';

class PizzaService {
  static Future<List<Pizza>> getPizzas() async {
    final data = await ApiClient.get('/pizzas') as List<dynamic>;
    return data.map((e) => Pizza.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Pizza> createPizza(Pizza pizza) async {
    final data = await ApiClient.post('/pizzas', pizza.toMap());
    return Pizza.fromJson(data as Map<String, dynamic>);
  }

  static Future<Pizza> updatePizza(int id, Pizza pizza) async {
    final data = await ApiClient.put('/pizzas/$id', pizza.toMap());
    return Pizza.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deletePizza(int id) async {
    await ApiClient.delete('/pizzas/$id');
  }
}
