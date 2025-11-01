import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';

/// Widget para el header de estadísticas del historial de entrenamientos
class WorkoutStatsHeader extends StatelessWidget {
  const WorkoutStatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatColumn(
                'Volumen Total',
                '${controller.totalVolume.toInt()} kg',
                Icons.scale,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
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

  /// Widget para columna de estadística individual
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
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
