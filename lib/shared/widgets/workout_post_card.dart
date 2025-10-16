import 'package:flutter/material.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/features/training/views/widgets/comments_bottom_sheet.dart';
import 'package:tribbe_app/features/profile/utils/workout_utils.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:get/get.dart';

/// Card de post de entrenamiento para el feed
class WorkoutPostCard extends StatelessWidget {
  final WorkoutPostModel post;
  final String? currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  // final VoidCallback? onShare; // Eliminado

  const WorkoutPostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.onLike,
    this.onComment,
    // this.onShare, // Eliminado
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLiked = currentUserId != null && post.isLikedBy(currentUserId!);
    final focusColor = WorkoutUtils.getFocusColor(post.workout.focus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          _buildHeaderWithGradient(isDark, focusColor),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del entrenamiento mejorada
                _buildWorkoutInfoModern(isDark, focusColor),

                const SizedBox(height: 16),

                // Caption si existe
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.caption!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Ejercicios con mejor diseño
                _buildExercisesListModern(isDark),

                const SizedBox(height: 16),

                // Acciones mejoradas
                _buildActionsModern(isLiked, isDark),

                const SizedBox(height: 12),

                // Timestamp mejorado
                _buildTimestamp(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header con gradiente y avatar
  Widget _buildHeaderWithGradient(bool isDark, Color focusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: WorkoutUtils.getGradientColors(
            post.workout.focus,
            isDark: isDark,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Avatar con borde
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: post.userPhotoUrl != null
                  ? NetworkImage(post.userPhotoUrl!)
                  : null,
              child: post.userPhotoUrl == null
                  ? Text(
                      post.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'completó un entrenamiento',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            WorkoutUtils.getFocusIcon(post.workout.focus),
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  /// Información del entrenamiento moderna
  Widget _buildWorkoutInfoModern(bool isDark, Color focusColor) {
    return GestureDetector(
      onTap: () => _navigateToWorkoutDetail(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: focusColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: focusColor.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            // Enfoque con mejor diseño
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: focusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    WorkoutUtils.getFocusIcon(post.workout.focus),
                    color: focusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    post.workout.focus,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: focusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: focusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estadísticas con mejor diseño
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItemModern(
                  '${post.workout.duration}',
                  'min',
                  Icons.schedule,
                  focusColor,
                  isDark,
                ),
                _buildStatItemModern(
                  '${post.workout.exercises.length}',
                  'ejercicios',
                  Icons.fitness_center,
                  focusColor,
                  isDark,
                ),
                _buildStatItemModern(
                  '${post.workout.totalSets}',
                  'series',
                  Icons.repeat,
                  focusColor,
                  isDark,
                ),
                _buildStatItemModern(
                  '${post.workout.totalVolume.toStringAsFixed(0)}',
                  'kg',
                  Icons.scale,
                  focusColor,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Item de estadística moderno
  Widget _buildStatItemModern(
    String value,
    String label,
    IconData icon,
    Color focusColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: focusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: focusColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Lista de ejercicios moderna
  Widget _buildExercisesListModern(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Ejercicios',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...post.workout.exercises.take(3).toList().asMap().entries.map((
            entry,
          ) {
            final index = entry.key;
            final exercise = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exercise.sets.length} series',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (post.workout.exercises.length > 3)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.more_horiz, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '+${post.workout.exercises.length - 3} ejercicios más',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Acciones modernas
  Widget _buildActionsModern(bool isLiked, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Like
          Expanded(
            child: InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    if (post.likes.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${post.likes.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isLiked ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: 1,
            height: 20,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),

          // Comment
          Expanded(
            child: InkWell(
              onTap: () {
                if (onComment != null) {
                  onComment!();
                }
                Get.bottomSheet(
                  CommentsBottomSheet(postId: post.id),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    if (post.commentsCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentsCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Timestamp mejorado
  Widget _buildTimestamp(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: isDark ? Colors.grey[500] : Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Text(
          _formatTimestamp(post.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Formatear timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Justo ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Navegar al detalle del entrenamiento
  void _navigateToWorkoutDetail() {
    Get.toNamed(
      RoutePaths.workoutDetail.replaceAll(':id', post.workout.id),
      arguments: {'workout': post.workout},
    );
  }
}
