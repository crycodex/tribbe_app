import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Modal minimalista para finalizar entrenamiento
class FinishTrainingModal extends StatefulWidget {
  const FinishTrainingModal({super.key});

  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const FinishTrainingModal(),
    );
  }

  @override
  State<FinishTrainingModal> createState() => _FinishTrainingModalState();
}

class _FinishTrainingModalState extends State<FinishTrainingModal> {
  final captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark, controller),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildIcon(isDark),
                  const SizedBox(height: 24),
                  _buildTitle(isDark),
                  const SizedBox(height: 12),
                  _buildStats(controller, isDark),
                  const SizedBox(height: 48),
                  _buildCaptionField(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    TrainingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
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
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
              controller.finishTraining(caption: captionController.text);
            },
            child: const Text(
              'Finalizar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    return Icon(
      CupertinoIcons.checkmark_circle,
      size: 60,
      color: isDark
          ? CupertinoColors.systemGreen
          : CupertinoColors.systemGreen,
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      'Entrenamiento Completado',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
        decoration: TextDecoration.none,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStats(TrainingController controller, bool isDark) {
    return Obx(
      () => Text(
        '${controller.exercises.length} ejercicios • ${controller.totalSets} series • ${controller.formattedTime}',
        style: TextStyle(
          fontSize: 15,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
          decoration: TextDecoration.none,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCaptionField(bool isDark) {
    return CupertinoTextField(
      controller: captionController,
      placeholder: 'Agregar comentario...',
      maxLines: 4,
      minLines: 4,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? CupertinoColors.systemGrey5
              : CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
    );
  }
}

