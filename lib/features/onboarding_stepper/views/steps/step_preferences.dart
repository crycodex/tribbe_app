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
              children: [
                const Text('Claro'),
                const SizedBox(width: 16),
                Obx(
                  () => Switch(
                    value: controller.tema.value == 'Noche',
                    onChanged: (value) {
                      final nuevoTema = value ? 'Noche' : 'Día';
                      controller.updateTema(nuevoTema);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Oscuro'),
              ],
            ),
          ),

          // Peso
          _buildSection(
            context,
            'Peso',
            Obx(
              () => DropdownButton<String>(
                value: controller.unidadPeso.value,
                isExpanded: true,
                items: ['kg', 'lb'].map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.unidadPeso.value = value;
                },
              ),
            ),
          ),

          // Medidas
          _buildSection(
            context,
            'Medidas',
            Obx(
              () => DropdownButton<String>(
                value: controller.unidadMedida.value,
                isExpanded: true,
                items: ['cm', 'in'].map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.unidadMedida.value = value;
                },
              ),
            ),
          ),

          // Idioma
          _buildSection(
            context,
            'Idioma',
            Obx(
              () => DropdownButton<String>(
                value: controller.idioma.value,
                isExpanded: true,
                items: ['Español', 'English'].map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.updateIdioma(value);
                },
              ),
            ),
          ),

          // Género
          _buildSection(
            context,
            'Género',
            Obx(
              () => DropdownButton<String>(
                value: controller.genero.value,
                isExpanded: true,
                items: ['Masculino', 'Femenino'].map((genero) {
                  return DropdownMenuItem(value: genero, child: Text(genero));
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.updateGenero(value);
                },
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
}
