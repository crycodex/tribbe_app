import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';

/// Drawer lateral derecho para configuraciones y preferencias
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Configuración',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Sección: Cuenta
                  _buildSectionTitle('Cuenta'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Información Personal',
                    onTap: () {
                      Get.back();
                      Get.toNamed(RoutePaths.editProfile);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sección: Apariencia
                  _buildSectionTitle('Apariencia'),
                  const SizedBox(height: 12),

                  Obx(
                    () => _buildSettingItem(
                      context: context,
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: 'Tema Oscuro',
                      trailing: CNSwitch(
                        value:
                            settingsController.themeMode.value ==
                            AppThemeMode.dark,
                        onChanged: (value) {
                          settingsController.setThemeMode(
                            value ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        },
                      ),
                      showArrow: false,
                    ),
                  ),

                  Obx(
                    () => _buildSettingItem(
                      context: context,
                      icon: Icons.language,
                      title: 'Idioma',
                      trailing: Text(
                        settingsController.language.value.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      onTap: () =>
                          _showLanguageSheet(context, settingsController),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sección: Fitness
                  _buildSectionTitle('Fitness'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.history,
                    title: 'Historial de Entrenamientos',
                    onTap: () {
                      Get.back();
                      Get.toNamed(RoutePaths.workoutHistory);
                    },
                  ),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.fitness_center,
                    title: 'Objetivos Fitness',
                    onTap: () {
                      Get.back();
                      Get.snackbar(
                        'Próximamente',
                        'Esta función estará disponible pronto',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sección: Privacidad
                  _buildSectionTitle('Privacidad y Seguridad'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Privacidad',
                    onTap: () {
                      // TODO: Implementar página de privacidad
                      Get.snackbar(
                        'Próximamente',
                        'Esta función estará disponible pronto',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: 'Seguridad',
                    onTap: () {
                      // TODO: Implementar página de seguridad
                      Get.snackbar(
                        'Próximamente',
                        'Esta función estará disponible pronto',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sección: Soporte
                  _buildSectionTitle('Soporte'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    onTap: () {
                      // TODO: Implementar página de ayuda
                      Get.snackbar(
                        'Próximamente',
                        'Esta función estará disponible pronto',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  _buildSettingItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    onTap: () {
                      // TODO: Implementar página "Acerca de"
                      Get.snackbar(
                        'Tribbe App',
                        'Versión 1.0.0',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sección: Zona de Peligro
                  _buildSectionTitle('Sesión'),
                  const SizedBox(height: 12),

                  //cerrar sesión
                  _buildSettingItem(
                    context: context,
                    icon: Icons.logout,
                    showArrow: false,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    title: 'Cerrar Sesión',
                    onTap: () => _showLogoutDialog(context, authController),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = true,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? (isDark ? Colors.grey.shade900 : Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          textColor ?? (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                if (showArrow && trailing == null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsController controller) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecciona tu idioma',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              controller.setLanguage(AppLanguage.spanish);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  'Español',
                  style: TextStyle(
                    fontSize: 17,
                    color: controller.language.value == AppLanguage.spanish
                        ? CupertinoColors.activeBlue
                        : null,
                    fontWeight: controller.language.value == AppLanguage.spanish
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (controller.language.value == AppLanguage.spanish) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Get.back(); // Cerrar drawer
              controller.logout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Eliminar Cuenta'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Text(
              '¿Estás seguro que deseas eliminar tu cuenta?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'Esta acción eliminará permanentemente:\n\n'
              '• Tu información personal\n'
              '• Fotos y archivos\n'
              '• Entrenamientos y estadísticas\n'
              '• Tu cuenta de autenticación\n\n'
              'No podrás recuperar esta información.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              profileController.deleteUserAccount();
            },
            child: const Text('Eliminar Cuenta'),
          ),
        ],
      ),
    );
  }
}
