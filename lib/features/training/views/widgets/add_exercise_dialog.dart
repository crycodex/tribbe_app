import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Diálogo para agregar ejercicio
class AddExerciseDialog extends StatefulWidget {
  final TrainingController controller;

  const AddExerciseDialog({super.key, required this.controller});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _nameController = TextEditingController();
  final List<SetData> _sets = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Agregar Ejercicio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // Nombre del ejercicio
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del ejercicio',
                hintText: 'Ej: Press Banca',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 24),

            // Lista de series
            if (_sets.isNotEmpty) ...[
              Text(
                'Series (${_sets.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    final set = _sets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      child: ListTile(
                        title: Text(
                          'Serie ${index + 1}: ${set.weight} kg × ${set.reps} reps',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _sets.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón agregar serie
            OutlinedButton.icon(
              onPressed: () => _showAddSetDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Serie'),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sets.isEmpty
                      ? null
                      : () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ingresa el nombre del ejercicio',
                                ),
                              ),
                            );
                            return;
                          }

                          widget.controller.addExercise(
                            name: _nameController.text.trim(),
                            sets: _sets
                                .map(
                                  (s) =>
                                      SetModel(weight: s.weight, reps: s.reps),
                                )
                                .toList(),
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo para agregar serie
  void _showAddSetDialog(BuildContext context) {
    final weightController = TextEditingController();
    final repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Serie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(
                labelText: 'Repeticiones',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final reps = int.tryParse(repsController.text);

              if (weight == null || weight <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Peso inválido')));
                return;
              }

              if (reps == null || reps <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Repeticiones inválidas')),
                );
                return;
              }

              setState(() {
                _sets.add(SetData(weight: weight, reps: reps));
              });
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

/// Clase auxiliar para datos de serie
class SetData {
  final double weight;
  final int reps;

  SetData({required this.weight, required this.reps});
}
