import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/home/controllers/home_controller.dart';
import 'package:tribbe_app/features/dashboard/views/pages/dashboard_page.dart';
import 'package:tribbe_app/features/gym/views/pages/gym_page.dart';
import 'package:tribbe_app/features/profile/views/pages/profile_page.dart';
import 'package:tribbe_app/features/store/views/pages/store_page.dart';
import 'package:tribbe_app/features/training/views/pages/training_page.dart';
import 'package:tribbe_app/shared/widgets/training_menu_sheet.dart';
import 'package:tribbe_app/shared/widgets/tribbe_tab_bar.dart';

/// Página principal con navegación por tabs
/// Cada tab es un feature completamente independiente
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Páginas para cada tab (features independientes)
  static const List<Widget> _pages = [
    DashboardPage(), // Home/Dashboard
    GymPage(), // Gimnasios
    TrainingPage(), // Entrenar
    StorePage(), // Tienda
    ProfilePage(), // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
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
                onTap: (index) {
                  if (index == 2) {
                    // Tab central: solo cambiar índice, el long press abre menú
                    controller.changeTab(index);
                  } else {
                    controller.changeTab(index);
                  }
                },
                onCenterLongPress: () => _showTrainingMenu(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar bottom sheet con opciones de entrenamiento
  void _showTrainingMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const TrainingMenuSheet(),
    );
  }
}
