import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Controller para manejar la edición de ejercicios en modo entrenamiento
class TrainingExerciseEditorController extends GetxController {
  // TextControllers para ejercicios de fuerza
  final weightController = TextEditingController();
  final repsController = TextEditingController();

  // TextControllers para ejercicios de cardio/tiempo
  final distanceController = TextEditingController();
  final durationMinutesController = TextEditingController();
  final durationSecondsController = TextEditingController();

  // Estado observable
  final selectedExercise = Rx<ExerciseTemplate?>(null);
  final currentSets = <SetModel>[].obs;
  final editingSetIndex = Rx<int?>(null);
  final editingExerciseIndex = Rx<int?>(null);

  // Flag para verificar si está disposed
  bool _isDisposed = false;

  // Getters
  bool get hasExerciseSelected => selectedExercise.value != null;
  bool get hasSets => currentSets.isNotEmpty;
  bool get isEditingSet => editingSetIndex.value != null;
  bool get isEditingExercise => editingExerciseIndex.value != null;

  /// Verificar si el ejercicio seleccionado es de cardio
  bool get isCardioExercise =>
      selectedExercise.value?.isCardio ?? false;

  /// Verificar si el ejercicio seleccionado es de tiempo
  bool get isTimeExercise => selectedExercise.value?.isTime ?? false;

  /// Verificar si el ejercicio seleccionado es de fuerza
  bool get isStrengthExercise =>
      selectedExercise.value?.isStrength ?? true;

  double get totalVolume {
    if (_isDisposed) return 0.0;
    return currentSets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );
  }

  @override
  void onClose() {
    _isDisposed = true;
    weightController.dispose();
    repsController.dispose();
    distanceController.dispose();
    durationMinutesController.dispose();
    durationSecondsController.dispose();
    super.onClose();
  }

  /// Seleccionar un ejercicio para configurar
  void selectExercise(ExerciseTemplate exercise) {
    if (_isDisposed) return;

    selectedExercise.value = exercise;
    currentSets.clear();

    if (!_isDisposed) {
      _clearAllInputs();
    }

    editingSetIndex.value = null;
    editingExerciseIndex.value = null;
  }

  /// Limpiar todos los campos de entrada
  void _clearAllInputs() {
    if (_isDisposed) return;

    weightController.clear();
    repsController.clear();
    distanceController.clear();
    durationMinutesController.clear();
    durationSecondsController.clear();
  }

  /// Agregar o actualizar una serie
  void addOrUpdateSet() {
    if (_isDisposed) return;

    SetModel? newSet;

    // Determinar qué tipo de set crear según el ejercicio
    if (isCardioExercise) {
      // Ejercicio de cardio: distancia + duración
      final distance = double.tryParse(distanceController.text);
      final minutes = int.tryParse(durationMinutesController.text) ?? 0;
      final seconds = int.tryParse(durationSecondsController.text) ?? 0;
      final totalSeconds = (minutes * 60) + seconds;

      if (distance != null && distance > 0 && totalSeconds > 0) {
        newSet = SetModel.cardio(
          distance: distance,
          duration: totalSeconds,
        );
      }
    } else if (isTimeExercise) {
      // Ejercicio de tiempo: solo duración
      final minutes = int.tryParse(durationMinutesController.text) ?? 0;
      final seconds = int.tryParse(durationSecondsController.text) ?? 0;
      final totalSeconds = (minutes * 60) + seconds;

      if (totalSeconds > 0) {
        newSet = SetModel.time(duration: totalSeconds);
      }
    } else {
      // Ejercicio de fuerza: peso + reps
      final weight = double.tryParse(weightController.text);
      final reps = int.tryParse(repsController.text);

      if (weight != null && weight > 0 && reps != null && reps > 0) {
        newSet = SetModel.strength(weight: weight, reps: reps);
      }
    }

    // Si se creó un set válido, agregarlo o actualizar
    if (newSet != null) {
      if (editingSetIndex.value != null) {
        // Editando serie existente
        currentSets[editingSetIndex.value!] = newSet;
        editingSetIndex.value = null;
      } else {
        // Agregando nueva serie
        currentSets.add(newSet);
      }

      if (!_isDisposed) {
        _clearAllInputs();
      }
    }
  }

  /// Editar una serie existente
  void editSet(int index) {
    if (_isDisposed) return;

    final set = currentSets[index];
    editingSetIndex.value = index;

    if (set.isCardio) {
      // Set de cardio
      distanceController.text = set.distance?.toString() ?? '';
      final totalSeconds = set.duration ?? 0;
      durationMinutesController.text = (totalSeconds ~/ 60).toString();
      durationSecondsController.text = (totalSeconds % 60).toString();
    } else if (set.isTime) {
      // Set de tiempo
      final totalSeconds = set.duration ?? 0;
      durationMinutesController.text = (totalSeconds ~/ 60).toString();
      durationSecondsController.text = (totalSeconds % 60).toString();
    } else {
      // Set de fuerza
      weightController.text = set.weight.toString();
      repsController.text = set.reps.toString();
    }
  }

  /// Cancelar edición de serie
  void cancelSetEdit() {
    if (_isDisposed) return;

    editingSetIndex.value = null;
    _clearAllInputs();
  }

  /// Eliminar una serie
  void removeSet(int index) {
    if (_isDisposed) return;

    currentSets.removeAt(index);
    if (editingSetIndex.value == index) {
      editingSetIndex.value = null;
      if (!_isDisposed) {
        _clearAllInputs();
      }
    } else if (editingSetIndex.value != null &&
        editingSetIndex.value! > index) {
      editingSetIndex.value = editingSetIndex.value! - 1;
    }
  }

  /// Preparar edición de un ejercicio completo
  void editExercise(
    ExerciseData exercise,
    int exerciseIndex,
    List<ExerciseTemplate> availableExercises,
  ) {
    if (_isDisposed) return;

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

    if (!_isDisposed) {
      _clearAllInputs();
    }
  }

  /// Cancelar configuración de ejercicio
  void cancelExercise() {
    if (_isDisposed) return;

    selectedExercise.value = null;
    currentSets.clear();

    if (!_isDisposed) {
      _clearAllInputs();
    }

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
