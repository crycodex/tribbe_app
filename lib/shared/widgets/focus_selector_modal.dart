import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tribbe_app/shared/utils/workout_utils.dart';

/// Modal para seleccionar el enfoque del entrenamiento
class FocusSelectorModal extends StatelessWidget {
  final String selectedFocus;
  final Function(String) onFocusSelected;

  const FocusSelectorModal({
    super.key,
    required this.selectedFocus,
    required this.onFocusSelected,
  });

  static Future<String?> show({
    required BuildContext context,
    String? currentFocus,
  }) async {
    return await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => FocusSelectorModal(
        selectedFocus: currentFocus ?? 'Fuerza',
        onFocusSelected: (focus) {
          Navigator.pop(context, focus);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  'Por Objetivo',
                  [
                    'Fuerza',
                    'Hipertrofia',
                    'Resistencia',
                    'Cardio',
                    'Funcional',
                    'CrossFit',
                    'Calistenia',
                  ],
                  isDark,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Por Grupo Muscular',
                  [
                    'Pecho',
                    'Espalda',
                    'Piernas',
                    'Hombros',
                    'Brazos',
                    'Abdomen',
                    'Full Body',
                  ],
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Seleccionar Enfoque',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              decoration: TextDecoration.none,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> focuses, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        ...focuses.map((focus) => _buildFocusOption(focus, isDark)),
      ],
    );
  }

  Widget _buildFocusOption(String focus, bool isDark) {
    final isSelected = selectedFocus == focus;
    final color = WorkoutUtils.getFocusColor(focus);
    final icon = WorkoutUtils.getFocusIcon(focus);

    return GestureDetector(
      onTap: () => onFocusSelected(focus),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: WorkoutUtils.getGradientColors(focus, isDark: isDark),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? CupertinoColors.darkBackgroundGray
                  : CupertinoColors.systemGrey6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? CupertinoColors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                focus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? CupertinoColors.white
                      : (isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

