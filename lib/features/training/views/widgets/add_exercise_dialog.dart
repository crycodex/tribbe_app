import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Diálogo para agregar ejercicio (con lista de ejercicios)
class AddExerciseDialog extends StatefulWidget {
  final TrainingController controller;

  const AddExerciseDialog({super.key, required this.controller});

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final _searchController = TextEditingController();
  final List<SetData> _sets = [];
  ExerciseTemplate? _selectedExercise;
  List<ExerciseTemplate> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _filteredExercises = widget.controller.availableExercises;
    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = widget.controller.availableExercises;
      } else {
        _filteredExercises = widget.controller.availableExercises
            .where((ex) => ex.name.toLowerCase().contains(query))
            .toList();
      }
    });
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

            // Búsqueda de ejercicio
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar ejercicio',
                hintText: 'Escribe para buscar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de ejercicios o ejercicio seleccionado
            if (_selectedExercise == null)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return ListTile(
                      dense: true,
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.muscleGroup} - ${exercise.equipment}',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedExercise = exercise;
                          _searchController.text = exercise.name;
                        });
                      },
                    );
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedExercise!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_selectedExercise!.muscleGroup} - ${_selectedExercise!.equipment}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedExercise = null;
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
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
                  onPressed: _sets.isEmpty || _selectedExercise == null
                      ? null
                      : () {
                          widget.controller.addExercise(
                            name: _selectedExercise!.name,
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
