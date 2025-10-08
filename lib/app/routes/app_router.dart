import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/onboarding/views/pages/onboarding_page.dart';
import 'package:tribbe_app/features/onboarding/views/pages/welcome_page.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';
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

    // TODO: Auth routes
    // GetPage<dynamic>(
    //   name: RoutePaths.login,
    //   page: () => const LoginPage(),
    //   binding: AuthBinding(),
    //   transition: Transition.fade,
    // ),

    // TODO: Home routes
    // GetPage<dynamic>(
    //   name: RoutePaths.home,
    //   page: () => const HomePage(),
    //   binding: HomeBinding(),
    //   transition: Transition.fadeIn,
    // ),

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

    // Controllers globales
    Get.put(SettingsController(), permanent: true);

    // TODO: Inicializar otros servicios
    // Get.lazyPut<AuthService>(() => AuthService());
    // Get.lazyPut<WorkoutService>(() => WorkoutService());
  }
}
