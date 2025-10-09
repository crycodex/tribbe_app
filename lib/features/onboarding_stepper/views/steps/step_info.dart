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
            () => TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'mm/dd/yyyy',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: controller.fechaNacimiento.value != null
                    ? '${controller.fechaNacimiento.value!.month}/${controller.fechaNacimiento.value!.day}/${controller.fechaNacimiento.value!.year}'
                    : '',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.fechaNacimiento.value = date;
                }
              },
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
            decoration: InputDecoration(
              hintText: 'Preséntate (250)',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => controller.bio.value = value,
          ),
          const SizedBox(height: 24),

          // Meta Fitness
          const Text(
            'Meta fitnes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.metaFitness.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: controller.metasFitness.map((meta) {
                return DropdownMenuItem(value: meta, child: Text(meta));
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.metaFitness.value = value;
              },
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
          TextFormField(
            initialValue: controller.pais.value,
            decoration: InputDecoration(
              hintText: 'Ecuador, Imbabura, Ibarra',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              // Parse location (simple implementation)
              final parts = value.split(',').map((e) => e.trim()).toList();
              if (parts.isNotEmpty) controller.pais.value = parts[0];
              if (parts.length > 1) controller.provincia.value = parts[1];
              if (parts.length > 2) controller.ciudad.value = parts[2];
            },
          ),
        ],
      ),
    );
  }
}
