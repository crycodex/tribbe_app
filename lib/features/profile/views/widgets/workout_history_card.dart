import 'package:flutter/material.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';

/// Widget para tarjeta individual de entrenamiento en el historial
class WorkoutHistoryCard extends StatelessWidget {
  final WorkoutModel? workout;
  final WorkoutPostModel? workoutPost;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const WorkoutHistoryCard({
    super.key,
    this.workout,
    this.workoutPost,
    this.onShare,
    this.onTap,
  }) : assert(
          workout != null || workoutPost != null,
          'Debe proporcionar workout o workoutPost',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentWorkout = workout ?? workoutPost!.workout;
    final photoUrl = workoutPost?.workoutPhotoUrl;
    final caption = workoutPost?.caption;
    final focusColor = WorkoutUtils.getFocusColor(currentWorkout.focus);

    // Diseño con foto (más visual y compacto)
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return _buildCardWithPhoto(
        context,
        currentWorkout,
        photoUrl,
        caption,
        focusColor,
        isDark,
      );
    }

    // Diseño sin foto (clásico mejorado)
    return _buildCardWithoutPhoto(
      context,
      currentWorkout,
      caption,
      focusColor,
      isDark,
    );
  }

  /// Card con foto destacada
  Widget _buildCardWithPhoto(
    BuildContext context,
    WorkoutModel currentWorkout,
    String photoUrl,
    String? caption,
    Color focusColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto con overlay
            Stack(
              children: [
                // Foto principal
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    photoUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
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
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Gradiente overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                ),
                // Badge del tipo en la esquina
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: focusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          WorkoutUtils.getFocusIcon(currentWorkout.focus),
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentWorkout.focus,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón compartir
                if (onShare != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: onShare,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Estadísticas en la parte inferior de la foto
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildPhotoStat(
                        Icons.schedule,
                        '${currentWorkout.duration} min',
                      ),
                      const SizedBox(width: 12),
                      _buildPhotoStat(
                        Icons.fitness_center,
                        '${currentWorkout.exercises.length} ejercicios',
                      ),
                      const Spacer(),
                      if (currentWorkout.totalVolume > 0)
                        _buildPhotoStat(
                          Icons.scale,
                          '${currentWorkout.totalVolume.toInt()} kg',
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Caption y fecha
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null && caption.isNotEmpty) ...[
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        WorkoutUtils.formatRelativeDate(
                          currentWorkout.createdAt,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: focusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card sin foto (diseño clásico mejorado)
  Widget _buildCardWithoutPhoto(
    BuildContext context,
    WorkoutModel currentWorkout,
    String? caption,
    Color focusColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: WorkoutUtils.getGradientColors(
                    currentWorkout.focus,
                    isDark: isDark,
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      WorkoutUtils.getFocusIcon(currentWorkout.focus),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentWorkout.focus,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          WorkoutUtils.formatRelativeDate(
                            currentWorkout.createdAt,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onShare != null)
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: onShare,
                    ),
                ],
              ),
            ),
            // Métricas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (caption != null && caption.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[850]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 18,
                            color: isDark
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        Icons.schedule,
                        '${currentWorkout.duration}',
                        'minutos',
                        focusColor,
                        isDark,
                      ),
                      _buildStatDivider(isDark),
                      _buildStatColumn(
                        Icons.fitness_center,
                        '${currentWorkout.exercises.length}',
                        'ejercicios',
                        focusColor,
                        isDark,
                      ),
                      _buildStatDivider(isDark),
                      _buildStatColumn(
                        Icons.repeat,
                        '${currentWorkout.totalSets}',
                        'series',
                        focusColor,
                        isDark,
                      ),
                    ],
                  ),
                  if (currentWorkout.totalVolume > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: focusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.scale, color: focusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Volumen Total: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${currentWorkout.totalVolume.toInt()} kg',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: focusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estadística pequeña para overlay de foto
  Widget _buildPhotoStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Columna de estadística
  Widget _buildStatColumn(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  /// Divisor vertical
  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 50,
      color: isDark ? Colors.grey[800] : Colors.grey[300],
    );
  }
}
