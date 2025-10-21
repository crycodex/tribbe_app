import 'package:flutter/cupertino.dart';
import 'package:tribbe_app/features/training/models/workout_model.dart';

/// Widget para mostrar un item de serie en el panel de configuración
class SetItemWidget extends StatelessWidget {
  final SetModel set;
  final int index;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SetItemWidget({
    super.key,
    required this.set,
    required this.index,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('temp_set_$index'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: CupertinoColors.systemOrange,
        icon: CupertinoIcons.pencil_circle_fill,
        label: 'Editar',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: CupertinoColors.systemRed,
        icon: CupertinoIcons.delete_solid,
        label: 'Eliminar',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isEditing
              ? LinearGradient(
                  colors: [
                    CupertinoColors.systemOrange.withValues(alpha: 0.2),
                    CupertinoColors.systemOrange.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isEditing
              ? null
              : (isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEditing
                ? CupertinoColors.systemOrange
                : (isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey4),
            width: isEditing ? 2 : 1,
          ),
          boxShadow: isEditing
              ? [
                  BoxShadow(
                    color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            _buildIndexBadge(isEditing),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${set.weight} kg × ${set.reps} reps',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    'Vol: ${(set.weight * set.reps).toStringAsFixed(0)} kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: CupertinoColors.systemOrange.withOpacity(0.6),
                ),
                const SizedBox(width: 2),
                Icon(
                  CupertinoIcons.arrow_left,
                  size: 14,
                  color: CupertinoColors.systemRed.withOpacity(0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: alignment,
      padding: EdgeInsets.only(
        left: alignment == Alignment.centerLeft ? 20 : 0,
        right: alignment == Alignment.centerRight ? 20 : 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CupertinoColors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexBadge(bool isEditing) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEditing
              ? [
                  CupertinoColors.systemOrange,
                  CupertinoColors.systemOrange.withValues(alpha: 0.8),
                ]
              : [
                  CupertinoColors.activeBlue,
                  CupertinoColors.activeBlue.withValues(alpha: 0.8),
                ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isEditing
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.activeBlue)
                .withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

