import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/features/training/views/widgets/comments_bottom_sheet.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';

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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header estilo Instagram
          _buildInstagramHeader(isDark),

          // Foto del entrenamiento si existe (estilo Instagram)
          if (post.workoutPhotoUrl != null && post.workoutPhotoUrl!.isNotEmpty)
            _buildWorkoutPhoto(),

          // Acciones rápidas (Like, Comment) - Estilo Instagram
          _buildQuickActions(isLiked, isDark),

          // Información del entrenamiento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption si existe
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${post.userName} ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: post.caption!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Stats compactas estilo gym
                _buildCompactStats(isDark, focusColor),

                const SizedBox(height: 12),

                // Timestamp
                _buildTimestamp(isDark),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header estilo Instagram simple
  Widget _buildInstagramHeader(bool isDark) {
    final isOwnPost = currentUserId != null && currentUserId == post.userId;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar - tap para ver perfil
          GestureDetector(
            onTap: () => _navigateToUserProfile(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: post.userPhotoUrl != null
                  ? NetworkImage(post.userPhotoUrl!)
                  : null,
              child: post.userPhotoUrl == null
                  ? Text(
                      post.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Nombre de usuario - tap para ver perfil
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _formatTimestamp(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menú de opciones
          IconButton(
            onPressed: () => _showPostOptions(isDark, isOwnPost),
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Acciones rápidas estilo Instagram con contadores
  Widget _buildQuickActions(bool isLiked, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Like button con contador
          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : (isDark ? Colors.white : Colors.black),
                  size: 28,
                ),
              ),
              if (post.likes.isNotEmpty)
                Text(
                  '${post.likes.length}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Comment button con contador
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (onComment != null) {
                    onComment!();
                  }
                  Get.bottomSheet(
                    CommentsBottomSheet(postId: post.id),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: isDark ? Colors.white : Colors.black,
                  size: 26,
                ),
              ),
              if (post.commentsCount > 0)
                Text(
                  '${post.commentsCount}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Ver detalle
          IconButton(
            onPressed: () => _navigateToWorkoutDetail(),
            icon: Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Stats compactas estilo gym
  Widget _buildCompactStats(bool isDark, Color focusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.schedule,
            '${post.workout.duration} min',
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            Icons.fitness_center,
            '${post.workout.exercises.length} ejercicios',
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            Icons.repeat,
            '${post.workout.totalSets} series',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 16,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }


  /// Foto del entrenamiento con overlay de info (estilo Instagram con AspectRatio fijo)
  Widget _buildWorkoutPhoto() {
    final focusColor = WorkoutUtils.getFocusColor(post.workout.focus);
    
    return AspectRatio(
      aspectRatio: 4 / 5, // Mismo ratio que Instagram (4:5)
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto de fondo
          Image.network(
            post.workoutPhotoUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),

          // Gradiente sutil en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge del tipo de entrenamiento
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: focusColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          WorkoutUtils.getFocusIcon(post.workout.focus),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.workout.focus.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Ejercicios sobre la foto
                  ..._buildPhotoOverlayExercises(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de ejercicios sobre la foto
  List<Widget> _buildPhotoOverlayExercises() {
    final exercisesToShow = post.workout.exercises.take(3).toList();
    final hasMore = post.workout.exercises.length > 3;

    return [
      ...exercisesToShow.map((exercise) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${exercise.name} • ${exercise.sets.length} series',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )),
      if (hasMore)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '+${post.workout.exercises.length - 3} ejercicios más',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
    ];
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
      arguments: {'workoutPost': post},
    );
  }

  /// Navegar al perfil del usuario
  void _navigateToUserProfile() {
    // Si es el perfil propio, no navegar
    if (currentUserId != null && currentUserId == post.userId) {
      Get.toNamed(RoutePaths.profile);
      return;
    }

    // TODO: Implementar navegación a perfil de otro usuario
    // Por ahora solo mostramos un mensaje
    Get.snackbar(
      'Perfil',
      'Ver perfil de ${post.userName}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Mostrar menú de opciones del post
  void _showPostOptions(bool isDark, bool isOwnPost) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  isOwnPost ? 'Opciones' : 'Opciones del post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              const Divider(height: 1),

              // Opciones
              if (!isOwnPost) ...[
                _buildOptionTile(
                  icon: Icons.person_outline,
                  title: 'Ver perfil',
                  isDark: isDark,
                  onTap: () {
                    Get.back();
                    _navigateToUserProfile();
                  },
                ),
                _buildOptionTile(
                  icon: Icons.person_remove_outlined,
                  title: 'Dejar de seguir',
                  isDark: isDark,
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    _showUnfollowConfirmation(isDark);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.visibility_off_outlined,
                  title: 'Ocultar este post',
                  isDark: isDark,
                  onTap: () {
                    Get.back();
                    _hidePost();
                  },
                ),
              ] else ...[
                _buildOptionTile(
                  icon: Icons.delete_outline,
                  title: 'Eliminar entrenamiento',
                  isDark: isDark,
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation(isDark);
                  },
                ),
              ],

              _buildOptionTile(
                icon: Icons.report_outlined,
                title: 'Reportar',
                isDark: isDark,
                onTap: () {
                  Get.back();
                  _reportPost();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  /// Widget para item de opción del menú
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    Color? color,
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? (isDark ? Colors.white : Colors.black);

    return ListTile(
      leading: Icon(icon, color: itemColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: itemColor,
        ),
      ),
      onTap: onTap,
    );
  }

  /// Mostrar confirmación para dejar de seguir
  void _showUnfollowConfirmation(bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          'Dejar de seguir',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          '¿Dejar de seguir a ${post.userName}?',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _unfollowUser();
            },
            child: const Text(
              'Dejar de seguir',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar confirmación para eliminar post
  void _showDeleteConfirmation(bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text(
          'Eliminar entrenamiento',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este entrenamiento? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deletePost();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dejar de seguir usuario
  void _unfollowUser() {
    // TODO: Implementar lógica de dejar de seguir
    Get.snackbar(
      'Dejaste de seguir',
      'Ya no verás posts de ${post.userName}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }

  /// Ocultar post
  void _hidePost() {
    Get.snackbar(
      'Post oculto',
      'No volverás a ver este post',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
    // TODO: Implementar lógica de ocultar post
  }

  /// Eliminar post propio
  void _deletePost() {
    Get.snackbar(
      'Entrenamiento eliminado',
      'Tu entrenamiento ha sido eliminado',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
    // TODO: Implementar lógica de eliminar post
  }

  /// Reportar post
  void _reportPost() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reportar post'),
        content: const Text('¿Por qué deseas reportar este post?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Reporte enviado',
                'Gracias por ayudarnos a mantener la comunidad segura',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Enviar reporte',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
