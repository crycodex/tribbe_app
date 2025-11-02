import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tribbe_app/features/dashboard/models/streak_model.dart';
import 'package:tribbe_app/features/dashboard/views/widgets/character_streak_share_image.dart';
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
  final RxList<String> followingUserIds = <String>[].obs;
  StreamSubscription<List<WorkoutPostModel>>? _feedSubscription;
  StreamSubscription<StreakModel>? _streakSubscription;

  // Getters
  bool get hasTrainedToday => streak.value.hasTrainedToday();
  int get currentStreak {
    final value = streak.value.currentStreak;
    debugPrint('DEBUG getter currentStreak: $value');
    return value;
  }

  int get longestStreak => streak.value.longestStreak;
  List<bool> get weeklyStreak => streak.value.weeklyStreak;
  List<DateTime> get trainedDates => streak.value.trainedDates;
  bool get isStreakActive => streak.value.isStreakActive();
  bool get isStreakInDanger => streak.value.isStreakInDanger();
  bool get isStreakLost => streak.value.isStreakLost();
  int get daysSinceLastWorkout => streak.value.getDaysSinceLastWorkout();
  String get streakStatusMessage => streak.value.getStreakStatusMessage();

  @override
  void onInit() {
    super.onInit();
    _listenToStreak(); // Escuchar cambios de racha en tiempo real
    _loadFollowingAndStartFeed(); // Cargar usuarios seguidos y luego el feed
  }

  @override
  void onClose() {
    _streakSubscription?.cancel(); // Cancelar suscripción de racha
    _feedSubscription?.cancel(); // Cancelar suscripción al cerrar
    super.onClose();
  }

  /// Escuchar cambios en la racha en tiempo real
  void _listenToStreak() {
    _streakSubscription?.cancel(); // Cancelar suscripción anterior si existe
    isLoading.value = true;

    _streakSubscription = _streakService.getStreakStream().listen(
      (updatedStreak) {
        streak.value = updatedStreak;
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Error en el stream de racha: $error');
        _showError('Error al cargar tu racha en tiempo real');
        isLoading.value = false;
      },
      onDone: () => debugPrint('Stream de racha finalizado'),
    );
  }

  /// Cargar la racha desde Firestore (método manual por si se necesita)
  Future<void> loadStreak() async {
    try {
      isLoading.value = true;
      final loadedStreak = await _streakService.getStreak();
      streak.value = loadedStreak;
    } catch (e) {
      debugPrint('Error al cargar racha: $e');
      // _showError('No se pudo cargar tu racha'); // Puedes descomentar esto si prefieres un snackbar
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar usuarios seguidos y luego iniciar el stream del feed
  Future<void> _loadFollowingAndStartFeed() async {
    try {
      isFeedLoading.value = true;
      final currentUserId = _authService.currentUser?.uid;
      
      if (currentUserId == null) {
        debugPrint('Usuario no autenticado');
        isFeedLoading.value = false;
        return;
      }

      // Obtener IDs de usuarios seguidos
      final followingIds = await _workoutService.getFollowingUserIds(currentUserId);
      followingUserIds.value = followingIds;

      debugPrint('Usuarios seguidos: ${followingIds.length}');

      // Iniciar stream del feed con los usuarios seguidos
      _listenToFeedPosts(currentUserId, followingIds);
    } catch (e) {
      debugPrint('Error al cargar usuarios seguidos: $e');
      _showError('Error al cargar el feed');
      isFeedLoading.value = false;
    }
  }

  /// Escuchar cambios en el feed de posts en tiempo real
  void _listenToFeedPosts(String currentUserId, List<String> followingIds) {
    _feedSubscription?.cancel(); // Cancelar suscripción anterior si existe
    _feedSubscription = _workoutService
        .getFeedPostsStream(
          currentUserId: currentUserId,
          followingUserIds: followingIds,
          limit: 20,
        )
        .listen(
          (posts) {
            feedPosts.value = posts;
            isFeedLoading.value = false; // El stream ya indica que cargó
          },
          onError: (error) {
            debugPrint('Error en el stream del feed: $error');
            _showError('Error al cargar el feed en tiempo real');
            isFeedLoading.value = false;
          },
          onDone: () => debugPrint('Stream del feed finalizado'),
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
    isFeedLoading.value = true;
    await _loadFollowingAndStartFeed(); // Recargar usuarios seguidos y feed
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
      debugPrint('Error al registrar entrenamiento: $e');
      _showError('No se pudo registrar el entrenamiento');
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar manualmente la racha (reiniciar el stream)
  Future<void> refreshStreak() async {
    _listenToStreak(); // Reiniciar la escucha del stream
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
      debugPrint('Error al dar like: $e');
      _showError('No se pudo dar like');
      // Revertir cambio en caso de error
      loadFeed();
    }
  }

  /// Compartir personaje y racha como imagen
  Future<void> shareCharacterAndStreak() async {
    try {
      // Mostrar indicador de carga
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      debugPrint('🔄 Iniciando proceso de compartir personaje y racha.');

      final screenshotController = ScreenshotController();
      final captureKey = GlobalKey();

      // Capturar el widget como imagen
      final Uint8List imageBytes = await screenshotController
          .captureFromWidget(
            CharacterStreakShareImage(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              shareKey: captureKey,
            ),
            delay: const Duration(milliseconds: 500),
            pixelRatio: 3.0, // Alta resolución
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '❌ Timeout: La captura de imagen superó los 10 segundos.',
              );
              throw Exception('La captura de imagen tardó demasiado.');
            },
          );

      debugPrint('✅ Imagen capturada exitosamente. Guardando temporalmente...');

      // Guardar en directorio temporal
      final directory = await getTemporaryDirectory();
      final imagePath = File(
        '${directory.path}/tribbe_character_streak_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await imagePath.writeAsBytes(imageBytes);

      debugPrint('📄 Imagen guardada temporalmente en: ${imagePath.path}');

      // Cerrar el diálogo de carga antes de abrir el diálogo de compartir
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Compartir la imagen usando share_plus
      // El usuario puede guardarla en su galería desde el diálogo de compartir
      try {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: '¡Mira mi personaje y racha en Tribbe App! 🔥',
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
        );

        debugPrint('✅ Imagen compartida exitosamente.');
      } catch (e) {
        debugPrint('❌ Error al compartir imagen: $e');
        _showError('No se pudo compartir la imagen: ${e.toString()}');
        return;
      }

      // Limpiar archivo temporal después de un delay
      Future.delayed(const Duration(seconds: 5), () {
        if (imagePath.existsSync()) {
          imagePath.deleteSync();
        }
      });
    } catch (e) {
      debugPrint('❌ Error al compartir personaje y racha: ${e.toString()}');
      _showError('No se pudo guardar la imagen: ${e.toString()}');
    } finally {
      // Asegurarse de cerrar el diálogo si aún está abierto
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint('🔚 Proceso de compartir personaje y racha finalizado.');
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
