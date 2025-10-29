import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/widgets/workout_post_card.dart';

/// Widget del feed de entrenamientos
class WorkoutFeedWidget extends StatelessWidget {
  const WorkoutFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // Título del feed
        _buildFeedTitle(theme),

        const SizedBox(height: 16),

        // Lista de posts
        _buildFeedContent(controller, theme),
      ],
    );
  }

  /// Título del feed
  Widget _buildFeedTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'Feed de Entrenamientos',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  /// Contenido del feed
  Widget _buildFeedContent(DashboardController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isFeedLoading.value) {
        return _buildLoadingState();
      }

      if (controller.feedPosts.isEmpty) {
        return _buildEmptyState(theme);
      }

      return _buildPostsList(controller);
    });
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: theme.brightness == Brightness.dark
                ? Colors.grey[700]
                : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay entrenamientos aún',
            style: TextStyle(
              fontSize: 16,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sé el primero en compartir tu entrenamiento!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de posts
  Widget _buildPostsList(DashboardController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.feedPosts.length,
      itemBuilder: (context, index) {
        final post = controller.feedPosts[index];
        final authService = Get.find<FirebaseAuthService>();
        final currentUserId = authService.currentUser?.uid;

        return WorkoutPostCard(
          post: post,
          currentUserId: currentUserId,
          onLike: () => controller.toggleLike(post.id),
        );
      },
    );
  }
}
