import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/models/streak_model.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/streak_service.dart';
import 'package:tribbe_app/shared/services/workout_service.dart';

/// Controlador para el Dashboard (Home principal)
class DashboardController extends GetxController {
  // Dependencias
  final StreakService _streakService = Get.find<StreakService>();
  final WorkoutService _workoutService = Get.find<WorkoutService>();
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  // Observables
  final Rx<StreakModel> streak = StreakModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool isFeedLoading = false.obs;
  final RxList<WorkoutPostModel> feedPosts = <WorkoutPostModel>[].obs;

  // Getters
  bool get hasTrainedToday => streak.value.hasTrainedToday();
  int get currentStreak => streak.value.currentStreak;
  int get longestStreak => streak.value.longestStreak;
  List<bool> get weeklyStreak => streak.value.weeklyStreak;

  @override
  void onInit() {
    super.onInit();
    loadStreak();
    loadFeed();
  }

  /// Cargar la racha desde el almacenamiento
  void loadStreak() {
    try {
      isLoading.value = true;
      final loadedStreak = _streakService.getStreak();
      streak.value = loadedStreak;
    } catch (e) {
      print('Error al cargar racha: $e');
      _showError('No se pudo cargar tu racha');
    } finally {
      isLoading.value = false;
    }
  }

  /// Registrar un entrenamiento
  Future<void> registerWorkout() async {
    try {
      isLoading.value = true;

      // Si ya entrenó hoy, mostrar mensaje
      if (hasTrainedToday) {
        _showInfo('Ya registraste tu entrenamiento hoy 💪');
        return;
      }

      // Registrar el entrenamiento
      final updatedStreak = await _streakService.registerWorkout();
      streak.value = updatedStreak;

      // Mostrar mensaje de éxito
      _showSuccess('¡Entrenamiento registrado! 🔥');

      // Si es un nuevo récord, celebrar
      if (updatedStreak.currentStreak == updatedStreak.longestStreak &&
          updatedStreak.currentStreak > 1) {
        _showSuccess(
          '¡Nuevo récord de racha: ${updatedStreak.currentStreak} días! 🎉',
        );
      }
    } catch (e) {
      print('Error al registrar entrenamiento: $e');
      _showError('No se pudo registrar el entrenamiento');
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar manualmente la racha
  Future<void> refreshStreak() async {
    loadStreak();
  }

  /// Cargar feed de posts
  Future<void> loadFeed() async {
    try {
      isFeedLoading.value = true;
      final posts = await _workoutService.getFeedPosts(limit: 20);
      feedPosts.value = posts;
    } catch (e) {
      print('Error al cargar feed: $e');
      _showError('No se pudo cargar el feed');
    } finally {
      isFeedLoading.value = false;
    }
  }

  /// Refrescar feed
  Future<void> refreshFeed() async {
    await loadFeed();
  }

  /// Dar/quitar like a un post
  Future<void> toggleLike(String postId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Actualizar UI optimistamente
      final index = feedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        feedPosts[index] = feedPosts[index].toggleLike(userId);
      }

      // Actualizar en Firebase
      await _workoutService.toggleLike(postId: postId, userId: userId);
    } catch (e) {
      print('Error al dar like: $e');
      _showError('No se pudo dar like');
      // Revertir cambio en caso de error
      loadFeed();
    }
  }

  // ========== UTILIDADES ==========

  void _showSuccess(String message) {
    Get.snackbar(
      '¡Éxito!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
