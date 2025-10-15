import 'package:flutter/material.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar un entrenamiento en formato de grilla (estilo Instagram)
class WorkoutGridItem extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onTap;

  const WorkoutGridItem({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Fondo con gradiente según el foco
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(workout.focus, isDark),
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header con fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatDate(workout.createdAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.fitness_center,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                      ],
                    ),

                    // Información principal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foco del entrenamiento
                        Text(
                          workout.focus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Estadísticas
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.white.withOpacity(0.8),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.duration} min',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.repeat,
                              color: Colors.white.withOpacity(0.8),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.exercises.length}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtener colores del gradiente según el foco del entrenamiento
  List<Color> _getGradientColors(String focus, bool isDark) {
    final Map<String, List<Color>> focusColors = {
      'Pecho': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
      'Espalda': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
      'Piernas': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      'Hombros': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
      'Brazos': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      'Abdomen': [const Color(0xFFFFEB3B), const Color(0xFFFBC02D)],
      'Cardio': [const Color(0xFFF44336), const Color(0xFFD32F2F)],
      'Full Body': [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    };

    final colors =
        focusColors[focus] ??
        [const Color(0xFF607D8B), const Color(0xFF455A64)];

    if (isDark) {
      return colors.map((c) => Color.lerp(c, Colors.black, 0.3) ?? c).toList();
    }

    return colors;
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}
