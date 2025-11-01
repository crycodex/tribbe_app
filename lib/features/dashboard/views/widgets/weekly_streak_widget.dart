import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/controllers/dashboard_controller.dart';

/// Widget del sistema de rachas semanales
class WeeklyStreakWidget extends StatelessWidget {
  const WeeklyStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;
    final theme = Theme.of(context);

    // Calcular la fecha del lunes de esta semana
    final mondayOfWeek = now.subtract(Duration(days: currentDayIndex));

    return Column(
      children: [
        // Título con racha actual
        _buildStreakTitle(controller, theme),

        const SizedBox(height: 8),

        // Estado de la racha
        _buildStreakStatus(controller, theme),

        const SizedBox(height: 4),

        // Récord personal
        _buildPersonalRecord(controller, theme),

        const SizedBox(height: 24),

        // Días de la semana con iconos de fuego
        _buildWeeklyDays(controller, mondayOfWeek, currentDayIndex, context),
      ],
    );
  }

  /// Título con racha actual
  Widget _buildStreakTitle(DashboardController controller, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
        const SizedBox(width: 8),
        Obx(
          () => Text(
            '${controller.currentStreak}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'días',
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Estado de la racha
  Widget _buildStreakStatus(DashboardController controller, ThemeData theme) {
    return Obx(
      () => Text(
        controller.streakStatusMessage,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: controller.isStreakInDanger
              ? Colors.orange[700]
              : controller.isStreakLost
              ? Colors.red[700]
              : controller.hasTrainedToday
              ? Colors.green[700]
              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Récord personal
  Widget _buildPersonalRecord(DashboardController controller, ThemeData theme) {
    return Obx(
      () => Text(
        'Récord: ${controller.longestStreak} días',
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Días de la semana con iconos de fuego
  Widget _buildWeeklyDays(
    DashboardController controller,
    DateTime mondayOfWeek,
    int currentDayIndex,
    BuildContext context,
  ) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final dayDate = mondayOfWeek.add(Duration(days: index));
          final isActive = controller.streak.value.hasTrainedOnDate(dayDate);
          final isToday = index == currentDayIndex;

          return _buildDayStreak(
            date: dayDate,
            isActive: isActive,
            isToday: isToday,
            context: context,
          );
        }),
      ),
    );
  }

  /// Widget individual para cada día de la semana
  Widget _buildDayStreak({
    required DateTime date,
    required bool isActive,
    required bool isToday,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Nombres de días en español
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayName = dayNames[date.weekday - 1];

    // Nombres de meses en español
    final monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final monthName = monthNames[date.month - 1];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isToday
              ? Colors.orange.withValues(alpha: isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: Colors.orange.withValues(alpha: isDark ? 0.4 : 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Día de la semana
            Text(
              dayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday
                    ? Colors.orange
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 4),

            // Ícono de fuego
            Icon(
              Icons.local_fire_department,
              size: 28,
              color: isActive
                  ? Colors.orange
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
            ),

            const SizedBox(height: 4),

            // Número del día
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: isToday
                    ? Colors.orange
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),

            // Mes
            Text(
              monthName,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
