import 'package:flutter/material.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/profile/utils/workout_utils.dart';

/// Widget para mostrar un entrenamiento en formato de grilla (estilo Instagram)
class WorkoutGridItem extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onTap;

  const WorkoutGridItem({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final focusColor = WorkoutUtils.getFocusColor(workout.focus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: focusColor, width: 2),
        ),
        child: Padding(
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
                      color: focusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      WorkoutUtils.formatRelativeDate(workout.createdAt),
                      style: TextStyle(
                        color: focusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    WorkoutUtils.getFocusIcon(workout.focus),
                    color: focusColor,
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
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
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
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.duration} min',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.repeat,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exercises.length}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
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
      ),
    );
  }
}
