import 'package:get/get.dart';

/// Controlador para el Home y navegación principal
class HomeController extends GetxController {
  // Índice del tab actual
  final RxInt currentTabIndex = 0.obs;

  /// Cambiar a un tab específico
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// Mostrar menú de opciones de entrenamiento
  void showTrainingMenu() {
    // El bottom sheet se manejará desde el widget
    print('Mostrar menú de entrenamiento');
  }
}
