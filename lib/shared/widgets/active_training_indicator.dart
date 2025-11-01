import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Indicador flotante de entrenamiento activo
class ActiveTrainingIndicator extends StatelessWidget {
  const ActiveTrainingIndicator({super.key});

  /// Formatear tiempo transcurrido
  String _formatTime(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si existe el TrainingController
    if (!Get.isRegistered<TrainingController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<TrainingController>();

    return Obx(() {
      // Solo mostrar si hay entrenamiento activo
      if (!controller.isTraining.value) {
        return const SizedBox.shrink();
      }

      return Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: GestureDetector(
          onTap: () => Get.toNamed(RoutePaths.trainingMode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: controller.isPaused.value
                    ? [
                        Colors.orange.withValues(alpha: 0.95),
                        Colors.deepOrange.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.green.withValues(alpha: 0.95),
                        Colors.teal.withValues(alpha: 0.95),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (controller.isPaused.value ? Colors.orange : Colors.green)
                          .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono animado
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      controller.isPaused.value
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.flame_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Contador de tiempo prominente
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.time_solid,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          // Observar explícitamente elapsedSeconds para actualizaciones en tiempo real
                          Obx(
                            () => Text(
                              _formatTime(controller.elapsedSeconds.value),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Estado y ejercicios
                      Row(
                        children: [
                          Text(
                            controller.isPaused.value ? 'En pausa' : 'Activo',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.circle_fill,
                            size: 4,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => Text(
                              '${controller.exercises.length} ejercicios',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
