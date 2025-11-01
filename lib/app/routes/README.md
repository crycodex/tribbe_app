# 🧭 Sistema de Rutas con GetX

Este módulo contiene la configuración de rutas de la aplicación usando GetX para navegación y gestión de estado.

## 📂 Estructura

```
routes/
├── route_paths.dart    # Constantes de rutas
├── app_router.dart     # Configuración de rutas y bindings
└── README.md
```

## 🎯 Componentes Principales

### RoutePaths

Clase que contiene todas las constantes de rutas de la aplicación organizadas por módulo:

```dart
class RoutePaths {
  // Onboarding
  static const String welcome = '/';
  static const String onboarding = '/onboarding';
  
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  
  // Main
  static const String home = '/home';
  
  // ... más rutas
}
```

**Convenciones:**
- ✅ Usar `snake_case` para nombres de rutas
- ✅ Agrupar por módulo funcional
- ✅ Rutas con parámetros: `/workout/:id`
- ✅ Constructor privado para clase de constantes

### AppRouter

Clase que configura las rutas usando GetX Pages:

```dart
class AppRouter {
  static final List<GetPage<dynamic>> routes = [
    GetPage<dynamic>(
      name: RoutePaths.welcome,
      page: () => const WelcomePage(),
      transition: Transition.fade,
      binding: WelcomeBinding(), // Opcional
    ),
    // ... más rutas
  ];
  
  static void initDependencies() {
    // Inicializar servicios globales
  }
}
```

## 🚀 Uso del Sistema de Rutas

### Configuración en Main

```dart
void main() {
  // Inicializar dependencias globales
  AppRouter.initDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: RoutePaths.welcome,
      getPages: AppRouter.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
```

### Navegación Básica

```dart
// Push - Agregar nueva página al stack
Get.toNamed(RoutePaths.home);

// Replace - Reemplazar la página actual
Get.offNamed(RoutePaths.login);

// Clear stack - Limpiar todo el stack y navegar
Get.offAllNamed(RoutePaths.home);

// Pop - Volver atrás
Get.back();

// Pop con resultado
Get.back(result: {'success': true});
```

### Navegación con Parámetros

#### Opción 1: Arguments (Recomendado para datos complejos)

```dart
// Enviar
Get.toNamed(
  RoutePaths.workoutDetail,
  arguments: {
    'workoutId': '123',
    'fromFeed': true,
  },
);

// Recibir
final args = Get.arguments as Map<String, dynamic>;
final workoutId = args['workoutId'] as String;
final fromFeed = args['fromFeed'] as bool;
```

#### Opción 2: Parameters (Para IDs simples en la URL)

```dart
// Definir ruta
static const String workoutDetail = '/workout/:id';

// Enviar
Get.toNamed('/workout/123');

// Recibir
final workoutId = Get.parameters['id'];
```

#### Opción 3: Query Parameters

```dart
// Enviar
Get.toNamed(
  RoutePaths.workoutList,
  parameters: {'filter': 'recent', 'limit': '10'},
);

// Recibir
final filter = Get.parameters['filter'];
final limit = Get.parameters['limit'];
```

### Transiciones

GetX ofrece múltiples tipos de transiciones:

```dart
GetPage<dynamic>(
  name: RoutePaths.profile,
  page: () => const ProfilePage(),
  transition: Transition.cupertino,      // iOS style
  // transition: Transition.fade,        // Fade in/out
  // transition: Transition.rightToLeft, // Android style
  // transition: Transition.zoom,        // Zoom effect
  // transition: Transition.fadeIn,      // Solo fade in
  transitionDuration: const Duration(milliseconds: 300),
);
```

### Bindings (Inyección de Dependencias)

Los Bindings permiten inicializar controllers y servicios cuando se navega a una página:

```dart
// 1. Crear el Binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutController>(() => WorkoutController());
    Get.lazyPut<SocialController>(() => SocialController());
  }
}

// 2. Asociar el Binding a la ruta
GetPage<dynamic>(
  name: RoutePaths.home,
  page: () => const HomePage(),
  binding: HomeBinding(),
),

// 3. Usar el controller en la página
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutController = Get.find<WorkoutController>();
    return Scaffold(...);
  }
}
```

### Middlewares (Guards)

Para proteger rutas o ejecutar lógica antes de navegar:

```dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Verificar si el usuario está autenticado
    final authService = Get.find<AuthService>();
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: RoutePaths.login);
    }
    return null;
  }
}

// Aplicar a una ruta
GetPage<dynamic>(
  name: RoutePaths.home,
  page: () => const HomePage(),
  middlewares: [AuthMiddleware()],
),
```

## 📋 Convenciones y Best Practices

### Nomenclatura

```dart
// ✅ CORRECTO
static const String welcome = '/';
static const String workoutList = '/workouts';
static const String workoutDetail = '/workout/:id';

// ❌ INCORRECTO
static const String Welcome = '/welcome';
static const String workout_list = '/workouts';
static const String workoutDetailPage = '/workout/:id';
```

### Organización de Rutas

1. **Por Módulo**: Agrupar rutas relacionadas
2. **Orden Lógico**: Onboarding → Auth → Main → Features
3. **Comentarios**: Documentar secciones claramente

### Dependency Injection

```dart
// ✅ CORRECTO: Servicios globales en initDependencies
static void initDependencies() {
  Get.lazyPut<StorageService>(() => StorageService());
  Get.lazyPut<AuthService>(() => AuthService());
}

// ✅ CORRECTO: Controllers específicos en Bindings
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutController>(() => WorkoutController());
  }
}

// ❌ INCORRECTO: Controllers en initDependencies
static void initDependencies() {
  Get.put(WorkoutController()); // Se crea siempre, no lazy
}
```

### Lazy Loading

```dart
// ✅ CORRECTO: Lazy loading para mejor performance
Get.lazyPut(() => WorkoutController());

// ⚠️ USAR CON CUIDADO: Crea la instancia inmediatamente
Get.put(WorkoutController());

// ✅ CORRECTO: Para servicios que se usan siempre
Get.put<StorageService>(StorageService(), permanent: true);
```

## 🔍 Debugging

### Ver ruta actual

```dart
print('Current route: ${Get.currentRoute}');
```

### Ver si una ruta está activa

```dart
if (Get.currentRoute == RoutePaths.home) {
  // Estamos en home
}
```

### Ver historial de rutas

```dart
print('Routing history: ${Get.routing.history}');
```

## 🎯 Estructura Recomendada para Nuevas Features

Al agregar un nuevo módulo (ej: "statistics"):

1. **Agregar rutas en `route_paths.dart`:**
```dart
// Statistics
static const String statisticsOverview = '/statistics';
static const String statisticsDetail = '/statistics/:id';
```

2. **Crear el binding:**
```dart
// lib/features/statistics/controllers/statistics_binding.dart
class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StatisticsController());
  }
}
```

3. **Registrar en `app_router.dart`:**
```dart
GetPage<dynamic>(
  name: RoutePaths.statisticsOverview,
  page: () => const StatisticsPage(),
  binding: StatisticsBinding(),
  transition: Transition.cupertino,
),
```

## 📚 Recursos

- [GetX Documentation](https://pub.dev/packages/get)
- [GetX Route Management](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/route_management.md)
- [GetX Dependency Injection](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/dependency_management.md)

## ⚠️ Notas Importantes

1. **No usar Navigator tradicional**: Siempre usar métodos de GetX
2. **Lazy loading por defecto**: Usar `Get.lazyPut()` para controllers
3. **Bindings para features**: Crear un Binding por feature/módulo
4. **Services globales**: Solo los servicios compartidos en `initDependencies`
5. **Type safety**: Siempre especificar tipos en `GetPage<dynamic>`
