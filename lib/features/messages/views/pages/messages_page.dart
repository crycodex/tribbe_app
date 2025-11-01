import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tribbe_app/features/messages/controllers/messages_controller.dart';
import 'package:tribbe_app/features/messages/views/pages/chat_page.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/friendship_service.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/shared/services/social_service.dart';
import 'package:tribbe_app/shared/models/social_models.dart';

/// Página principal de mensajes - Lista de conversaciones
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessagesController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Mensajes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: false,
          actions: [
            // Buscar usuarios para iniciar chat directo
            IconButton(
              onPressed: () => _showUserSearchSheet(context),
              icon: const Icon(Icons.search),
              tooltip: 'Buscar usuarios',
            ),
            // Badge de mensajes no leídos
            Obx(() {
              if (controller.totalUnreadCount.value == 0) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.totalUnreadCount.value > 99
                        ? '99+'
                        : controller.totalUnreadCount.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: isDark ? Colors.white : Colors.black,
            tabs: const [
              Tab(text: 'Chats'),
              Tab(text: 'Bloqueados'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.conversations.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final normal = controller.normalConversations;
          final blocked = controller.blockedConversations;

          return TabBarView(
            children: [
              // Tab de Chats normales
              RefreshIndicator(
                onRefresh: controller.refreshConversations,
                child: normal.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: normal.length,
                        itemBuilder: (context, index) {
                          final conversation = normal[index];
                          return _buildConversationCard(
                            conversation: conversation,
                            isDark: isDark,
                            theme: theme,
                            controller: controller,
                          );
                        },
                      ),
              ),

              // Tab de Chats bloqueados
              RefreshIndicator(
                onRefresh: controller.refreshConversations,
                child: blocked.isEmpty
                    ? Center(
                        child: Text(
                          'Sin chats bloqueados',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: blocked.length,
                        itemBuilder: (context, index) {
                          final conversation = blocked[index];
                          return _buildConversationCard(
                            conversation: conversation,
                            isDark: isDark,
                            theme: theme,
                            controller: controller,
                            isBlocked: true,
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.message_outlined,
              size: 50,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin mensajes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Los mensajes duran 7 días y luego se eliminan\nautomáticamente',
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

  /// Tarjeta de conversación
  Widget _buildConversationCard({
    required dynamic conversation,
    required bool isDark,
    required ThemeData theme,
    required MessagesController controller,
    bool isBlocked = false,
  }) {
    // Obtener el ID del usuario actual a través de Get.find
    final authService = Get.find<FirebaseAuthService>();
    final currentUserId = authService.currentUser?.uid ?? '';
    final isLastMessageFromMe =
        conversation.lastMessageSenderId == currentUserId;
    final hasUnread = conversation.unreadCount > 0;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        controller.deleteConversation(conversation);
      },
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => ChatPage(
              otherUserId: conversation.otherUserId,
              otherUsername: conversation.otherUserUsername,
              otherUserPhotoUrl: conversation.otherUserPhotoUrl,
              otherUserDisplayName: conversation.otherUserDisplayName,
            ),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 300),
          );
        },
        onLongPress: () {
          // Opciones: bloquear/desbloquear y eliminar
          final List<Map<String, dynamic>> options = [];
          if (conversation.isBlocked == true) {
            options.add({
              'title': 'Desbloquear chat',
              'action': () => controller.unblockConversation(conversation),
            });
          } else {
            options.add({
              'title': 'Bloquear chat',
              'action': () => controller.blockConversation(conversation),
            });
          }
          options.add({
            'title': 'Eliminar chat',
            'action': () => controller.deleteConversation(conversation),
          });

          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  return ListTile(
                    title: Text(option['title'] as String),
                    onTap: () {
                      Get.back();
                      (option['action'] as VoidCallback)();
                    },
                  );
                }).toList(),
              ),
            ),
            backgroundColor: Get.theme.cardColor,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (conversation.isBlocked == true)
                  ? Colors.red.withValues(alpha: 0.25)
                  : hasUnread
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05)),
              width: (conversation.isBlocked == true)
                  ? 1.0
                  : hasUnread
                  ? 1.5
                  : 0.5,
            ),
            boxShadow: hasUnread
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      border: Border.all(
                        color: (conversation.isBlocked == true)
                            ? Colors.red
                            : hasUnread
                            ? theme.colorScheme.primary
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1)),
                        width: hasUnread ? 2 : 1,
                      ),
                    ),
                    child: conversation.otherUserPhotoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              conversation.otherUserPhotoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 28,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                  ),
                  // Indicador de no leído
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF0A0A0A)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            conversation.unreadCount > 9
                                ? '9+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: (conversation.isBlocked == true)
                                  ? FontWeight.w500
                                  : hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(conversation.lastMessageTimestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: (conversation.isBlocked == true)
                                ? Colors.red
                                : hasUnread
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white38 : Colors.black38),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (isLastMessageFromMe) ...[
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            conversation.isBlocked == true
                                ? 'Chat bloqueado'
                                : conversation.lastMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: (conversation.isBlocked == true)
                                  ? Colors.red.withValues(alpha: 0.8)
                                  : hasUnread
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white38 : Colors.black38),
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Indicador de expiración
                    Row(
                      children: [
                        Icon(
                          conversation.isBlocked == true
                              ? Icons.block
                              : Icons.timer_outlined,
                          size: 12,
                          color: conversation.isBlocked == true
                              ? Colors.red.withValues(alpha: 0.6)
                              : (isDark ? Colors.white24 : Colors.black26),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          conversation.isBlocked == true
                              ? 'Bloqueado'
                              : 'Expira en ${conversation.daysRemaining} ${conversation.daysRemaining == 1 ? "día" : "días"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: conversation.isBlocked == true
                                ? Colors.red.withValues(alpha: 0.6)
                                : (isDark ? Colors.white24 : Colors.black26),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatear timestamp
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.Hm().format(date);
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return DateFormat.E('es').format(date);
    } else {
      return DateFormat.MMMd('es').format(date);
    }
  }

  /// Hoja inferior para buscar usuarios y abrir chat directo
  void _showUserSearchSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final friendshipService = Get.find<FriendshipService>();
    final socialService = Get.find<SocialService>();
    final TextEditingController searchController = TextEditingController();
    final RxList<UserModel> results = <UserModel>[].obs;
    final RxBool isSearching = false.obs;
    final RxList<FollowRelation> followingList = <FollowRelation>[].obs;
    final RxList<FollowRelation> followersList = <FollowRelation>[].obs;

    // Suscripciones para sugerencias iniciales
    socialService.getFollowing().listen((list) => followingList.value = list);
    socialService.getFollowers().listen((list) => followersList.value = list);

    void performSearch(String query) async {
      if (query.trim().length < 2) {
        results.clear();
        return;
      }
      isSearching.value = true;
      final users = await friendshipService.searchUsers(query);
      results.value = users;
      isSearching.value = false;
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Buscar usuarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Caja de búsqueda
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  hintText: 'Busca por @usuario...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: performSearch,
              ),
            ),
            const SizedBox(height: 12),
            // Resultados o sugerencias
            Expanded(
              child: Obx(() {
                final hasQuery = searchController.text.trim().isNotEmpty;
                if (hasQuery) {
                  if (isSearching.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (results.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    );
                  }
                  return _buildUsersList(
                    context: context,
                    isDark: isDark,
                    users: results
                        .map(
                          (u) => (
                            id: u.id,
                            displayName:
                                u.displayName ?? '@${u.username ?? 'usuario'}',
                            username: u.username,
                            photoUrl: u.photoUrl,
                          ),
                        )
                        .toList(),
                  );
                }

                // Sugerencias iniciales: unión de seguidos y seguidores
                final Map<
                  String,
                  ({String? displayName, String? username, String? photoUrl})
                >
                suggestions = {};
                for (final rel in followingList) {
                  suggestions[rel.followingId] = (
                    displayName:
                        rel.followingDisplayName ??
                        (rel.followingUsername != null
                            ? '@${rel.followingUsername}'
                            : null),
                    username: rel.followingUsername,
                    photoUrl: rel.followingPhotoUrl,
                  );
                }
                for (final rel in followersList) {
                  final existing = suggestions[rel.followerId];
                  suggestions[rel.followerId] = (
                    displayName:
                        existing?.displayName ??
                        rel.followerDisplayName ??
                        (rel.followerUsername != null
                            ? '@${rel.followerUsername}'
                            : null),
                    username: existing?.username ?? rel.followerUsername,
                    photoUrl: existing?.photoUrl ?? rel.followerPhotoUrl,
                  );
                }

                if (suggestions.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay seguidores ni seguidos aún',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  );
                }

                final list = suggestions.entries
                    .map(
                      (e) => (
                        id: e.key,
                        displayName: e.value.displayName ?? 'Usuario',
                        username: e.value.username,
                        photoUrl: e.value.photoUrl,
                      ),
                    )
                    .toList();

                return _buildUsersList(
                  context: context,
                  isDark: isDark,
                  users: list,
                );
              }),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// Lista reutilizable para mostrar usuarios y abrir chat
  Widget _buildUsersList({
    required BuildContext context,
    required bool isDark,
    required List<
      ({String id, String displayName, String? username, String? photoUrl})
    >
    users,
  }) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      itemBuilder: (ctx, i) {
        final user = users[i];
        return ListTile(
          onTap: () {
            Get.back();
            Get.to(
              () => ChatPage(
                otherUserId: user.id,
                otherUsername: user.username ?? 'usuario',
                otherUserPhotoUrl: user.photoUrl,
                otherUserDisplayName: user.displayName,
              ),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 300),
            );
          },
          leading: CircleAvatar(
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Icon(
                    Icons.person,
                    color: isDark ? Colors.white38 : Colors.black38,
                  )
                : null,
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: user.username != null
              ? Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        );
      },
    );
  }
}
