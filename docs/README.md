# 📚 Documentación de Tribbe App

Bienvenido a la documentación técnica de Tribbe App.

## 📑 Índice de Documentación

### Sistemas Implementados

- [🔥 Sistema de Rachas de Entrenamiento](./STREAKS_SYSTEM.md) - Sistema completo de seguimiento de entrenamientos consecutivos con almacenamiento en Firestore

## 🚀 Quick Start

Para desarrolladores nuevos en el proyecto:

1. Lee el [README principal](../README.md) del proyecto
2. Revisa las [Reglas de Desarrollo](../.cursor/rules/) (Custom Rules)
3. Consulta la documentación específica de cada sistema según lo necesites

## 📂 Estructura del Proyecto

```
lib/
├── app/                    # Configuración de la app (rutas, tema)
├── core/                   # Constantes, utilidades, enums
├── features/              # Módulos por funcionalidad (MVC)
│   ├── auth/             # Autenticación
│   ├── dashboard/        # Dashboard principal
│   ├── training/         # Entrenamientos
│   ├── profile/          # Perfil de usuario
│   └── ...
└── shared/               # Código compartido
    ├── controllers/      # Controladores globales
    ├── services/         # Servicios (API, Firestore, etc.)
    └── widgets/          # Widgets reutilizables
```

## 🛠️ Tecnologías

- **Flutter** 3.16+
- **Dart** 3.2+
- **Firebase** (Auth, Firestore, Storage)
- **GetX** (State Management, DI, Routing)

## 📝 Convenciones

### Nomenclatura

- **Archivos:** `snake_case.dart`
- **Clases:** `PascalCase`
- **Variables/Funciones:** `camelCase`
- **Constantes:** `kCamelCase`
- **Constantes API:** `SCREAMING_SNAKE_CASE`

### Arquitectura

Seguimos el patrón **MVC** estricto:

- **Models:** Solo datos y serialización (JSON)
- **Views:** Solo UI, consumir controllers
- **Controllers:** Lógica de negocio, state management

## 🔐 Firebase

### Colecciones Principales

- `users/{userId}` - Datos de usuario
  - `preferencias/` - Configuraciones
  - `informacion/` - Info fitness
  - `personaje/` - Avatar
  - `medidas/` - Medidas corporales
  - `workouts/` - Entrenamientos
  - `streaks/` - Rachas 🔥 **NUEVO**

- `workout_posts/{postId}` - Feed de entrenamientos
  - `comments/` - Comentarios

- `friendships/{friendshipId}` - Relaciones de amistad

## 🤝 Contribución

1. Crea una rama desde `develop`
2. Nombra la rama: `feat/nombre-feature` o `fix/nombre-fix`
3. Sigue las convenciones de código
4. Asegúrate de no tener errores de linting
5. Crea un PR hacia `develop`

## 📞 Soporte

Si tienes dudas sobre algún sistema:

1. Consulta la documentación específica
2. Revisa el código de ejemplo en los tests
3. Pregunta al equipo en el canal de desarrollo

---

**Última actualización:** Octubre 2025

