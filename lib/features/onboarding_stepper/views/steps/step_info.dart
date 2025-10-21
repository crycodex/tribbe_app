import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';
import 'package:tribbe_app/shared/services/location_service.dart';

/// Step 2: Información Personal y Fitness
class StepInfo extends StatelessWidget {
  const StepInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingStepperController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Fecha nacimiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => GestureDetector(
              onTap: () => _showDatePicker(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.fechaNacimiento.value != null
                          ? '${controller.fechaNacimiento.value!.day}/${controller.fechaNacimiento.value!.month}/${controller.fechaNacimiento.value!.year}'
                          : 'Selecciona tu fecha de nacimiento',
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.fechaNacimiento.value != null
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bio
          const Text(
            'Bio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            maxLength: 250,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Preséntate (250)',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              counterStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            onChanged: (value) => controller.bio.value = value,
          ),
          const SizedBox(height: 24),

          // Meta Fitness
          Row(
            children: [
              const Text(
                'Meta fitness',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => GestureDetector(
              onTap: () => _showMetaFitnessActionSheet(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.metaFitness.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lesiones
          const Text(
            'Lesiones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.lesionesList.map((lesion) {
                final isSelected = controller.lesiones.contains(lesion);
                return FilterChip(
                  label: Text(lesion),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.toggleLesion(lesion);
                  },
                  selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  checkmarkColor: theme.colorScheme.primary,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Nivel de Experiencia
          const Text(
            'Nivel experiencia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              children: controller.nivelesExperiencia.map((nivel) {
                final isSelected = controller.nivelExperiencia.value == nivel;
                return ChoiceChip(
                  label: Text(nivel),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.nivelExperiencia.value = nivel;
                    }
                  },
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Ubicación
          Row(
            children: [
              const Text(
                'Ubicación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final hasLocation =
                controller.pais.value.isNotEmpty ||
                controller.ciudad.value.isNotEmpty;
            final locationText = hasLocation
                ? [
                    controller.ciudad.value,
                    controller.provincia.value,
                    controller.pais.value,
                  ].where((e) => e.isNotEmpty).join(', ')
                : 'Obtener mi ubicación';

            return GestureDetector(
              onTap: () => _showLocationOptions(context, controller, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasLocation ? Icons.location_on : Icons.my_location,
                      size: 20,
                      color: hasLocation
                          ? theme.colorScheme.primary
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        locationText,
                        style: TextStyle(
                          fontSize: 16,
                          color: hasLocation
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Mostrar CupertinoDatePicker para seleccionar fecha
  void _showDatePicker(
    BuildContext context,
    OnboardingStepperController controller,
  ) {
    DateTime selectedDate = controller.fechaNacimiento.value ?? DateTime(2000);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Barra superior con botón Confirmar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        controller.fechaNacimiento.value = selectedDate;
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Date Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: DateTime(1940),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar CupertinoActionSheet para seleccionar meta fitness
  void _showMetaFitnessActionSheet(
    BuildContext context,
    OnboardingStepperController controller,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecciona tu meta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        message: const Text(
          'Elige tu objetivo principal de entrenamiento',
          style: TextStyle(fontSize: 13),
        ),
        actions: controller.metasFitness.map((meta) {
          final isSelected = controller.metaFitness.value == meta;
          return CupertinoActionSheetAction(
            onPressed: () {
              controller.metaFitness.value = meta;
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 17,
                    color: isSelected ? CupertinoColors.activeBlue : null,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
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

  /// Mostrar opciones de ubicación
  void _showLocationOptions(
    BuildContext context,
    OnboardingStepperController controller,
    bool isDark,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecciona tu ubicación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        message: const Text(
          'Elige cómo quieres configurar tu ubicación',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await _obtainCurrentLocation(context, controller);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location, color: CupertinoColors.activeBlue),
                SizedBox(width: 8),
                Text(
                  'Usar mi ubicación actual',
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showManualLocationInput(context, controller, isDark);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_location, color: CupertinoColors.activeBlue),
                SizedBox(width: 8),
                Text('Ingresar manualmente', style: TextStyle(fontSize: 17)),
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

  /// Obtener ubicación actual del usuario
  Future<void> _obtainCurrentLocation(
    BuildContext context,
    OnboardingStepperController controller,
  ) async {
    // Mostrar loading
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Obteniendo ubicación...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final locationService = LocationService();
      final locationData = await locationService.getCurrentLocation();

      Get.back(); // Cerrar loading

      if (locationData != null) {
        controller.pais.value = locationData['pais'] as String;
        controller.provincia.value = locationData['provincia'] as String;
        controller.ciudad.value = locationData['ciudad'] as String;
        controller.latitud.value = locationData['latitud'] as double;
        controller.longitud.value = locationData['longitud'] as double;

        Get.snackbar(
          '¡Ubicación obtenida!',
          'Tu ubicación ha sido configurada',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'No se pudo obtener tu ubicación. Verifica los permisos.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Cerrar loading
      Get.snackbar(
        'Error',
        'Ocurrió un error al obtener tu ubicación',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Mostrar formulario para ingresar ubicación manualmente
  void _showManualLocationInput(
    BuildContext context,
    OnboardingStepperController controller,
    bool isDark,
  ) {
    final paisController = TextEditingController(text: controller.pais.value);
    final provinciaController = TextEditingController(
      text: controller.provincia.value,
    );
    final ciudadController = TextEditingController(
      text: controller.ciudad.value,
    );

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Barra superior con botones
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final pais = paisController.text.trim();
                        final provincia = provinciaController.text.trim();
                        final ciudad = ciudadController.text.trim();

                        if (pais.isEmpty || ciudad.isEmpty) {
                          Get.snackbar(
                            'Campos requeridos',
                            'Por favor ingresa al menos país y ciudad',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }

                        controller.pais.value = pais;
                        controller.provincia.value = provincia;
                        controller.ciudad.value = ciudad;
                        controller.latitud.value = null;
                        controller.longitud.value = null;

                        Navigator.pop(context);

                        Get.snackbar(
                          '¡Ubicación guardada!',
                          'Tu ubicación ha sido configurada',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido con campos de texto
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // País
                      _buildCupertinoTextField(
                        context: context,
                        controller: paisController,
                        placeholder: 'País *',
                        icon: Icons.public,
                      ),
                      const SizedBox(height: 16),
                      // Provincia
                      _buildCupertinoTextField(
                        context: context,
                        controller: provinciaController,
                        placeholder: 'Provincia/Estado',
                        icon: Icons.location_city,
                      ),
                      const SizedBox(height: 16),
                      // Ciudad
                      _buildCupertinoTextField(
                        context: context,
                        controller: ciudadController,
                        placeholder: 'Ciudad *',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '* Campos requeridos',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget de campo de texto estilo Cupertino
  Widget _buildCupertinoTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              icon,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              size: 20,
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: const BoxDecoration(),
              style: const TextStyle(fontSize: 16),
              placeholderStyle: TextStyle(
                fontSize: 16,
                color: CupertinoColors.placeholderText.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
