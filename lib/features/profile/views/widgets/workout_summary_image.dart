import 'package:flutter/material.dart';
import 'package:tribbe_app/features/profile/utils/workout_utils.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

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
                color: WorkoutUtils.getFocusColor(
                  workout.focus,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                WorkoutUtils.getFocusIcon(workout.focus),
                color: WorkoutUtils.getFocusColor(workout.focus),
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
}
