import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/models/user_profile_model.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';

/// Controlador de autenticación con Firebase
class AuthController extends GetxController {
  // Dependencias
  final StorageService _storageService = Get.find();
  final FirebaseAuthService _authService = Get.find();
  final FirestoreService _firestoreService = Get.find();

  // Observables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPasswordValue = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
  }

  /// Escuchar cambios de autenticación
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((User? user) {
      firebaseUser.value = user;
      isAuthenticated.value = user != null;

      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        userProfile.value = null;
      }
    });
  }

  /// Cargar perfil del usuario desde Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final profile = await _firestoreService.getUserProfile(uid);
      userProfile.value = profile;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar perfil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Registrar usuario con email y contraseña
  Future<void> registerWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Registrar en Firebase Auth
      final userCredential = await _authService.registerWithEmail(
        email: email.value.trim(),
        password: password.value,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al crear usuario');
      }

      // Crear perfil en Firestore con preferencias iniciales
      await _firestoreService.createUserProfile(
        uid: user.uid,
        email: email.value.trim(),
        nombreUsuario: null, // Ya no usamos username
      );

      // Sincronizar preferencias de SharedPreferences a Firebase
      final currentTheme = _storageService.getThemeMode().value;
      final currentLanguage = _storageService.getLanguage().name;
      final currentGender = _storageService.getGender()?.value ?? 'male';

      await _firestoreService.syncPreferenciasFromLocal(
        uid: user.uid,
        tema: currentTheme == 'dark' ? 'Noche' : 'Día',
        idioma: currentLanguage == 'spanish' ? 'Español' : 'English',
        genero: currentGender == 'male'
            ? 'Masculino'
            : currentGender == 'female'
            ? 'Femenino'
            : 'Otro',
      );

      // Enviar email de verificación
      await _authService.sendEmailVerification();

      // Mostrar diálogo primero (mientras el usuario aún está autenticado)
      _showEmailVerificationDialog();

      // Esperar a que el usuario cierre el diálogo
      await Future.delayed(const Duration(milliseconds: 500));

      // Cerrar sesión y redirigir al login
      await logout();
      Get.offAllNamed(RoutePaths.login);
    } catch (e) {
      errorMessage.value = e.toString();
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

  /// Mostrar diálogo de verificación de email
  void _showEmailVerificationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Verifica tu Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.email_outlined,
              size: 64,
              color: Color(0xFF0047FF),
            ),
            const SizedBox(height: 16),
            Text(
              'Te hemos enviado un email de verificación a:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              email.value.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Por favor, revisa tu bandeja de entrada y spam. Verifica tu email antes de iniciar sesión.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Iniciar sesión con email y contraseña
  Future<void> loginWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Iniciar sesión en Firebase Auth
      final userCredential = await _authService.loginWithEmail(
        email: email.value.trim(),
        password: password.value,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al iniciar sesión');
      }

      // Verificar si el email está verificado
      if (!user.emailVerified) {
        Get.snackbar(
          'Email No Verificado',
          'Por favor verifica tu email antes de continuar.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );

        // Ofrecer reenviar email de verificación
        _showResendVerificationDialog();

        await logout();
        return;
      }

      // Cargar perfil desde Firestore
      await _loadUserProfile(user.uid);

      // Guardar en storage local
      await _storageService.saveAuthToken(await user.getIdToken() ?? '');
      await _storageService.saveLoginState(true);

      // Verificar si completó la personalización
      final hasCompletedPersonalization =
          userProfile.value?.hasCompletedPersonalization ?? false;

      if (!hasCompletedPersonalization) {
        // Primera vez: Ir al stepper de personalización
        Get.offAllNamed(
          RoutePaths.onboardingStepper,
          arguments: {'userId': user.uid},
        );

        Get.snackbar(
          'Completa tu Perfil',
          '¡Bienvenido! Personaliza tu cuenta para empezar',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Ya completó: Ir directamente al home
        Get.offAllNamed(RoutePaths.home);

        Get.snackbar(
          'Bienvenido',
          '¡Hola ${userProfile.value?.datosPersonales?.nombreUsuario ?? email.value.split('@')[0]}!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
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

  /// Mostrar diálogo para reenviar email de verificación
  void _showResendVerificationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('¿Reenviar Email?'),
        content: const Text(
          '¿Deseas que te reenviemos el email de verificación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await resendVerificationEmail();
            },
            child: const Text('Reenviar'),
          ),
        ],
      ),
    );
  }

  /// Reenviar email de verificación
  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;

      // Primero necesitamos iniciar sesión temporalmente
      await _authService.loginWithEmail(
        email: email.value.trim(),
        password: password.value,
      );

      await _authService.sendEmailVerification();

      Get.snackbar(
        'Email Enviado',
        'Te hemos enviado un nuevo email de verificación',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      await logout();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al reenviar email: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Iniciar sesión con Facebook
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

  /// Iniciar sesión con Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Iniciar sesión con Google
      final userCredential = await _authService.loginWithGoogle();

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al iniciar sesión con Google');
      }

      // Verificar si ya existe un perfil en Firestore
      final existingProfile = await _firestoreService.getUserProfile(user.uid);

      if (existingProfile == null) {
        // Primera vez con Google: Crear perfil básico
        await _firestoreService.createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          nombreUsuario: user.displayName, // Usar nombre de Google
        );

        // Sincronizar preferencias locales
        final currentTheme = _storageService.getThemeMode().value;
        final currentLanguage = _storageService.getLanguage().name;
        final currentGender = _storageService.getGender()?.value ?? 'male';

        await _firestoreService.syncPreferenciasFromLocal(
          uid: user.uid,
          tema: currentTheme == 'dark' ? 'Noche' : 'Día',
          idioma: currentLanguage == 'spanish' ? 'Español' : 'English',
          genero: currentGender == 'male'
              ? 'Masculino'
              : currentGender == 'female'
              ? 'Femenino'
              : 'Otro',
        );
      }

      // Cargar perfil desde Firestore
      await _loadUserProfile(user.uid);

      // Guardar en storage local
      await _storageService.saveAuthToken(await user.getIdToken() ?? '');
      await _storageService.saveLoginState(true);

      // Verificar si completó la personalización
      final hasCompletedPersonalization =
          userProfile.value?.hasCompletedPersonalization ?? false;

      if (!hasCompletedPersonalization) {
        // Primera vez: Ir al stepper de personalización
        Get.offAllNamed(
          RoutePaths.onboardingStepper,
          arguments: {'userId': user.uid},
        );

        Get.snackbar(
          'Completa tu Perfil',
          '¡Bienvenido! Personaliza tu cuenta para empezar',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Ya completó: Ir directamente al home
        Get.offAllNamed(RoutePaths.home);

        Get.snackbar(
          'Bienvenido',
          '¡Hola ${userProfile.value?.datosPersonales?.nombreUsuario ?? user.displayName ?? 'Usuario'}!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();

      // No mostrar error si el usuario canceló
      if (!e.toString().contains('cancelado')) {
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Iniciar sesión con Apple
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

  /// Enviar email para recuperar contraseña
  Future<void> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.sendPasswordResetEmail(email.value.trim());

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
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Cerrar sesión en Firebase
      await _authService.logout();

      // Limpiar storage local
      await _storageService.clearSessionData();

      // Limpiar estado
      firebaseUser.value = null;
      userProfile.value = null;
      isAuthenticated.value = false;
      email.value = '';
      password.value = '';
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

  /// Verificar si el usuario completó la personalización
  bool get hasCompletedPersonalization =>
      userProfile.value?.hasCompletedPersonalization ?? false;
}
