import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart'; // Necesario para _buildWorkoutCard
import 'package:screenshot/screenshot.dart'; // Para capturar el widget
import 'package:share_plus/share_plus.dart'; // Para compartir la imagen
import 'package:path_provider/path_provider.dart'; // Para guardar la imagen temporalmente
import 'dart:io'; // Para manejar archivos
import 'package:flutter/rendering.dart'; // Para la captura
import 'dart:typed_data'; // Para manejar bytes de imagen

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

          return Column(
            children: [
              // Estadísticas generales
              _buildStatsHeader(controller, isDark),

              const SizedBox(height: 16),

              // Lista de entrenamientos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.userWorkouts.length,
                  itemBuilder: (context, index) {
                    final workout = controller.userWorkouts[index];
                    return _buildWorkoutCard(workout, isDark, context);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Header con estadísticas
  Widget _buildStatsHeader(ProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1a237e), const Color(0xFF0d47a1)]
              : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Resumen Total',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Entrenamientos',
                controller.totalWorkouts.toString(),
                Icons.fitness_center,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatColumn(
                'Volumen Total',
                '${controller.totalVolume.toInt()} kg',
                Icons.scale,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatColumn(
                'Tiempo Total',
                '${controller.totalDuration} min',
                Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }

  /// Card de entrenamiento individual
  Widget _buildWorkoutCard(
    WorkoutModel workout,
    bool isDark,
    BuildContext context,
  ) {
    // Key para el botón de compartir de este workout específico
    final GlobalKey shareButtonKey = GlobalKey();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con enfoque y fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: _getFocusColor(workout.focus),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    workout.focus,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _formatDate(workout.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: shareButtonKey, // Asignar la key al IconButton
                    icon: Icon(
                      Icons.share,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () => _shareWorkout(
                      context,
                      workout,
                      shareButtonKey,
                    ), // Pasar la key
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Estadísticas del entrenamiento
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkoutStat(
                'Duración',
                '${workout.duration} min',
                Icons.timer,
                isDark,
              ),
              _buildWorkoutStat(
                'Ejercicios',
                workout.exercises.length.toString(),
                Icons.fitness_center,
                isDark,
              ),
              _buildWorkoutStat(
                'Series',
                workout.totalSets.toString(),
                Icons.repeat,
                isDark,
              ),
              _buildWorkoutStat(
                'Volumen',
                '${workout.totalVolume.toInt()} kg',
                Icons.scale,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lista de ejercicios (colapsada)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios (${workout.exercises.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...workout.exercises.take(3).map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${exercise.name} - ${exercise.sets.length} series',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (workout.exercises.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${workout.exercises.length - 3} más',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getFocusColor(String focus) {
    switch (focus) {
      case 'Fuerza':
        return Colors.red;
      case 'Hipertrofia':
        return Colors.purple;
      case 'Resistencia':
        return Colors.green;
      case 'Cardio':
        return Colors.blue;
      case 'Funcional':
        return Colors.orange;
      case 'CrossFit':
        return Colors.deepOrange;
      case 'Calistenia':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Compartir un entrenamiento como imagen
  Future<void> _shareWorkout(
    BuildContext context,
    WorkoutModel workout,
    GlobalKey shareButtonKey, // Recibir la key del botón de compartir
  ) async {
    // Mostrar un indicador de carga
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      debugPrint('🔄 Iniciando proceso de compartir entrenamiento.');

      // Calcular la posición y tamaño del botón de compartir
      final RenderBox? renderBox =
          shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final Rect? sharePositionOrigin = renderBox != null
          ? renderBox.localToGlobal(Offset.zero) & renderBox.size
          : null;

      // Crear una key única para el widget a capturar
      final GlobalKey captureKey =
          GlobalKey(); // Renombrado a captureKey para evitar conflicto con shareKey

      // Capturar el widget de resumen de entrenamiento con un retardo y timeout
      final Uint8List? imageBytes = await screenshotController
          .captureFromWidget(
            WorkoutSummaryImage(
              workout: workout,
              shareKey: captureKey, // Usar captureKey aquí
            ), // Pasa la key
            delay: const Duration(milliseconds: 300), // Aumentado el retardo
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
          '${directory.path}/tribbe_workout_${workout.id}.png', // Nombre de archivo único
        ).create();
        await imagePath.writeAsBytes(imageBytes);

        debugPrint('📄 Imagen guardada en: ${imagePath.path}');

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: '¡Mira mi entrenamiento en Tribbe App!',
          sharePositionOrigin: sharePositionOrigin,
        ); // Pasar sharePositionOrigin
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

// --- Nuevo Widget para la imagen de resumen del entrenamiento ---

/// Widget para generar la imagen compartible del resumen de entrenamiento
class WorkoutSummaryImage extends StatelessWidget {
  final WorkoutModel workout;
  final Key shareKey; // Recibe la GlobalKey para la captura

  const WorkoutSummaryImage({
    super.key,
    required this.workout,
    required this.shareKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: shareKey, // Asigna la key al RepaintBoundary
      child: Container(
        width: 225, // Ancho fijo para la imagen
        padding: const EdgeInsets.all(24), // Padding interno del container
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de Tribbe
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/icon/icon_ligth.png', height: 50),
            ),
            _buildStatRow('Duración', '${workout.duration} min', Icons.timer),
            _buildStatRow(
              'Ejercicios',
              '${workout.exercises.length}',
              Icons.fitness_center,
            ),
            _buildStatRow('Series', '${workout.totalSets}', Icons.repeat),
            _buildStatRow(
              'Volumen Total',
              '${workout.totalVolume.toInt()} kg',
              Icons.scale,
            ),
            Text(
              '#TribbeApp',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
