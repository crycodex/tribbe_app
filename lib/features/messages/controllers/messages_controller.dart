import 'dart:async';
import 'package:get/get.dart';
import 'package:tribbe_app/features/messages/models/conversation_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/message_service.dart';

/// Controller para la lista de conversaciones
class MessagesController extends GetxController {
  final MessageService _messageService = Get.find();
  final FirebaseAuthService _authService = Get.find();

  /// Lista de conversaciones
  final conversations = <ConversationModel>[].obs;

  /// Estado de carga
  final isLoading = false.obs;

  /// Total de mensajes no leídos
  final totalUnreadCount = 0.obs;

  /// Subscripciones
  StreamSubscription<List<ConversationModel>>? _conversationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeConversations();
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.onClose();
  }

  /// Inicializar conversaciones
  void _initializeConversations() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;

    // Escuchar conversaciones
    _conversationsSubscription = _messageService
        .getConversationsStream(userId)
        .listen(
          (conversationsList) {
            conversations.value = conversationsList;
            isLoading.value = false;
          },
          onError: (error) {
            print('Error loading conversations: $error');
            isLoading.value = false;
            Get.snackbar(
              'Error',
              'No se pudieron cargar las conversaciones',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );

    // Escuchar contador de no leídos
    _unreadCountSubscription = _messageService
        .getTotalUnreadCountStream(userId)
        .listen((count) {
          totalUnreadCount.value = count;
        });
  }

  /// Refrescar conversaciones
  Future<void> refreshConversations() async {
    // Las conversaciones se actualizan automáticamente con el stream
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Conversaciones normales (no bloqueadas)
  List<ConversationModel> get normalConversations {
    return conversations.where((c) => !c.isBlocked).toList();
  }

  /// Conversaciones bloqueadas
  List<ConversationModel> get blockedConversations {
    return conversations.where((c) => c.isBlocked).toList();
  }

  /// Bloquear conversación
  Future<void> blockConversation(ConversationModel conversation) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _messageService.blockConversation(
        userId: userId,
        conversationId: conversation.id,
      );

      Get.snackbar(
        'Chat bloqueado',
        'Ya no recibirás notificaciones de ${conversation.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error blocking conversation: $e');
      Get.snackbar(
        'Error',
        'No se pudo bloquear el chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Desbloquear conversación
  Future<void> unblockConversation(ConversationModel conversation) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _messageService.unblockConversation(
        userId: userId,
        conversationId: conversation.id,
      );

      Get.snackbar(
        'Chat desbloqueado',
        'Has reactivado el chat con ${conversation.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error unblocking conversation: $e');
      Get.snackbar(
        'Error',
        'No se pudo desbloquear el chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Eliminar conversación
  Future<void> deleteConversation(ConversationModel conversation) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _messageService.deleteConversation(
        userId: userId,
        conversationId: conversation.id,
      );

      Get.snackbar(
        'Conversación eliminada',
        'La conversación con ${conversation.displayName} ha sido eliminada',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error deleting conversation: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la conversación',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Obtener conversación por ID
  ConversationModel? getConversationById(String conversationId) {
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  /// Limpiar mensajes expirados usando Cloud Function
  Future<void> cleanExpiredMessages() async {
    try {
      isLoading.value = true;

      final result = await _messageService.cleanExpiredMessages();

      Get.snackbar(
        'Limpieza completada',
        'Se eliminaron ${result['deletedMessages']} mensajes expirados',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Refrescar conversaciones después de la limpieza
      await refreshConversations();
    } catch (e) {
      print('Error cleaning expired messages: $e');
      Get.snackbar(
        'Error',
        'No se pudieron limpiar los mensajes expirados',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
