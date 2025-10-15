# 📋 Stepper de Personalización - Tribbe App

## 🎯 Flujo Completo

```
Welcome Page (preferencias iniciales)
  ↓ (guarda: tema, idioma, género)
Onboarding
  ↓
Login/Register
  ↓
[¿has_completed_personalization?]
  ├─ false → Stepper de Personalización (4 pasos)
  └─ true  → Home (dashboard)
```

---

## 📱 Los 4 Pasos del Stepper

### **Step 1: Preferencias** 
*(Ya guardadas del Welcome, solo mostrar)*
- ✅ Tema (Día/Noche)
- ✅ Unidades (cm/kg o in/lb)
- ✅ Idioma (Español/English)
- ✅ Género (Masculino/Femenino)

**Ubicación**: `lib/features/onboarding_stepper/views/steps/step_preferences.dart`

---

### **Step 2: Información Personal**
- 📅 Fecha de nacimiento
- 📝 Bio (presentación de hasta 250 caracteres)
- 🎯 Meta fitness (dropdown con opciones)
- 🤕 Lesiones (chips multi-selección)
- 🌍 Ubicación (país, provincia, ciudad)

**Ubicación**: `lib/features/onboarding_stepper/views/steps/step_info.dart`

**Opciones disponibles**:
```dart
metasFitness: ['Perder peso', 'Masa muscular', 'Mantenimiento', 'Rendimiento']
lesiones: ['Hombros', 'Rodillas', 'Espalda', 'Codos', 'Caderas', 'Ninguna']
nivelesExperiencia: ['Principiante', 'Intermedio', 'Avanzado']
```

---

### **Step 3: Personaliza tu Personaje/Avatar**
- 👤 Nombre completo
- ⚥ Género (Masculino/Femenino)
- 💪 Nivel experiencia (principiante/intermedio/avanzado)
- 🔥 Condición física actual (slider 0-100)
- 📏 Altura (slider 100-220 cm)
- 🎨 Tono de piel (3 opciones: #ffd7ba, #d4a87b, #8b6f47)

**Ubicación**: `lib/features/onboarding_stepper/views/steps/step_personaje.dart`

---

### **Step 4: Medidas Corporales**

**Básicas** (obligatorias):
- 📏 Altura (cm)
- ⚖️ Peso (kg)

**Avanzado** (opcional - checkbox para activar):
- Cuello
- Brazo Izquierdo / Derecho
- Antebrazo Izquierdo / Derecho
- Pecho
- Espalda / Cintura
- Cuádricep Izquierdo / Derecho
- Pantorrilla Izquierda / Derecha

**Ubicación**: `lib/features/onboarding_stepper/views/steps/step_medidas.dart`

---

## 🗂️ Estructura Firestore Resultante

```
users/{uid}/
├── uid: "abc123"
├── email: "juan@email.com"
├── has_completed_personalization: true
├── created_at: "2024-01-15T10:30:00"
├── updated_at: "2024-01-15T11:00:00"
├── datos_personales:
│   ├── nombre_completo: "Juan Pérez"
│   ├── nombre_usuario: "juanp"
│   ├── email: "juan@email.com"
│   ├── fecha_nacimiento: "15/05/1990"
│   └── ubicacion:
│       ├── pais: "Ecuador"
│       ├── provincia: "Imbabura"
│       └── ciudad: "Ibarra"
│
├── [SUBCOLLECTIONS]
│
├── /preferencias/current/
│   ├── tema: "Día"
│   ├── unidades:
│   │   ├── medida: "cm"
│   │   └── peso: "kg"
│   ├── idioma: "Español"
│   └── genero: "Masculino"
│
├── /informacion/current/
│   ├── proposito: "Mejorar mi condición física..."
│   ├── meta_fitness: "Masa muscular"
│   ├── lesiones: ["Hombros", "Rodillas"]
│   ├── nivel_experiencia: "Intermedio"
│   └── condicion_fisica_actual: 75
│
├── /personaje/current/
│   ├── genero: "Masculino"
│   ├── tono_piel: "#ffcc99"
│   └── avatar_url: null
│
└── /medidas/current/
    ├── altura_cm: 180
    ├── peso_kg: 85
    ├── porcentaje_grasa_corporal: null
    └── medidas_especificas_cm:
        ├── cuello: 40
        ├── hombro: null
        ├── brazo_izquierdo: 38
        └── ... (otras medidas)
```

---

## 🔧 Archivos Clave Creados

### **Controller**
- `lib/features/onboarding_stepper/controllers/onboarding_stepper_controller.dart`
  - Maneja estado de los 4 pasos
  - Validación de datos
  - Guardado final en Firestore
  - Actualiza `has_completed_personalization` a `true`

### **Views**
- `lib/features/onboarding_stepper/views/pages/onboarding_stepper_page.dart`
  - Layout principal del stepper
  - Indicadores de progreso
  - Navegación entre pasos (Atrás/Siguiente/Finalizar)

### **Steps**
- `step_preferences.dart` → Step 1
- `step_info.dart` → Step 2
- `step_personaje.dart` → Step 3
- `step_medidas.dart` → Step 4

---

## 🚀 Rutas Actualizadas

**Nueva ruta agregada en `app_router.dart`:**
```dart
GetPage<dynamic>(
  name: RoutePaths.onboardingStepper,
  page: () => const OnboardingStepperPage(),
  binding: OnboardingStepperBinding(),
  transition: Transition.fade,
),
```

**Path agregado en `route_paths.dart`:**
```dart
static const String onboardingStepper = '/onboarding-stepper';
```

---

## ✅ Lógica de Redirección

**En `AuthController.loginWithEmail()`:**
```dart
// Verificar si completó la personalización
final hasCompletedPersonalization = 
    userProfile.value?.hasCompletedPersonalization ?? false;

if (!hasCompletedPersonalization) {
  // Primera vez: Ir al stepper de personalización
  Get.offAllNamed(
    RoutePaths.onboardingStepper,
    arguments: {'userId': user.uid},
  );
} else {
  // Ya completó: Ir directamente al home
  Get.offAllNamed(RoutePaths.home);
}
```

---

## 🎨 Características UI/UX

### **Indicadores de Paso**
- Dots visuales para mostrar progreso (1/4, 2/4, etc.)
- Navegación intuitiva con botones "Atrás" y "Siguiente"
- Botón "Finalizar" en el último paso

### **Validaciones**
- Step 1: Sin validación (solo lectura)
- Step 2: Validación opcional
- Step 3: Nombre es obligatorio
- Step 4: Altura y peso obligatorios

### **Guardado**
- Al presionar "Finalizar" en el Step 4:
  1. Guarda todas las subcolecciones en Firestore
  2. Actualiza `has_completed_personalization = true`
  3. Navega al Home
  4. Muestra snackbar de bienvenida

---

## 📦 Servicios Usados

### **FirestoreService**
Métodos clave:
```dart
- createUserProfile() → Crea documento principal + preferencias default
- getUserProfile() → Lee documento + todas las subcolecciones
- updatePreferencias() → Actualiza subcolección preferencias
- updateInformacion() → Actualiza subcolección informacion
- updatePersonaje() → Actualiza subcolección personaje
- updateMedidas() → Actualiza subcolección medidas
```

### **StorageService**
```dart
- getThemeMode() → Obtiene tema del welcome page
- getLanguage() → Obtiene idioma del welcome page
- getGender() → Obtiene género del welcome page
```

---

## 🧪 Testing Flow

### **Test Manual**
1. ✅ Registrar nuevo usuario
2. ✅ Verificar email
3. ✅ Login → Debe redirigir al stepper
4. ✅ Completar los 4 pasos
5. ✅ Verificar en Firestore que todas las subcolecciones se crearon
6. ✅ Verificar que `has_completed_personalization = true`
7. ✅ Cerrar sesión y volver a entrar → Debe ir directo al Home

---

## 🔮 Próximos Pasos (Futuro)

- [ ] Permitir editar perfil desde Settings
- [ ] Agregar avatar/foto de perfil
- [ ] Subir foto de avatar a Firebase Storage
- [ ] Agregar visualización 3D del avatar
- [ ] Permitir saltar pasos opcionales
- [ ] Guardar progreso parcial (borrador)

---

## 🎉 ¡Listo!

El sistema completo de personalización está implementado y funcionando. El flujo es:

**Welcome → Onboarding → Login/Register → Stepper (4 pasos) → Home**

Todas las preferencias y datos del usuario quedan guardados en Firestore con la estructura de subcolecciones especificada.

