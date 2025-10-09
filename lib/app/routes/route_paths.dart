/// Constantes de rutas de la aplicación
class RoutePaths {
  RoutePaths._();

  // Onboarding
  static const String welcome = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingStepper = '/onboarding-stepper';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/home';
  static const String splash = '/splash';

  // Workout
  static const String workoutList = '/workouts';
  static const String workoutDetail = '/workout/:id';
  static const String createWorkout = '/workout/create';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Social
  static const String feed = '/feed';
  static const String friends = '/friends';

  // Gym
  static const String gymList = '/gyms';
  static const String gymDetail = '/gym/:id';
}
