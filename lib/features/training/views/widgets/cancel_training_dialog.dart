import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Diálogo para confirmar cancelación de entrenamiento
class CancelTrainingDialog {
  static void show(BuildContext context) {
    final controller = Get.find<TrainingController>();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cancelar Entrenamiento'),
        content: const Text(
          '¿Estás seguro? Se perderán todos los datos del entrenamiento.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              controller.cancelTraining();
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

