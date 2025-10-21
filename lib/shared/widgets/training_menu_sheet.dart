import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/shared/widgets/focus_selector_modal.dart';

/// Bottom sheet con opciones de entrenamiento
class TrainingMenuSheet extends StatelessWidget {
  const TrainingMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opciones de Entrenamiento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid de opciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.fitness_center,
                    label: 'Gym',
                    color: Colors.orange,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.people,
                    label: 'Social',
                    color: Colors.blue,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.psychology,
                    label: 'AI',
                    color: Colors.purple,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.wifi_tethering,
                    label: 'Remoto',
                    color: Colors.cyan,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.bolt,
                    label: 'Entrenar',
                    color: Colors.green,
                    isMain: true,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Estadísticas',
                    color: Colors.teal,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.list_alt,
                    label: 'Rutinas',
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool isMain = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        if (label == 'Entrenar') {
          // Para la opción principal, primero mostrar selector de enfoque
          final focus = await FocusSelectorModal.show(context: context);
          if (focus != null) {
            Navigator.pop(context);
            // Navegar a selección de músculos/entrenamiento con el enfoque seleccionado
            Get.toNamed(
              RoutePaths.muscleSelection,
              arguments: {'selectedFocus': focus},
            );
          }
        } else {
          Navigator.pop(context);
          // TODO: Navegar a otras opciones
          debugPrint('Opción seleccionada: $label');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isMain
              ? color.withValues(alpha: 0.2)
              : (isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.5)
                    : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMain
                ? color
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isMain ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
