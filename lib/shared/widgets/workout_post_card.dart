import 'package:flutter/material.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/features/training/views/widgets/comments_bottom_sheet.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            _buildHeader(isDark),

            const SizedBox(height: 16),

            // Información del entrenamiento
            _buildWorkoutInfo(isDark),

            const SizedBox(height: 16),

            // Caption si existe
            if (post.caption != null && post.caption!.isNotEmpty) ...[
              Text(
                post.caption!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ejercicios
            _buildExercisesList(isDark),

            const SizedBox(height: 16),

            // Acciones (like, comment)
            _buildActions(isLiked, isDark),

            const SizedBox(height: 8),

            // Timestamp
            Text(
              _formatTimestamp(post.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header con avatar y nombre
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueAccent,
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
                ),
              ),
              Text(
                'completó un entrenamiento',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.fitness_center,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ],
    );
  }

  /// Información del entrenamiento
  Widget _buildWorkoutInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Enfoque
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                post.workout.focus,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Duración',
                '${post.workout.duration} min',
                Icons.timer,
                isDark,
              ),
              _buildStatItem(
                'Ejercicios',
                '${post.workout.exercises.length}',
                Icons.fitness_center,
                isDark,
              ),
              _buildStatItem(
                'Series',
                '${post.workout.totalSets}',
                Icons.repeat,
                isDark,
              ),
              _buildStatItem(
                'Volumen',
                '${post.workout.totalVolume.toStringAsFixed(0)} kg',
                Icons.scale,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Lista de ejercicios colapsada
  Widget _buildExercisesList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicios',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...post.workout.exercises.take(3).map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${exercise.name} - ${exercise.sets.length} series',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (post.workout.exercises.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${post.workout.exercises.length - 3} más',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Acciones (like, comment)
  Widget _buildActions(bool isLiked, bool isDark) {
    return Row(
      children: [
        // Like
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked
                      ? Colors.red
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 22,
                ),
                if (post.likes.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Comment
        InkWell(
          onTap: () {
            if (onComment != null) {
              onComment!();
            }
            Get.bottomSheet(
              CommentsBottomSheet(postId: post.id),
              isScrollControlled:
                  true, // Permite que el bottom sheet ocupe casi toda la pantalla
              backgroundColor: Colors.transparent,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 22,
                ),
                if (post.commentsCount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentsCount}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Spacer() // Eliminado

        // Share (eliminado)
        // InkWell(
        //   onTap: onShare,
        //   borderRadius: BorderRadius.circular(20),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     child: Icon(
        //       Icons.share_outlined,
        //       color: isDark ? Colors.grey[400] : Colors.grey[600],
        //       size: 22,
        //     ),
        //   ),
        // ),
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
}
