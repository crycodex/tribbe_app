import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/training/controllers/training_exercise_editor_controller.dart';
import 'package:tribbe_app/features/training/views/widgets/set_item_widget.dart';

/// Panel de configuración de ejercicio inline
class ExerciseConfigPanelWidget extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ExerciseConfigPanelWidget({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingExerciseEditorController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)]
              : [CupertinoColors.white, const Color(0xFFF5F5F7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CupertinoColors.activeBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(controller, isDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInputFields(controller, isDark),
                const SizedBox(height: 12),
                Obx(
                  () => controller.isEditingSet
                      ? _buildEditingIndicator(controller)
                      : const SizedBox.shrink(),
                ),
                _buildAddSetButton(controller),
                Obx(
                  () => controller.hasSets
                      ? _buildSetsList(controller, isDark)
                      : const SizedBox.shrink(),
                ),
                Obx(
                  () => controller.hasSets
                      ? _buildSaveButton()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Obx(() {
      final isEditing = controller.isEditingExercise;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEditing
                ? (isDark
                      ? [
                          CupertinoColors.systemOrange.withValues(alpha: 0.3),
                          CupertinoColors.systemOrange.withValues(alpha: 0.15),
                        ]
                      : [
                          CupertinoColors.systemOrange.withValues(alpha: 0.15),
                          CupertinoColors.systemOrange.withValues(alpha: 0.05),
                        ])
                : (isDark
                      ? [
                          CupertinoColors.activeBlue.withValues(alpha: 0.3),
                          CupertinoColors.activeBlue.withValues(alpha: 0.15),
                        ]
                      : [
                          CupertinoColors.activeBlue.withValues(alpha: 0.15),
                          CupertinoColors.activeBlue.withValues(alpha: 0.05),
                        ]),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEditing
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isEditing
                    ? CupertinoIcons.pencil_circle_fill
                    : CupertinoIcons.sportscourt_fill,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isEditing)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EDITANDO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      if (isEditing) const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          controller.selectedExercise.value!.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.selectedExercise.value!.muscleGroup} • ${controller.selectedExercise.value!.equipment}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de información
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                final exerciseId = controller.selectedExercise.value!.id;
                Get.toNamed(
                  RoutePaths.exerciseDetail,
                  arguments: {'exerciseId': exerciseId},
                );
              },
              child: Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.activeBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 4),
            // Botón de cerrar
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onCancel,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
                size: 28,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInputFields(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Obx(() {
      // Campos según el tipo de ejercicio
      if (controller.isCardioExercise) {
        return _buildCardioFields(controller, isDark);
      } else if (controller.isTimeExercise) {
        return _buildTimeFields(controller, isDark);
      } else {
        return _buildStrengthFields(controller, isDark);
      }
    });
  }

  /// Campos para ejercicios de fuerza (peso + reps)
  Widget _buildStrengthFields(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peso (kg)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2,
                ),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: controller.weightController,
                placeholder: '0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? CupertinoColors.black : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2,
                ),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: controller.repsController,
                placeholder: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? CupertinoColors.black : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Campos para ejercicios de cardio (distancia + duración)
  Widget _buildCardioFields(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        // Distancia
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distancia (km)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: controller.distanceController,
              placeholder: '0.0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? CupertinoColors.black : CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Duración
        _buildDurationFields(controller, isDark),
      ],
    );
  }

  /// Campos para ejercicios de tiempo (solo duración)
  Widget _buildTimeFields(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return _buildDurationFields(controller, isDark);
  }

  /// Campos de duración (minutos + segundos)
  Widget _buildDurationFields(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minutos',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.systemGrey3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CupertinoTextField(
                    controller: controller.durationMinutesController,
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segundos',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.systemGrey3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CupertinoTextField(
                    controller: controller.durationSecondsController,
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditingIndicator(TrainingExerciseEditorController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CupertinoColors.systemOrange, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.pencil_circle_fill,
              color: CupertinoColors.systemOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Editando serie ${controller.editingSetIndex.value! + 1}',
                style: const TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.cancelSetEdit,
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSetButton(TrainingExerciseEditorController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: controller.isEditingSet
              ? CupertinoColors.systemOrange
              : CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(10),
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: () {
            controller.addOrUpdateSet();
            HapticFeedback.mediumImpact();
          },
          child: Text(
            controller.isEditingSet ? 'Actualizar Serie' : 'Agregar Serie',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Get.isDarkMode
                  ? CupertinoColors.black
                  : CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetsList(
    TrainingExerciseEditorController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Obx(
            () => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.currentSets.length,
              itemBuilder: (context, index) {
                final set = controller.currentSets[index];
                return Obx(
                  () => SetItemWidget(
                    set: set,
                    index: index,
                    isEditing: controller.editingSetIndex.value == index,
                    onEdit: () {
                      controller.editSet(index);
                      HapticFeedback.lightImpact();
                    },
                    onDelete: () {
                      controller.removeSet(index);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar_circle_fill,
                size: 16,
                color: CupertinoColors.activeGreen,
              ),
              const SizedBox(width: 6),
              Text(
                _getSummaryText(controller),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Obtener texto de resumen según tipo de ejercicio
  String _getSummaryText(TrainingExerciseEditorController controller) {
    if (controller.isCardioExercise) {
      // Para cardio: distancia total + duración total
      final totalDistance = controller.currentSets.fold<double>(
        0.0,
        (sum, set) => sum + (set.distance ?? 0),
      );
      final totalDuration = controller.currentSets.fold<int>(
        0,
        (sum, set) => sum + (set.duration ?? 0),
      );
      return 'Total: ${totalDistance.toStringAsFixed(2)} km • ${_formatDuration(totalDuration)}';
    } else if (controller.isTimeExercise) {
      // Para tiempo: duración total
      final totalDuration = controller.currentSets.fold<int>(
        0,
        (sum, set) => sum + (set.duration ?? 0),
      );
      return 'Tiempo total: ${_formatDuration(totalDuration)}';
    } else {
      // Para fuerza: volumen total
      return 'Volumen: ${controller.totalVolume.toStringAsFixed(0)} kg';
    }
  }

  /// Formatear duración
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: CupertinoColors.activeGreen,
            borderRadius: BorderRadius.circular(10),
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: () {
              onSave();
              HapticFeedback.mediumImpact();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.checkmark_circle, size: 20),
                SizedBox(width: 6),
                Text(
                  'Guardar Ejercicio',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
