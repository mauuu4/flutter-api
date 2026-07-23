import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../services/ingredient_service.dart';
import '../services/api_client.dart';

class IngredientFormPage extends StatefulWidget {
  final Ingredient? ingredient;
  const IngredientFormPage({super.key, this.ingredient});

  @override
  State<IngredientFormPage> createState() => _IngredientFormPageState();
}

class _IngredientFormPageState extends State<IngredientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _caloriasController;
  bool _activo = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.ingredient?.ingName ?? '');
    _caloriasController =
        TextEditingController(text: widget.ingredient?.ingCalories.toString() ?? '');
    _activo = widget.ingredient?.ingState ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _caloriasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final ingredient = Ingredient(
        ingName: _nombreController.text.trim(),
        ingCalories: double.parse(_caloriasController.text.trim()),
        ingState: _activo,
      );
      if (widget.ingredient == null) {
        await IngredientService.createIngredient(ingredient);
      } else {
        await IngredientService.updateIngredient(widget.ingredient!.ingId!, ingredient);
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
    final isEditing = widget.ingredient != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar ingrediente' : 'Nuevo ingrediente')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Queso mozzarella',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _caloriasController,
                decoration: InputDecoration(
                  labelText: 'Calorías',
                  prefixIcon: Icon(Icons.local_fire_department),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa las calorías';
                  if (double.tryParse(v.trim()) == null) return 'Valor inválido';
                  return null;
                },
              ),
              SizedBox(height: 8),
              SwitchListTile(
                title: Text('Activo'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              SizedBox(height: 20),
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
                  label: Text(isEditing ? 'Guardar cambios' : 'Crear ingrediente'),
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
      ),
    );
  }
}
