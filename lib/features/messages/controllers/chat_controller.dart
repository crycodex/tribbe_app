import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/messages/models/message_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/message_service.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';

/// Controller para conversación individual
class ChatController extends GetxController {
  final MessageService _messageService = Get.find();
  final FirebaseAuthService authService = Get.find();
  final FirestoreService _firestoreService = Get.find();

  /// Información del otro usuario
  final String otherUserId;
  final String otherUsername;
  final String? otherUserPhotoUrl;
  final String? otherUserDisplayName;

  /// ID de la conversación
  late final String conversationId;

  /// Lista de mensajes
  final messages = <MessageModel>[].obs;

  /// Estado de carga
  final isLoading = false.obs;

  /// Estado de envío
  final isSending = false.obs;

  /// Estado de edición
  final isEditing = false.obs;
  final editingMessageId = RxString('');

  /// Estado de bloqueo del chat
  final isBlocked = false.obs;

  /// Controlador del campo de texto
  final textController = TextEditingController();

  /// Controlador del campo de edición
  final editTextController = TextEditingController();

  /// Controlador del scroll
  final scrollController = ScrollController();

  /// Subscripción a mensajes
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  ChatController({
    required this.otherUserId,
    required this.otherUsername,
    this.otherUserPhotoUrl,
    this.otherUserDisplayName,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    textController.dispose();
    editTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Inicializar chat
  void _initializeChat() {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;

    // Crear ID de conversación
    conversationId = _messageService.createConversationId(
      currentUserId,
      otherUserId,
    );

    isLoading.value = true;

    // Escuchar mensajes
    _messagesSubscription = _messageService
        .getMessagesStream(conversationId)
        .listen(
          (messagesList) {
            messages.value = messagesList;
            isLoading.value = false;

            // Scroll al final cuando lleguen mensajes nuevos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          },
          onError: (error) {
            print('Error loading messages: $error');
            isLoading.value = false;
            Get.snackbar(
              'Error',
              'No se pudieron cargar los mensajes',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );

    // Marcar mensajes como leídos
    _markAsRead();

    // Cargar estado de bloqueo
    _loadBlockedState();
  }

  /// Enviar mensaje
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // Si está en modo edición, guardar la edición
    if (isEditing.value) {
      await saveEdit();
      return;
    }

    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    try {
      isSending.value = true;

      // Obtener información del usuario actual desde Firestore
      final userDoc = await _firestoreService.getUserProfile(currentUser.uid);
      final currentUsername =
          userDoc?.datosPersonales?.nombreUsuario ?? 'usuario';
      final currentUserPhotoUrl = userDoc?.personaje?.avatarUrl;

      await _messageService.sendMessage(
        conversationId: conversationId,
        senderId: currentUser.uid,
        senderUsername: currentUsername,
        senderPhotoUrl: currentUserPhotoUrl,
        receiverId: otherUserId,
        receiverUsername: otherUsername,
        receiverPhotoUrl: otherUserPhotoUrl,
        receiverDisplayName: otherUserDisplayName,
        text: text,
      );

      // Limpiar campo de texto
      textController.clear();

      // Scroll al final
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'No se pudo enviar el mensaje',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Marcar mensajes como leídos
  Future<void> _markAsRead() async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      await _messageService.markMessagesAsRead(
        conversationId: conversationId,
        userId: currentUserId,
      );
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Scroll al final de la lista
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Cargar estado bloqueado de la conversación
  Future<void> _loadBlockedState() async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;
    try {
      final conversation = await _messageService.getConversation(
        userId: currentUserId,
        conversationId: conversationId,
      );
      if (conversation != null) {
        isBlocked.value = conversation.isBlocked;
      }
    } catch (e) {
      // noop
    }
  }

  /// Bloquear conversación
  Future<void> blockConversation() async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;
    try {
      await _messageService.blockConversation(
        userId: currentUserId,
        conversationId: conversationId,
      );
      isBlocked.value = true;
      Get.snackbar(
        'Chat bloqueado',
        'Ya no recibirás notificaciones de este chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo bloquear el chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Desbloquear conversación
  Future<void> unblockConversation() async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;
    try {
      await _messageService.unblockConversation(
        userId: currentUserId,
        conversationId: conversationId,
      );
      isBlocked.value = false;
      Get.snackbar(
        'Chat desbloqueado',
        'Has reactivado este chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo desbloquear el chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Eliminar conversación (solo para el usuario actual)
  Future<void> deleteConversation() async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;
    try {
      await _messageService.deleteConversation(
        userId: currentUserId,
        conversationId: conversationId,
      );
      Get.back();
      Get.snackbar(
        'Conversación eliminada',
        'El chat ha sido eliminado para ti',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Verificar si un mensaje es del usuario actual
  bool isMyMessage(MessageModel message) {
    return message.senderId == authService.currentUser?.uid;
  }

  /// Agregar o quitar reacción a un mensaje
  Future<void> toggleReaction(MessageModel message, String emoji) async {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      await _messageService.toggleReaction(
        conversationId: conversationId,
        messageId: message.id,
        userId: currentUserId,
        emoji: emoji,
      );
    } catch (e) {
      print('Error toggling reaction: $e');
      Get.snackbar(
        'Error',
        'No se pudo agregar la reacción',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Eliminar mensaje
  Future<void> deleteMessage(MessageModel message) async {
    try {
      await _messageService.deleteMessage(
        conversationId: conversationId,
        messageId: message.id,
      );

      Get.snackbar(
        'Mensaje eliminado',
        'El mensaje ha sido eliminado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el mensaje',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Editar mensaje
  Future<void> editMessage(MessageModel message) async {
    isEditing.value = true;
    editingMessageId.value = message.id;
    textController.text = message.displayText;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    // Scroll al final para mostrar el campo de edición
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// Cancelar edición
  void cancelEdit() {
    isEditing.value = false;
    editingMessageId.value = '';
    textController.clear();
  }

  /// Guardar edición
  Future<void> saveEdit() async {
    final text = textController.text.trim();
    if (text.isEmpty) {
      cancelEdit();
      return;
    }

    try {
      await _messageService.editMessage(
        conversationId: conversationId,
        messageId: editingMessageId.value,
        newText: text,
      );

      Get.snackbar(
        'Mensaje editado',
        'El mensaje ha sido actualizado',
        snackPosition: SnackPosition.BOTTOM,
      );

      cancelEdit();
    } catch (e) {
      print('Error editing message: $e');
      Get.snackbar(
        'Error',
        'No se pudo editar el mensaje',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Mostrar selector de reacciones simple
  void showReactionSelector(MessageModel message) {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;

    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de agarre
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text('Reaccionar al mensaje', style: Get.textTheme.titleMedium),
            const SizedBox(height: 20),

            // Emojis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: reactions.map((emoji) {
                final hasReacted =
                    message.hasReaction(currentUserId) &&
                    message.getUserReaction(currentUserId) == emoji;
                return GestureDetector(
                  onTap: () {
                    Get.back();
                    toggleReaction(message, emoji);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: hasReacted
                          ? Get.theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: hasReacted
                            ? Get.theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Mostrar opciones de mensaje (para editar/eliminar)
  void showMessageOptions(MessageModel message) {
    final currentUserId = authService.currentUser?.uid;
    if (currentUserId == null) return;

    final List<Map<String, dynamic>> options = [];

    // Solo opciones del emisor
    if (message.senderId == currentUserId) {
      if (message.canBeEdited(currentUserId)) {
        options.add({'title': 'Editar', 'action': () => editMessage(message)});
      }
      if (message.canBeDeleted(currentUserId)) {
        options.add({
          'title': 'Eliminar',
          'action': () => deleteMessage(message),
        });
      }
    }

    if (options.isEmpty) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option['title']),
              onTap: () {
                Get.back();
                option['action']();
              },
            );
          }).toList(),
        ),
      ),
      backgroundColor: Get.theme.cardColor,
    );
  }

  /// Obtener tiempo restante de expiración del chat
  String get expirationInfo {
    if (messages.isEmpty) return '';

    final lastMessage = messages.last;
    final daysRemaining = lastMessage.daysRemaining;

    if (daysRemaining <= 0) {
      return 'Mensajes expirados';
    } else if (daysRemaining == 1) {
      return 'Expira en 1 día';
    } else {
      return 'Expira en $daysRemaining días';
    }
  }
}
