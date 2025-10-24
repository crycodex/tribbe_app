import 'package:flutter/material.dart';

/// Widget para mostrar un entrenamiento en la grilla del perfil de usuario
class UserWorkoutGridItem extends StatelessWidget {
  final String workoutId;
  final String? workoutName;
  final String? workoutDate;
  final VoidCallback? onTap;

  const UserWorkoutGridItem({
    super.key,
    required this.workoutId,
    this.workoutName,
    this.workoutDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de entrenamiento
                  Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),

                  const Spacer(),

                  // Nombre del entrenamiento
                  Text(
                    workoutName ?? 'Entrenamiento',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Fecha
                  if (workoutDate != null)
                    Text(
                      workoutDate!,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

            // Overlay de hover
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
