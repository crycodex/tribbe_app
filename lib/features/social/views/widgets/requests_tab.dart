import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';

/// Tab de solicitudes de amistad
class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final receivedRequests = controller.receivedRequests;
      final sentRequests = controller.sentRequests;

      if (receivedRequests.isEmpty && sentRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline,
                size: 64,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin solicitudes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No tienes solicitudes de amistad',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Solicitudes recibidas
          if (receivedRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recibidas (${receivedRequests.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ...receivedRequests.map((request) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      backgroundImage: request.senderPhotoUrl != null
                          ? NetworkImage(request.senderPhotoUrl!)
                          : null,
                      child: request.senderPhotoUrl == null
                          ? Icon(
                              Icons.person,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade500,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.senderDisplayName ??
                                '@${request.senderUsername ?? "usuario"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '@${request.senderUsername ?? ""}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              controller.acceptFriendRequest(request.id),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          tooltip: 'Aceptar',
                        ),
                        IconButton(
                          onPressed: () =>
                              controller.rejectFriendRequest(request.id),
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Rechazar',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],

          // Solicitudes enviadas
          if (sentRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Enviadas (${sentRequests.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ...sentRequests.map((request) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      backgroundImage: request.receiverPhotoUrl != null
                          ? NetworkImage(request.receiverPhotoUrl!)
                          : null,
                      child: request.receiverPhotoUrl == null
                          ? Icon(
                              Icons.person,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade500,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.receiverDisplayName ??
                                '@${request.receiverUsername ?? "usuario"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Solicitud pendiente',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          controller.cancelFriendRequest(request.receiverId),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      );
    });
  }
}
