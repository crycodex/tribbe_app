import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart';
import 'package:tribbe_app/features/onboarding_stepper/views/steps/step_info.dart';
import 'package:tribbe_app/features/onboarding_stepper/views/steps/step_medidas.dart';
import 'package:tribbe_app/features/onboarding_stepper/views/steps/step_personaje.dart';
import 'package:tribbe_app/features/onboarding_stepper/views/steps/step_preferences.dart';

/// Página principal del stepper de personalización
class OnboardingStepperPage extends StatelessWidget {
  const OnboardingStepperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingStepperController());

    // Obtener userId del usuario autenticado
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      controller.userId.value = Get.arguments['userId'] as String;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu cuenta'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Indicador de pasos
          Obx(() => _buildStepIndicator(context, controller.currentStep.value)),

          // Contenido del paso actual
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.currentStep.value,
                children: const [
                  StepPreferences(),
                  StepInfo(),
                  StepPersonaje(),
                  StepMedidas(),
                ],
              ),
            ),
          ),

          // Botones de navegación
          Obx(() => _buildNavigationButtons(context, controller)),
        ],
      ),
    );
  }

  /// Construir indicador de pasos
  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepDot(context, 0, currentStep, 'Preferencias'),
          _buildStepLine(context, currentStep >= 1),
          _buildStepDot(context, 1, currentStep, 'Info'),
          _buildStepLine(context, currentStep >= 2),
          _buildStepDot(context, 2, currentStep, 'Personaliza'),
          _buildStepLine(context, currentStep >= 3),
          _buildStepDot(context, 3, currentStep, 'Medidas'),
        ],
      ),
    );
  }

  /// Construir punto de paso
  Widget _buildStepDot(
    BuildContext context,
    int step,
    int currentStep,
    String label,
  ) {
    final theme = Theme.of(context);
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? theme.colorScheme.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Construir línea entre pasos
  Widget _buildStepLine(BuildContext context, bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
    );
  }

  /// Construir botones de navegación
  Widget _buildNavigationButtons(
    BuildContext context,
    OnboardingStepperController controller,
  ) {
    final isLastStep = controller.currentStep.value == 3;
    final isFirstStep = controller.currentStep.value == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Botón atrás
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Atrás'),
              ),
            ),

          if (!isFirstStep) const SizedBox(width: 16),

          // Botón siguiente/completar
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (isLastStep) {
                        controller.completeOnboarding();
                      } else {
                        controller.nextStep();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(isLastStep ? 'Completar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }
}
