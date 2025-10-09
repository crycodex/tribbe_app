import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/utils/validators.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/shared/widgets/custom_button.dart';
import 'package:tribbe_app/shared/widgets/custom_text_field.dart';
import 'package:tribbe_app/shared/widgets/oauth_button.dart';

/// Página de inicio de sesión
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Text(
                    'tribbe.',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Título de bienvenida
                Text(
                  'Hey, bienvenido a la tribu!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Botones de OAuth
                OAuthButtonsRow(
                  onFacebookPressed: controller.loginWithFacebook,
                  onGooglePressed: controller.loginWithGoogle,
                  onApplePressed: controller.loginWithApple,
                  isLoading: controller.isLoading.value,
                ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: theme.dividerColor, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: theme.dividerColor, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Campo de Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Ingresa tu email',
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  onChanged: (value) => controller.email.value = value,
                ),

                const SizedBox(height: 16),

                // Campo de Contraseña
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Ingresa tu contraseña',
                  labelText: 'Contraseña',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onChanged: (value) => controller.password.value = value,
                ),

                const SizedBox(height: 12),

                // Link de olvidaste contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(RoutePaths.forgotPassword),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de iniciar sesión
                Obx(
                  () => CustomButton(
                    text: 'Iniciar Sesión',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.loginWithEmail();
                      }
                    },
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 24),

                // Link para registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No tienes una cuenta? ',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(RoutePaths.register),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
