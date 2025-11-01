# 📱 Tribbe App

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)
![GetX](https://img.shields.io/badge/GetX-State%20Management-9B59B6)

**Tribbe App** es una aplicación móvil social de fitness que combina lo mejor de Instagram con el mundo del gimnasio. Registra tus entrenamientos con fotos, compite con amigos, mantén rachas semanales y visualiza tu progreso en tiempo real.

---

## ✨ Características Principales

### 🏋️‍♂️ **Entrenamientos Inteligentes**
- ✅ Registro detallado de ejercicios, series, peso y repeticiones
- ✅ Timer integrado con pausa/reanudar
- ✅ Selector de enfoque (Fuerza, Hipertrofia, Cardio, etc.)
- ✅ Biblioteca de ejercicios filtrados por grupo muscular
- ✅ **Fotos de entrenamientos** estilo Instagram
- ✅ Caption opcional para cada sesión

### 📸 **Feed Social - Estilo Instagram**
- ✅ Posts de entrenamientos con fotos en ratio 4:5
- ✅ Ejercicios mostrados sobre la foto con overlay
- ✅ Likes y comentarios en tiempo real
- ✅ Sistema de seguidores/siguiendo
- ✅ Menú contextual (ver perfil, dejar de seguir, ocultar, reportar)
- ✅ Navegación fluida al detalle del entrenamiento

### 🔥 **Sistema de Rachas Semanales**
- ✅ Seguimiento de días entrenados por semana
- ✅ Visualización de racha actual (lunes a domingo)
- ✅ Animaciones y celebraciones al completar días
- ✅ Personaje dinámico que evoluciona con tu racha
- ✅ Compartir racha en redes sociales

### 💬 **Mensajería Temporal**
- ✅ Chats privados 1-a-1 con **Realtime Database**
- ✅ Mensajes que expiran en 7 días (auto-limpieza)
- ✅ Reacciones con emojis a mensajes
- ✅ Editar y eliminar mensajes propios
- ✅ Bloquear conversaciones
- ✅ Indicadores de lectura y envío

### 👥 **Red Social**
- ✅ Sistema de seguidores/siguiendo
- ✅ Contadores en tiempo real (Firestore)
- ✅ Búsqueda de usuarios
- ✅ Perfiles públicos con grid de entrenamientos
- ✅ Tarjeta de perfil compartible (Credit Card style)

### 📊 **Estadísticas y Progreso**
- ✅ Volumen total levantado
- ✅ Total de series y repeticiones
- ✅ Tiempo total de entrenamiento
- ✅ Historial completo de workouts
- ✅ Gráficos de progreso por tipo de entrenamiento

### 📱 **Experiencia de Usuario**
- ✅ Material Design 3 con modo oscuro/claro
- ✅ Animaciones fluidas (Lottie + Rive)
- ✅ Diseño responsivo (móvil y tablet)
- ✅ Navegación intuitiva con tabs
- ✅ Onboarding interactivo con stepper

---

## 🛠️ Stack Tecnológico

### Frontend
- **Framework**: Flutter 3.16+ (Dart 3.2+)
- **State Management**: GetX (Reactive Programming)
- **Routing**: GetX Navigation
- **UI Components**: Material Design 3 + Cupertino + Custom Widgets
- **Animaciones**: Lottie + Rive + Flutter Animations
- **Local Storage**: SharedPreferences
- **Fonts**: Google Fonts
- **Imágenes**: image_picker (cámara/galería)

### Backend & Cloud
- **Backend**: Firebase (Authentication, Firestore, Realtime Database, Storage)
- **Auth Providers**: Email/Password + Google Sign-In v7.2.0
- **Database**: 
  - Firestore (perfiles, entrenamientos, posts, seguidores)
  - Realtime Database (mensajería temporal)
- **Storage**: Firebase Storage (fotos de entrenamientos y perfiles)
- **Cloud Functions**: Node.js (limpieza de mensajes, triggers)
- **Monitoring**: Firebase Crashlytics
- **CI/CD**: GitHub Actions

---

## 📂 Arquitectura del Proyecto

El proyecto utiliza **Clean Architecture** con el patrón **MVC** adaptado para Flutter:

```
lib/
├── main.dart
├── app/                          # Configuración principal
│   ├── routes/                   # Gestión de rutas (GetX Navigation)
│   │   ├── app_router.dart      # Definición de rutas
│   │   └── route_paths.dart     # Constantes de rutas
│   └── theme/                    # Tema y estilos
│       ├── app_theme.dart       # Tema principal
│       ├── colors.dart          # Paleta de colores
│       └── text_styles.dart     # Estilos de texto
│
├── core/                         # Funcionalidades core
│   ├── constants/                # Constantes globales
│   ├── enums/                    # Enumeraciones
│   └── utils/                    # Validadores y helpers
│
├── features/                     # Módulos funcionales (MVC)
│   ├── auth/                     # 🔐 Autenticación
│   ├── onboarding/               # 👋 Onboarding inicial
│   ├── onboarding_stepper/       # 📝 Configuración de perfil
│   ├── dashboard/                # 🏠 Dashboard principal
│   ├── training/                 # 🏋️ Entrenamientos
│   │   ├── models/              # WorkoutModel, WorkoutPostModel
│   │   ├── controllers/         # TrainingController
│   │   └── views/               # TrainingModePage, widgets
│   ├── profile/                  # 👤 Perfil de usuario
│   ├── social/                   # 👥 Red social (seguidores)
│   ├── messages/                 # 💬 Mensajería temporal
│   ├── gym/                      # 🏢 Gimnasios
│   └── store/                    # 🛒 Tienda (premium)
│   
│   └── [cada feature contiene]
│       ├── models/               # Modelos de datos
│       ├── controllers/          # Lógica de negocio (GetX)
│       └── views/                # UI (Pages y Widgets)
│
└── shared/                       # Componentes compartidos
    ├── widgets/                  # Widgets reutilizables
    ├── services/                 # Servicios globales
    │   ├── firebase_auth_service.dart
    │   ├── firebase_storage_service.dart  # 📸 Upload fotos
    │   ├── firestore_service.dart
    │   ├── workout_service.dart
    │   ├── message_service.dart           # 💬 Realtime DB
    │   ├── social_service.dart
    │   └── streak_service.dart            # 🔥 Rachas
    ├── models/                   # Modelos compartidos
    ├── data/                     # Data estática (ejercicios)
    └── utils/                    # Utilidades compartidas
```

### Principios de Arquitectura

- ✅ **MVC Architecture**: Modelo-Vista-Controlador con GetX
- ✅ **Repository Pattern**: Para persistencia de datos (Firebase)
- ✅ **Controller Pattern**: Lógica de negocio con GetX Controllers
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

## 📅 Estado del Proyecto

### ✅ Fase 1: Core Funcionalidades - COMPLETADO
- [x] Setup del proyecto Flutter con Firebase
- [x] Autenticación completa (Email/Password + Google Sign-In)
- [x] Onboarding interactivo con stepper
- [x] Perfil de usuario completo (datos personales, medidas, info fitness)
- [x] Biblioteca de ejercicios (50+ ejercicios organizados)
- [x] Sistema de registro de entrenamientos
- [x] Timer de entrenamiento con pausa/reanudar
- [x] Historial de entrenamientos
- [x] UI/UX profesional con Material Design 3

### ✅ Fase 2: Social Features - COMPLETADO
- [x] Sistema de seguidores/siguiendo (Firestore real-time)
- [x] Feed de actividad estilo Instagram
- [x] **Fotos de entrenamientos** (Firebase Storage)
- [x] Posts con caption y likes
- [x] Sistema de comentarios en posts
- [x] Mensajería temporal 1-a-1 (Realtime Database)
- [x] Mensajes que expiran en 7 días
- [x] Reacciones a mensajes con emojis
- [x] Búsqueda de usuarios
- [x] Perfiles públicos con grid de workouts

### ✅ Gamificación - COMPLETADO
- [x] Sistema de rachas semanales (lunes a domingo)
- [x] Personaje dinámico que evoluciona
- [x] Compartir personaje y racha
- [x] Tarjeta de perfil estilo tarjeta de crédito
- [x] Animaciones de celebración

### 🚧 En Desarrollo
- [ ] Sistema de gimnasios con QR y geolocalización
- [ ] Rankings por gimnasio
- [ ] Competencias temporales
- [ ] Sistema de logros y badges avanzados
- [ ] Notificaciones push personalizadas

### 📋 Roadmap Futuro
- [ ] Modo offline con sincronización
- [ ] Estadísticas avanzadas con gráficos
- [ ] Integración con Apple Health / Google Fit
- [ ] Sistema premium (freemium)
- [ ] Analytics avanzados
- [ ] Widget de iOS para rachas

---

## 🔑 Decisiones Técnicas Clave

### 📸 Sistema de Fotos en Entrenamientos
- **Firebase Storage**: `users/{userId}/workouts/{workoutId}.jpg`
- **Compresión**: 80% calidad, máx 1080px de ancho
- **Ratio fijo**: 4:5 (mismo que Instagram)
- **Opcional**: Usuario puede skipear la foto
- **Flujo**: Caption → Foto → Subida → Post creado

### 💬 Mensajería Temporal (Realtime Database)
- **Expiración**: 7 días desde el último mensaje
- **Cloud Functions**: Limpieza automática diaria
- **Estructura**: 
  - `messages/{conversationId}/{messageId}` (mensajes)
  - `conversations/{userId}/{conversationId}` (metadata)
- **Features**: Reacciones, edición, eliminación, bloqueo

### 👥 Sistema de Seguidores
- **Arquitectura dual**: 
  - `users/{userId}` → `followers_count`, `following_count`
  - `social_connections/{userId}/followers` (lista completa)
- **Listeners en tiempo real**: Actualización instantánea de contadores
- **Bidireccional**: Seguir/dejar de seguir con Cloud Functions

### 🔥 Rachas Semanales
- **Período**: Lunes a domingo
- **Registro**: Se marca al finalizar entrenamiento
- **Persistencia**: Firestore + SharedPreferences (caché)
- **Validación**: Un entrenamiento = un día marcado

### Validación de Gimnasios
Combinación de **códigos QR únicos** + **geolocalización** para garantizar que los usuarios están realmente en el gimnasio.

### Prevención de Datos Falsos
- Sistema de reportes comunitario
- Validación automática basada en peso corporal
- Límites razonables por ejercicio (3x peso corporal)
- Verificación manual por administradores

### Modelo de Monetización
- **Freemium**: Funciones básicas gratuitas (5 amigos, 1 gimnasio)
- **Premium ($4.99/mes)**: Amigos ilimitados, múltiples gimnasios, estadísticas avanzadas, sin ads

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

## 🧭 Guías internas (resumen)

- Arquitectura MVC estricta: `models` (datos), `controllers` (GetX, lógica), `views` (UI).
- Nomenclatura: Clases en PascalCase, archivos en snake_case, variables/métodos en camelCase.
- Imports ordenados: Dart SDK → Flutter → terceros → proyecto.
- Estado con GetX: Controladores reactivos (`obs`, `Obx`) y DI con `Get.lazyPut`.
- Networking: Cliente HTTP centralizado (timeouts, interceptores, manejo de errores).
- Errores: Excepciones (`AppException`, `NetworkException`, etc.) y manejo en controllers.
- Almacenamiento: `SharedPreferences`/seguro para tokens, claves en constantes.
- Validaciones: Reglas en `core/utils` y validaciones básicas en modelos.
- Rutas: Definidas en `app/routes`, navegación con GetX (`Get.toNamed`, `Get.offAllNamed`).
- UI/UX: Material 3, `shared/widgets`, uso de `const` y estructura plana.
- Testing: AAA para unit y widget tests; dobles de prueba para servicios.

---

## 📚 Documentación Adicional

### 📖 **Documentación General:**
- [📋 PRD (Product Requirements Document)](design/prd.md)
- [🏗️ Arquitectura Social](docs/SOCIAL_ARCHITECTURE.md)
- [👥 Seguidores - Implementación](docs/SOCIAL_FOLLOWERS_IMPLEMENTATION.md)
- [💬 Sistema de Mensajería](features/messages/README.md)
- [🏋️ Sistema de Entrenamientos](features/training/README.md)
- [📚 Docs Index](docs/README.md)

### 🚀 **Quick Start para Desarrollo:**
```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/tribbe_app.git
cd tribbe_app

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Firebase (primera vez)
flutterfire configure

# 4. Configurar Firebase Storage Rules
firebase deploy --only storage

# 5. Configurar Realtime Database Rules
firebase deploy --only database

# 6. Desplegar Cloud Functions
cd functions
npm install
npm run deploy
cd ..

# 7. Ejecutar en modo debug
flutter run
```

### 🏭 **Build para Producción:**
```bash
# Android - APK de release (firmado)
flutter build apk --release

# Android - App Bundle para Play Store
flutter build appbundle --release

# iOS - Build para App Store
flutter build ios --release
```

### 🔥 **Firebase Setup:**

#### **Firestore Collections:**
```
users/                           # Perfiles de usuarios
  ├── {userId}/
  │   ├── workouts/             # Entrenamientos del usuario
  │   └── social_connections/   # Seguidores/siguiendo
  
workout_posts/                   # Posts públicos en el feed
social_connections/              # Relaciones sociales
streak_data/                     # Datos de rachas
```

#### **Realtime Database Structure:**
```
conversations/                   # Metadata de conversaciones
  └── {userId}/
      └── {conversationId}/
      
messages/                        # Mensajes temporales (7 días)
  └── {conversationId}/
      └── {messageId}/
```

#### **Storage Structure:**
```
users/
  └── {userId}/
      ├── profile/
      │   └── avatar.jpg          # Foto de perfil
      └── workouts/
          └── {workoutId}.jpg     # Fotos de entrenamientos
```

---

## 🎬 Flujos Principales de la App

### 📸 **Flujo de Entrenamiento con Foto**

```
1. Usuario inicia entrenamiento
   └─> Selecciona enfoque (Fuerza, Cardio, etc.)
   
2. Agrega ejercicios durante la sesión
   └─> Nombre del ejercicio + Series (peso x reps)
   
3. Finaliza entrenamiento
   └─> Escribe caption opcional
   └─> Toca "Siguiente"
   
4. Modal de captura de foto
   ├─> 📷 Tomar foto con cámara
   ├─> 🖼️ Seleccionar de galería  
   └─> ⏭️ Omitir (opcional)
   
5. Preview de foto (si seleccionó)
   └─> Confirmar o cambiar foto
   
6. Subida automática
   ├─> Storage: users/{userId}/workouts/{id}.jpg
   ├─> Firestore: workout_posts con workoutPhotoUrl
   └─> Feed actualizado en tiempo real
```

### 💬 **Flujo de Mensajería**

```
1. Buscar usuario en la pestaña Social
2. Tocar "Enviar mensaje"
3. Se crea conversación en Realtime Database
4. Enviar mensajes (texto + emojis)
5. Reaccionar con emojis (long press)
6. Mensajes expiran automáticamente en 7 días
7. Cloud Function limpia mensajes expirados diariamente
```

### 👥 **Flujo de Seguir Usuario**

```
1. Buscar usuario o tocar perfil desde post
2. Tocar "Seguir"
3. Se ejecuta Cloud Function:
   ├─> Incrementa followers_count del usuario
   ├─> Incrementa following_count tuyo
   └─> Crea relaciones en social_connections/
4. Actualizaciones en tiempo real (Firestore listeners)
```

### 🔥 **Flujo de Racha Semanal**

```
1. Completar un entrenamiento
2. StreakService registra el día actual
3. Se actualiza Firestore: streak_data/{userId}
4. Dashboard muestra visualización de racha
5. Personaje evoluciona según días completados
6. Compartir racha (imagen con personaje + stats)
```

---

## 🔐 Seguridad y Privacidad

### **Firebase Rules Implementadas:**

#### **Firestore Security Rules:**
```javascript
// Usuarios solo pueden leer/escribir su propio perfil
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}

// Posts de workout visibles para todos los autenticados
match /workout_posts/{postId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

#### **Realtime Database Rules:**
```json
{
  "rules": {
    "messages": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "conversations": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

#### **Storage Rules:**
```javascript
// Solo el dueño puede subir/modificar sus fotos
match /users/{userId}/{allPaths=**} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}
```

### **Privacidad:**
- ✅ Datos sensibles nunca en logs
- ✅ Tokens en memoria (no en SharedPreferences)
- ✅ Validación de entrada en cliente y servidor
- ✅ Mensajes con expiración automática
- ✅ Sistema de reportes y moderación

---

## 🎯 Características Destacadas

| Característica | Estado | Tecnología |
|----------------|--------|------------|
| 📸 Fotos de Entrenamientos | ✅ Completado | Firebase Storage + image_picker |
| 📱 Feed Estilo Instagram | ✅ Completado | Custom Widgets + AspectRatio |
| 💬 Mensajería Temporal | ✅ Completado | Realtime Database + Cloud Functions |
| 🔥 Rachas Semanales | ✅ Completado | Firestore + SharedPreferences |
| 👥 Sistema de Seguidores | ✅ Completado | Firestore + Real-time Listeners |
| ⏱️ Timer de Entrenamiento | ✅ Completado | Dart Timer + GetX State |
| 🎨 Dark/Light Mode | ✅ Completado | Material Design 3 |
| 🎭 Personaje Dinámico | ✅ Completado | Custom Illustrations |
| 💳 Tarjeta de Perfil | ✅ Completado | Custom Widget Compartible |
| 🔍 Búsqueda de Usuarios | ✅ Completado | Firestore Queries |
| ❤️ Likes y Comentarios | ✅ Completado | Firestore Subcollections |
| 🏋️ Biblioteca de Ejercicios | ✅ Completado | Data Estática Filtrable |

---

## 📦 Paquetes Principales Utilizados

```yaml
dependencies:
  # Core Framework
  flutter: sdk: flutter
  
  # State Management & Navigation
  get: ^4.6.6
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.5.1
  firebase_database: ^11.3.3
  firebase_storage: ^13.0.3
  cloud_functions: ^5.2.3
  
  # Google Sign-In
  google_sign_in: ^7.2.0
  
  # Image & Media
  image_picker: ^1.2.0
  cached_network_image: ^3.4.1
  
  # UI & Animations
  lottie: ^3.2.0
  rive: ^0.14.0
  
  # Storage & Cache
  shared_preferences: ^2.3.4
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.5.1
```

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, asegúrate de:

1. Seguir las convenciones de código del proyecto (ver `/design/CUSTOM_RULES.md`)
2. Escribir tests para nuevas funcionalidades
3. Actualizar la documentación según sea necesario
4. Crear un Pull Request descriptivo con:
   - Título claro
   - Descripción de los cambios
   - Screenshots si hay cambios UI
   - Tests pasando

### 🐛 Reportar Bugs

Para reportar bugs, por favor incluye:
- Versión de la app
- Sistema operativo (iOS/Android + versión)
- Pasos para reproducir
- Screenshots o videos si es posible
- Logs de error

---

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

---

## 👨‍💻 Autor

Desarrollado por **Cristhian Recalde** con 💪 para la comunidad fitness.

---

## 📞 Contacto y Soporte

- 🐛 **Bugs**: Abre un [issue](https://github.com/tu-usuario/tribbe_app/issues)
- 💡 **Features**: Abre un [feature request](https://github.com/tu-usuario/tribbe_app/issues/new?template=feature_request.md)
- 📧 **Email**: cristhian@tribbe.app

---

## 🌟 Screenshots

### 📱 **Feed Estilo Instagram**
Posts con fotos de entrenamientos, ejercicios overlay, likes y comentarios

### 🏋️ **Modo Entrenamiento**
Timer en vivo, agregar ejercicios, configurar series

### 🔥 **Rachas Semanales**
Visualización de días entrenados, personaje dinámico

### 👤 **Perfil de Usuario**
Grid de entrenamientos, estadísticas, seguidores/siguiendo

### 💬 **Mensajería Temporal**
Chats 1-a-1 con reacciones, expiran en 7 días

---

**✨ ¡Únete a la tribu y alcanza tus objetivos fitness! 🏋️‍♂️💪**

---

<p align="center">
  <sub>Hecho con ❤️ usando Flutter y Firebase</sub>
</p>