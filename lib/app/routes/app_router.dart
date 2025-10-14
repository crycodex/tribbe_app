import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/app/routes/routes.dart';

/// Configuración de rutas de la aplicación usando GetX
class AppRouter {
  AppRouter._();

  /// Lista de páginas de la aplicación
  static final List<GetPage<dynamic>> routes = [
    // Onboarding routes
    GetPage<dynamic>(
      name: RoutePaths.welcome,
      page: () => const WelcomePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.onboardingStepper,
      page: () => const OnboardingStepperPage(),
      binding: OnboardingStepperBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Auth routes
    GetPage<dynamic>(
      name: RoutePaths.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.forgotPassword,
      page: () => ForgotPasswordPage(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Home routes
    GetPage<dynamic>(
      name: RoutePaths.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Profile routes
    GetPage<dynamic>(
      name: RoutePaths.editProfile,
      page: () => const EditProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Training routes
    GetPage<dynamic>(
      name: RoutePaths.muscleSelection,
      page: () => const MuscleSelectionPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.trainingMode,
      page: () => const TrainingModePage(),
      binding: TrainingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<dynamic>(
      name: RoutePaths.workoutHistory,
      page: () => WorkoutHistoryPage(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // TODO: Social routes
    // TODO: Gym routes
  ];

  /// Inicializa las dependencias globales de la aplicación
  static Future<void> initDependencies() async {
    // Servicios globales (singleton permanente)
    final storageService = Get.put(StorageService(), permanent: true);
    await storageService.init();

    // Servicios de Firebase (singleton permanente)
    Get.put(FirebaseAuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);

    // Servicios de la aplicación
    Get.put(StreakService(), permanent: true);
    Get.put(WorkoutService(), permanent: true);

    // Controllers globales
    Get.put(SettingsController(), permanent: true);
  }

  /// Determina la ruta inicial basándose en el estado de autenticación
  static Future<String> getInitialRoute() async {
    try {
      final authService = Get.put<FirebaseAuthService>(FirebaseAuthService());
      final firestoreService = Get.put<FirestoreService>(FirestoreService());
      final storageService = Get.put<StorageService>(StorageService());

      // Verificar si hay un usuario autenticado
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        // No hay usuario autenticado
        // Verificar si es primera vez (mostrar welcome/onboarding)
        final hasSeenOnboarding = storageService.getAuthToken() != null;
        return hasSeenOnboarding ? RoutePaths.login : RoutePaths.welcome;
      }

      // Verificar si el email está verificado
      if (!currentUser.emailVerified) {
        // Email no verificado, cerrar sesión y volver al login
        await authService.logout();
        return RoutePaths.login;
      }

      // Usuario autenticado y verificado, cargar perfil
      final userProfile = await firestoreService.getUserProfile(
        currentUser.uid,
      );

      // Verificar si completó la personalización
      if (userProfile?.hasCompletedPersonalization ?? false) {
        // Ya completó todo, ir al home
        return RoutePaths.home;
      } else {
        // Aún falta completar personalización
        return RoutePaths.onboardingStepper;
      }
    } catch (e) {
      debugPrint('Error al determinar ruta inicial: $e');
      // En caso de error, ir al welcome
      return RoutePaths.welcome;
    }
  }
}

/// Binding para autenticación
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}

/// Binding para el Home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

/// Binding para el stepper de personalización
class OnboardingStepperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingStepperController>(
      () => OnboardingStepperController(),
    );
  }
}

/// Binding para el perfil
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

/// Binding para el entrenamiento
class TrainingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingController>(() => TrainingController());
  }
}
