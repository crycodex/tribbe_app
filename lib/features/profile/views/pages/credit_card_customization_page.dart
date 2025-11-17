import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/features/profile/controllers/credit_card_customization_controller.dart';
import 'package:tribbe_app/shared/widgets/credit_card_widget.dart';

/// Página para personalizar la tarjeta de crédito
class CreditCardCustomizationPage extends StatelessWidget {
  final UserModel user;
  final int followersCount;
  final int followingCount;

  const CreditCardCustomizationPage({
    super.key,
    required this.user,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.put(
      CreditCardCustomizationController(),
      tag: 'credit_card_customization',
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Personalizar Tarjeta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                controller.savePreferences();
                Get.back();
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.cardPreferences.value.cardStyle == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa de la tarjeta
              _buildCardPreview(context, controller, isDark),

              const SizedBox(height: 32),

              // Estilos predefinidos
              _buildStyleSection(context, controller, isDark),

              const SizedBox(height: 24),

              // Colores personalizados
              _buildColorSection(context, controller, isDark),

              const SizedBox(height: 24),

              // Opciones de patrón
              _buildPatternSection(context, controller, isDark),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCardPreview(
    BuildContext context,
    CreditCardCustomizationController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista previa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final colors = controller.getCurrentColors();
            return CreditCardWidget(
              user: user,
              followersCount: followersCount,
              followingCount: followingCount,
              showShareButton: false,
              customGradientColors: colors,
              customCardStyle: controller.selectedStyle.value,
              showPattern: controller.showPattern.value,
              patternOpacity: controller.patternOpacity.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStyleSection(
    BuildContext context,
    CreditCardCustomizationController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estilos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.cardStyles.length,
            itemBuilder: (context, index) {
              final style = controller.cardStyles[index];
              final isSelected = controller.selectedStyle.value == style['name'];
              final colors = style['colors'] as List<Color>;

              return GestureDetector(
                onTap: () => controller.changeStyle(style['name'] as String),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        style['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    CreditCardCustomizationController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colores personalizados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColorPicker(
              context,
              controller,
              0,
              'Color 1',
              controller.color1.value,
              isDark,
            ),
            _buildColorPicker(
              context,
              controller,
              1,
              'Color 2',
              controller.color2.value,
              isDark,
            ),
            _buildColorPicker(
              context,
              controller,
              2,
              'Color 3',
              controller.color3.value,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    CreditCardCustomizationController controller,
    int index,
    String label,
    Color color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        final newColor = await showDialog<Color>(
          context: context,
          builder: (context) => _ColorPickerDialog(initialColor: color),
        );
        if (newColor != null) {
          controller.changeColor(index, newColor);
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSection(
    BuildContext context,
    CreditCardCustomizationController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patrón de fondo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: Text(
                  'Mostrar patrón',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                value: controller.showPattern.value,
                onChanged: (_) => controller.togglePattern(),
              ),
            ),
          ],
        ),
        if (controller.showPattern.value) ...[
          const SizedBox(height: 8),
          Text(
            'Opacidad: ${(controller.patternOpacity.value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Slider(
            value: controller.patternOpacity.value,
            min: 0.0,
            max: 0.1,
            divisions: 10,
            onChanged: (value) => controller.changePatternOpacity(value),
          ),
        ],
      ],
    );
  }
}

/// Diálogo para seleccionar color
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color selectedColor;

  final List<Color> presetColors = [
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    const Color(0xFF1A1A1A),
    const Color(0xFF2D2D2D),
    const Color(0xFF667EEA),
    const Color(0xFF764BA2),
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presetColors.map((color) {
                final isSelected = selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedColor),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

