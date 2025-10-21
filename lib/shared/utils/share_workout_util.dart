import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_summary_image.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';

/// Utilidad para compartir entrenamientos como imagen
class ShareWorkoutUtil {
  ShareWorkoutUtil._();

  /// Controlador para capturar el widget como imagen
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Compartir entrenamiento como imagen
  static Future<void> shareWorkout(WorkoutModel workout) async {
    // Mostrar un indicador de carga
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      debugPrint('🔄 Iniciando proceso de compartir entrenamiento.');

      // Crear una key única para el widget a capturar
      final GlobalKey captureKey = GlobalKey();

      // Capturar el widget de resumen de entrenamiento con un retardo y timeout
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            WorkoutSummaryImage(workout: workout, shareKey: captureKey),
            delay: const Duration(milliseconds: 300),
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

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/tribbe_workout_${workout.id}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      debugPrint('📄 Imagen guardada en: ${imagePath.path}');

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: '¡Mira mi entrenamiento en Tribbe App!',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
      debugPrint('🚀 Compartido exitosamente.');
    } catch (e) {
      debugPrint('❌ Error al compartir entrenamiento: ${e.toString()}');
      Get.snackbar(
        'Error',
        'No se pudo compartir el entrenamiento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      Get.back(); // Asegurarse de cerrar el indicador de carga
      debugPrint('🔚 Proceso de compartir entrenamiento finalizado.');
    }
  }

  /// Verificar si el usuario actual es el dueño del entrenamiento
  static bool isOwner(WorkoutModel workout) {
    final authService = Get.find<FirebaseAuthService>();
    final currentUserId = authService.currentUser?.uid;
    return currentUserId != null && currentUserId == workout.userId;
  }

  /// Mostrar botón de compartir solo si es el propietario
  static Widget buildShareButton(
    WorkoutModel workout, {
    IconData icon = Icons.share,
    Color iconColor = Colors.white,
    VoidCallback? onPressed,
  }) {
    if (!isOwner(workout)) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(icon, color: iconColor),
      onPressed: onPressed ?? () => shareWorkout(workout),
    );
  }

  /// Mostrar botón de compartir personalizado solo si es el propietario
  static Widget buildCustomShareButton(
    WorkoutModel workout, {
    required Widget child,
    VoidCallback? onPressed,
  }) {
    if (!isOwner(workout)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onPressed ?? () => shareWorkout(workout),
      child: child,
    );
  }
}
