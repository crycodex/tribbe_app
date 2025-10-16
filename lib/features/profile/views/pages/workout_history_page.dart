import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_stats_header.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_history_card.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_summary_image.dart';

/// Página de historial de entrenamientos
class WorkoutHistoryPage extends StatelessWidget {
  // Constructor ya no es constante porque tiene un campo no constante
  WorkoutHistoryPage({super.key});

  // Controlador para capturar el widget como imagen
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Historial de Entrenamientos'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshWorkouts,
        child: Obx(() {
          if (controller.isLoadingWorkouts.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.userWorkouts.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              // Estadísticas generales
              const WorkoutStatsHeader(),

              const SizedBox(height: 16),

              // Lista de entrenamientos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.userWorkouts.length,
                  itemBuilder: (context, index) {
                    final workout = controller.userWorkouts[index];
                    return WorkoutHistoryCard(
                      workout: workout,
                      onShare: () => _shareWorkout(context, workout),
                      onTap: () => _navigateToWorkoutDetail(workout),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Widget para estado vacío
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Sin entrenamientos aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Comienza tu primer entrenamiento!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Navegar al detalle del entrenamiento
  void _navigateToWorkoutDetail(WorkoutModel workout) {
    // TODO: Implementar navegación al detalle
    Get.snackbar(
      'Próximamente',
      'Función de detalle en desarrollo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Compartir un entrenamiento como imagen
  Future<void> _shareWorkout(BuildContext context, WorkoutModel workout) async {
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
      final Uint8List? imageBytes = await screenshotController
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

      if (imageBytes != null) {
        debugPrint(
          '✅ Imagen capturada exitosamente. Guardando temporalmente...',
        );

        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/tribbe_workout_${workout.id}.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);

        debugPrint('📄 Imagen guardada en: ${imagePath.path}');

        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: '¡Mira mi entrenamiento en Tribbe App!');
        debugPrint('🚀 Compartido exitosamente.');
      } else {
        throw Exception('No se pudo capturar la imagen. Bytes nulos.');
      }
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
}
