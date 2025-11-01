import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/shared/models/friendship_models.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';

/// Servicio para gestionar amistades, solicitudes y bloqueos
class FriendshipService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = Get.find();

  // Colecciones
  static const String _usernamesCollection = 'usernames';
  static const String _usersCollection = 'users';
  static const String _socialCollection = 'social';

  // Subcolecciones dentro de social
  static const String _friendsSubcollection = 'friends';
  static const String _friendRequestsSentSubcollection = 'friend_requests_sent';
  static const String _friendRequestsReceivedSubcollection =
      'friend_requests_received';
  static const String _blockedUsersSubcollection = 'blocked_users';

  /// Verificar si un username está disponible
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      if (normalizedUsername.isEmpty || normalizedUsername.length < 3) {
        return false;
      }

      // Verificar si existe el documento en la colección usernames
      final doc = await _firestore
          .collection(_usernamesCollection)
          .doc(normalizedUsername)
          .get();

      // Si el documento no existe, el username está disponible
      // Firestore retorna doc.exists = false si la colección no existe o el doc no existe
      return !doc.exists;
    } catch (e) {
      // En caso de error, asumimos que NO está disponible por seguridad
      debugPrint('❌ Error al verificar disponibilidad de username: $e');
      return false;
    }
  }

  /// Reservar un username para un usuario
  Future<bool> reserveUsername(String username, String userId) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      // Verificar disponibilidad primero
      final isAvailable = await isUsernameAvailable(normalizedUsername);
      if (!isAvailable) {
        debugPrint('❌ Username $normalizedUsername no está disponible');
        return false;
      }

      debugPrint('✅ Username $normalizedUsername disponible, reservando...');

      // Usar transacción para evitar race conditions
      await _firestore.runTransaction((transaction) async {
        final usernameRef = _firestore
            .collection(_usernamesCollection)
            .doc(normalizedUsername);

        final userRef = _firestore.collection(_usersCollection).doc(userId);

        // ⚠️ IMPORTANTE: Todas las lecturas DEBEN ir ANTES de las escrituras

        // 1. LECTURA: Verificar si el username existe
        final usernameDoc = await transaction.get(usernameRef);

        // 2. LECTURA: Verificar si el usuario existe
        final userDoc = await transaction.get(userRef);

        // Validar que el username esté disponible
        if (usernameDoc.exists) {
          throw Exception('Username ya está en uso');
        }

        // 3. ESCRITURA: Reservar el username (esto crea la colección si no existe)
        transaction.set(usernameRef, {
          'user_id': userId,
          'username': username, // Guardar versión original
          'created_at': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Username reservado en colección usernames');

        // 4. ESCRITURA: Actualizar o crear el documento del usuario
        if (userDoc.exists) {
          // Si existe, actualizar
          transaction.update(userRef, {
            'username': normalizedUsername,
            'display_name': username,
            'updated_at': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Usuario actualizado con username');
        } else {
          // Si no existe, crear (esto también crea la colección si no existe)
          transaction.set(userRef, {
            'username': normalizedUsername,
            'display_name': username,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Usuario creado con username');
        }
      });

      debugPrint('✅ Transacción completada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al reservar username: $e');
      return false;
    }
  }

  /// Liberar un username (cuando el usuario lo cambia)
  Future<void> releaseUsername(String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();
      await _firestore
          .collection(_usernamesCollection)
          .doc(normalizedUsername)
          .delete();
    } catch (e) {
      // Silencioso
    }
  }

  /// Buscar usuarios por username o UID
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return [];

      final normalizedQuery = query.toLowerCase().trim();

      if (normalizedQuery.isEmpty || normalizedQuery.length < 2) {
        return [];
      }

      // Buscar por UID exacto primero
      if (normalizedQuery.length >= 20) {
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(normalizedQuery)
            .get();

        if (userDoc.exists) {
          final user = UserModel.fromJson({
            'id': userDoc.id,
            ...userDoc.data()!,
          });

          // No incluir al usuario actual ni bloqueados
          if (user.id != currentUserId) {
            final isBlocked = await isUserBlocked(user.id);
            if (!isBlocked) {
              return [user];
            }
          }
        }
      }

      // Buscar por username (usando query range)
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('username', isGreaterThanOrEqualTo: normalizedQuery)
          .where('username', isLessThan: '${normalizedQuery}z')
          .limit(20)
          .get();

      final users = <UserModel>[];

      for (final doc in querySnapshot.docs) {
        final user = UserModel.fromJson({'id': doc.id, ...doc.data()});

        // Excluir usuario actual y bloqueados
        if (user.id != currentUserId) {
          final isBlocked = await isUserBlocked(user.id);
          if (!isBlocked) {
            users.add(user);
          }
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }

  /// Enviar solicitud de amistad
  Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final senderId = _authService.currentUser?.uid;
      if (senderId == null || senderId == receiverId) {
        debugPrint('❌ FriendshipService: Usuario inválido');
        return false;
      }

      // Verificar si ya son amigos
      final areFriends = await checkFriendship(receiverId);
      if (areFriends) {
        debugPrint('❌ FriendshipService: Ya son amigos');
        return false;
      }

      // Verificar si ya existe una solicitud enviada
      final existingRequestSent = await _firestore
          .collection(_usersCollection)
          .doc(senderId)
          .collection(_socialCollection)
          .doc(_friendRequestsSentSubcollection)
          .collection(_friendRequestsSentSubcollection)
          .doc(receiverId)
          .get();

      if (existingRequestSent.exists) {
        debugPrint('❌ FriendshipService: Solicitud ya enviada');
        return false;
      }

      // Verificar si el usuario está bloqueado
      final isBlocked = await isUserBlocked(receiverId);
      if (isBlocked) {
        debugPrint('❌ FriendshipService: Usuario bloqueado');
        return false;
      }

      final now = FieldValue.serverTimestamp();

      // Usar transacción para crear la solicitud en ambas subcolecciones
      await _firestore.runTransaction((transaction) async {
        // 1. Crear solicitud en "enviadas" del sender
        final sentRef = _firestore
            .collection(_usersCollection)
            .doc(senderId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(receiverId);

        transaction.set(sentRef, {
          'receiver_id': receiverId,
          'status': 'pending',
          'created_at': now,
        });

        // 2. Crear solicitud en "recibidas" del receiver
        final receivedRef = _firestore
            .collection(_usersCollection)
            .doc(receiverId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(senderId);

        transaction.set(receivedRef, {
          'sender_id': senderId,
          'status': 'pending',
          'created_at': now,
        });
      });

      debugPrint('✅ FriendshipService: Solicitud enviada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al enviar solicitud: $e');
      return false;
    }
  }

  /// Aceptar solicitud de amistad
  /// [senderId] es el ID del usuario que envió la solicitud
  Future<bool> acceptFriendRequest(String senderId) async {
    try {
      debugPrint('🔄 FriendshipService: Aceptando solicitud de $senderId');

      final receiverId = _authService.currentUser?.uid;
      if (receiverId == null) {
        debugPrint('❌ FriendshipService: Usuario no autenticado');
        return false;
      }

      debugPrint('✅ FriendshipService: Receptor: $receiverId');

      // Verificar que la solicitud existe
      final requestDoc = await _firestore
          .collection(_usersCollection)
          .doc(receiverId)
          .collection(_socialCollection)
          .doc(_friendRequestsReceivedSubcollection)
          .collection(_friendRequestsReceivedSubcollection)
          .doc(senderId)
          .get();

      if (!requestDoc.exists) {
        debugPrint('❌ FriendshipService: Solicitud no existe');
        return false;
      }

      final requestData = requestDoc.data()!;
      if (requestData['status'] != 'pending') {
        debugPrint('❌ FriendshipService: Solicitud no está pendiente');
        return false;
      }

      debugPrint('🔄 FriendshipService: Iniciando transacción...');

      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((transaction) async {
        // 1. Actualizar solicitud recibida a "accepted"
        final receivedRef = _firestore
            .collection(_usersCollection)
            .doc(receiverId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(senderId);

        transaction.update(receivedRef, {
          'status': 'accepted',
          'updated_at': now,
        });

        // 2. Actualizar solicitud enviada a "accepted"
        final sentRef = _firestore
            .collection(_usersCollection)
            .doc(senderId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(receiverId);

        transaction.update(sentRef, {'status': 'accepted', 'updated_at': now});

        // 3. Crear amistad en la colección del receiver
        final friendshipReceiver = _firestore
            .collection(_usersCollection)
            .doc(receiverId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(senderId);

        transaction.set(friendshipReceiver, {
          'friend_id': senderId,
          'created_at': now,
        });

        // 4. Crear amistad en la colección del sender
        final friendshipSender = _firestore
            .collection(_usersCollection)
            .doc(senderId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(receiverId);

        transaction.set(friendshipSender, {
          'friend_id': receiverId,
          'created_at': now,
        });

        // 5. Incrementar contadores
        transaction.update(
          _firestore.collection(_usersCollection).doc(receiverId),
          {'friends_count': FieldValue.increment(1)},
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(senderId),
          {'friends_count': FieldValue.increment(1)},
        );
      });

      debugPrint('✅ FriendshipService: Solicitud aceptada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al aceptar solicitud: $e');
      return false;
    }
  }

  /// Rechazar solicitud de amistad
  /// [senderId] es el ID del usuario que envió la solicitud
  Future<bool> rejectFriendRequest(String senderId) async {
    try {
      final receiverId = _authService.currentUser?.uid;
      if (receiverId == null) return false;

      await _firestore.runTransaction((transaction) async {
        // Eliminar solicitud recibida
        final receivedRef = _firestore
            .collection(_usersCollection)
            .doc(receiverId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(senderId);

        transaction.delete(receivedRef);

        // Eliminar solicitud enviada
        final sentRef = _firestore
            .collection(_usersCollection)
            .doc(senderId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(receiverId);

        transaction.delete(sentRef);
      });

      debugPrint('✅ FriendshipService: Solicitud rechazada');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al rechazar solicitud: $e');
      return false;
    }
  }

  /// Cancelar solicitud de amistad
  Future<bool> cancelFriendRequest(String receiverId) async {
    try {
      final senderId = _authService.currentUser?.uid;
      if (senderId == null) return false;

      await _firestore.runTransaction((transaction) async {
        // Eliminar solicitud enviada
        final sentRef = _firestore
            .collection(_usersCollection)
            .doc(senderId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(receiverId);

        transaction.delete(sentRef);

        // Eliminar solicitud recibida
        final receivedRef = _firestore
            .collection(_usersCollection)
            .doc(receiverId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(senderId);

        transaction.delete(receivedRef);
      });

      debugPrint('✅ FriendshipService: Solicitud cancelada');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al cancelar solicitud: $e');
      return false;
    }
  }

  /// Eliminar amistad
  Future<bool> removeFriend(String friendId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      await _firestore.runTransaction((transaction) async {
        // Eliminar amistad del usuario actual
        final userFriendshipRef = _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(friendId);

        transaction.delete(userFriendshipRef);

        // Eliminar amistad del amigo
        final friendFriendshipRef = _firestore
            .collection(_usersCollection)
            .doc(friendId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(userId);

        transaction.delete(friendFriendshipRef);

        // Decrementar contadores
        transaction.update(
          _firestore.collection(_usersCollection).doc(userId),
          {'friends_count': FieldValue.increment(-1)},
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(friendId),
          {'friends_count': FieldValue.increment(-1)},
        );
      });

      debugPrint('✅ FriendshipService: Amistad eliminada');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al eliminar amistad: $e');
      return false;
    }
  }

  /// Bloquear usuario
  Future<bool> blockUser(String blockedUserId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null || userId == blockedUserId) {
        return false;
      }

      await _firestore.runTransaction((transaction) async {
        // Crear bloqueo
        final blockRef = _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_socialCollection)
            .doc(_blockedUsersSubcollection)
            .collection(_blockedUsersSubcollection)
            .doc(blockedUserId);

        transaction.set(blockRef, {
          'blocked_user_id': blockedUserId,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Eliminar amistad si existe
        final userFriendshipRef = _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(blockedUserId);

        transaction.delete(userFriendshipRef);

        final friendFriendshipRef = _firestore
            .collection(_usersCollection)
            .doc(blockedUserId)
            .collection(_socialCollection)
            .doc(_friendsSubcollection)
            .collection(_friendsSubcollection)
            .doc(userId);

        transaction.delete(friendFriendshipRef);

        // Eliminar solicitudes en ambas direcciones
        final sentRequestRef = _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(blockedUserId);

        transaction.delete(sentRequestRef);

        final receivedRequestRef = _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(blockedUserId);

        transaction.delete(receivedRequestRef);

        // También eliminar del otro lado
        final otherSentRequestRef = _firestore
            .collection(_usersCollection)
            .doc(blockedUserId)
            .collection(_socialCollection)
            .doc(_friendRequestsSentSubcollection)
            .collection(_friendRequestsSentSubcollection)
            .doc(userId);

        transaction.delete(otherSentRequestRef);

        final otherReceivedRequestRef = _firestore
            .collection(_usersCollection)
            .doc(blockedUserId)
            .collection(_socialCollection)
            .doc(_friendRequestsReceivedSubcollection)
            .collection(_friendRequestsReceivedSubcollection)
            .doc(userId);

        transaction.delete(otherReceivedRequestRef);
      });

      debugPrint('✅ FriendshipService: Usuario bloqueado');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al bloquear usuario: $e');
      return false;
    }
  }

  /// Desbloquear usuario
  Future<bool> unblockUser(String blockedUserId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_socialCollection)
          .doc(_blockedUsersSubcollection)
          .collection(_blockedUsersSubcollection)
          .doc(blockedUserId)
          .delete();

      debugPrint('✅ FriendshipService: Usuario desbloqueado');
      return true;
    } catch (e) {
      debugPrint('❌ FriendshipService: Error al desbloquear usuario: $e');
      return false;
    }
  }

  /// Verificar si un usuario está bloqueado
  Future<bool> isUserBlocked(String userId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return false;

      // Verificar si yo bloqueé al usuario
      final blockedByMe = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_socialCollection)
          .doc(_blockedUsersSubcollection)
          .collection(_blockedUsersSubcollection)
          .doc(userId)
          .get();

      if (blockedByMe.exists) return true;

      // Verificar si el usuario me bloqueó
      final blockedMe = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_socialCollection)
          .doc(_blockedUsersSubcollection)
          .collection(_blockedUsersSubcollection)
          .doc(currentUserId)
          .get();

      return blockedMe.exists;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si existe una amistad
  Future<bool> checkFriendship(String friendId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      final friendshipDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_socialCollection)
          .doc(_friendsSubcollection)
          .collection(_friendsSubcollection)
          .doc(friendId)
          .get();

      return friendshipDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Obtener lista de amigos
  Stream<List<Friendship>> getFriends() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_socialCollection)
        .doc(_friendsSubcollection)
        .collection(_friendsSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final friendships = <Friendship>[];

          for (final doc in snapshot.docs) {
            final friendId = doc.id;
            final data = doc.data();

            // Obtener info del amigo
            final friendDoc = await _firestore
                .collection(_usersCollection)
                .doc(friendId)
                .get();

            if (friendDoc.exists) {
              final friendData = friendDoc.data()!;

              friendships.add(
                Friendship(
                  id: doc.id,
                  userId: userId,
                  friendId: friendId,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  friendUsername: friendData['username'] as String?,
                  friendDisplayName: friendData['display_name'] as String?,
                  friendPhotoUrl: friendData['photo_url'] as String?,
                  friendBio: friendData['bio'] as String?,
                ),
              );
            }
          }

          return friendships;
        });
  }

  /// Obtener solicitudes de amistad recibidas (pendientes)
  Stream<List<FriendRequest>> getReceivedFriendRequests() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_socialCollection)
        .doc(_friendRequestsReceivedSubcollection)
        .collection(_friendRequestsReceivedSubcollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = <FriendRequest>[];

          for (final doc in snapshot.docs) {
            final senderId = doc.id;
            final data = doc.data();

            // Obtener info del sender
            final senderDoc = await _firestore
                .collection(_usersCollection)
                .doc(senderId)
                .get();

            if (senderDoc.exists) {
              final senderData = senderDoc.data()!;

              requests.add(
                FriendRequest(
                  id: senderId, // Ahora el ID es el senderId
                  senderId: senderId,
                  receiverId: userId,
                  status: FriendRequestStatus.pending,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  senderUsername: senderData['username'] as String?,
                  senderDisplayName: senderData['display_name'] as String?,
                  senderPhotoUrl: senderData['photo_url'] as String?,
                ),
              );
            }
          }

          return requests;
        });
  }

  /// Obtener solicitudes enviadas (pendientes)
  Stream<List<FriendRequest>> getSentFriendRequests() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_socialCollection)
        .doc(_friendRequestsSentSubcollection)
        .collection(_friendRequestsSentSubcollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = <FriendRequest>[];

          for (final doc in snapshot.docs) {
            final receiverId = doc.id;
            final data = doc.data();

            // Obtener info del receiver
            final receiverDoc = await _firestore
                .collection(_usersCollection)
                .doc(receiverId)
                .get();

            if (receiverDoc.exists) {
              final receiverData = receiverDoc.data()!;

              requests.add(
                FriendRequest(
                  id: receiverId, // Ahora el ID es el receiverId
                  senderId: userId,
                  receiverId: receiverId,
                  status: FriendRequestStatus.pending,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  receiverUsername: receiverData['username'] as String?,
                  receiverDisplayName: receiverData['display_name'] as String?,
                  receiverPhotoUrl: receiverData['photo_url'] as String?,
                ),
              );
            }
          }

          return requests;
        });
  }

  /// Obtener usuarios bloqueados
  Stream<List<BlockedUser>> getBlockedUsers() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_socialCollection)
        .doc(_blockedUsersSubcollection)
        .collection(_blockedUsersSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUsers = <BlockedUser>[];

          for (final doc in snapshot.docs) {
            final blockedUserId = doc.id;
            final data = doc.data();

            // Obtener info del usuario bloqueado
            final blockedUserDoc = await _firestore
                .collection(_usersCollection)
                .doc(blockedUserId)
                .get();

            if (blockedUserDoc.exists) {
              final blockedUserData = blockedUserDoc.data()!;

              blockedUsers.add(
                BlockedUser(
                  id: blockedUserId,
                  userId: userId,
                  blockedUserId: blockedUserId,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  blockedUsername: blockedUserData['username'] as String?,
                  blockedDisplayName:
                      blockedUserData['display_name'] as String?,
                  blockedPhotoUrl: blockedUserData['photo_url'] as String?,
                ),
              );
            }
          }

          return blockedUsers;
        });
  }
}
