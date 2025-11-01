import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/messages/views/pages/chat_page.dart';

/// Página de perfil de usuario - Estilo Instagram Minimalista
class UserProfilePage extends StatelessWidget {
  final String userId;
  final String username;
  final String? displayName;
  final String? photoUrl;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // AppBar con nombre de usuario y botón de seguir
              SliverAppBar(
                backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  '@$username',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  // Botón de seguir/dejar de seguir
                  FutureBuilder<bool>(
                    future: controller.isFollowingUser(userId),
                    builder: (context, snapshot) {
                      final isFollowing = snapshot.data ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            if (isFollowing) {
                              controller.unfollowUser(userId, username);
                            } else {
                              controller.followUser(userId);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isFollowing
                                  ? (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.05))
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                              border: isFollowing
                                  ? Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.1),
                                      width: 0.5,
                                    )
                                  : null,
                            ),
                            child: Text(
                              isFollowing ? 'Siguiendo' : 'Seguir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isFollowing
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () async {
              // TODO: Recargar datos del usuario
            },
            child: CustomScrollView(
              slivers: [
                // Header del perfil
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Foto de perfil + Stats
                        Row(
                          children: [
                            // Foto de perfil
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                                image: photoUrl != null && photoUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(photoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: photoUrl == null || photoUrl!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 45,
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade500,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 24),

                            // Estadísticas (simuladas por ahora)
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    context,
                                    value: '0', // TODO: Obtener del usuario
                                    label: 'Posts',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    value: '0', // TODO: Obtener del usuario
                                    label: 'Seguidores',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    value: '0', // TODO: Obtener del usuario
                                    label: 'Siguiendo',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Nombre completo
                        if (displayName != null && displayName!.isNotEmpty)
                          Text(
                            displayName!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Bio (simulada por ahora)
                        Text(
                          'Entusiasta del fitness y la vida saludable 💪',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botones de acción
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navegar a chat
                                  Get.to(
                                    () => ChatPage(
                                      otherUserId: userId,
                                      otherUsername: username,
                                      otherUserPhotoUrl: photoUrl,
                                      otherUserDisplayName: displayName,
                                    ),
                                    transition: Transition.cupertino,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Mensaje',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                // TODO: Compartir perfil
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.share, size: 18),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),

                        const SizedBox(height: 16),

                        // Título de entrenamientos
                        const Text(
                          'Entrenamientos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Grilla de entrenamientos del usuario
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // TODO: Cargar entrenamientos del usuario
                        if (index == 0) {
                          return _buildEmptyWorkoutCard(isDark);
                        }
                        return null;
                      },
                      childCount:
                          1, // TODO: Cambiar por la cantidad real de entrenamientos
                    ),
                  ),
                ),

                // Espacio al final
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para columna de estadística
  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para card de entrenamiento vacío
  Widget _buildEmptyWorkoutCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 32,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin entrenamientos',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
