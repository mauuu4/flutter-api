import 'package:flutter/material.dart';
import '../models/pizza.dart';
import '../services/pizza_service.dart';
import '../services/api_client.dart';
import 'pizza_form.dart';

class PizzaListPage extends StatefulWidget {
  const PizzaListPage({super.key});

  @override
  State<PizzaListPage> createState() => _PizzaListPageState();
}

class _PizzaListPageState extends State<PizzaListPage> {
  late Future<List<Pizza>> _pizzasFuture;

  @override
  void initState() {
    super.initState();
    _pizzasFuture = PizzaService.getPizzas();
  }

  Future<void> _load() async {
    setState(() {
      _pizzasFuture = PizzaService.getPizzas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Pizza>>(
        future: _pizzasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_pizza, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay pizzas registradas.\nToca el botón + para crear una.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final pizzas = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: pizzas.length,
              itemBuilder: (context, index) {
                final pizza = pizzas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: pizza.pizState
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.grey.shade300,
                            child: Icon(
                              Icons.local_pizza,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(pizza.pizName, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${pizza.pizOrigin} · ${pizza.pizState ? "Activa" : "Inactiva"}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () async {
                                  final result = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => PizzaFormPage(pizza: pizza),
                                    ),
                                  );
                                  if (result == true) await _load();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirmar'),
                                      content: Text('¿Eliminar la pizza ${pizza.pizName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && pizza.pizId != null) {
                                    try {
                                      await PizzaService.deletePizza(pizza.pizId!);
                                      await _load();
                                    } on ApiException catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text(e.message)));
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        if (pizza.ingredients.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 10, right: 8),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: pizza.ingredients
                                  .map((i) => Chip(
                                        label: Text('${i.ingName} (${i.ingQuantity})'),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => PizzaFormPage()),
          );
          if (result == true) await _load();
        },
        icon: Icon(Icons.add),
        label: Text('Nueva pizza'),
      ),
    );
  }
}
