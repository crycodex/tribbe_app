import 'dart:async';
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
  StreamSubscription<List<WorkoutPostModel>>? _feedSubscription;

  // Getters
  bool get hasTrainedToday => streak.value.hasTrainedToday();
  int get currentStreak => streak.value.currentStreak;
  int get longestStreak => streak.value.longestStreak;
  List<bool> get weeklyStreak => streak.value.weeklyStreak;

  @override
  void onInit() {
    super.onInit();
    loadStreak();
    _listenToFeedPosts(); // Usar el stream aquí
  }

  @override
  void onClose() {
    _feedSubscription?.cancel(); // Cancelar suscripción al cerrar
    super.onClose();
  }

  /// Cargar la racha desde el almacenamiento
  void loadStreak() {
    try {
      isLoading.value = true;
      final loadedStreak = _streakService.getStreak();
      streak.value = loadedStreak;
    } catch (e) {
      print('Error al cargar racha: $e');
      // _showError('No se pudo cargar tu racha'); // Puedes descomentar esto si prefieres un snackbar
    } finally {
      isLoading.value = false;
    }
  }

  /// Escuchar cambios en el feed de posts en tiempo real
  void _listenToFeedPosts() {
    _feedSubscription?.cancel(); // Cancelar suscripción anterior si existe
    _feedSubscription = _workoutService
        .getFeedPostsStream(limit: 20)
        .listen(
          (posts) {
            feedPosts.value = posts;
            isFeedLoading.value = false; // El stream ya indica que cargó
          },
          onError: (error) {
            print('Error en el stream del feed: $error');
            _showError('Error al cargar el feed en tiempo real');
            isFeedLoading.value = false;
          },
          onDone: () => print('Stream del feed finalizado'),
        );
  }

  /// Cargar feed de posts (solo para la primera carga o si se necesita forzar)
  Future<void> loadFeed() async {
    // La carga inicial se hará a través del stream en _listenToFeedPosts
    // Este método puede ser útil si quieres una carga one-time por alguna razón,
    // pero con el stream, el feed se mantiene actualizado automáticamente.
    if (isFeedLoading.value == false) {
      // Evitar múltiples cargas si ya está escuchando
      isFeedLoading.value = true;
    }
    // No es necesario llamar a getFeedPosts aquí si el stream está activo.
    // Si necesitas recargar manualmente el stream (ej. después de un error), podrías hacerlo aquí.
    // Para este caso, el stream se encarga.
  }

  /// Refrescar feed (simplemente reinicia la escucha del stream si es necesario)
  Future<void> refreshFeed() async {
    isFeedLoading.value = true; // Indicar que se está refrescando
    _listenToFeedPosts(); // Reiniciar la escucha del stream
    // Firestore se encargará de entregar los datos más recientes.
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
