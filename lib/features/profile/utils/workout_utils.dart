import 'package:flutter/material.dart';

/// Utilidades para entrenamientos - Colores e iconos
class WorkoutUtils {
  /// Obtener color según el tipo de entrenamiento
  static Color getFocusColor(String focus) {
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

  /// Obtener icono según el tipo de entrenamiento
  static IconData getFocusIcon(String focus) {
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

  /// Formatear fecha relativa
  static String formatRelativeDate(DateTime date) {
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
}
