import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';

/// Step 3: Personaliza tu Personaje/Avatar
class StepPersonaje extends StatelessWidget {
  const StepPersonaje({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingStepperController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar Placeholder
          Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.person, size: 100, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 24),

          // Nombre
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '¿Cómo te llamas?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Ingresa tu nombre',
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
            ),
            onChanged: (value) => controller.nombreCompleto.value = value,
          ),
          const SizedBox(height: 24),

          // Género
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Género',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildGenderButton(
                    context,
                    'Femenino',
                    controller.genero.value == 'Femenino',
                    () => controller.genero.value = 'Femenino',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderButton(
                    context,
                    'Masculino',
                    controller.genero.value == 'Masculino',
                    () => controller.genero.value = 'Masculino',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nivel
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nivel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLevelOption(
                    context,
                    'principiante',
                    controller.nivelExperiencia.value == 'Principiante',
                    () => controller.nivelExperiencia.value = 'Principiante',
                  ),
                  _buildLevelOption(
                    context,
                    'intermedio',
                    controller.nivelExperiencia.value == 'Intermedio',
                    () => controller.nivelExperiencia.value = 'Intermedio',
                  ),
                  _buildLevelOption(
                    context,
                    'avanzado',
                    controller.nivelExperiencia.value == 'Avanzado',
                    () => controller.nivelExperiencia.value = 'Avanzado',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Condición Física
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Condición',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🔥 pésima'),
                    Text(
                      '${controller.condicionFisicaActual.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('óptima 🔥'),
                  ],
                ),
                Slider(
                  value: controller.condicionFisicaActual.value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) {
                    controller.condicionFisicaActual.value = value.toInt();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Altura
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Altura',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final esCm = controller.unidadMedida.value == 'cm';
            final minAltura = esCm ? 100.0 : 39.4; // 100cm = 39.4in
            final maxAltura = esCm ? 220.0 : 86.6; // 220cm = 86.6in

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(esCm ? '1m' : '3.2ft'),
                    Text(
                      controller.alturaConUnidad,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(esCm ? '2.2m+' : '7.2ft+'),
                  ],
                ),
                Slider(
                  value: controller.alturaCm.value.clamp(minAltura, maxAltura),
                  min: minAltura,
                  max: maxAltura,
                  divisions: esCm ? 120 : 472,
                  onChanged: (value) {
                    controller.alturaCm.value = value;
                  },
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Piel
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Piel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSkinToneOption(
                  context,
                  '#ffd7ba',
                  controller.tonoPiel.value == '#ffd7ba',
                ),
                const SizedBox(width: 16),
                _buildSkinToneOption(
                  context,
                  '#d4a87b',
                  controller.tonoPiel.value == '#d4a87b',
                ),
                const SizedBox(width: 16),
                _buildSkinToneOption(
                  context,
                  '#8b6f47',
                  controller.tonoPiel.value == '#8b6f47',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelOption(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSkinToneOption(
    BuildContext context,
    String colorHex,
    bool isSelected,
  ) {
    final color = Color(
      int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return InkWell(
      onTap: () {
        final controller = Get.find<OnboardingStepperController>();
        controller.tonoPiel.value = colorHex;
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 4 : 2,
          ),
        ),
      ),
    );
  }
}
