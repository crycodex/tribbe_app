import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tribbe_app/features/messages/models/message_model.dart';
import 'package:tribbe_app/features/messages/models/conversation_model.dart';

/// Servicio para manejar mensajes temporales con Firebase Realtime Database
class MessageService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Referencias a nodos principales
  DatabaseReference get _messagesRef => _database.ref('messages');
  DatabaseReference get _conversationsRef => _database.ref('conversations');

  /// Stream de conversaciones del usuario
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return _conversationsRef
        .child(userId)
        .orderByChild('lastMessageTimestamp')
        .onValue
        .map((event) {
          final conversations = <ConversationModel>[];

          if (event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>,
            );

            data.forEach((key, value) {
              try {
                final conversation = ConversationModel.fromJson(
                  key,
                  Map<dynamic, dynamic>.from(value as Map<dynamic, dynamic>),
                );

                // Solo incluir conversaciones no expiradas
                if (!conversation.isExpired) {
                  conversations.add(conversation);
                }
              } catch (e) {
                print('Error parsing conversation: $e');
              }
            });

            // Ordenar por timestamp descendente (más reciente primero)
            conversations.sort(
              (a, b) =>
                  b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
            );
          }

          return conversations;
        });
  }

  /// Stream de mensajes de una conversación
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _messagesRef
        .child(conversationId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          final messages = <MessageModel>[];

          if (event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>,
            );

            data.forEach((key, value) {
              try {
                final message = MessageModel.fromJson(
                  key,
                  Map<dynamic, dynamic>.from(value as Map<dynamic, dynamic>),
                );

                // Solo incluir mensajes no expirados
                if (!message.isExpired) {
                  messages.add(message);
                }
              } catch (e) {
                print('Error parsing message: $e');
              }
            });

            // Ordenar por timestamp ascendente (más antiguo primero)
            messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          }

          return messages;
        });
  }

  /// Enviar mensaje
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderUsername,
    String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    String? receiverPhotoUrl,
    String? receiverDisplayName,
    required String text,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = MessageModel.calculateExpiresAt();

      // Crear mensaje
      final messageRef = _messagesRef.child(conversationId).push();
      final messageId = messageRef.key!;

      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderUsername: senderUsername,
        senderPhotoUrl: senderPhotoUrl,
        receiverId: receiverId,
        text: text,
        timestamp: timestamp,
        isRead: false,
        expiresAt: expiresAt,
      );

      // Guardar mensaje
      await messageRef.set(message.toJson());

      // Actualizar conversación del emisor
      await _updateConversation(
        userId: senderId,
        otherUserId: receiverId,
        otherUserUsername: receiverUsername,
        otherUserPhotoUrl: receiverPhotoUrl,
        otherUserDisplayName: receiverDisplayName,
        conversationId: conversationId,
        lastMessage: text,
        lastMessageTimestamp: timestamp,
        lastMessageSenderId: senderId,
        expiresAt: expiresAt,
        incrementUnread: false, // No incrementar para el emisor
      );

      // Actualizar conversación del receptor
      await _updateConversation(
        userId: receiverId,
        otherUserId: senderId,
        otherUserUsername: senderUsername,
        otherUserPhotoUrl: senderPhotoUrl,
        otherUserDisplayName: null,
        conversationId: conversationId,
        lastMessage: text,
        lastMessageTimestamp: timestamp,
        lastMessageSenderId: senderId,
        expiresAt: expiresAt,
        incrementUnread: true, // Incrementar para el receptor
      );

      return message;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Actualizar conversación
  Future<void> _updateConversation({
    required String userId,
    required String otherUserId,
    required String otherUserUsername,
    String? otherUserPhotoUrl,
    String? otherUserDisplayName,
    required String conversationId,
    required String lastMessage,
    required int lastMessageTimestamp,
    required String lastMessageSenderId,
    required int expiresAt,
    required bool incrementUnread,
  }) async {
    final conversationRef = _conversationsRef
        .child(userId)
        .child(conversationId);

    // Obtener conversación actual para mantener unreadCount
    final snapshot = await conversationRef.get();
    int currentUnreadCount = 0;

    if (snapshot.exists) {
      final data = Map<dynamic, dynamic>.from(
        snapshot.value as Map<dynamic, dynamic>,
      );
      currentUnreadCount = data['unreadCount'] as int? ?? 0;
    }

    final conversation = ConversationModel(
      id: conversationId,
      userId: userId,
      otherUserId: otherUserId,
      otherUserUsername: otherUserUsername,
      otherUserPhotoUrl: otherUserPhotoUrl,
      otherUserDisplayName: otherUserDisplayName,
      lastMessage: lastMessage,
      lastMessageTimestamp: lastMessageTimestamp,
      lastMessageSenderId: lastMessageSenderId,
      unreadCount: incrementUnread ? currentUnreadCount + 1 : 0,
      expiresAt: expiresAt,
    );

    await conversationRef.set(conversation.toJson());
  }

  /// Marcar mensajes como leídos
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Resetear contador de no leídos en la conversación
      await _conversationsRef
          .child(userId)
          .child(conversationId)
          .child('unreadCount')
          .set(0);

      // Marcar todos los mensajes de la conversación como leídos
      final messagesSnapshot = await _messagesRef.child(conversationId).get();

      if (messagesSnapshot.exists) {
        final data = Map<String, dynamic>.from(
          messagesSnapshot.value as Map<dynamic, dynamic>,
        );

        final updates = <String, dynamic>{};

        data.forEach((key, value) {
          final messageData = Map<dynamic, dynamic>.from(
            value as Map<dynamic, dynamic>,
          );
          final receiverId = messageData['receiverId'] as String?;

          // Solo marcar como leído si es para el usuario actual
          if (receiverId == userId) {
            updates['$key/isRead'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await _messagesRef.child(conversationId).update(updates);
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Crear ID de conversación entre dos usuarios (siempre el mismo orden)
  String createConversationId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  /// Obtener conversación específica
  Future<ConversationModel?> getConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final snapshot = await _conversationsRef
          .child(userId)
          .child(conversationId)
          .get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>,
        );
        return ConversationModel.fromJson(conversationId, data);
      }

      return null;
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  /// Eliminar conversación (solo para el usuario actual)
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      await _conversationsRef.child(userId).child(conversationId).remove();
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  /// Obtener total de mensajes no leídos
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final snapshot = await _conversationsRef.child(userId).get();

      if (!snapshot.exists) return 0;

      final data = Map<String, dynamic>.from(
        snapshot.value as Map<dynamic, dynamic>,
      );

      int total = 0;
      data.forEach((key, value) {
        final conversationData = Map<dynamic, dynamic>.from(
          value as Map<dynamic, dynamic>,
        );
        total += conversationData['unreadCount'] as int? ?? 0;
      });

      return total;
    } catch (e) {
      print('Error getting total unread count: $e');
      return 0;
    }
  }

  /// Stream del total de mensajes no leídos
  Stream<int> getTotalUnreadCountStream(String userId) {
    return _conversationsRef.child(userId).onValue.map((event) {
      if (event.snapshot.value == null) return 0;

      final data = Map<String, dynamic>.from(
        event.snapshot.value as Map<dynamic, dynamic>,
      );

      int total = 0;
      data.forEach((key, value) {
        final conversationData = Map<dynamic, dynamic>.from(
          value as Map<dynamic, dynamic>,
        );
        total += conversationData['unreadCount'] as int? ?? 0;
      });

      return total;
    });
  }

  /// Limpiar mensajes expirados usando Cloud Function
  Future<Map<String, dynamic>> cleanExpiredMessages() async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('cleanExpiredMessagesManual');

      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      print('✅ Mensajes expirados limpiados:');
      print('   - Mensajes eliminados: ${data['deletedMessages']}');
      print(
        '   - Conversaciones procesadas: ${data['processedConversations']}',
      );

      return data;
    } catch (e) {
      print('Error calling cleanExpiredMessages Cloud Function: $e');
      // Fallback a limpieza local si falla la Cloud Function
      await _cleanExpiredMessagesLocal();
      rethrow;
    }
  }

  /// Limpiar mensajes expirados localmente (fallback)
  Future<void> _cleanExpiredMessagesLocal() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Limpiar mensajes expirados
      final messagesSnapshot = await _messagesRef.get();
      if (messagesSnapshot.exists) {
        final conversationsData = Map<String, dynamic>.from(
          messagesSnapshot.value as Map<dynamic, dynamic>,
        );

        for (var conversationEntry in conversationsData.entries) {
          final conversationId = conversationEntry.key;
          final messages = Map<String, dynamic>.from(
            conversationEntry.value as Map<dynamic, dynamic>,
          );

          for (var messageEntry in messages.entries) {
            final messageId = messageEntry.key;
            final messageData = Map<dynamic, dynamic>.from(
              messageEntry.value as Map<dynamic, dynamic>,
            );
            final expiresAt = messageData['expiresAt'] as int? ?? 0;

            if (now > expiresAt) {
              await _messagesRef
                  .child(conversationId)
                  .child(messageId)
                  .remove();
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning expired messages locally: $e');
    }
  }
}
