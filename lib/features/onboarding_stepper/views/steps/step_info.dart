import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';

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
          const Text(
            'Fecha nacimiento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      ? Colors.grey.shade800.withOpacity(0.5)
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
                  ? Colors.grey.shade800.withOpacity(0.5)
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
          const Text(
            'Meta fitness',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      ? Colors.grey.shade800.withOpacity(0.5)
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
                  selectedColor: theme.colorScheme.primary.withOpacity(0.3),
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
          const Text(
            'Ubicación',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withOpacity(0.5)
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
                  Icons.location_on,
                  size: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ecuador, Imbabura, Ibarra',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
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
}
