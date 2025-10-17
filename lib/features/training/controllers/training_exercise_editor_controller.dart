import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/training/models/exercise_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Controller para manejar la edición de ejercicios en modo entrenamiento
class TrainingExerciseEditorController extends GetxController {
  // TextControllers
  final weightController = TextEditingController();
  final repsController = TextEditingController();

  // Estado observable
  final selectedExercise = Rx<ExerciseTemplate?>(null);
  final currentSets = <SetModel>[].obs;
  final editingSetIndex = Rx<int?>(null);
  final editingExerciseIndex = Rx<int?>(null);

  // Getters
  bool get hasExerciseSelected => selectedExercise.value != null;
  bool get hasSets => currentSets.isNotEmpty;
  bool get isEditingSet => editingSetIndex.value != null;
  bool get isEditingExercise => editingExerciseIndex.value != null;

  double get totalVolume {
    return currentSets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );
  }

  @override
  void onClose() {
    weightController.dispose();
    repsController.dispose();
    super.onClose();
  }

  /// Seleccionar un ejercicio para configurar
  void selectExercise(ExerciseTemplate exercise) {
    selectedExercise.value = exercise;
    currentSets.clear();
    weightController.clear();
    repsController.clear();
    editingSetIndex.value = null;
    editingExerciseIndex.value = null;
  }

  /// Agregar o actualizar una serie
  void addOrUpdateSet() {
    final weight = double.tryParse(weightController.text);
    final reps = int.tryParse(repsController.text);

    if (weight != null && weight > 0 && reps != null && reps > 0) {
      if (editingSetIndex.value != null) {
        // Editando serie existente
        currentSets[editingSetIndex.value!] = SetModel(
          weight: weight,
          reps: reps,
        );
        editingSetIndex.value = null;
      } else {
        // Agregando nueva serie
        currentSets.add(SetModel(weight: weight, reps: reps));
      }
      weightController.clear();
      repsController.clear();
    }
  }

  /// Editar una serie existente
  void editSet(int index) {
    final set = currentSets[index];
    editingSetIndex.value = index;
    weightController.text = set.weight.toString();
    repsController.text = set.reps.toString();
  }

  /// Cancelar edición de serie
  void cancelSetEdit() {
    editingSetIndex.value = null;
    weightController.clear();
    repsController.clear();
  }

  /// Eliminar una serie
  void removeSet(int index) {
    currentSets.removeAt(index);
    if (editingSetIndex.value == index) {
      editingSetIndex.value = null;
      weightController.clear();
      repsController.clear();
    } else if (editingSetIndex.value != null && editingSetIndex.value! > index) {
      editingSetIndex.value = editingSetIndex.value! - 1;
    }
  }

  /// Preparar edición de un ejercicio completo
  void editExercise(ExerciseData exercise, int exerciseIndex, List<ExerciseTemplate> availableExercises) {
    // Buscar el template del ejercicio
    final template = availableExercises.firstWhere(
      (e) => e.name == exercise.name,
      orElse: () => availableExercises.first,
    );

    selectedExercise.value = template;
    currentSets.clear();
    currentSets.addAll(exercise.sets);
    editingSetIndex.value = null;
    editingExerciseIndex.value = exerciseIndex;
    weightController.clear();
    repsController.clear();
  }

  /// Cancelar configuración de ejercicio
  void cancelExercise() {
    selectedExercise.value = null;
    currentSets.clear();
    weightController.clear();
    repsController.clear();
    editingSetIndex.value = null;
    editingExerciseIndex.value = null;
  }

  /// Obtener el ejercicio configurado para guardar
  ExerciseData? getConfiguredExercise() {
    if (selectedExercise.value != null && currentSets.isNotEmpty) {
      return ExerciseData(
        name: selectedExercise.value!.name,
        sets: List.from(currentSets),
      );
    }
    return null;
  }

  /// Reset completo del estado
  void reset() {
    cancelExercise();
  }
}

