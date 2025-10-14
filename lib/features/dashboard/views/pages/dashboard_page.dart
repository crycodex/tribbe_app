import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/controllers/dashboard_controller.dart';

/// Dashboard principal (Home Tab)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Header fijo con efecto sliver
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    expandedHeight: 100,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: _buildHeader(context),
                      titlePadding: const EdgeInsets.only(bottom: 16),
                    ),
                  ),

                  // Contenido principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Personaje del usuario
                          _buildCharacter(),

                          const SizedBox(height: 40),

                          // Sistema de rachas semanales
                          _buildWeeklyStreak(controller, context),

                          const SizedBox(height: 40),

                          // Botón temporal para registrar entrenamiento (debug)
                          if (!controller.hasTrainedToday)
                            ElevatedButton.icon(
                              onPressed: controller.registerWorkout,
                              icon: const Icon(Icons.fitness_center),
                              label: const Text(
                                'Registrar Entrenamiento (Debug)',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Header con logo de Tribbe
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'tribbe',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '.',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  /// Personaje del usuario
  Widget _buildCharacter() {
    return Image.asset(
      'assets/images/character/home/home.png',
      height: 300,
      fit: BoxFit.contain,
    );
  }

  /// Sistema de rachas semanales (7 días)
  Widget _buildWeeklyStreak(
    DashboardController controller,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calcular la fecha del lunes de esta semana
    final mondayOfWeek = now.subtract(Duration(days: currentDayIndex));

    return Column(
      children: [
        // Título con racha actual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 28,
            ),
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
          ],
        ),

        const SizedBox(height: 24),

        // Días de la semana con iconos de fuego
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayDate = mondayOfWeek.add(Duration(days: index));
              final isActive = controller.weeklyStreak[index];
              final isToday = index == currentDayIndex;

              return _buildDayStreak(
                date: dayDate,
                isActive: isActive,
                isToday: isToday,
                context: context,
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        // Récord personal
        Obx(
          () => Text(
            'Récord: ${controller.longestStreak} días',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
              ? Colors.orange.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: Colors.orange.withOpacity(isDark ? 0.4 : 0.3),
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
