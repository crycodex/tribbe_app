import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';

/// Página de Perfil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header con título y settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perfil',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      // TODO: Navegar a configuración
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Avatar con foto de perfil
              Obx(() {
                final profile = authController.userProfile.value;
                final photoUrl = profile?.personaje?.avatarUrl;

                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    image: photoUrl != null && photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        )
                      : null,
                );
              }),
              const SizedBox(height: 16),

              // Nombre del usuario
              Obx(() {
                final profile = authController.userProfile.value;
                final displayName =
                    profile?.datosPersonales?.nombreCompleto ??
                    profile?.datosPersonales?.nombreUsuario ??
                    authController.firebaseUser.value?.email?.split('@')[0] ??
                    'Usuario';
                return Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Botón Editar Perfil
              TextButton.icon(
                onPressed: () {
                  Get.toNamed(RoutePaths.editProfile);
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  'Editar perfil',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Card de estadísticas (placeholder)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1a237e), const Color(0xFF0d47a1)]
                        : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.fitness_center,
                      label: 'Entrenamientos',
                      value: '25',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      icon: Icons.emoji_events,
                      label: 'Ranking',
                      value: 'Top 40',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sección Preferencias
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preferencias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información Personal
              _buildPreferenceItem(
                context,
                icon: Icons.person_outline,
                title: 'Información Personal',
                onTap: () {
                  // TODO: Navegar a información personal
                },
              ),

              // Idioma
              Obx(
                () => _buildPreferenceItem(
                  context,
                  icon: Icons.language,
                  title: 'Idioma',
                  trailing: Text(
                    settingsController.language.value == AppLanguage.spanish
                        ? 'Español'
                        : 'English',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  onTap: () => _showLanguageSheet(context, settingsController),
                ),
              ),

              // Tema oscuro
              Obx(
                () => _buildPreferenceItem(
                  context,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: 'Tema oscuro',
                  trailing: CNSwitch(
                    value:
                        settingsController.themeMode.value == AppThemeMode.dark,
                    onChanged: (value) {
                      settingsController.setThemeMode(
                        value ? AppThemeMode.dark : AppThemeMode.light,
                      );
                    },
                  ),
                  showArrow: false,
                ),
              ),

              const SizedBox(height: 32),

              // Botón Cerrar Sesión
              Obx(
                () => Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: authController.isLoading.value
                          ? null
                          : () => _showLogoutDialog(context, authController),
                      child: Center(
                        child: authController.isLoading.value
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Cerrar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                if (showArrow && trailing == null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
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
              controller.logout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
