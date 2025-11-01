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

  // Training
  static const String muscleSelection = '/muscle-selection';
  static const String trainingMode = '/training-mode';
  static const String workoutHistory = '/workout-history';
  static const String workoutList = '/workouts';
  static const String workoutDetail = '/workout/:id';
  static const String createWorkout = '/workout/create';

  // Exercises
  static const String exercisesLibrary = '/exercises';
  static const String exerciseDetail = '/exercise/:id';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Social
  static const String feed = '/feed';
  static const String social = '/social';

  // Messages
  static const String messages = '/messages';
  static const String chat = '/chat';

  // Gym
  static const String gymList = '/gyms';
  static const String gymDetail = '/gym/:id';
}
