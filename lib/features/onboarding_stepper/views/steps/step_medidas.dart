import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';

/// Step 4: Medidas Corporales
class StepMedidas extends StatelessWidget {
  const StepMedidas({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingStepperController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Altura
          _buildMeasureField(
            context,
            'Altura',
            controller.alturaCm,
            'cm',
            min: 100,
            max: 220,
          ),
          const SizedBox(height: 16),

          // Peso
          _buildMeasureField(
            context,
            'Peso (kg)',
            controller.pesoKg,
            'kg',
            min: 30,
            max: 200,
          ),
          const SizedBox(height: 24),

          // Sección Avanzado
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.cuello.value > 0,
                  onChanged: (value) {
                    if (value == false) {
                      // Reset all advanced measures
                      controller.cuello.value = 0;
                      controller.hombro.value = 0;
                      controller.brazoIzquierdo.value = 0;
                      controller.brazoDerecho.value = 0;
                      controller.antebrazoIzquierdo.value = 0;
                      controller.antebrazoDerecho.value = 0;
                      controller.pecho.value = 0;
                      controller.espalda.value = 0;
                      controller.cintura.value = 0;
                      controller.cuadricepIzquierdo.value = 0;
                      controller.cuadricepDerecho.value = 0;
                      controller.pantorrillaIzquierda.value = 0;
                      controller.pantorrillaDerecha.value = 0;
                    } else {
                      controller.cuello.value = 35;
                    }
                  },
                ),
              ),
              const Text(
                'Avanzado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Text(
                'Medidas Específicas (cm)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          Obx(() {
            if (controller.cuello.value == 0) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                const SizedBox(height: 16),

                // Cuello
                _buildMeasureInput('Cuello', controller.cuello),
                const SizedBox(height: 12),

                // Brazo Izquierdo y Derecho
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureInput(
                        'Brazo Izq.',
                        controller.brazoIzquierdo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureInput(
                        'Brazo Der.',
                        controller.brazoDerecho,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Antebrazo Izquierdo y Derecho
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureInput(
                        'Antebrazo Izq.',
                        controller.antebrazoIzquierdo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureInput(
                        'Antebrazo Der.',
                        controller.antebrazoDerecho,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pecho
                _buildMeasureInput('Pecho', controller.pecho),
                const SizedBox(height: 12),

                // Espalda y Cintura
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureInput('Espalda', controller.espalda),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureInput('Cintura', controller.cintura),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cuádriceps Izquierdo y Derecho
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureInput(
                        'Cuádricep Izq.',
                        controller.cuadricepIzquierdo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureInput(
                        'Cuádricep Der.',
                        controller.cuadricepDerecho,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pantorrilla Izquierda y Derecha
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureInput(
                        'Pantorrilla Izq.',
                        controller.pantorrillaIzquierda,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureInput(
                        'Pantorrilla Der.',
                        controller.pantorrillaDerecha,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMeasureField(
    BuildContext context,
    String label,
    RxDouble value,
    String unit, {
    double min = 0,
    double max = 300,
  }) {
    final controller = Get.find<OnboardingStepperController>();

    return Obx(() {
      // Determinar la unidad actual
      String currentUnit = unit;
      double currentMin = min;
      double currentMax = max;

      if (unit == 'cm') {
        currentUnit = controller.unidadMedida.value;
        if (currentUnit == 'in') {
          currentMin = min / 2.54;
          currentMax = max / 2.54;
        }
      } else if (unit == 'kg') {
        currentUnit = controller.unidadPeso.value;
        if (currentUnit == 'lb') {
          currentMin = min * 2.20462;
          currentMax = max * 2.20462;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                currentUnit == 'cm' || currentUnit == 'kg'
                    ? '${value.value.toInt()} $currentUnit'
                    : '${value.value.toStringAsFixed(1)} $currentUnit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CNSlider(
            value: value.value.clamp(currentMin, currentMax),
            min: currentMin,
            max: currentMax,
            onChanged: (newValue) => value.value = newValue,
          ),
        ],
      );
    });
  }

  Widget _buildMeasureInput(String label, RxDouble value) {
    final controller = Get.find<OnboardingStepperController>();

    return Obx(() {
      final unit = controller.unidadMedida.value;
      final displayValue = value.value > 0
          ? (unit == 'cm'
                ? value.value.toInt().toString()
                : value.value.toStringAsFixed(1))
          : '';

      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($unit)',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextFormField(
                key: ValueKey('${label}_$unit'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '0.0',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixText: unit,
                  suffixStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                initialValue: displayValue,
                onChanged: (text) {
                  if (text.isEmpty) {
                    value.value = 0;
                    return;
                  }
                  final number = double.tryParse(text);
                  if (number != null && number >= 0) {
                    value.value = number;
                  }
                },
              ),
            ],
          );
        },
      );
    });
  }
}
