import 'package:get/get.dart';
import 'package:tribbe_app/shared/data/exercises_data.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Controlador para la biblioteca de ejercicios
class ExercisesController extends GetxController {
  // Ejercicios disponibles
  final RxList<ExerciseTemplate> exercises = <ExerciseTemplate>[].obs;
  final RxList<ExerciseTemplate> filteredExercises = <ExerciseTemplate>[].obs;

  // Filtros
  final RxString selectedMuscleGroup = ''.obs;
  final RxList<String> selectedEquipment = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedDifficulty = ''.obs;

  // Estado
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();

    // Escuchar cambios en filtros
    ever(selectedMuscleGroup, (_) => applyFilters());
    ever(selectedEquipment, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(selectedDifficulty, (_) => applyFilters());
  }

  /// Cargar todos los ejercicios
  void loadExercises() {
    isLoading.value = true;
    exercises.value = ExercisesData.exercises;
    filteredExercises.value = ExercisesData.exercises;
    isLoading.value = false;
  }

  /// Aplicar filtros
  void applyFilters() {
    List<ExerciseTemplate> result = exercises;

    // Filtro por grupo muscular
    if (selectedMuscleGroup.value.isNotEmpty) {
      result = result.where((exercise) {
        return exercise.muscleGroup == selectedMuscleGroup.value ||
            exercise.secondaryMuscles.contains(selectedMuscleGroup.value);
      }).toList();
    }

    // Filtro por equipamiento
    if (selectedEquipment.isNotEmpty) {
      result = result.where((exercise) {
        return selectedEquipment.contains(exercise.equipment);
      }).toList();
    }

    // Filtro por dificultad
    if (selectedDifficulty.value.isNotEmpty) {
      result = result.where((exercise) {
        return exercise.difficulty == selectedDifficulty.value;
      }).toList();
    }

    // Filtro por búsqueda
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((exercise) {
        return exercise.name.toLowerCase().contains(query) ||
            exercise.muscleGroup.toLowerCase().contains(query);
      }).toList();
    }

    filteredExercises.value = result;
  }

  /// Establecer grupo muscular
  void setMuscleGroup(String? group) {
    selectedMuscleGroup.value = group ?? '';
  }

  /// Toggle equipamiento
  void toggleEquipment(String equipment) {
    if (selectedEquipment.contains(equipment)) {
      selectedEquipment.remove(equipment);
    } else {
      selectedEquipment.add(equipment);
    }
  }

  /// Establecer dificultad
  void setDifficulty(String? difficulty) {
    selectedDifficulty.value = difficulty ?? '';
  }

  /// Establecer búsqueda
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Limpiar filtros
  void clearFilters() {
    selectedMuscleGroup.value = '';
    selectedEquipment.clear();
    selectedDifficulty.value = '';
    searchQuery.value = '';
  }

  /// Obtener ejercicio por ID
  ExerciseTemplate? getExerciseById(String id) {
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener ejercicios por grupo muscular
  List<ExerciseTemplate> getByMuscleGroup(String muscleGroup) {
    return exercises.where((exercise) {
      return exercise.muscleGroup == muscleGroup ||
          exercise.secondaryMuscles.contains(muscleGroup);
    }).toList();
  }

  /// Obtener ejercicios recomendados (populares)
  List<ExerciseTemplate> getRecommended({int limit = 5}) {
    // Por ahora retornamos los primeros, en el futuro podríamos usar analytics
    return exercises.take(limit).toList();
  }

  /// Buscar ejercicios
  List<ExerciseTemplate> searchExercises(String query) {
    return ExercisesData.search(query);
  }
}
