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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Obx(
              () => Text(
                '${value.value.toInt()} $unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Obx(
          () => Slider(
            value: value.value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: (newValue) => value.value = newValue,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureInput(String label, RxDouble value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Obx(
          () => TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Number',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            controller: TextEditingController(
              text: value.value > 0 ? value.value.toInt().toString() : '',
            ),
            onChanged: (text) {
              final number = double.tryParse(text);
              if (number != null && number >= 0) {
                value.value = number;
              }
            },
          ),
        ),
      ],
    );
  }
}
