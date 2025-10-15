import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';

/// Step 1: Preferencias (Mostrar las ya guardadas)
class StepPreferences extends StatelessWidget {
  const StepPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingStepperController>();
    Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tema
          _buildSection(
            context,
            'Tema',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Claro'),
                Obx(
                  () => CNSwitch(
                    value: controller.tema.value == 'Noche',
                    onChanged: (value) {
                      final nuevoTema = value ? 'Noche' : 'Día';
                      controller.updateTema(nuevoTema);
                    },
                  ),
                ),
                const Text('Oscuro'),
              ],
            ),
          ),

          // Peso
          _buildSection(
            context,
            'Unidad de Peso',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kg'),
                Obx(
                  () => CNSwitch(
                    value: controller.unidadPeso.value == 'lb',
                    onChanged: (value) {
                      controller.updateUnidadPeso(value ? 'lb' : 'kg');
                    },
                  ),
                ),
                const Text('Lb'),
              ],
            ),
          ),

          // Medidas
          _buildSection(
            context,
            'Unidad de Medida',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('cm'),
                Obx(
                  () => CNSwitch(
                    value: controller.unidadMedida.value == 'in',
                    onChanged: (value) {
                      controller.updateUnidadMedida(value ? 'in' : 'cm');
                    },
                  ),
                ),
                const Text('in'),
              ],
            ),
          ),

          // Idioma
          _buildSection(
            context,
            'Idioma',
            Obx(
              () => GestureDetector(
                onTap: () => _showLanguageActionSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800.withOpacity(0.5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getLanguageFlag(controller.idioma.value),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.idioma.value,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Género
          _buildSection(
            context,
            'Género',
            Obx(
              () => GestureDetector(
                onTap: () => _showGenderActionSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800.withOpacity(0.5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.genero.value,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  /// Mostrar CupertinoActionSheet para seleccionar idioma
  void _showLanguageActionSheet(
    BuildContext context,
    OnboardingStepperController controller,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecciona tu idioma',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        message: const Text(
          'Elige el idioma de la aplicación',
          style: TextStyle(fontSize: 13),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              controller.updateIdioma('Español');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'Español',
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.idioma.value == 'Español'
                        ? CupertinoColors.activeBlue
                        : null,
                    fontWeight: controller.idioma.value == 'Español'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (controller.idioma.value == 'Español') ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  /// Obtener emoji de bandera según idioma
  String _getLanguageFlag(String idioma) {
    switch (idioma) {
      case 'Español':
        return '🇪🇸';
      case 'English':
        return '🇺🇸';
      default:
        return '🌍';
    }
  }

  /// Mostrar CupertinoActionSheet para seleccionar género
  void _showGenderActionSheet(
    BuildContext context,
    OnboardingStepperController controller,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecciona tu género',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        message: const Text(
          'Elige la opción que mejor te represente',
          style: TextStyle(fontSize: 13),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              controller.updateGenero('Masculino');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Masculino',
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.genero.value == 'Masculino'
                        ? CupertinoColors.activeBlue
                        : null,
                    fontWeight: controller.genero.value == 'Masculino'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (controller.genero.value == 'Masculino') ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.updateGenero('Femenino');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Femenino',
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.genero.value == 'Femenino'
                        ? CupertinoColors.activeBlue
                        : null,
                    fontWeight: controller.genero.value == 'Femenino'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (controller.genero.value == 'Femenino') ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.updateGenero('Otro');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Otro',
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.genero.value == 'Otro'
                        ? CupertinoColors.activeBlue
                        : null,
                    fontWeight: controller.genero.value == 'Otro'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (controller.genero.value == 'Otro') ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
