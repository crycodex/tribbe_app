import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';
import 'package:tribbe_app/shared/utils/share_workout_util.dart';

/// Vista de detalle unificada para entrenamientos
class WorkoutDetailPage extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final focusColor = WorkoutUtils.getFocusColor(workout.focus);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: focusColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                workout.focus,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: WorkoutUtils.getGradientColors(
                      workout.focus,
                      isDark: isDark,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    WorkoutUtils.getFocusIcon(workout.focus),
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              ShareWorkoutUtil.buildShareButton(
                workout,
                icon: Icons.share,
                iconColor: Colors.white,
              ),
            ],
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información general
                  _buildInfoCard(theme, isDark),

                  const SizedBox(height: 16),

                  // Estadísticas del entrenamiento
                  _buildStatsCard(theme, isDark),

                  const SizedBox(height: 16),

                  // Lista de ejercicios
                  _buildExercisesCard(theme, isDark),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card con información general del entrenamiento
  Widget _buildInfoCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Fecha',
              WorkoutUtils.formatRelativeDate(workout.createdAt),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'Duración',
              '${workout.duration} minutos',
              Icons.schedule,
            ),
            _buildInfoRow('Tipo', workout.focus, Icons.fitness_center),
          ],
        ),
      ),
    );
  }

  /// Card con estadísticas del entrenamiento
  Widget _buildStatsCard(ThemeData theme, bool isDark) {
    final totalSets = workout.exercises.fold(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
    final totalReps = workout.exercises.fold(
      0,
      (sum, exercise) =>
          sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${workout.exercises.length}',
                    'Ejercicios',
                    Icons.fitness_center,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '$totalSets',
                    'Series',
                    Icons.repeat,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '$totalReps',
                    'Repeticiones',
                    Icons.sports_gymnastics,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card con lista de ejercicios
  Widget _buildExercisesCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ejercicios (${workout.exercises.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            ...workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseItem(exercise, index + 1, theme, isDark);
            }),
          ],
        ),
      ),
    );
  }

  /// Widget para fila de información
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para item de estadística
  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: WorkoutUtils.getFocusColor(workout.focus)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Widget para item de ejercicio
  Widget _buildExerciseItem(
    dynamic exercise,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: WorkoutUtils.getFocusColor(workout.focus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Series: ${exercise.sets.length}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
