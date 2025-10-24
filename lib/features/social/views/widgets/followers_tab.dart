import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/social/views/pages/user_profile_page.dart';

/// Tab de seguidores con diseño minimalista
class FollowersTab extends StatelessWidget {
  const FollowersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.followers.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.followers.length,
        itemBuilder: (context, index) {
          final follower = controller.followers[index];
          return _buildFollowerCard(follower, isDark, index);
        },
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.people_outline,
              size: 40,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin seguidores aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparte tu perfil para conseguir seguidores',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowerCard(dynamic follower, bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: follower.followerPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      follower.followerPhotoUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 24,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
          ),

          const SizedBox(width: 16),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  follower.followerDisplayName ??
                      '@${follower.followerUsername ?? "usuario"}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${follower.followerUsername ?? ""}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // Botón de acción
          GestureDetector(
            onTap: () {
              Get.to(
                () => UserProfilePage(
                  userId: follower.followerId,
                  username: follower.followerUsername ?? 'usuario',
                  displayName: follower.followerDisplayName,
                  photoUrl: follower.followerPhotoUrl,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
