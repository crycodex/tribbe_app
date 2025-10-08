# 📱 Tribbe App

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)

**Tribbe App** es una aplicación móvil social para atletas de gimnasio que permite registrar entrenamientos, competir con amigos y visualizar estadísticas en tiempo real. Diseñada para crear competencia sana y motivación entre usuarios del mismo gimnasio.

---

## 🎯 Características Principales

- 🏋️‍♂️ **Registro de Entrenamientos**: Seguimiento detallado de ejercicios y rutinas
- 📊 **Estadísticas en Tiempo Real**: Visualiza tu progreso y compara con amigos
- 🏆 **Rankings y Competencias**: Competencias por gimnasio y entre amigos
- 👥 **Red Social**: Comparte entrenamientos y motiva a otros
- 🏢 **Validación de Gimnasios**: Sistema de verificación mediante QR y geolocalización
- 🎖️ **Sistema de Logros**: Desbloquea badges y alcanza nuevos niveles
- 📱 **Multiplataforma**: Disponible para iOS y Android

---

## 🛠️ Stack Tecnológico

### Frontend
- **Framework**: Flutter 3.16+ (Dart 3.2+)
- **State Management**: Riverpod
- **Inyección de Dependencias**: GetIt
- **Routing**: AutoRoute
- **UI Components**: Material Design 3 + Custom Components
- **Animaciones**: Lottie + Custom Animations + RIVE
- **Networking**: Dio
- **Local Storage**: SharedPreferences
- **Freezed**: Para manejo de estados UI

### Backend & Cloud
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **Cloud Provider**: Google Cloud Platform
- **Monitoring**: Firebase Crashlytics
- **CI/CD**: GitHub Actions

---

## 📂 Arquitectura del Proyecto

El proyecto utiliza **Clean Architecture** con el patrón **MVC** adaptado para Flutter:

```
lib/
├── main.dart
├── app/                          # Configuración principal
│   ├── routes/                   # Gestión de rutas (AutoRoute)
│   └── theme/                    # Tema y estilos
│
├── core/                         # Funcionalidades core
│   ├── constants/                # Constantes y configuración
│   ├── errors/                   # Manejo de errores
│   ├── network/                  # Cliente HTTP y conectividad
│   ├── utils/                    # Validadores y helpers
│   └── extensions/               # Extensiones de Dart
│
├── features/                     # Módulos funcionales
│   ├── auth/                     # Autenticación
│   ├── workout/                  # Entrenamientos
│   ├── social/                   # Red social
│   ├── gym/                      # Gimnasios
│   └── profile/                  # Perfil de usuario
│   
│   └── [cada feature contiene]
│       ├── models/               # Modelos de datos
│       ├── controllers/          # Lógica de negocio (Riverpod)
│       └── views/                # UI (Pages y Widgets)
│
└── shared/                       # Componentes compartidos
    ├── widgets/                  # Widgets reutilizables
    ├── services/                 # Servicios globales
    └── utils/                    # Utilidades compartidas
```

### Principios de Arquitectura

- ✅ **Clean Architecture**: Separación clara de responsabilidades
- ✅ **Repository Pattern**: Para persistencia de datos
- ✅ **Controller Pattern**: Lógica de negocio con Riverpod
- ✅ **SOLID Principles**: Código mantenible y escalable
- ✅ **Composition over Inheritance**: Componentes reutilizables
- ✅ **Widgets Flat Structure**: Evitar anidación excesiva

---

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK 3.16 o superior
- Dart 3.2 o superior
- Android Studio / Xcode (según plataforma)
- Firebase CLI configurado

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/tribbe_app.git
cd tribbe_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

4. **Generar código necesario**
```bash
# Generar assets
flutter pub run build_runner build --delete-conflicting-outputs

# Generar localizaciones
flutter gen-l10n
```

5. **Ejecutar la aplicación**
```bash
# Para desarrollo
flutter run

# Para producción
flutter run --release
```

---

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests de integración
flutter test integration_test
```

---

## 📅 Roadmap de Desarrollo

### 🎯 Fase 1: MVP (Mes 1-2)
- [x] Setup del proyecto Flutter
- [ ] Autenticación básica (email/password)
- [ ] Perfil de usuario básico
- [ ] Catálogo de ejercicios (20 ejercicios principales)
- [ ] Registro de entrenamientos
- [ ] Historial básico
- [ ] UI/UX básica

### 🎯 Fase 2: Social (Mes 3-4)
- [ ] Sistema de amigos básico
- [ ] Feed de actividad
- [ ] Compartir entrenamientos
- [ ] Rankings básicos
- [ ] Notificaciones push

### 🎯 Fase 3: Competencias (Mes 5-6)
- [ ] Sistema de gimnasios con QR
- [ ] Rankings avanzados por gimnasio
- [ ] Competencias temporales
- [ ] Sistema de logros y badges
- [ ] Comparación de estadísticas entre amigos

### 🎯 Fase 4: Optimización (Mes 7-8)
- [ ] Modo offline
- [ ] Estadísticas avanzadas
- [ ] Integración con redes sociales
- [ ] Sistema de monetización (freemium)
- [ ] Analytics avanzados

---

## 🔑 Decisiones Técnicas

### Validación de Gimnasios
Combinación de **códigos QR únicos** + **geolocalización** para garantizar que los usuarios están realmente en el gimnasio.

### Prevención de Datos Falsos
- Sistema de reportes comunitario
- Validación automática basada en peso corporal
- Límites razonables por ejercicio
- Verificación manual por administradores

### Modelo de Monetización
- **Freemium**: Funciones básicas gratuitas
- **Premium ($4.99/mes)**: Amigos ilimitados, múltiples gimnasios, estadísticas avanzadas

---

## 🎨 Convenciones de Código

Este proyecto sigue estrictas convenciones de código Dart/Flutter:

- ✅ Nombres de clases en **PascalCase**
- ✅ Variables y funciones en **camelCase**
- ✅ Archivos y directorios en **snake_case**
- ✅ Tipado estricto (evitar `dynamic`)
- ✅ Funciones cortas (< 20 líneas)
- ✅ Clases pequeñas (< 200 líneas)
- ✅ Uso de `const` constructors cuando sea posible
- ✅ Widgets reutilizables y componibles

Para más detalles, consulta el archivo `analysis_options.yaml`.

---

## 📚 Documentación Adicional

- [📋 PRD (Product Requirements Document)](design/prd.md)
- [🏗️ Arquitectura Detallada](design/prd.md#-arquitectura-de-flutter)
- [🛠️ Stack Tecnológico Completo](design/prd.md#%EF%B8%8F-stack-tecnológico)

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, asegúrate de:

1. Seguir las convenciones de código del proyecto
2. Escribir tests para nuevas funcionalidades
3. Actualizar la documentación según sea necesario
4. Crear un Pull Request descriptivo

---

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

---

## 👨‍💻 Autor

Desarrollado por Cristhian Recalde con 💪 para la comunidad fitness.

---

## 📞 Contacto y Soporte

Para reportar bugs o solicitar nuevas funcionalidades, por favor abre un [issue](https://github.com/tu-usuario/tribbe_app/issues).

---

**¡Únete a la tribu y alcanza tus objetivos fitness! 🏋️‍♂️💪**