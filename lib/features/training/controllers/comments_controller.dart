import 'dart:async';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/models/comment_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/workout_service.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';

/// Controlador para gestionar los comentarios de un post de entrenamiento
class CommentsController extends GetxController {
  final WorkoutService _workoutService = Get.find<WorkoutService>();
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();
  final AuthController _authController = Get.find<AuthController>();

  final String postId;

  CommentsController({required this.postId}); // Constructor para recibir postId

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoadingComments = true.obs;
  final RxString newCommentText = ''.obs;
  final RxBool isSendingComment = false.obs;

  StreamSubscription<List<CommentModel>>? _commentsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToComments();
  }

  @override
  void onClose() {
    _commentsSubscription?.cancel();
    super.onClose();
  }

  /// Escuchar comentarios en tiempo real
  void _listenToComments() {
    _commentsSubscription?.cancel();
    _commentsSubscription = _workoutService
        .getCommentsStream(postId)
        .listen(
          (latestComments) {
            comments.value = latestComments;
            isLoadingComments.value = false;
          },
          onError: (error) {
            print('Error al obtener comentarios: $error');
            isLoadingComments.value = false;
            Get.snackbar(
              'Error',
              'No se pudieron cargar los comentarios',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
  }

  /// Enviar un nuevo comentario
  Future<void> sendComment() async {
    if (newCommentText.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'El comentario no puede estar vacío',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Debes iniciar sesión para comentar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSendingComment.value = true;

      // Obtener el nombre real del usuario desde el perfil
      String userName = 'Usuario'; // Valor por defecto
      String? userPhotoUrl = currentUser.photoURL;

      final userProfile = _authController.userProfile.value;
      if (userProfile?.datosPersonales?.nombreCompleto != null &&
          userProfile!.datosPersonales!.nombreCompleto!.isNotEmpty) {
        userName = userProfile.datosPersonales!.nombreCompleto!;
      } else if (userProfile?.datosPersonales?.nombreUsuario != null &&
          userProfile!.datosPersonales!.nombreUsuario!.isNotEmpty) {
        userName = userProfile.datosPersonales!.nombreUsuario!;
      }

      // Obtener foto de perfil desde el perfil si no está en Auth
      if (userProfile?.personaje?.avatarUrl != null &&
          userProfile!.personaje!.avatarUrl!.isNotEmpty) {
        userPhotoUrl = userProfile.personaje!.avatarUrl;
      }

      await _workoutService.addComment(
        postId: postId,
        userId: currentUser.uid,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        text: newCommentText.value.trim(),
      );
      newCommentText.value = ''; // Limpiar el campo de texto
      // No es necesario recargar, el stream se encargará de actualizar la lista
    } catch (e) {
      print('Error al enviar comentario: $e');
      Get.snackbar(
        'Error',
        'No se pudo enviar el comentario',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingComment.value = false;
    }
  }
}
