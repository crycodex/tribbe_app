import 'package:flutter/cupertino.dart';
import 'package:tribbe_app/features/onboarding/models/onboarding_feature.dart';

/// Constantes relacionadas con el onboarding de la aplicación
class OnboardingConstants {
  OnboardingConstants._();

  // Textos de la página de bienvenida
  static const String welcomeHeader = 'welcome';
  static const String welcomeTitle = 'Encuentra\ntu rutina';
  static const String welcomeButtonText = 'Enfócate en ti mismo';

  // Textos del onboarding principal
  static const String onboardingTitle = '¿Qué es Tribbe?';

  // Características principales de Tribbe
  static const List<OnboardingFeature> features = [
    OnboardingFeature(
      title: 'Crea tu perfil',
      description:
          'Define tus características de tus entrenamientos y tus objetivos.',
      iconData: CupertinoIcons.person_circle,
    ),
    OnboardingFeature(
      title: 'Gimnasio',
      description:
          'Vincúlate a tu gimnasio, valida una reputación, entrena/abona, rutinas y más.',
      iconData: CupertinoIcons.building_2_fill,
    ),
    OnboardingFeature(
      title: 'Insignias',
      description: 'Gana una racha y comparte tus logros.',
      iconData: CupertinoIcons.rosette,
    ),
    OnboardingFeature(
      title: 'Tiendas',
      description:
          'Accede a tiendas de suplementos y ropa deportiva con exclusivas ofertas.',
      iconData: CupertinoIcons.bag,
    ),
    OnboardingFeature(
      title: 'Social',
      description: 'Haz amigos, incluso compite y mira quien es el mas fuerte.',
      iconData: CupertinoIcons.person_2,
    ),
  ];

  // Textos de páginas adicionales del onboarding
  static const String progressPageTitle = 'Tu progreso, tu forma';
  static const String progressPageDescription =
      'Registra tus entrenamientos y observa tu evolución en tiempo real.';
  static const String progressPageSubDescription =
      'Establece metas y alcánzalas con dedicación.';

  static const String communityPageTitle = 'Compite y motívate';
  static const String communityPageDescription =
      'Únete a tu gimnasio y compite con otros atletas.';
  static const String communityPageSubDescription =
      'Comparte logros, gana insignias y forma parte de la tribu.';

  // Rutas de assets
  static const String welcomeIllustrationPath = 'assets/images/welcome.png';
}
