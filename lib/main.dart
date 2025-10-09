import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/app_router.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/app/theme/theme_data.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

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

    return FutureBuilder<String>(
      future: AppRouter.getInitialRoute(),
      builder: (context, snapshot) {
        // Mientras se determina la ruta, mostrar splash
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: settingsController.isDarkMode
                  ? const Color(0xFF121212)
                  : Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/icon_ligth.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 24),
                    const CupertinoActivityIndicator(),
                  ],
                ),
              ),
            ),
          );
        }

        final initialRoute = snapshot.data ?? RoutePaths.welcome;

        return Obx(
          () => GetMaterialApp(
            title: 'Tribbe App',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsController.flutterThemeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: initialRoute,
            getPages: AppRouter.routes,
            defaultTransition: Transition.cupertino,
          ),
        );
      },
    );
  }
}
