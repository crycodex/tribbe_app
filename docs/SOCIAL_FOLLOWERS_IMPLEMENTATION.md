# 📱 Sistema de Seguidores (Followers/Following) - Implementación Simplificada

## 📋 Resumen

Este documento describe la implementación del sistema de seguidores **simplificado**, eliminando el sistema de amistades y bloqueos:

- ✅ **Seguidores**: Sistema unidireccional donde cualquier usuario puede seguir a otro sin solicitud
- ✅ **Contadores actualizados en tiempo real**: `followers_count`, `following_count`
- ❌ **Sistema de amistades eliminado**: Ya no hay amigos, solicitudes, ni bloqueos
- ❌ **Chat eliminado**: Solo se puede seguir/ver entrenamientos

---

## 🏗️ Arquitectura

### Estructura de Datos en Firestore

```
users/{userId}/
  ├── followers_count: number      // Cantidad de seguidores
  ├── following_count: number      // Cantidad que sigue
  └── social/
      ├── followers/
      │   └── followers/{followerId}   // Quién me sigue
      └── following/
          └── following/{followingId}   // A quién sigo
```

---

## 📦 Archivos Creados/Modificados

### Nuevos Archivos

1. **`lib/shared/models/social_models.dart`**
   - `FollowRelation`: Modelo para relaciones de seguimiento
   - `SocialStats`: Modelo para estadísticas sociales

2. **`lib/shared/services/social_service.dart`**
   - `followUser()`: Seguir a un usuario
   - `unfollowUser()`: Dejar de seguir
   - `isFollowing()`: Verificar si sigue a alguien
   - `isFollowedBy()`: Verificar si alguien lo sigue
   - `getFollowers()`: Stream de seguidores
   - `getFollowing()`: Stream de usuarios que sigue
   - `getSocialStats()`: Obtener estadísticas
   - `getSocialStatsStream()`: Stream de estadísticas en tiempo real

3. **`functions/migrate_social_counters.js`**
   - Script de migración para inicializar contadores en 0

### Archivos Modificados

1. **`lib/features/social/controllers/social_controller.dart`**
   - **SIMPLIFICADO**: Eliminadas funcionalidades de amistades y bloqueos
   - Solo métodos: `followUser()`, `unfollowUser()`, `isFollowingUser()`, etc.

2. **`lib/features/profile/controllers/profile_controller.dart`**
   - Modificado `_loadSocialStats()` para escuchar cambios en tiempo real

3. **`lib/features/social/views/pages/social_page.dart`**
   - **SIMPLIFICADO**: Solo 3 tabs: Seguidores, Siguiendo, Buscar
   - Eliminados tabs: Amigos, Solicitudes, Bloqueados

4. **`lib/features/social/views/widgets/search_tab.dart`**
   - **SIMPLIFICADO**: Solo botón "Seguir" / "Siguiendo"
   - Eliminados botones de amistades

5. **`lib/features/social/views/widgets/followers_tab.dart`**
   - **NUEVO**: Lista de seguidores con menú simplificado

6. **`lib/features/social/views/widgets/following_tab.dart`**
   - **NUEVO**: Lista de usuarios seguidos con opción de dejar de seguir

7. **`firestore.rules`**
   - **SIMPLIFICADO**: Solo reglas para `followers` y `following`
   - Eliminadas reglas de amistades y bloqueos

8. **`lib/app/routes/app_router.dart`**
   - Registrado `SocialService` en las dependencias globales

---

## 🚀 Pasos de Implementación

### 1. Migrar Contadores Existentes

Ejecuta el script de migración para inicializar los contadores de todos los usuarios:

```bash
cd functions
node migrate_social_counters.js
```

**Nota:** Necesitas descargar `serviceAccountKey.json` desde Firebase Console:
- Ve a: **Project Settings > Service Accounts**
- Click en **Generate new private key**
- Guarda el archivo como `functions/serviceAccountKey.json`
- ⚠️ **NO lo subas a Git** (ya está en `.gitignore`)

### 2. Desplegar Reglas de Firestore

```bash
firebase deploy --only firestore:rules
```

### 3. Pruebas

#### Probar Seguir a un Usuario

1. Abre la app y ve a la pestaña **Social**
2. Busca un usuario
3. Verás dos botones:
   - **Seguir** (outline): Para seguir sin ser amigos
   - **+** (elevado): Para enviar solicitud de amistad
4. Toca **Seguir** → Deberías ver "¡Usuario seguido!"
5. El botón cambiará a **Siguiendo**

#### Verificar Contadores

1. Ve al **Perfil**
2. Verifica que los contadores se actualicen:
   - **Seguidores**: Cuántos te siguen
   - **Siguiendo**: A cuántos sigues
   - **Posts**: Entrenamientos publicados

---

## 🔐 Reglas de Seguridad

### Followers/Following

```javascript
// Subcolección de Seguidores
match /followers/{followerId} {
  // El dueño puede ver sus seguidores
  allow read: if isOwner(userId);
  
  // Otros usuarios pueden ver si siguen a este usuario
  allow read: if isAuthenticated();
  
  // Cualquier usuario puede seguir (crear documento)
  allow create: if isAuthenticated() && request.auth.uid == followerId;
  
  // Cualquier usuario puede dejar de seguir (eliminar su documento)
  allow delete: if isAuthenticated() && request.auth.uid == followerId;
}

// Subcolección de Siguiendo (Following)
match /following/{followingId} {
  // El dueño puede ver a quién sigue
  allow read: if isOwner(userId);
  
  // Solo el dueño puede crear/eliminar registros
  allow create, delete: if isOwner(userId);
}
```

### Contadores

```javascript
// Permitir actualización de contadores sociales
allow update: if isAuthenticated() 
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly(['friends_count', 'followers_count', 'following_count']);
```

---

## 💡 Diferencias: Sistema Simplificado

| Característica | Seguidores |
|---|---|
| **Requiere aceptación** | ❌ No |
| **Relación** | Unidireccional |
| **Chat** | ❌ No permitido |
| **Ver entrenamientos** | ✅ Sí (si el perfil es público) |
| **Notificaciones** | Media prioridad |
| **Límite** | Ilimitado |

---

## 📊 Flujos de Usuario

### Seguir a un Usuario

```
1. Usuario A busca a Usuario B
2. Usuario A toca "Seguir"
3. Se crea:
   - users/{A}/social/following/following/{B}
   - users/{B}/social/followers/followers/{A}
4. Se incrementan contadores:
   - users/{A}.following_count += 1
   - users/{B}.followers_count += 1
5. Usuario A ve botón "Siguiendo"
```

### Dejar de Seguir

```
1. Usuario A toca "Siguiendo"
2. Se muestra confirmación
3. Se eliminan:
   - users/{A}/social/following/following/{B}
   - users/{B}/social/followers/followers/{A}
4. Se decrementan contadores:
   - users/{A}.following_count -= 1
   - users/{B}.followers_count -= 1
5. Usuario A vuelve a ver botón "Seguir"
```

---

## 🐛 Solución de Problemas

### Contador en -1

**Problema:** El campo `following_count` muestra `-1`.

**Solución:**
1. Ejecuta el script de migración: `node migrate_social_counters.js`
2. O actualiza manualmente en Firebase Console:
   ```
   users/{userId}
   followers_count: 0
   following_count: 0
   friends_count: 0
   ```

### Botón "Seguir" no aparece

**Verificar:**
1. Que `SocialService` esté registrado en `app_router.dart`
2. Que las reglas de Firestore estén desplegadas
3. Logs en consola para errores

### Contadores no se actualizan

**Verificar:**
1. Que `ProfileController` esté usando el listener (`.snapshots()`)
2. Que las transacciones en `SocialService` se completen exitosamente
3. Permisos en reglas de Firestore para actualizar contadores

---

## 🎯 Próximos Pasos

- [ ] Agregar pestañas "Seguidores" y "Siguiendo" en el perfil
- [ ] Implementar notificaciones cuando alguien te sigue
- [ ] Mostrar sugerencias de usuarios para seguir
- [ ] Feed de actividad de usuarios que sigues
- [ ] Perfiles públicos vs privados
- [ ] Remover seguidores

---

## 📚 Referencias

- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/rules-structure)
- [GetX State Management](https://pub.dev/packages/get)
- [Flutter Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

---

**✅ Implementación completada el:** $(date +%Y-%m-%d)  
**👨‍💻 Autor:** Cristhian Recalde  
**📱 Proyecto:** Tribbe App

