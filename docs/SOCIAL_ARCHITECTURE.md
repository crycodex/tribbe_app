# 📱 Arquitectura Social - Tribbe App

## 📊 Nueva Estructura de Datos

La gestión de amistades, solicitudes y bloqueos ahora se maneja mediante **subcolecciones dentro de cada usuario**, lo que proporciona mejor organización, seguridad y rendimiento.

### Estructura de Firestore

```
users/
  {userId}/
    ├── (campos del usuario: email, username, photo_url, etc.)
    └── social/
        ├── friends/                    # Colección de amigos
        │   └── {friendId}/             # Documento con ID del amigo
        │       ├── friend_id: string
        │       └── created_at: timestamp
        │
        ├── friend_requests_sent/       # Solicitudes enviadas
        │   └── {receiverId}/           # Documento con ID del receptor
        │       ├── receiver_id: string
        │       ├── status: "pending" | "accepted" | "rejected" | "cancelled"
        │       └── created_at: timestamp
        │
        ├── friend_requests_received/   # Solicitudes recibidas
        │   └── {senderId}/             # Documento con ID del remitente
        │       ├── sender_id: string
        │       ├── status: "pending" | "accepted" | "rejected"
        │       └── created_at: timestamp
        │
        └── blocked_users/              # Usuarios bloqueados
            └── {blockedUserId}/        # Documento con ID del bloqueado
                ├── blocked_user_id: string
                └── created_at: timestamp
```

---

## 🎯 Ventajas de esta Arquitectura

### 1. **Seguridad Mejorada** 🔒
- Cada usuario tiene control total sobre sus propias subcolecciones
- Las reglas de seguridad son más simples y restrictivas
- No hay colecciones globales que puedan ser accedidas indebidamente

### 2. **Organización Clara** 📂
- Toda la información social está agrupada bajo el usuario
- Fácil de entender y mantener
- Sigue el principio de "encapsulación de datos"

### 3. **Rendimiento Optimizado** ⚡
- Queries más eficientes (no se necesitan `where` complejos)
- Acceso directo por ID de documento
- Menos lecturas de Firestore

### 4. **Escalabilidad** 📈
- Cada usuario puede tener sus propias colecciones sin afectar a otros
- Fácil de particionar y escalar horizontalmente
- Eliminar un usuario elimina automáticamente todas sus subcolecciones

### 5. **Costos Reducidos** 💰
- Menos lecturas compuestas (no necesita múltiples `where`)
- Acceso directo por documento ID es más económico
- Eliminación en cascada más eficiente

---

## 🔐 Reglas de Seguridad

### Principios Aplicados

1. **Propiedad Estricta**: Solo el dueño puede leer/escribir sus propias subcolecciones
2. **Creación Bidireccional**: Al enviar solicitud, se crea en ambos usuarios (sent/received)
3. **Permisos Limitados**: Otros usuarios pueden leer amigos para verificar relaciones
4. **Validación de Estado**: Solo cambios válidos de estado son permitidos

### Reglas para Amigos

```javascript
match /social/{socialDoc} {
  match /friends/{friendId} {
    // El usuario puede gestionar su lista de amigos
    allow read, write: if isOwner(userId);
    
    // Otros usuarios autenticados pueden leer para verificar amistades
    allow read: if isAuthenticated();
  }
}
```

### Reglas para Solicitudes Recibidas

```javascript
match /friend_requests_received/{senderId} {
  // Solo el dueño puede leer sus solicitudes recibidas
  allow read: if isOwner(userId);
  
  // Solo el dueño puede actualizar (aceptar/rechazar)
  allow update: if isOwner(userId);
  
  // El remitente puede crear la solicitud en el documento del receptor
  allow create: if isAuthenticated() && request.auth.uid == senderId;
  
  // El remitente puede eliminar (cancelar) su propia solicitud
  allow delete: if isAuthenticated() && request.auth.uid == senderId;
}
```

---

## 🔄 Flujos de Operaciones

### 1️⃣ Enviar Solicitud de Amistad

**Transacción atómica:**
1. Crear documento en `sender/social/friend_requests_sent/{receiverId}`
2. Crear documento en `receiver/social/friend_requests_received/{senderId}`

**Datos guardados:**
```dart
{
  'receiver_id': receiverId,    // En sent
  'sender_id': senderId,        // En received
  'status': 'pending',
  'created_at': FieldValue.serverTimestamp(),
}
```

---

### 2️⃣ Aceptar Solicitud de Amistad

**Transacción atómica:**
1. Actualizar estado en `receiver/social/friend_requests_received/{senderId}` → `accepted`
2. Actualizar estado en `sender/social/friend_requests_sent/{receiverId}` → `accepted`
3. Crear amistad en `receiver/social/friends/{senderId}`
4. Crear amistad en `sender/social/friends/{receiverId}`
5. Incrementar contador `friends_count` en ambos usuarios

**Datos de amistad:**
```dart
{
  'friend_id': friendId,
  'created_at': FieldValue.serverTimestamp(),
}
```

---

### 3️⃣ Rechazar Solicitud

**Transacción atómica:**
1. Eliminar `receiver/social/friend_requests_received/{senderId}`
2. Eliminar `sender/social/friend_requests_sent/{receiverId}`

---

### 4️⃣ Cancelar Solicitud Enviada

**Transacción atómica:**
1. Eliminar `sender/social/friend_requests_sent/{receiverId}`
2. Eliminar `receiver/social/friend_requests_received/{senderId}`

---

### 5️⃣ Eliminar Amistad

**Transacción atómica:**
1. Eliminar `user/social/friends/{friendId}`
2. Eliminar `friend/social/friends/{userId}`
3. Decrementar contador `friends_count` en ambos usuarios

---

### 6️⃣ Bloquear Usuario

**Transacción atómica:**
1. Crear `user/social/blocked_users/{blockedUserId}`
2. Eliminar amistades si existen (bidireccional)
3. Eliminar todas las solicitudes pendientes en ambas direcciones

**Datos de bloqueo:**
```dart
{
  'blocked_user_id': blockedUserId,
  'created_at': FieldValue.serverTimestamp(),
}
```

---

## 🚀 Uso en el Código

### FriendshipService

El servicio maneja todas las operaciones de Firestore:

```dart
// Enviar solicitud
await friendshipService.sendFriendRequest(receiverId);

// Aceptar solicitud (requestId es el senderId)
await friendshipService.acceptFriendRequest(senderId);

// Rechazar solicitud
await friendshipService.rejectFriendRequest(senderId);

// Verificar amistad
final areFriends = await friendshipService.checkFriendship(friendId);

// Obtener amigos (Stream)
friendshipService.getFriends().listen((friends) { ... });
```

### SocialController

El controller orquesta la UI y el servicio:

```dart
final controller = Get.find<SocialController>();

// Enviar solicitud
await controller.sendFriendRequest(userId);

// Aceptar solicitud
await controller.acceptFriendRequest(requestId);

// Verificar estado
final isPending = controller.hasPendingRequestWith(userId);
final isFriend = controller.isFriendWith(userId);
```

---

## 📊 Índices de Firestore

Los índices están configurados para optimizar las queries más comunes:

```json
{
  "indexes": [
    {
      "collectionGroup": "friends",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "friend_requests_received",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    }
    // ... otros índices
  ]
}
```

---

## 🔧 Migración de Datos

Si ya tienes datos en la estructura antigua, necesitarás migrarlos:

### Script de Migración (Firebase Functions)

```javascript
// Migrar de colecciones globales a subcolecciones
exports.migrateSocialData = functions.https.onCall(async (data, context) => {
  const batch = admin.firestore().batch();
  
  // Migrar friend_requests → users/{uid}/social/friend_requests_received
  const requests = await admin.firestore()
    .collection('friend_requests')
    .where('status', '==', 'pending')
    .get();
    
  for (const doc of requests.docs) {
    const data = doc.data();
    
    // Crear en sent
    const sentRef = admin.firestore()
      .collection('users').doc(data.sender_id)
      .collection('social').doc('friend_requests_sent')
      .collection('friend_requests_sent').doc(data.receiver_id);
    batch.set(sentRef, {
      receiver_id: data.receiver_id,
      status: data.status,
      created_at: data.created_at
    });
    
    // Crear en received
    const receivedRef = admin.firestore()
      .collection('users').doc(data.receiver_id)
      .collection('social').doc('friend_requests_received')
      .collection('friend_requests_received').doc(data.sender_id);
    batch.set(receivedRef, {
      sender_id: data.sender_id,
      status: data.status,
      created_at: data.created_at
    });
  }
  
  await batch.commit();
  return { success: true };
});
```

---

## ✅ Checklist de Despliegue

Antes de desplegar a producción:

- [ ] Desplegar reglas de Firestore: `firebase deploy --only firestore:rules`
- [ ] Desplegar índices: `firebase deploy --only firestore:indexes`
- [ ] Ejecutar script de migración si hay datos existentes
- [ ] Verificar que los contadores de `friends_count` son correctos
- [ ] Probar todos los flujos en staging
- [ ] Monitorear logs de errores en las primeras 24 horas

---

## 🐛 Debugging

### Ver estructura en Firestore Console

```
Firestore Database → 
  users → 
    [seleccionar un usuario] → 
      social → 
        friends / friend_requests_sent / friend_requests_received / blocked_users
```

### Logs útiles

El servicio incluye logs detallados con emojis:

```
✅ FriendshipService: Solicitud enviada exitosamente
🔄 FriendshipService: Aceptando solicitud de {senderId}
❌ FriendshipService: Error al aceptar solicitud: [error]
```

---

## 📚 Referencias

- [Firestore Data Model Best Practices](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Collection Group Queries](https://firebase.google.com/docs/firestore/query-data/queries#collection-group-query)

---

**Última actualización:** Octubre 2025  
**Versión de la arquitectura:** 2.0  
**Estado:** ✅ Implementado y probado

