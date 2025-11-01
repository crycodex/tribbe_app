import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';
import 'package:tribbe_app/shared/utils/share_workout_util.dart';

/// Vista de detalle unificada para entrenamientos
class WorkoutDetailPage extends StatelessWidget {
  final WorkoutModel? workout;
  final WorkoutPostModel? workoutPost;

  const WorkoutDetailPage({
    super.key,
    this.workout,
    this.workoutPost,
  }) : assert(workout != null || workoutPost != null, 'Debe proporcionar workout o workoutPost');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentWorkout = workout ?? workoutPost!.workout;
    final focusColor = WorkoutUtils.getFocusColor(currentWorkout.focus);
    final photoUrl = workoutPost?.workoutPhotoUrl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar con foto o gradiente
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: focusColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                currentWorkout.focus,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: photoUrl != null && photoUrl.isNotEmpty
                  ? _buildPhotoBackground(photoUrl, currentWorkout, focusColor)
                  : _buildGradientBackground(currentWorkout, isDark),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                onPressed: () => ShareWorkoutUtil.shareWorkout(currentWorkout),
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
                  // Caption si existe (solo para workoutPost)
                  if (workoutPost?.caption != null && workoutPost!.caption!.isNotEmpty)
                    _buildCaptionSection(workoutPost!.caption!, theme, isDark),

                  // Estadísticas del entrenamiento
                  _buildStatsCard(currentWorkout, theme, isDark, focusColor),

                  const SizedBox(height: 16),

                  // Lista de ejercicios detallada
                  _buildExercisesCard(currentWorkout, theme, isDark, focusColor),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Background con foto del entrenamiento
  Widget _buildPhotoBackground(String photoUrl, WorkoutModel currentWorkout, Color focusColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Foto de fondo
        Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildGradientBackground(currentWorkout, false);
          },
        ),
        // Gradiente oscuro para legibilidad
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        // Badge del tipo
        Positioned(
          bottom: 60,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  WorkoutUtils.getFocusIcon(currentWorkout.focus),
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '${currentWorkout.duration} min • ${currentWorkout.exercises.length} ejercicios',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Background con gradiente (cuando no hay foto)
  Widget _buildGradientBackground(WorkoutModel currentWorkout, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: WorkoutUtils.getGradientColors(
            currentWorkout.focus,
            isDark: isDark,
          ),
        ),
      ),
      child: Center(
        child: Icon(
          WorkoutUtils.getFocusIcon(currentWorkout.focus),
          size: 100,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Sección de caption
  Widget _buildCaptionSection(String caption, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              caption,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card con estadísticas mejorado
  Widget _buildStatsCard(WorkoutModel currentWorkout, ThemeData theme, bool isDark, Color focusColor) {
    final totalSets = currentWorkout.totalSets;
    final totalReps = currentWorkout.totalReps;
    final totalVolume = currentWorkout.totalVolume;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: focusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernStatItem(
                  '${currentWorkout.duration}',
                  'min',
                  Icons.schedule,
                  focusColor,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildModernStatItem(
                  '${currentWorkout.exercises.length}',
                  'ejercicios',
                  Icons.fitness_center,
                  focusColor,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModernStatItem(
                  '$totalSets',
                  'series',
                  Icons.repeat,
                  focusColor,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildModernStatItem(
                  '$totalReps',
                  'reps',
                  Icons.sports_gymnastics,
                  focusColor,
                  isDark,
                ),
              ),
            ],
          ),
          if (totalVolume > 0) ...[
            const SizedBox(height: 16),
            _buildModernStatItem(
              totalVolume.toStringAsFixed(0),
              'kg volumen total',
              Icons.scale,
              focusColor,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernStatItem(String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card con lista de ejercicios mejorado
  Widget _buildExercisesCard(WorkoutModel currentWorkout, ThemeData theme, bool isDark, Color focusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: focusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Ejercicios (${currentWorkout.exercises.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...currentWorkout.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _buildModernExerciseItem(exercise, index + 1, theme, isDark, focusColor);
          }),
        ],
      ),
    );
  }

  /// Widget mejorado para item de ejercicio con detalles de series
  Widget _buildModernExerciseItem(
    dynamic exercise,
    int index,
    ThemeData theme,
    bool isDark,
    Color focusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: focusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: focusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${exercise.sets.length} series',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: focusColor,
                  ),
                ),
              ),
            ],
          ),
          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.sets.asMap().entries.map<Widget>((entry) {
                final setIndex = entry.key + 1;
                final set = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    'S$setIndex: ${set.weight}kg × ${set.reps}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
