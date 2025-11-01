import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/training_controller.dart';

/// Widget de estadísticas del entrenamiento
class TrainingStatsRowWidget extends StatelessWidget {
  const TrainingStatsRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _StatItem(
                icon: CupertinoIcons.sportscourt,
                label: 'Ejercicios',
                value: controller.exercises.length.toString(),
                isDark: isDark,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
          Expanded(
            child: Obx(
              () => _StatItem(
                icon: CupertinoIcons.repeat,
                label: 'Series',
                value: controller.totalSets.toString(),
                isDark: isDark,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
          Expanded(
            child: Obx(
              () => _StatItem(
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Volumen',
                value: '${controller.totalVolume.toStringAsFixed(0)}kg',
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
          ),
        ),
      ],
    );
  }
}
