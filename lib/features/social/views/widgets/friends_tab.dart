import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';

/// Tab de amigos
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin amigos aún',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca y agrega amigos para comenzar',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => controller.changeTab(3),
                icon: const Icon(Icons.search),
                label: const Text('Buscar amigos'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.friends.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final friendship = controller.friends[index];

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
              backgroundImage: friendship.friendPhotoUrl != null
                  ? NetworkImage(friendship.friendPhotoUrl!)
                  : null,
              child: friendship.friendPhotoUrl == null
                  ? Icon(
                      Icons.person,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                    )
                  : null,
            ),
            title: Text(
              friendship.friendDisplayName ??
                  '@${friendship.friendUsername ?? "usuario"}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: friendship.friendBio != null
                ? Text(
                    friendship.friendBio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  )
                : Text(
                    '@${friendship.friendUsername ?? ""}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              onSelected: (value) {
                if (value == 'remove') {
                  controller.removeFriend(
                    friendship.friendId,
                    friendship.friendDisplayName ??
                        friendship.friendUsername ??
                        'este usuario',
                  );
                } else if (value == 'block') {
                  controller.blockUser(
                    friendship.friendId,
                    friendship.friendUsername ?? 'este usuario',
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 20),
                      SizedBox(width: 12),
                      Text('Eliminar amistad'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Bloquear', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navegar al perfil del amigo
            },
          );
        },
      );
    });
  }
}
