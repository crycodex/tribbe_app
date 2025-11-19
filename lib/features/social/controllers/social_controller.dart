import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/shared/models/social_models.dart';
import 'package:tribbe_app/shared/models/friendship_models.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/friendship_service.dart';
import 'package:tribbe_app/shared/services/social_service.dart';
import 'package:tribbe_app/shared/services/workout_service.dart';

/// Controller para gestionar funcionalidad social (solo followers/following)
class SocialController extends GetxController {
  final FriendshipService _friendshipService = Get.find();
  final SocialService _socialService = Get.find();
  final FirebaseAuthService _authService = Get.find();
  final AuthController _authController = Get.find();
  final WorkoutService _workoutService = Get.find();

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

  // Lista de usuarios bloqueados
  final RxList<BlockedUser> blockedUsers = <BlockedUser>[].obs;

  // Datos del perfil de usuario visitado
  final Rx<SocialStats?> visitedUserStats = Rx<SocialStats?>(null);
  final RxList<WorkoutPostModel> visitedUserPosts = <WorkoutPostModel>[].obs;
  final RxBool isLoadingUserProfile = false.obs;

  // Usuario actual
  UserModel? get currentUser {
    final uid = _authService.currentUser?.uid;
    final userProfile = _authController.userProfile.value;

    if (uid == null) return null;

    // Obtener username del perfil de Firestore (como ProfileController)
    final username =
        userProfile?.datosPersonales?.nombreUsuario ??
        _authService.currentUser!.displayName ??
        'usuario';

    return UserModel(
      id: uid,
      email: _authService.currentUser!.email!,
      username: username,
    );
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
    loadBlockedUsers();
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
        _showSnackbar('¡Usuario seguido!', 'Ahora sigues a este usuario');

        // Recargar datos
        loadFollowing();
      } else {
        debugPrint('❌ SocialController: No se pudo seguir al usuario');
        _showSnackbar('Error', 'No se pudo seguir al usuario');
      }
    } catch (e) {
      debugPrint('❌ SocialController: Error al seguir usuario: $e');
      _showSnackbar('Error', 'Ocurrió un error al seguir al usuario');
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
        _showSnackbar('Dejaste de seguir', 'Ya no sigues a este usuario');

        // Recargar datos
        loadFollowing();
      } else {
        _showSnackbar('Error', 'No se pudo dejar de seguir al usuario');
      }
    } catch (e) {
      _showSnackbar('Error', 'Ocurrió un error al dejar de seguir al usuario');
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

  /// Cargar lista de usuarios bloqueados
  void loadBlockedUsers() {
    _socialService.getBlockedUsers().listen((blockedList) {
      blockedUsers.value = blockedList;
    });
  }

  /// Bloquear usuario
  Future<void> blockUser(String userId, String username) async {
    // Confirmar con diálogo
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text(
          '¿Estás seguro de bloquear a @$username?\n\nNo podrás ver su contenido ni interactuar con él.',
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
      // Bloquear usuario (SocialService maneja la eliminación de relaciones)
      final success = await _socialService.blockUser(userId);

      if (success) {
        _showSnackbar(
          'Usuario bloqueado',
          'Ya no verás el contenido de @$username',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Recargar datos
        loadBlockedUsers();
        loadFollowing();
        loadFollowers();
      } else {
        _showSnackbar('Error', 'No se pudo bloquear al usuario');
      }
    } catch (e) {
      debugPrint('❌ SocialController: Error al bloquear usuario: $e');
      _showSnackbar('Error', 'Ocurrió un error al bloquear al usuario');
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
      final success = await _socialService.unblockUser(userId);

      if (success) {
        _showSnackbar(
          'Usuario desbloqueado',
          'Ahora puedes ver el contenido de @$username',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Recargar datos
        loadBlockedUsers();
      } else {
        _showSnackbar('Error', 'No se pudo desbloquear al usuario');
      }
    } catch (e) {
      debugPrint('❌ SocialController: Error al desbloquear usuario: $e');
      _showSnackbar('Error', 'Ocurrió un error al desbloquear al usuario');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar si un usuario está bloqueado
  Future<bool> isUserBlocked(String userId) async {
    return await _socialService.isUserBlocked(userId);
  }

  /// Cambiar tab actual
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// Cargar datos del perfil de un usuario visitado
  Future<void> loadUserProfile(String userId) async {
    isLoadingUserProfile.value = true;
    try {
      // Cargar estadísticas sociales
      final stats = await _socialService.getSocialStats(userId);
      visitedUserStats.value = stats;

      // Cargar posts del usuario
      final posts = await _workoutService.getUserPosts(userId);
      visitedUserPosts.value = posts;
    } catch (e) {
      debugPrint('❌ SocialController: Error al cargar perfil de usuario: $e');
    } finally {
      isLoadingUserProfile.value = false;
    }
  }

  /// Limpiar datos del perfil visitado
  void clearVisitedUserProfile() {
    visitedUserStats.value = null;
    visitedUserPosts.clear();
  }

  /// Mostrar snackbar de forma segura (evita errores de Overlay)
  void _showSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
  }) {
    // NO usar Get.snackbar directamente para evitar errores de Overlay
    // En su lugar, solo loguear el mensaje
    debugPrint('✅ SocialController: $title - $message');

    // Intentar mostrar snackbar SOLO si hay contexto válido y después de un delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      try {
        // Verificar si hay contexto válido
        final context = Get.key.currentContext ?? Get.context;
        if (context == null) {
          debugPrint(
            '⚠️ SocialController: No hay contexto, omitiendo snackbar',
          );
          return;
        }

        // Verificar si hay Overlay disponible
        try {
          Overlay.of(context, rootOverlay: true);
        } catch (e) {
          debugPrint(
            '⚠️ SocialController: No hay Overlay disponible, omitiendo snackbar',
          );
          return;
        }

        // Si llegamos aquí, hay contexto y overlay, mostrar snackbar
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }

        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: colorText ?? Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      } catch (e) {
        // Si falla, simplemente no mostrar (ya logueamos arriba)
        debugPrint(
          '⚠️ SocialController: Error al mostrar snackbar (ignorado): $e',
        );
      }
    });
  }
}
