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
  final FirebaseAuthService _authService = Get.find();
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

  /// Controlador del campo de texto
  final textController = TextEditingController();

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
    scrollController.dispose();
    super.onClose();
  }

  /// Inicializar chat
  void _initializeChat() {
    final currentUserId = _authService.currentUser?.uid;
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
  }

  /// Enviar mensaje
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final currentUser = _authService.currentUser;
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
    final currentUserId = _authService.currentUser?.uid;
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

  /// Verificar si un mensaje es del usuario actual
  bool isMyMessage(MessageModel message) {
    return message.senderId == _authService.currentUser?.uid;
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
