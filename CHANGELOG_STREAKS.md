# 🔥 Sistema de Rachas - Changelog

## ✅ Implementación Completa - Octubre 2025

### 📋 Resumen

Se ha implementado completamente el sistema de rachas de entrenamiento que se activa automáticamente cuando un usuario completa un entrenamiento. Las rachas se almacenan en Firestore bajo la subcolección `users/{uid}/streaks/` para mantener un registro persistente y sincronizado.

---

## 🎯 Características Implementadas

### 1. Almacenamiento en Firestore

**Estructura de datos:**
```
users/{userId}/streaks/
├── current_streak (documento principal)
│   ├── current_streak: int
│   ├── longest_streak: int
│   ├── last_workout_date: timestamp
│   ├── weekly_streak: array[bool]
│   ├── created_at: timestamp
│   └── updated_at: timestamp
└── {recordId} (historial de récords)
    ├── current_streak: int
    ├── longest_streak: int
    ├── achieved_at: timestamp
    └── type: "new_record"
```

### 2. Servicio de Rachas Actualizado

**Archivo:** `lib/shared/services/streak_service.dart`

**Cambios principales:**
- ✅ Migrado de SharedPreferences a Firestore
- ✅ Métodos async para operaciones de base de datos
- ✅ Stream en tiempo real de rachas
- ✅ Historial automático de récords
- ✅ Gestión inteligente de semanas

**Nuevos métodos:**
- `getStreak()` - Obtener racha desde Firestore
- `saveStreak(StreakModel)` - Guardar racha en Firestore
- `registerWorkout()` - Registrar entrenamiento y actualizar racha
- `getStreakHistory()` - Obtener historial de récords
- `getStreakStream()` - Stream en tiempo real
- `resetStreak()` - Resetear racha (testing)

### 3. Modelo de Racha Mejorado

**Archivo:** `lib/features/dashboard/models/streak_model.dart`

**Campos agregados:**
- `createdAt: DateTime?` - Fecha de creación
- `updatedAt: DateTime?` - Fecha de última actualización

**Mejoras:**
- ✅ Timestamps automáticos
- ✅ Serialización completa a/desde JSON
- ✅ Método copyWith actualizado

### 4. Controlador de Dashboard Actualizado

**Archivo:** `lib/features/dashboard/controllers/dashboard_controller.dart`

**Cambios:**
- ✅ Método `loadStreak()` ahora es async
- ✅ Compatible con Firestore
- ✅ Manejo de errores mejorado

### 5. Integración con Entrenamientos

**Archivo:** `lib/features/training/controllers/training_controller.dart`

**Flujo:**
1. Usuario completa entrenamiento
2. Se guarda workout en Firestore
3. Se crea post en el feed
4. **Se registra automáticamente en rachas** ✨
5. Se actualiza UI

```dart
// Registrar entrenamiento para la racha
await _streakService.registerWorkout();
```

### 6. Reglas de Seguridad de Firestore

**Archivo:** `firestore.rules`

**Nueva regla agregada:**
```javascript
// Subcolección de Rachas
match /streaks/{streakId} {
  // El usuario puede leer, crear, actualizar y eliminar sus propias rachas
  allow read, write: if isOwner(userId);
}
```

---

## 📚 Documentación

Se ha creado documentación completa del sistema:

### Archivos de Documentación

1. **`docs/STREAKS_SYSTEM.md`**
   - Arquitectura completa
   - Guía de uso
   - Ejemplos de código
   - Diagramas de flujo
   - Troubleshooting

2. **`docs/README.md`**
   - Índice de documentación
   - Quick start
   - Estructura del proyecto
   - Convenciones

---

## 🔄 Lógica de Rachas

### Cálculo de Racha

```
Si ya entrenó hoy:
  → No hacer nada, retornar racha actual

Si NO entrenó hoy:
  Si racha está activa (entrenó ayer):
    → Incrementar racha actual
  Si NO está activa (perdió días):
    → Resetear racha a 1
  
  Si racha actual == récord:
    → Guardar en historial de récords
```

### Racha Semanal

- Array de 7 booleanos: `[Lun, Mar, Mie, Jue, Vie, Sab, Dom]`
- Se resetea automáticamente cada semana
- Calcula el inicio de semana basado en el último entrenamiento

---

## 🎨 Ejemplo de Uso en UI

```dart
// Mostrar racha actual
Obx(() => Text(
  '${controller.currentStreak} días',
  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
))

// Mostrar récord
Obx(() => Text('Récord: ${controller.longestStreak} días'))

// Verificar si entrenó hoy
Obx(() => controller.hasTrainedToday 
  ? Icon(Icons.check_circle, color: Colors.green)
  : Icon(Icons.fitness_center, color: Colors.grey)
)

// Mostrar semana
Row(
  children: List.generate(7, (index) {
    return DayCircle(
      day: StreakService.getWeekDayNames()[index],
      completed: controller.weeklyStreak[index],
    );
  }),
)
```

---

## 🧪 Testing

Para probar el sistema de rachas:

```dart
// Obtener servicio
final streakService = Get.find<StreakService>();

// Registrar un entrenamiento de prueba
final streak = await streakService.registerWorkout();
print('Nueva racha: ${streak.currentStreak}');

// Ver historial
final history = await streakService.getStreakHistory();
print('Récords alcanzados: ${history.length}');

// Resetear (solo testing)
await streakService.resetStreak();
```

---

## 🚀 Próximos Pasos (Pendientes)

### Para Desplegar

1. **Actualizar reglas de Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Verificar permisos:**
   - Asegurarse de que todos los usuarios tengan acceso a sus propias rachas

### Características Futuras

- [ ] Notificaciones push cuando se está por perder una racha
- [ ] Logros por alcanzar ciertos hitos (7, 30, 100 días)
- [ ] Comparación de rachas con amigos
- [ ] Gráficos de progreso histórico
- [ ] Sistema de "freeze" para recuperar rachas perdidas
- [ ] Animaciones celebratorias al alcanzar nuevos récords

---

## 🐛 Notas Importantes

### Zona Horaria
- El sistema usa la zona horaria local del dispositivo
- La verificación de "hoy" se basa en año/mes/día (no horas)

### Migración de Datos
- Los usuarios existentes con rachas en SharedPreferences necesitarán:
  - Sus rachas se migrarán automáticamente a Firestore en el primer `getStreak()`
  - O se creará una racha nueva desde cero

### Performance
- Las rachas se cachean localmente en el controller
- El stream solo se actualiza cuando hay cambios en Firestore
- Escrituras mínimas: solo cuando hay cambio de racha

---

## 📊 Estructura de Archivos Modificados

```
✏️ Modificados:
  - lib/shared/services/streak_service.dart
  - lib/features/dashboard/controllers/dashboard_controller.dart
  - lib/features/dashboard/models/streak_model.dart
  - firestore.rules

➕ Agregados:
  - docs/STREAKS_SYSTEM.md
  - docs/README.md
  - CHANGELOG_STREAKS.md (este archivo)

✅ Sin cambios (ya estaban correctos):
  - lib/features/training/controllers/training_controller.dart
  - lib/app/routes/app_router.dart
```

---

## ✨ Conclusión

El sistema de rachas está completamente implementado y listo para usar. Se activa automáticamente cuando un usuario completa un entrenamiento y mantiene un registro persistente en Firestore con historial de récords.

**Estado:** ✅ Completo y funcional  
**Versión:** 1.0.0  
**Fecha:** Octubre 2025

---

## 📞 Contacto

Para preguntas o reportar bugs relacionados con el sistema de rachas, contacta al equipo de desarrollo.

