# 🔥 Cloud Functions - Sistema de Rachas Tribbe

## 📋 Descripción

Cloud Functions para mantener las rachas de entrenamiento de todos los usuarios sincronizadas y actualizadas automáticamente.

## 🚀 Funciones Disponibles

### 1. `updateAllStreaks` (Programada)
- **Trigger**: Cada día a las 00:00 UTC
- **Propósito**: Actualizar rachas de todos los usuarios
- **Lógica**:
  - Día consecutivo (ayer): Incrementa +1
  - Perdiste 1-2 días: Mantiene la racha
  - Perdiste 3+ días: Resetea a 0

### 2. `updateUserStreak` (HTTPS)
- **Trigger**: Llamada manual desde la app
- **Propósito**: Actualizar racha de un usuario específico
- **Autenticación**: Requerida

### 3. `resetAllStreaks` (HTTPS - Solo Testing)
- **Trigger**: Llamada manual
- **Propósito**: Resetear todas las rachas a 0
- **Restricción**: Solo en desarrollo

## 🛠️ Instalación

```bash
# Instalar dependencias
cd functions
npm install

# Configurar Firebase
firebase login
firebase use --add

# Desplegar funciones
npm run deploy
```

## 📊 Monitoreo

```bash
# Ver logs en tiempo real
firebase functions:log

# Ver logs de una función específica
firebase functions:log --only updateAllStreaks
```

## 🧪 Testing

```bash
# Ejecutar emulador local
npm run serve

# Probar función específica
firebase functions:shell
```

## 📈 Métricas

Las funciones registran:
- Usuarios procesados
- Usuarios actualizados
- Nuevos récords alcanzados
- Errores y excepciones

## 🔧 Configuración

### Variables de Entorno
```bash
# Configurar zona horaria
firebase functions:config:set app.timezone="America/New_York"

# Configurar entorno
firebase functions:config:set app.environment="production"
```

### Permisos de Firestore
```javascript
// Reglas necesarias en firestore.rules
match /users/{userId}/streaks/{streakId} {
  allow read, write: if isOwner(userId);
}
```

## 📝 Logs de Ejemplo

```
🔥 Iniciando actualización de rachas...
📊 Procesando 150 usuarios...
👤 Usuario abc123:
   - Racha actual: 5
   - Último entrenamiento: 2025-10-15T09:36:44.599166Z
   - Días desde último entrenamiento: 2
   ⚠️ Perdió 2 días, manteniendo racha
✅ Actualización completada: 25 usuarios actualizados
📊 Resumen:
   - Usuarios procesados: 150
   - Usuarios actualizados: 25
```

## 🚨 Troubleshooting

### Error: "No hay usuarios para procesar"
- Verificar que existan documentos en la colección `users`
- Verificar permisos de Firestore

### Error: "Usuario no tiene racha"
- El usuario no ha completado ningún entrenamiento
- Crear racha inicial con `StreakModel.empty()`

### Error: "No hay fecha de último entrenamiento"
- El campo `last_workout_date` es null
- Verificar que se esté guardando correctamente en la app

## 🔄 Flujo de Actualización

1. **Trigger**: Scheduler ejecuta `updateAllStreaks` a medianoche
2. **Query**: Obtiene todos los usuarios de la colección `users`
3. **Process**: Para cada usuario:
   - Obtiene su racha actual
   - Calcula días desde último entrenamiento
   - Aplica lógica de actualización
   - Actualiza si es necesario
4. **Batch**: Ejecuta todas las actualizaciones en lote
5. **Log**: Registra métricas y resultados

## 📱 Integración con la App

```dart
// Llamar función desde la app
final callable = FirebaseFunctions.instance.httpsCallable('updateUserStreak');
final result = await callable.call();
```

## 🎯 Beneficios

- ✅ **Automatización**: No requiere intervención manual
- ✅ **Consistencia**: Todas las rachas se actualizan uniformemente
- ✅ **Escalabilidad**: Maneja miles de usuarios eficientemente
- ✅ **Confiabilidad**: Ejecuta en la nube con alta disponibilidad
- ✅ **Monitoreo**: Logs detallados para debugging
