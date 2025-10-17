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
                        Colors.orange.withOpacity(0.95),
                        Colors.deepOrange.withOpacity(0.95),
                      ]
                    : [
                        Colors.green.withOpacity(0.95),
                        Colors.teal.withOpacity(0.95),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (controller.isPaused.value ? Colors.orange : Colors.green)
                          .withOpacity(0.4),
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
                    color: Colors.white.withOpacity(0.2),
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
                      Text(
                        controller.isPaused.value
                            ? 'Entrenamiento en pausa'
                            : 'Entrenamiento activo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          // Observar explícitamente elapsedSeconds para actualizaciones en tiempo real
                          Obx(
                            () => Text(
                              _formatTime(controller.elapsedSeconds.value),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.list_bullet,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Obx(
                            () => Text(
                              '${controller.exercises.length} ejercicios',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
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
                  color: Colors.white.withOpacity(0.7),
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
