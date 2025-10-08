import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/app_router.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/app/theme/theme_data.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';

Future<void> main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias globales
  await AppRouter.initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put<SettingsController>(
      SettingsController(),
    );

    return Obx(
      () => GetMaterialApp(
        title: 'Tribbe App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settingsController.flutterThemeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: RoutePaths.welcome,
        getPages: AppRouter.routes,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
