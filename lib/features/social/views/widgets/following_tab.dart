import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/social/views/pages/user_profile_page.dart';

/// Tab de usuarios que sigues con diseño minimalista
class FollowingTab extends StatelessWidget {
  const FollowingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.following.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.following.length,
        itemBuilder: (context, index) {
          final following = controller.following[index];
          return _buildFollowingCard(following, isDark, index, controller);
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
              Icons.person_add_outlined,
              size: 40,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No sigues a nadie aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busca usuarios para seguir y ver sus entrenamientos',
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

  Widget _buildFollowingCard(
    dynamic following,
    bool isDark,
    int index,
    SocialController controller,
  ) {
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
            child: following.followingPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      following.followingPhotoUrl!,
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
                  following.followingDisplayName ??
                      '@${following.followingUsername ?? "usuario"}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${following.followingUsername ?? ""}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          Row(
            children: [
              // Botón para ver perfil
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => UserProfilePage(
                      userId: following.followingId,
                      username: following.followingUsername ?? 'usuario',
                      displayName: following.followingDisplayName,
                      photoUrl: following.followingPhotoUrl,
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
                    Icons.person,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Botón de dejar de seguir
              GestureDetector(
                onTap: () {
                  controller.unfollowUser(
                    following.followingId,
                    following.followingUsername ?? 'este usuario',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Dejar de seguir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
