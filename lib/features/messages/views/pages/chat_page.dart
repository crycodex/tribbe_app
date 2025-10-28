import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tribbe_app/features/messages/controllers/chat_controller.dart';
import 'package:tribbe_app/features/messages/models/message_model.dart';

/// Página de chat individual
class ChatPage extends StatelessWidget {
  final String otherUserId;
  final String otherUsername;
  final String? otherUserPhotoUrl;
  final String? otherUserDisplayName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUsername,
    this.otherUserPhotoUrl,
    this.otherUserDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatController(
        otherUserId: otherUserId,
        otherUsername: otherUsername,
        otherUserPhotoUrl: otherUserPhotoUrl,
        otherUserDisplayName: otherUserDisplayName,
      ),
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              child: otherUserPhotoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        otherUserPhotoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 24,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
            ),
            const SizedBox(width: 12),
            // Nombre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserDisplayName ?? '@$otherUsername',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(() {
                    if (controller.messages.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      controller.expirationInfo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMyMessage = controller.isMyMessage(message);

                  // Mostrar fecha si es necesario
                  bool showDate = false;
                  if (index == 0) {
                    showDate = true;
                  } else {
                    final previousMessage = controller.messages[index - 1];
                    final currentDate = DateTime.fromMillisecondsSinceEpoch(
                      message.timestamp,
                    );
                    final previousDate = DateTime.fromMillisecondsSinceEpoch(
                      previousMessage.timestamp,
                    );

                    if (currentDate.day != previousDate.day ||
                        currentDate.month != previousDate.month ||
                        currentDate.year != previousDate.year) {
                      showDate = true;
                    }
                  }

                  return Column(
                    children: [
                      if (showDate) _buildDateSeparator(message, isDark),
                      _buildMessageBubble(
                        message,
                        isMyMessage,
                        isDark,
                        theme,
                        context,
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Campo de texto
          _buildInputField(controller, isDark, theme),
        ],
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Inicia la conversación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los mensajes se eliminan después de 7 días',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Separador de fecha
  Widget _buildDateSeparator(MessageModel message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _formatDate(message.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Burbuja de mensaje
  Widget _buildMessageBubble(
    MessageModel message,
    bool isMyMessage,
    bool isDark,
    ThemeData theme,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del otro usuario (solo si no es mi mensaje)
          if (!isMyMessage) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              child: message.senderPhotoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        message.senderPhotoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 20,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
            ),
          ],

          // Burbuja de mensaje
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: 50,
              ),
              child: GestureDetector(
                onLongPress: () {
                  final controller = Get.find<ChatController>();
                  controller.showReactionSelector(message);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? theme.colorScheme.primary
                        : (isDark ? const Color(0xFF0A0A0A) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMyMessage ? 20 : 4),
                      bottomRight: Radius.circular(isMyMessage ? 4 : 20),
                    ),
                    border: isMyMessage
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            width: 0.5,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reacciones (dentro de la burbuja, arriba del texto)
                      if (message.reactions.isNotEmpty) ...[
                        _buildReactions(message, isMyMessage, isDark, theme),
                        const SizedBox(height: 3),
                      ],

                      // Texto del mensaje
                      Text(
                        message.displayText,
                        style: TextStyle(
                          fontSize: 15,
                          color: isMyMessage
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                          height: 1.4,
                          fontStyle: message.isDeleted
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),

                      // Indicador de edición
                      if (message.isEdited) ...[
                        const SizedBox(height: 2),
                        Text(
                          'editado',
                          style: TextStyle(
                            fontSize: 10,
                            color: isMyMessage
                                ? Colors.white.withValues(alpha: 0.5)
                                : (isDark ? Colors.white38 : Colors.black38),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 2),

                      // Timestamp y estado de lectura
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat.Hm().format(message.dateTime),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMyMessage
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              if (isMyMessage) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.isRead ? Icons.done_all : Icons.done,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ],
                          ),

                          // Botón de opciones para mensajes propios
                          if (isMyMessage)
                            GestureDetector(
                              onTap: () {
                                final controller = Get.find<ChatController>();
                                controller.showMessageOptions(message);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.more_horiz,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar reacciones (simple y claro)
  Widget _buildReactions(
    MessageModel message,
    bool isMyMessage,
    bool isDark,
    ThemeData theme,
  ) {
    if (message.reactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: message.reactionEmojis.map((emoji) {
          final count = message.getReactionCount(emoji);
          final controller = Get.find<ChatController>();
          final currentUserId = controller.authService.currentUser?.uid;
          final hasReacted =
              currentUserId != null &&
              message.hasReaction(currentUserId) &&
              message.getUserReaction(currentUserId) == emoji;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasReacted
                  ? (isMyMessage
                        ? Colors.white.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.2))
                  : (isMyMessage
                        ? Colors.white.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                if (count > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMyMessage
                          ? Colors.white.withValues(alpha: 0.8)
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Campo de entrada de texto
  Widget _buildInputField(
    ChatController controller,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Indicador de edición
            Obx(() {
              if (controller.isEditing.value) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Editando mensaje',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: controller.cancelEdit,
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Campo de texto y botón
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: controller.textController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: controller.isEditing.value
                            ? 'Edita tu mensaje...'
                            : 'Escribe un mensaje...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  return GestureDetector(
                    onTap: controller.isSending.value
                        ? null
                        : controller.sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: controller.isSending.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              controller.isEditing.value
                                  ? Icons.check
                                  : Icons.send,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formatear fecha para separador
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return DateFormat.EEEE('es').format(date);
    } else {
      return DateFormat.yMMMd('es').format(date);
    }
  }
}
