import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/shared/models/social_models.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/friendship_service.dart';
import 'package:tribbe_app/shared/services/social_service.dart';

/// Controller para gestionar funcionalidad social (solo followers/following)
class SocialController extends GetxController {
  final FriendshipService _friendshipService = Get.find();
  final SocialService _socialService = Get.find();
  final FirebaseAuthService _authService = Get.find();

  // Estado de carga
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;

  // Tab actual
  final RxInt currentTabIndex = 0.obs;

  // Listas de datos
  final RxList<UserModel> searchResults = <UserModel>[].obs;

  // Listas de followers/following
  final RxList<FollowRelation> followers = <FollowRelation>[].obs;
  final RxList<FollowRelation> following = <FollowRelation>[].obs;

  // Usuario actual
  UserModel? get currentUser {
    final uid = _authService.currentUser?.uid;
    return uid != null
        ? UserModel(
            id: uid,
            email: _authService.currentUser!.email!,
            username: _authService.currentUser!.displayName,
          )
        : null;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Cargar todos los datos
  void loadData() {
    loadFollowers();
    loadFollowing();
  }

  /// Cargar lista de seguidores
  void loadFollowers() {
    _socialService.getFollowers().listen((followersList) {
      followers.value = followersList;
    });
  }

  /// Cargar lista de usuarios que sigue
  void loadFollowing() {
    _socialService.getFollowing().listen((followingList) {
      following.value = followingList;
    });
  }

  /// Buscar usuarios
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final results = await _friendshipService.searchUsers(query);
      searchResults.value = results;
    } catch (e) {
      // Error silencioso
    } finally {
      isSearching.value = false;
    }
  }

  /// Seguir a un usuario
  Future<void> followUser(String userId) async {
    debugPrint('🔄 SocialController: Siguiendo usuario $userId');
    isLoading.value = true;

    try {
      final success = await _socialService.followUser(userId);
      debugPrint('📊 SocialController: Resultado de seguir usuario: $success');

      if (success) {
        Get.snackbar(
          '¡Usuario seguido!',
          'Ahora sigues a este usuario',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar datos
        loadFollowing();
      } else {
        debugPrint('❌ SocialController: No se pudo seguir al usuario');
        Get.snackbar(
          'Error',
          'No se pudo seguir al usuario',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ SocialController: Error al seguir usuario: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al seguir al usuario',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Dejar de seguir a un usuario
  Future<void> unfollowUser(String userId, String username) async {
    // Confirmar con diálogo
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Dejar de seguir'),
        content: Text('¿Estás seguro de dejar de seguir a @$username?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Dejar de seguir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final success = await _socialService.unfollowUser(userId);

      if (success) {
        Get.snackbar(
          'Dejaste de seguir',
          'Ya no sigues a este usuario',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar datos
        loadFollowing();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo dejar de seguir al usuario',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al dejar de seguir al usuario',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar si está siguiendo a un usuario
  Future<bool> isFollowingUser(String userId) async {
    return await _socialService.isFollowing(userId);
  }

  /// Verificar si un usuario lo está siguiendo
  Future<bool> isFollowedByUser(String userId) async {
    return await _socialService.isFollowedBy(userId);
  }

  /// Cambiar tab actual
  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
