import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/shared/widgets/custom_button.dart';

/// Página principal de la aplicación (temporal)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tribbe - Home'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Text(
                'tribbe.',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),

              const SizedBox(height: 40),

              // Mensaje de bienvenida
              Obx(() {
                final profile = authController.userProfile.value;
                final displayName =
                    profile?.datosPersonales?.nombreUsuario ??
                    authController.firebaseUser.value?.email?.split('@')[0] ??
                    'Usuario';
                return Text(
                  '¡Bienvenido $displayName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                );
              }),

              const SizedBox(height: 20),

              Text(
                'Has iniciado sesión correctamente.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Información del usuario
              Obx(() {
                final user = authController.firebaseUser.value;
                final profile = authController.userProfile.value;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Email', user?.email ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow(context, 'UID', user?.uid ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Email Verificado',
                        user?.emailVerified == true ? 'Sí' : 'No',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Personalización',
                        profile?.hasCompletedPersonalization == true
                            ? 'Completada'
                            : 'Pendiente',
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),

              // Botón de cerrar sesión
              Obx(
                () => CustomButton(
                  text: 'Cerrar Sesión',
                  onPressed: authController.logout,
                  isLoading: authController.isLoading.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
