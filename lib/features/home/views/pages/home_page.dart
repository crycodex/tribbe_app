import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/home/controllers/home_controller.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';
import 'package:tribbe_app/features/dashboard/views/pages/dashboard_page.dart';
// import 'package:tribbe_app/features/gym/views/pages/gym_page.dart';
import 'package:tribbe_app/features/profile/views/pages/profile_page.dart';
// import 'package:tribbe_app/features/store/views/pages/store_page.dart';
import 'package:tribbe_app/shared/widgets/tribbe_tab_bar.dart';
import 'package:tribbe_app/shared/widgets/settings_drawer.dart';
import 'package:tribbe_app/shared/widgets/active_training_indicator.dart';

/// GlobalKey para acceder al Scaffold desde cualquier lugar
final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();

/// Página principal con navegación por tabs
/// Cada tab es un feature completamente independiente
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Páginas para cada tab (features independientes)
  static const List<Widget> _pages = [
    DashboardPage(), // Home/Dashboard
    // GymPage(), // Gimnasios (temporalmente oculto)
    DashboardPage(), // Placeholder (no usado, botón central abre training)
    // StorePage(), // Tienda (temporalmente oculto)
    ProfilePage(), // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    // Usar Get.find() en lugar de Get.put() porque HomeBinding ya lo registró
    // Esto evita crear múltiples instancias y el error de GlobalKey duplicado
    final controller = Get.find<HomeController>();

    return Scaffold(
      key: homeScaffoldKey, // GlobalKey para acceder desde otras páginas
      // Drawer lateral derecho disponible globalmente
      endDrawer: const SettingsDrawer(),
      endDrawerEnableOpenDragGesture: false, // Solo se abre con botón
      body: Stack(
        children: [
          // Contenido del tab actual
          Obx(
            () => IndexedStack(
              index: controller.currentTabIndex.value,
              children: _pages,
            ),
          ),

          // Tab Bar en la parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => TribbeTabBar(
                currentIndex: controller.currentTabIndex.value,
                onTap: (index) => controller.changeTab(index),
                onTrainingTap: () => _openTrainingMode(),
              ),
            ),
          ),

          // Indicador de entrenamiento activo
          const ActiveTrainingIndicator(),
        ],
      ),
    );
  }

  /// Abrir selección de músculo o volver al entrenamiento activo
  void _openTrainingMode() {
    // Si hay un entrenamiento activo, volver a esa página
    if (Get.isRegistered<TrainingController>()) {
      final trainingController = Get.find<TrainingController>();
      if (trainingController.isTraining.value) {
        Get.toNamed(RoutePaths.trainingMode);
        return;
      }
    }

    // Si no hay entrenamiento activo, iniciar uno nuevo
    Get.toNamed(RoutePaths.muscleSelection);
  }
}
