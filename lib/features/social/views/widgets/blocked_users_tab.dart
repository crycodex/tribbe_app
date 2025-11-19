import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/shared/models/friendship_models.dart';

/// Tab para mostrar usuarios bloqueados
class BlockedUsersTab extends StatelessWidget {
  const BlockedUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final blockedUsers = controller.blockedUsers;

      if (blockedUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 64,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay usuarios bloqueados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Los usuarios que bloquees aparecerán aquí',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blockedUsers.length,
        itemBuilder: (context, index) {
          final blockedUser = blockedUsers[index];
          return _buildBlockedUserCard(
            context,
            blockedUser,
            controller,
            isDark,
          );
        },
      );
    });
  }

  Widget _buildBlockedUserCard(
    BuildContext context,
    BlockedUser blockedUser,
    SocialController controller,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Foto de perfil
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              shape: BoxShape.circle,
              image: blockedUser.blockedPhotoUrl != null &&
                      blockedUser.blockedPhotoUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(blockedUser.blockedPhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: blockedUser.blockedPhotoUrl == null ||
                    blockedUser.blockedPhotoUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 25,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockedUser.blockedDisplayName ??
                      blockedUser.blockedUsername ??
                      'Usuario',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (blockedUser.blockedUsername != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${blockedUser.blockedUsername}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Botón de desbloquear
          TextButton(
            onPressed: () {
              final username = blockedUser.blockedUsername ?? 'usuario';
              controller.unblockUser(blockedUser.blockedUserId, username);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }
}

