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

  /// Card de entrenamiento individual - Estilo Strava
  Widget _buildWorkoutCard(
    WorkoutModel workout,
    bool isDark,
    BuildContext context,
  ) {
    // Key para el botón de compartir de este workout específico
    final GlobalKey shareButtonKey = GlobalKey();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header con fecha y botón compartir
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(workout.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  key: shareButtonKey,
                  icon: Icon(
                    Icons.share,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () =>
                      _shareWorkout(context, workout, shareButtonKey),
                ),
              ],
            ),
          ),

          // Métricas principales - Estilo Strava
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Duración (métrica principal)
                _buildMainMetric('Duración', '${workout.duration} min', isDark),

                const SizedBox(height: 20),

                // Métricas secundarias en fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSecondaryMetric(
                      'Ejercicios',
                      workout.exercises.length.toString(),
                      isDark,
                    ),
                    _buildSecondaryMetric(
                      'Series',
                      workout.totalSets.toString(),
                      isDark,
                    ),
                    _buildSecondaryMetric(
                      'Volumen',
                      '${workout.totalVolume.toInt()} kg',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Icono del tipo de entrenamiento
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getFocusColor(workout.focus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: _getFocusColor(workout.focus),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.focus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Footer con ejercicios
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${workout.exercises.length} ejercicios',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Ver detalles',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getFocusColor(workout.focus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Métrica principal - Estilo Strava (más grande y destacada)
  Widget _buildMainMetric(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Métrica secundaria - Estilo Strava (más pequeña)
  Widget _buildSecondaryMetric(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
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

/// Widget para generar la imagen compartible del resumen de entrenamiento - Estilo Strava
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
        height: 580,
        padding: const EdgeInsets.all(32), // Padding interno
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de Tribbe
            Text(
              'Tribbe.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 40),

            // Métricas principales - Estilo Strava
            _buildMainMetric('Duración', '${workout.duration} min'),
            const SizedBox(height: 32),
            _buildMainMetric('Ejercicios', '${workout.exercises.length}'),
            const SizedBox(height: 32),
            _buildMainMetric('Volumen', '${workout.totalVolume.toInt()} kg'),

            const SizedBox(height: 40),

            // Icono del tipo de entrenamiento
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getFocusColor(workout.focus).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getFocusIcon(workout.focus),
                color: _getFocusColor(workout.focus),
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              workout.focus,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            // Hashtag
            Text(
              '#TribbeApp',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Métrica principal - Estilo Strava
  Widget _buildMainMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
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

  IconData _getFocusIcon(String focus) {
    switch (focus) {
      case 'Fuerza':
        return Icons.fitness_center;
      case 'Hipertrofia':
        return Icons.trending_up;
      case 'Resistencia':
        return Icons.directions_run;
      case 'Cardio':
        return Icons.favorite;
      case 'Funcional':
        return Icons.accessibility_new;
      case 'CrossFit':
        return Icons.local_fire_department;
      case 'Calistenia':
        return Icons.person;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
