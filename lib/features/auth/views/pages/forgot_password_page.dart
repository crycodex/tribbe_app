import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/core/utils/validators.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/shared/widgets/custom_button.dart';
import 'package:tribbe_app/shared/widgets/custom_text_field.dart';

/// Página de recuperación de contraseña
class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
                // Botón de retroceso
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),

                const SizedBox(height: 100),

                // Título
                Text(
                  'No pasa nada!, restablece tu contraseña.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Descripción
                Text(
                  'Ingresa tu email y te enviaremos las instrucciones para restablecer tu contraseña.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Campo de Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Ingresa tu email',
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                  onChanged: (value) => controller.email.value = value,
                ),

                const SizedBox(height: 32),

                // Botón de validar email
                Obx(
                  () => CustomButton(
                    text: 'Validar email',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.sendPasswordResetEmail();
                      }
                    },
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 24),

                // Link para volver al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya tienes una cuenta? ',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Inicia Sesión',
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
