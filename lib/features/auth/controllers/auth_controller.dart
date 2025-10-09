import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/models/auth_response_model.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';

/// Controlador de autenticación
class AuthController extends GetxController {
  // Dependencias
  final StorageService _storageService = Get.find();

  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString username = ''.obs;
  final RxString confirmPasswordValue = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Verifica si hay sesión activa
  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getToken();
    final userData = await _storageService.getUserData();

    if (token != null && userData != null) {
      try {
        currentUser.value = UserModel.fromJson(userData);
        isAuthenticated.value = true;
      } catch (e) {
        await logout();
      }
    }
  }

  /// Inicia sesión con email y contraseña
  Future<void> loginWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar llamada a API
      // Simulación por ahora
      await Future.delayed(const Duration(seconds: 2));

      // Simulación de respuesta exitosa
      final mockUser = UserModel(
        id: '1',
        email: email.value,
        username: email.value.split('@')[0],
        displayName: 'Usuario Demo',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      final mockAuthResponse = AuthResponseModel(
        user: mockUser,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Guardar en storage
      await _storageService.saveToken(mockAuthResponse.token);
      await _storageService.saveUserData(mockUser.toJson());

      // Actualizar estado
      currentUser.value = mockUser;
      isAuthenticated.value = true;

      // Navegar a home
      Get.offAllNamed(RoutePaths.home);

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Bienvenido',
        '¡Hola ${mockUser.displayName ?? mockUser.username}!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Registra un nuevo usuario
  Future<void> registerWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar llamada a API
      // Simulación por ahora
      await Future.delayed(const Duration(seconds: 2));

      // Simulación de respuesta exitosa
      final mockUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.value,
        username: username.value,
        displayName: username.value,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );

      final mockAuthResponse = AuthResponseModel(
        user: mockUser,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Guardar en storage
      await _storageService.saveToken(mockAuthResponse.token);
      await _storageService.saveUserData(mockUser.toJson());

      // Actualizar estado
      currentUser.value = mockUser;
      isAuthenticated.value = true;

      // Navegar a home
      Get.offAllNamed(RoutePaths.home);

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Registro Exitoso',
        '¡Bienvenido a la tribu ${mockUser.username}!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Error al registrarse: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Inicia sesión con Facebook
  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar Facebook Login
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Próximamente',
        'Login con Facebook estará disponible pronto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión con Facebook';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Inicia sesión con Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar Google Login
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Próximamente',
        'Login con Google estará disponible pronto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión con Google';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Inicia sesión con Apple
  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar Apple Login
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Próximamente',
        'Login con Apple estará disponible pronto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión con Apple';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Envía email para recuperar contraseña
  Future<void> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implementar recuperación de contraseña
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Email Enviado',
        'Revisa tu correo para restablecer tu contraseña',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Volver al login después de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    } catch (e) {
      errorMessage.value = 'Error al enviar email: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Limpiar storage
      await _storageService.clear();

      // Limpiar estado
      currentUser.value = null;
      isAuthenticated.value = false;
      email.value = '';
      password.value = '';
      username.value = '';
      confirmPasswordValue.value = '';

      // Navegar a welcome
      Get.offAllNamed(RoutePaths.welcome);
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpia los mensajes de error
  void clearError() {
    errorMessage.value = '';
  }
}
