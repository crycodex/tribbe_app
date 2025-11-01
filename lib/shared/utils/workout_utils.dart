import 'package:flutter/material.dart';

/// Utilidades para entrenamientos - Colores e iconos
class WorkoutUtils {
  /// Obtener color según el tipo de entrenamiento
  static Color getFocusColor(String focus) {
    switch (focus) {
      // Tipos de entrenamiento por objetivo
      case 'Fuerza':
        return const Color(0xFFE53E3E); // Rojo intenso
      case 'Hipertrofia':
        return const Color(0xFF9F7AEA); // Púrpura
      case 'Resistencia':
        return const Color(0xFF38A169); // Verde
      case 'Cardio':
        return const Color(0xFF3182CE); // Azul
      case 'Funcional':
        return const Color(0xFFDD6B20); // Naranja
      case 'CrossFit':
        return const Color(0xFFE53E3E); // Rojo intenso
      case 'Calistenia':
        return const Color(0xFF319795); // Teal

      // Tipos por grupo muscular
      case 'Pecho':
        return const Color(0xFFE91E63); // Rosa
      case 'Espalda':
        return const Color(0xFF2196F3); // Azul
      case 'Piernas':
        return const Color(0xFF4CAF50); // Verde
      case 'Hombros':
        return const Color(0xFFFF9800); // Naranja
      case 'Brazos':
        return const Color(0xFF9C27B0); // Púrpura
      case 'Abdomen':
        return const Color(0xFFFFEB3B); // Amarillo
      case 'Full Body':
        return const Color(0xFF00BCD4); // Cian

      default:
        return const Color(0xFF607D8B); // Gris azulado
    }
  }

  /// Obtener icono según el tipo de entrenamiento
  static IconData getFocusIcon(String focus) {
    switch (focus) {
      // Tipos de entrenamiento por objetivo
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

      // Tipos por grupo muscular
      case 'Pecho':
        return Icons.sports_gymnastics;
      case 'Espalda':
        return Icons.rowing;
      case 'Piernas':
        return Icons.directions_run;
      case 'Hombros':
        return Icons.accessibility_new;
      case 'Brazos':
        return Icons.fitness_center;
      case 'Abdomen':
        return Icons.sports;
      case 'Full Body':
        return Icons.people;

      default:
        return Icons.sports_gymnastics;
    }
  }

  /// Obtener colores del gradiente según el tipo de entrenamiento
  static List<Color> getGradientColors(String focus, {bool isDark = false}) {
    final Map<String, List<Color>> focusColors = {
      // Tipos de entrenamiento por objetivo
      'Fuerza': [const Color(0xFFE53E3E), const Color(0xFFC53030)],
      'Hipertrofia': [const Color(0xFF9F7AEA), const Color(0xFF805AD5)],
      'Resistencia': [const Color(0xFF38A169), const Color(0xFF2F855A)],
      'Cardio': [const Color(0xFF3182CE), const Color(0xFF2C5282)],
      'Funcional': [const Color(0xFFDD6B20), const Color(0xFFC05621)],
      'CrossFit': [const Color(0xFFE53E3E), const Color(0xFFC53030)],
      'Calistenia': [const Color(0xFF319795), const Color(0xFF2C7A7B)],

      // Tipos por grupo muscular
      'Pecho': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
      'Espalda': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
      'Piernas': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      'Hombros': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
      'Brazos': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      'Abdomen': [const Color(0xFFFFEB3B), const Color(0xFFFBC02D)],
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
