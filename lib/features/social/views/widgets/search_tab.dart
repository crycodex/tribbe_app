import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';

/// Tab de búsqueda de usuarios
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Barra de búsqueda
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
          ),
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Buscar por @usuario o UID',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => controller.searchUsers(value),
          ),
        ),

        // Resultados de búsqueda
        Expanded(
          child: Obx(() {
            if (controller.isSearching.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.searchResults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Busca amigos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa un @usuario o UID para buscar',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.searchResults.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final user = controller.searchResults[index];

                return FutureBuilder<bool>(
                  future: controller.isFollowingUser(user.id),
                  builder: (context, snapshot) {
                    final isFollowing = snapshot.data ?? false;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Icon(
                                Icons.person,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade500,
                              )
                            : null,
                      ),
                      title: Text(
                        user.displayName ?? '@${user.username ?? "usuario"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${user.username ?? ""}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (user.bio != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.bio!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: _buildActionButton(
                        context,
                        user.id,
                        isFollowing,
                        user.username ?? 'usuario',
                        controller,
                      ),
                      onTap: () {
                        // TODO: Navegar al perfil del usuario
                      },
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String userId,
    bool isFollowing,
    String username,
    SocialController controller,
  ) {
    // Si ya lo sigue, mostrar botón para dejar de seguir
    if (isFollowing) {
      return OutlinedButton(
        onPressed: () => controller.unfollowUser(userId, username),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Siguiendo', style: TextStyle(fontSize: 12)),
      );
    }

    // Botón para seguir
    return ElevatedButton.icon(
      onPressed: () => controller.followUser(userId),
      icon: const Icon(Icons.person_add_outlined, size: 16),
      label: const Text('Seguir', style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
