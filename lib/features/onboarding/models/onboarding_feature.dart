/// Modelo que representa una característica del onboarding
class OnboardingFeature {
  const OnboardingFeature({
    required this.title,
    required this.description,
    required this.iconData,
  });

  final String title;
  final String description;
  final dynamic iconData;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingFeature &&
        other.title == title &&
        other.description == description &&
        other.iconData == iconData;
  }

  @override
  int get hashCode => Object.hash(title, description, iconData);
}
