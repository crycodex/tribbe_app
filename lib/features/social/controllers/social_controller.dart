import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/shared/models/friendship_models.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/friendship_service.dart';

/// Controller para gestionar funcionalidad social
class SocialController extends GetxController {
  final FriendshipService _friendshipService = Get.find();
  final FirebaseAuthService _authService = Get.find();

  // Estado de carga
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;

  // Tab actual
  final RxInt currentTabIndex = 0.obs;

  // Listas de datos
  final RxList<Friendship> friends = <Friendship>[].obs;
  final RxList<FriendRequest> receivedRequests = <FriendRequest>[].obs;
  final RxList<FriendRequest> sentRequests = <FriendRequest>[].obs;
  final RxList<BlockedUser> blockedUsers = <BlockedUser>[].obs;
  final RxList<UserModel> searchResults = <UserModel>[].obs;

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
    loadFriends();
    loadReceivedRequests();
    loadSentRequests();
    loadBlockedUsers();
  }

  /// Cargar lista de amigos
  void loadFriends() {
    _friendshipService.getFriends().listen((friendshipList) {
      friends.value = friendshipList;
    });
  }

  /// Cargar solicitudes recibidas
  void loadReceivedRequests() {
    _friendshipService.getReceivedFriendRequests().listen((requests) {
      receivedRequests.value = requests;
    });
  }

  /// Cargar solicitudes enviadas
  void loadSentRequests() {
    _friendshipService.getSentFriendRequests().listen((requests) {
      sentRequests.value = requests;
    });
  }

  /// Cargar usuarios bloqueados
  void loadBlockedUsers() {
    _friendshipService.getBlockedUsers().listen((blocked) {
      blockedUsers.value = blocked;
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

  /// Enviar solicitud de amistad
  Future<void> sendFriendRequest(String userId) async {
    isLoading.value = true;

    try {
      final success = await _friendshipService.sendFriendRequest(userId);

      if (success) {
        Get.snackbar(
          'Solicitud enviada',
          'La solicitud de amistad ha sido enviada',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar solicitudes enviadas
        loadSentRequests();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo enviar la solicitud',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al enviar la solicitud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Aceptar solicitud de amistad
  Future<void> acceptFriendRequest(String requestId) async {
    debugPrint('🔄 SocialController: Aceptando solicitud $requestId');
    isLoading.value = true;

    try {
      final success = await _friendshipService.acceptFriendRequest(requestId);
      debugPrint(
        '📊 SocialController: Resultado de aceptar solicitud: $success',
      );

      if (success) {
        Get.snackbar(
          '¡Nueva amistad!',
          'Ahora son amigos',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar datos
        loadFriends();
        loadReceivedRequests();
      } else {
        debugPrint('❌ SocialController: No se pudo aceptar la solicitud');
        Get.snackbar(
          'Error',
          'No se pudo aceptar la solicitud',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ SocialController: Error al aceptar solicitud: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al aceptar la solicitud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Rechazar solicitud de amistad
  Future<void> rejectFriendRequest(String requestId) async {
    isLoading.value = true;

    try {
      final success = await _friendshipService.rejectFriendRequest(requestId);

      if (success) {
        Get.snackbar(
          'Solicitud rechazada',
          'La solicitud ha sido rechazada',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar solicitudes
        loadReceivedRequests();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo rechazar la solicitud',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al rechazar la solicitud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancelar solicitud enviada
  Future<void> cancelFriendRequest(String receiverId) async {
    isLoading.value = true;

    try {
      final success = await _friendshipService.cancelFriendRequest(receiverId);

      if (success) {
        Get.snackbar(
          'Solicitud cancelada',
          'La solicitud ha sido cancelada',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar solicitudes
        loadSentRequests();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo cancelar la solicitud',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al cancelar la solicitud',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar amistad
  Future<void> removeFriend(String friendId, String friendName) async {
    // Confirmar con diálogo
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar amistad'),
        content: Text('¿Estás seguro de eliminar a $friendName de tus amigos?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final success = await _friendshipService.removeFriend(friendId);

      if (success) {
        Get.snackbar(
          'Amistad eliminada',
          'La amistad ha sido eliminada',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar amigos
        loadFriends();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo eliminar la amistad',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al eliminar la amistad',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Bloquear usuario
  Future<void> blockUser(String userId, String username) async {
    // Confirmar con diálogo
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text(
          '¿Estás seguro de bloquear a @$username? No podrán enviarte solicitudes ni ver tu contenido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final success = await _friendshipService.blockUser(userId);

      if (success) {
        Get.snackbar(
          'Usuario bloqueado',
          'El usuario ha sido bloqueado',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar datos
        loadFriends();
        loadBlockedUsers();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo bloquear al usuario',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al bloquear al usuario',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Desbloquear usuario
  Future<void> unblockUser(String userId, String username) async {
    // Confirmar con diálogo
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Desbloquear usuario'),
        content: Text('¿Estás seguro de desbloquear a @$username?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final success = await _friendshipService.unblockUser(userId);

      if (success) {
        Get.snackbar(
          'Usuario desbloqueado',
          'El usuario ha sido desbloqueado',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Recargar bloqueados
        loadBlockedUsers();
      } else {
        Get.snackbar(
          'Error',
          'No se pudo desbloquear al usuario',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al desbloquear al usuario',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar si hay solicitudes pendientes con un usuario
  bool hasPendingRequestWith(String userId) {
    return sentRequests.any((request) => request.receiverId == userId);
  }

  /// Verificar si son amigos
  bool isFriendWith(String userId) {
    return friends.any((friendship) => friendship.friendId == userId);
  }

  /// Cambiar tab actual
  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
