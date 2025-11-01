import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/shared/models/social_models.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';

/// Servicio para gestionar followers/following (sistema de seguimiento)
class SocialService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = Get.find();

  // Colecciones
  static const String _usersCollection = 'users';
  static const String _socialCollection = 'social';

  // Subcolecciones dentro de social
  static const String _followersSubcollection = 'followers';
  static const String _followingSubcollection = 'following';

  /// Seguir a un usuario
  Future<bool> followUser(String userIdToFollow) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null || currentUserId == userIdToFollow) {
        debugPrint('❌ SocialService: Usuario inválido');
        return false;
      }

      // Verificar si ya lo sigue
      final alreadyFollowing = await isFollowing(userIdToFollow);
      if (alreadyFollowing) {
        debugPrint('❌ SocialService: Ya sigue a este usuario');
        return false;
      }

      // Verificar si son amigos (los amigos no necesitan seguirse)
      final areFriends = await _checkFriendship(userIdToFollow);
      if (areFriends) {
        debugPrint('❌ SocialService: Ya son amigos, no necesita seguirlo');
        return false;
      }

      final now = FieldValue.serverTimestamp();

      // Usar transacción para crear la relación en ambas direcciones
      await _firestore.runTransaction((transaction) async {
        // 1. Crear relación de following en el usuario actual
        final followingRef = _firestore
            .collection(_usersCollection)
            .doc(currentUserId)
            .collection(_socialCollection)
            .doc(_followingSubcollection)
            .collection(_followingSubcollection)
            .doc(userIdToFollow);

        transaction.set(followingRef, {
          'following_id': userIdToFollow,
          'created_at': now,
        });

        // 2. Crear relación de follower en el usuario seguido
        final followerRef = _firestore
            .collection(_usersCollection)
            .doc(userIdToFollow)
            .collection(_socialCollection)
            .doc(_followersSubcollection)
            .collection(_followersSubcollection)
            .doc(currentUserId);

        transaction.set(followerRef, {
          'follower_id': currentUserId,
          'created_at': now,
        });

        // 3. Incrementar contadores
        transaction.update(
          _firestore.collection(_usersCollection).doc(currentUserId),
          {'following_count': FieldValue.increment(1)},
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(userIdToFollow),
          {'followers_count': FieldValue.increment(1)},
        );
      });

      debugPrint('✅ SocialService: Usuario seguido exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ SocialService: Error al seguir usuario: $e');
      return false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<bool> unfollowUser(String userIdToUnfollow) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null || currentUserId == userIdToUnfollow) {
        debugPrint('❌ SocialService: Usuario inválido');
        return false;
      }

      // Verificar si lo está siguiendo
      final isCurrentlyFollowing = await isFollowing(userIdToUnfollow);
      if (!isCurrentlyFollowing) {
        debugPrint('❌ SocialService: No sigue a este usuario');
        return false;
      }

      // Usar transacción para eliminar la relación en ambas direcciones
      await _firestore.runTransaction((transaction) async {
        // 1. Eliminar relación de following del usuario actual
        final followingRef = _firestore
            .collection(_usersCollection)
            .doc(currentUserId)
            .collection(_socialCollection)
            .doc(_followingSubcollection)
            .collection(_followingSubcollection)
            .doc(userIdToUnfollow);

        transaction.delete(followingRef);

        // 2. Eliminar relación de follower del usuario seguido
        final followerRef = _firestore
            .collection(_usersCollection)
            .doc(userIdToUnfollow)
            .collection(_socialCollection)
            .doc(_followersSubcollection)
            .collection(_followersSubcollection)
            .doc(currentUserId);

        transaction.delete(followerRef);

        // 3. Decrementar contadores
        transaction.update(
          _firestore.collection(_usersCollection).doc(currentUserId),
          {'following_count': FieldValue.increment(-1)},
        );

        transaction.update(
          _firestore.collection(_usersCollection).doc(userIdToUnfollow),
          {'followers_count': FieldValue.increment(-1)},
        );
      });

      debugPrint('✅ SocialService: Dejó de seguir usuario exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ SocialService: Error al dejar de seguir usuario: $e');
      return false;
    }
  }

  /// Verificar si está siguiendo a un usuario
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return false;

      final followingDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_socialCollection)
          .doc(_followingSubcollection)
          .collection(_followingSubcollection)
          .doc(userId)
          .get();

      return followingDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si un usuario lo está siguiendo
  Future<bool> isFollowedBy(String userId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return false;

      final followerDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_socialCollection)
          .doc(_followersSubcollection)
          .collection(_followersSubcollection)
          .doc(userId)
          .get();

      return followerDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Obtener lista de seguidores
  Stream<List<FollowRelation>> getFollowers() {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_socialCollection)
        .doc(_followersSubcollection)
        .collection(_followersSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final followers = <FollowRelation>[];

          for (final doc in snapshot.docs) {
            final followerId = doc.id;
            final data = doc.data();

            // Obtener info del seguidor
            final followerDoc = await _firestore
                .collection(_usersCollection)
                .doc(followerId)
                .get();

            if (followerDoc.exists) {
              final followerData = followerDoc.data()!;

              followers.add(
                FollowRelation(
                  id: doc.id,
                  followerId: followerId,
                  followingId: currentUserId,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  followerUsername: followerData['username'] as String?,
                  followerDisplayName: followerData['display_name'] as String?,
                  followerPhotoUrl: followerData['photo_url'] as String?,
                ),
              );
            }
          }

          return followers;
        });
  }

  /// Obtener lista de usuarios que sigue
  Stream<List<FollowRelation>> getFollowing() {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(currentUserId)
        .collection(_socialCollection)
        .doc(_followingSubcollection)
        .collection(_followingSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final following = <FollowRelation>[];

          for (final doc in snapshot.docs) {
            final followingId = doc.id;
            final data = doc.data();

            // Obtener info del usuario seguido
            final followingDoc = await _firestore
                .collection(_usersCollection)
                .doc(followingId)
                .get();

            if (followingDoc.exists) {
              final followingData = followingDoc.data()!;

              following.add(
                FollowRelation(
                  id: doc.id,
                  followerId: currentUserId,
                  followingId: followingId,
                  createdAt: (data['created_at'] as Timestamp).toDate(),
                  followingUsername: followingData['username'] as String?,
                  followingDisplayName:
                      followingData['display_name'] as String?,
                  followingPhotoUrl: followingData['photo_url'] as String?,
                ),
              );
            }
          }

          return following;
        });
  }

  /// Obtener estadísticas sociales de un usuario
  Future<SocialStats> getSocialStats(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return SocialStats(
          userId: userId,
          followersCount: data['followers_count'] as int? ?? 0,
          followingCount: data['following_count'] as int? ?? 0,
          friendsCount: data['friends_count'] as int? ?? 0,
          updatedAt: data['updated_at'] != null
              ? (data['updated_at'] as Timestamp).toDate()
              : null,
        );
      }

      return SocialStats(
        userId: userId,
        followersCount: 0,
        followingCount: 0,
        friendsCount: 0,
      );
    } catch (e) {
      debugPrint('❌ SocialService: Error al obtener estadísticas: $e');
      return SocialStats(
        userId: userId,
        followersCount: 0,
        followingCount: 0,
        friendsCount: 0,
      );
    }
  }

  /// Stream de estadísticas sociales de un usuario
  Stream<SocialStats> getSocialStatsStream(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        final data = doc.data()!;
        return SocialStats(
          userId: userId,
          followersCount: data['followers_count'] as int? ?? 0,
          followingCount: data['following_count'] as int? ?? 0,
          friendsCount: data['friends_count'] as int? ?? 0,
          updatedAt: data['updated_at'] != null
              ? (data['updated_at'] as Timestamp).toDate()
              : null,
        );
      }

      return SocialStats(
        userId: userId,
        followersCount: 0,
        followingCount: 0,
        friendsCount: 0,
      );
    });
  }

  /// Verificar si existe una amistad (método privado)
  Future<bool> _checkFriendship(String friendId) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return false;

      final friendshipDoc = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection(_socialCollection)
          .doc('friends')
          .collection('friends')
          .doc(friendId)
          .get();

      return friendshipDoc.exists;
    } catch (e) {
      return false;
    }
  }
}
