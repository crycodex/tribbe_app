import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_stats_header.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_history_card.dart';
import 'package:tribbe_app/shared/utils/share_workout_util.dart';

/// Página de historial de entrenamientos
class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

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
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              // Estadísticas generales
              const WorkoutStatsHeader(),

              const SizedBox(height: 16),

              // Lista de entrenamientos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.userWorkouts.length,
                  itemBuilder: (context, index) {
                    final post = controller.userWorkouts[index];
                    return WorkoutHistoryCard(
                      workoutPost: post,
                      onShare: () =>
                          ShareWorkoutUtil.shareWorkout(post.workout),
                      onTap: () => _navigateToWorkoutDetail(post),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Widget para estado vacío
  Widget _buildEmptyState(bool isDark) {
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

  /// Navegar al detalle del entrenamiento
  void _navigateToWorkoutDetail(WorkoutPostModel post) {
    Get.toNamed(
      RoutePaths.workoutDetail.replaceAll(':id', post.workout.id),
      arguments: {'workoutPost': post},
    );
  }
}
