import 'dart:async';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/data/exercises_data.dart';
import 'package:tribbe_app/features/training/models/exercise_model.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/workout_service.dart';
import 'package:tribbe_app/shared/services/streak_service.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';

/// Controlador para el modo entrenamiento
class TrainingController extends GetxController {
  final WorkoutService _workoutService = Get.find();
  final FirebaseAuthService _authService = Get.find();
  final StreakService _streakService = Get.find();
  final AuthController _authController = Get.find<AuthController>();

  // Estado del entrenamiento
  final isTraining = false.obs;
  final isLoading = false.obs;
  final isPaused = false.obs;

  // Timer
  final elapsedSeconds = 0.obs;
  Timer? _timer;

  // Datos del entrenamiento actual
  final focusType = 'Fuerza'.obs;
  final exercises = <ExerciseData>[].obs;
  final currentExerciseName = ''.obs;
  final currentSets = <SetModel>[].obs;

  // Filtros de ejercicios
  String? selectedMuscleGroup;
  List<String>? selectedEquipment;
  final RxList<ExerciseTemplate> availableExercises = <ExerciseTemplate>[].obs;

  // Lista de enfoques disponibles
  final List<String> focusTypes = [
    'Fuerza',
    'Hipertrofia',
    'Resistencia',
    'Cardio',
    'Funcional',
    'CrossFit',
    'Calistenia',
    'Otro',
  ];

  @override
  void onInit() {
    super.onInit();

    // Obtener parámetros de navegación
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedMuscleGroup = args['muscleGroup'] as String?;
      selectedEquipment = args['equipment'] as List<String>?;
    }

    // Cargar ejercicios filtrados
    _loadAvailableExercises();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Cargar ejercicios disponibles según filtros
  void _loadAvailableExercises() {
    availableExercises.value = ExercisesData.getFiltered(
      muscleGroup: selectedMuscleGroup,
      equipment: selectedEquipment,
    );
  }

  /// Iniciar entrenamiento
  void startTraining({String? focus}) {
    if (isTraining.value) return;

    isTraining.value = true;
    isPaused.value = false;
    elapsedSeconds.value = 0;
    exercises.clear();
    
    // Establecer enfoque si se proporciona
    if (focus != null) {
      focusType.value = focus;
    }

    _startTimer();
  }

  /// Pausar/Reanudar entrenamiento
  void togglePause() {
    if (!isTraining.value) return;

    isPaused.value = !isPaused.value;

    if (isPaused.value) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  /// Finalizar entrenamiento
  Future<void> finishTraining({String? caption}) async {
    if (!isTraining.value) return;

    try {
      isLoading.value = true;
      _stopTimer();

      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Convertir ejercicios a modelo
      final exerciseModels = exercises
          .map((e) => ExerciseModel(name: e.name, sets: e.sets))
          .toList();

      if (exerciseModels.isEmpty) {
        Get.snackbar(
          'Error',
          'Debes agregar al menos un ejercicio',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Obtener el nombre real del usuario desde el perfil
      String userName = 'Usuario'; // Valor por defecto
      String? userPhotoUrl = user.photoURL;

      final userProfile = _authController.userProfile.value;
      if (userProfile?.datosPersonales?.nombreCompleto != null &&
          userProfile!.datosPersonales!.nombreCompleto!.isNotEmpty) {
        userName = userProfile.datosPersonales!.nombreCompleto!;
      } else if (userProfile?.datosPersonales?.nombreUsuario != null &&
          userProfile!.datosPersonales!.nombreUsuario!.isNotEmpty) {
        userName = userProfile.datosPersonales!.nombreUsuario!;
      }

      // Obtener foto de perfil desde el perfil si no está en Auth
      if (userProfile?.personaje?.avatarUrl != null &&
          userProfile!.personaje!.avatarUrl!.isNotEmpty) {
        userPhotoUrl = userProfile.personaje!.avatarUrl;
      }

      // Crear entrenamiento
      final workout = await _workoutService.createWorkout(
        userId: user.uid,
        userName: userName,
        focus: focusType.value,
        duration: (elapsedSeconds.value / 60).ceil(),
        exercises: exerciseModels,
      );

      // Crear post en el feed
      await _workoutService.createWorkoutPost(
        workout: workout,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        caption: caption,
      );

      // Registrar entrenamiento para la racha
      await _streakService.registerWorkout();

      // Resetear estado
      _resetState();

      Get.snackbar(
        'Entrenamiento Completado',
        '¡Excelente trabajo! Tu entrenamiento ha sido registrado.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Volver atrás
      Get.offAllNamed(RoutePaths.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el entrenamiento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancelar entrenamiento
  void cancelTraining() {
    _stopTimer();
    _resetState();
    Get.back();
  }

  /// Agregar ejercicio
  void addExercise({required String name, required List<SetModel> sets}) {
    if (name.trim().isEmpty || sets.isEmpty) {
      Get.snackbar(
        'Error',
        'Completa todos los datos del ejercicio',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    exercises.add(ExerciseData(name: name, sets: sets));
    currentExerciseName.value = '';
    currentSets.clear();

    Get.snackbar(
      'Ejercicio Agregado',
      '$name - ${sets.length} series',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Eliminar ejercicio
  void removeExercise(int index) {
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
    }
  }

  /// Agregar serie al ejercicio actual
  void addSet({required double weight, required int reps}) {
    if (weight <= 0 || reps <= 0) {
      Get.snackbar(
        'Error',
        'Peso y repeticiones deben ser mayores a 0',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentSets.add(SetModel(weight: weight, reps: reps));
  }

  /// Eliminar serie
  void removeSet(int index) {
    if (index >= 0 && index < currentSets.length) {
      currentSets.removeAt(index);
    }
  }

  /// Cambiar enfoque
  void changeFocus(String focus) {
    focusType.value = focus;
  }

  /// Iniciar timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        elapsedSeconds.value++;
      }
    });
  }

  /// Detener timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resetear estado
  void _resetState() {
    isTraining.value = false;
    isPaused.value = false;
    elapsedSeconds.value = 0;
    exercises.clear();
    currentExerciseName.value = '';
    currentSets.clear();
    focusType.value = 'Fuerza';
  }

  /// Formatear tiempo transcurrido
  String get formattedTime {
    final hours = (elapsedSeconds.value / 3600).floor();
    final minutes = ((elapsedSeconds.value % 3600) / 60).floor();
    final seconds = elapsedSeconds.value % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calcular volumen total actual
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  /// Calcular total de series actual
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  }
}

/// Clase auxiliar para datos de ejercicio
class ExerciseData {
  final String name;
  final List<SetModel> sets;

  ExerciseData({required this.name, required this.sets});

  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }
}
