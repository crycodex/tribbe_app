import 'package:flutter/material.dart';
import 'package:tribbe_app/features/profile/utils/workout_utils.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Widget para tarjeta individual de entrenamiento en el historial
class WorkoutHistoryCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const WorkoutHistoryCard({
    super.key,
    required this.workout,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header con fecha y botón compartir
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    WorkoutUtils.formatRelativeDate(workout.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (onShare != null)
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: onShare,
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
                  _buildMainMetric(
                    'Duración',
                    '${workout.duration} min',
                    isDark,
                  ),

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
                      color: WorkoutUtils.getFocusColor(
                        workout.focus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      WorkoutUtils.getFocusIcon(workout.focus),
                      color: WorkoutUtils.getFocusColor(workout.focus),
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
                      color: WorkoutUtils.getFocusColor(workout.focus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
