import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';

/// Tab de usuarios bloqueados
class BlockedTab extends StatelessWidget {
  const BlockedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (controller.blockedUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block_outlined,
                size: 64,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin usuarios bloqueados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No has bloqueado a ningún usuario',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.blockedUsers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final blockedUser = controller.blockedUsers[index];

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
              backgroundImage: blockedUser.blockedPhotoUrl != null
                  ? NetworkImage(blockedUser.blockedPhotoUrl!)
                  : null,
              child: blockedUser.blockedPhotoUrl == null
                  ? Icon(
                      Icons.person,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                    )
                  : null,
            ),
            title: Text(
              blockedUser.blockedDisplayName ??
                  '@${blockedUser.blockedUsername ?? "usuario"}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              '@${blockedUser.blockedUsername ?? ""}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            trailing: TextButton(
              onPressed: () => controller.unblockUser(
                blockedUser.blockedUserId,
                blockedUser.blockedUsername ?? 'este usuario',
              ),
              child: const Text('Desbloquear'),
            ),
          );
        },
      );
    });
  }
}
