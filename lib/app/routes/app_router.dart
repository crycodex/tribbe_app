import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/features/auth/views/pages/forgot_password_page.dart';
import 'package:tribbe_app/features/auth/views/pages/login_page.dart';
import 'package:tribbe_app/features/auth/views/pages/register_page.dart';
import 'package:tribbe_app/features/home/views/pages/home_page.dart';
import 'package:tribbe_app/features/onboarding/views/pages/onboarding_page.dart';
import 'package:tribbe_app/features/onboarding/views/pages/welcome_page.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';
import 'package:tribbe_app/features/onboarding_stepper/views/pages/onboarding_stepper_page.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';
import 'package:tribbe_app/shared/services/firebase_auth_service.dart';
import 'package:tribbe_app/shared/services/firestore_service.dart';
import 'package:tribbe_app/shared/services/storage_service.dart';

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
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // TODO: Workout routes
    // TODO: Profile routes
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

    // Controllers globales
    Get.put(SettingsController(), permanent: true);

    // TODO: Inicializar otros servicios
    // Get.lazyPut<ApiService>(() => ApiService());
    // Get.lazyPut<WorkoutService>(() => WorkoutService());
  }
}

/// Binding para autenticación
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
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
