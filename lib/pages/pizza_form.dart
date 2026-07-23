import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/pizza.dart';
import '../models/pizza_ingredient.dart';
import '../services/ingredient_service.dart';
import '../services/pizza_service.dart';
import '../services/api_client.dart';

class PizzaFormPage extends StatefulWidget {
  final Pizza? pizza;
  const PizzaFormPage({super.key, this.pizza});

  @override
  State<PizzaFormPage> createState() => _PizzaFormPageState();
}

class _PizzaFormPageState extends State<PizzaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _origenController;
  bool _activo = true;
  bool _saving = false;

  late Future<List<Ingredient>> _ingredientsFuture;
  final Map<int, bool> _selected = {};
  final Map<int, TextEditingController> _cantidadControllers = {};

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.pizza?.pizName ?? '');
    _origenController = TextEditingController(text: widget.pizza?.pizOrigin ?? '');
    _activo = widget.pizza?.pizState ?? true;
    _ingredientsFuture = IngredientService.getIngredients();

    for (final pi in widget.pizza?.ingredients ?? const <PizzaIngredient>[]) {
      _selected[pi.ingId] = true;
      _cantidadControllers[pi.ingId] = TextEditingController(text: pi.ingQuantity.toString());
    }
  }

  TextEditingController _controllerFor(int ingId) {
    return _cantidadControllers.putIfAbsent(
      ingId,
      () => TextEditingController(text: '1'),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _origenController.dispose();
    for (final c in _cantidadControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = <PizzaIngredient>[];
    for (final entry in _selected.entries) {
      if (entry.value != true) continue;
      final cantidad = int.tryParse(_controllerFor(entry.key).text.trim()) ?? 1;
      ingredients.add(PizzaIngredient(ingId: entry.key, ingName: '', ingQuantity: cantidad));
    }

    setState(() => _saving = true);
    try {
      final pizza = Pizza(
        pizName: _nombreController.text.trim(),
        pizOrigin: _origenController.text.trim(),
        pizState: _activo,
        ingredients: ingredients,
      );
      if (widget.pizza == null) {
        await PizzaService.createPizza(pizza);
      } else {
        await PizzaService.updatePizza(widget.pizza!.pizId!, pizza);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pizza != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar pizza' : 'Nueva pizza')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Margarita, Hawaiana',
                prefixIcon: Icon(Icons.local_pizza),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _origenController,
              decoration: InputDecoration(
                labelText: 'Origen',
                hintText: 'Ej. Italia, Estados Unidos',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa un origen' : null,
            ),
            SwitchListTile(
              title: Text('Activa'),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
            ),
            SizedBox(height: 12),
            Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 4),
            FutureBuilder<List<Ingredient>>(
              future: _ingredientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error cargando ingredientes: ${snapshot.error}');
                }
                final ingredients = snapshot.data ?? [];
                if (ingredients.isEmpty) {
                  return Text('No hay ingredientes disponibles. Crea alguno primero.');
                }
                return Column(
                  children: ingredients.map((ingredient) {
                    final ingId = ingredient.ingId!;
                    final checked = _selected[ingId] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: checked,
                              onChanged: (v) => setState(() => _selected[ingId] = v ?? false),
                            ),
                            Expanded(
                              child: Text(
                                '${ingredient.ingName} (${ingredient.ingCalories.toStringAsFixed(0)} kcal)',
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _controllerFor(ingId),
                                enabled: checked,
                                decoration: InputDecoration(
                                  labelText: 'Cant.',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (!checked) return null;
                                  if (v == null || v.trim().isEmpty) return 'Req.';
                                  if (int.tryParse(v.trim()) == null) return 'Inv.';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.check),
                label: Text(isEditing ? 'Guardar cambios' : 'Crear pizza'),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
