import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/core/constants/onboarding_constants.dart';

/// Página de onboarding que muestra las características principales de Tribbe
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboarding(
      onPressedOnLastPage: () => _completeOnboarding(context),
      bottomButtonColor: Theme.of(context).colorScheme.primary,
      bottomButtonBorderRadius: BorderRadius.circular(30),
      pages: [
        _buildFeaturesPage(context),
        _buildMotivationPage(context),
        _buildCommunityPage(context),
      ],
    );
  }

  /// Página que muestra "¿Qué es Tribbe?"
  WhatsNewPage _buildFeaturesPage(BuildContext context) {
    return WhatsNewPage(
      title: const Text(
        OnboardingConstants.onboardingTitle,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      features: OnboardingConstants.features
          .map(
            (feature) => WhatsNewFeature(
              icon: Icon(
                feature.iconData as IconData,
                color: CupertinoColors.systemBlue,
                size: 32,
              ),
              title: Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              description: Text(
                feature.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Página sobre motivación y enfoque
  CupertinoOnboardingPage _buildMotivationPage(BuildContext context) {
    return CupertinoOnboardingPage(
      title: const Text(
        OnboardingConstants.progressPageTitle,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              OnboardingConstants.progressPageDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              OnboardingConstants.progressPageSubDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Página sobre comunidad y competencia
  CupertinoOnboardingPage _buildCommunityPage(BuildContext context) {
    return CupertinoOnboardingPage(
      title: const Text(
        OnboardingConstants.communityPageTitle,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.sportscourt,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              OnboardingConstants.communityPageDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              OnboardingConstants.communityPageSubDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding(BuildContext context) {
    // Navegar al login después de completar el onboarding
    Get.offAllNamed(RoutePaths.login);
  }
}
