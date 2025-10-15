import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/constants/onboarding_constants.dart';
import 'package:tribbe_app/core/enums/app_enums.dart';
import 'package:tribbe_app/shared/controllers/settings_controller.dart';

/// Página de bienvenida que se muestra al iniciar la app por primera vez
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            children: [
              _buildHeader(context, settingsController),
              _buildTitle(textTheme),
              _buildIllustration(context),
              const Spacer(),
              _buildContinueButton(context, colorScheme, textTheme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => CNPopupMenuButton.icon(
          buttonIcon: CNSymbol('gearshape.fill', size: 18, color: Colors.white),
          tint: Colors.white,
          items: [
            // Tema
            CNPopupMenuItem(
              label: 'Tema: ${settingsController.themeMode.value.label}',
              icon: CNSymbol(
                settingsController.isDarkMode ? 'moon.fill' : 'sun.max.fill',
                size: 18,
                color: CupertinoColors.systemYellow,
              ),
            ),
            const CNPopupMenuDivider(),
            // Idioma
            CNPopupMenuItem(
              label:
                  'Idioma: ${settingsController.language.value.flag} ${settingsController.language.value.label}',
              icon: const CNSymbol('globe', size: 18),
            ),
            const CNPopupMenuDivider(),
            // Género
            CNPopupMenuItem(
              label: settingsController.gender.value != null
                  ? 'Género: ${settingsController.gender.value!.label}'
                  : 'Seleccionar género',
              icon: CNSymbol(
                settingsController.gender.value == UserGender.male
                    ? 'person.fill'
                    : settingsController.gender.value == UserGender.female
                    ? 'person.fill'
                    : 'person',
                size: 18,
                color: settingsController.gender.value == UserGender.male
                    ? CupertinoColors.systemBlue
                    : settingsController.gender.value == UserGender.female
                    ? CupertinoColors.systemPink
                    : CupertinoColors.systemGrey,
              ),
            ),
          ],
          onSelected: (index) =>
              _handleSettingsSelection(index, context, settingsController),
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Image.asset(
        OnboardingConstants.welcomeIllustrationPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder si no existe la imagen
          return Container(
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.fitness_center, size: 120, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return Text(
      OnboardingConstants.welcomeTitle,
      textAlign: TextAlign.center,
      style: textTheme.displayMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        height: 1.2,
        fontSize: 65,
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToOnboarding(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBBF24),
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              OnboardingConstants.welcomeButtonText,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Get.offNamed(RoutePaths.onboarding);
  }

  void _handleSettingsSelection(
    int index,
    BuildContext context,
    SettingsController settingsController,
  ) {
    // index 0: Tema, 1: Divider, 2: Idioma, 3: Divider, 4: Género
    if (index == 0) {
      // Cambiar tema
      _showThemeDialog(context, settingsController);
    } else if (index == 2) {
      // Idioma (actualmente solo español)
      Get.snackbar(
        'Idioma',
        'Actualmente solo está disponible Español',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        duration: const Duration(seconds: 2),
      );
    } else if (index == 4) {
      // Cambiar género
      _showGenderDialog(context, settingsController);
    }
  }

  void _showThemeDialog(
    BuildContext context,
    SettingsController settingsController,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Seleccionar Tema',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        message: const Text('Elige cómo quieres ver la aplicación'),
        actions: AppThemeMode.values.map((mode) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settingsController.setThemeMode(mode);
              Get.back();
            },
            isDefaultAction: settingsController.themeMode.value == mode,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mode == AppThemeMode.light
                      ? CupertinoIcons.sun_max_fill
                      : mode == AppThemeMode.dark
                      ? CupertinoIcons.moon_fill
                      : CupertinoIcons.device_phone_portrait,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(mode.label),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showGenderDialog(
    BuildContext context,
    SettingsController settingsController,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Seleccionar Género',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        message: const Text(
          'Esta información nos ayuda a personalizar tu experiencia',
        ),
        actions: UserGender.values.map((gender) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settingsController.setGender(gender);
              Get.back();
            },
            isDefaultAction: settingsController.gender.value == gender,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  gender == UserGender.male
                      ? CupertinoIcons.person_fill
                      : CupertinoIcons.person_fill,
                  size: 20,
                  color: gender == UserGender.male
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemPink,
                ),
                const SizedBox(width: 8),
                Text(gender.label),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
