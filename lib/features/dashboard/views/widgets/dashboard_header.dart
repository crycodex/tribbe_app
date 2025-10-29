import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';

/// Header del dashboard con logo y botones de acción
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo mejorado con animación
          _buildLogo(theme, isSmallScreen),

          // Botones de acción con diseño moderno
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.message_outlined,
                label: 'Mensajes',
                onPressed: () => Get.toNamed(RoutePaths.messages),
                theme: theme,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              _buildActionButton(
                icon: Icons.people_outline,
                label: 'Social',
                onPressed: () => Get.toNamed(RoutePaths.social),
                theme: theme,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Logo con diseño mejorado, animaciones y responsive
  Widget _buildLogo(ThemeData theme, bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.withValues(alpha: 0.1),
            Colors.blueAccent.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'tribbe',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de acción con diseño moderno, animaciones y responsive
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Animación de feedback táctil
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blueAccent.withValues(alpha: 0.1),
        highlightColor: Colors.blueAccent.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.grey[800]?.withValues(alpha: 0.3)
                : Colors.grey[100]?.withValues(alpha: 0.5),
            border: Border.all(
              color: isDark
                  ? Colors.grey[700]!.withValues(alpha: 0.3)
                  : Colors.grey[300]!.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
