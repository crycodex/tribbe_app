# 💬 Sistema de Mensajes Temporales

Sistema completo de mensajes temporales (7 días) usando **Firebase Realtime Database** para la aplicación Tribbe.

## ✨ Características

- 📱 **Mensajes en tiempo real** con Firebase Realtime Database
- ⏰ **Expiración automática** después de 7 días
- 🔔 **Notificaciones de mensajes no leídos**
- 💬 **Conversaciones privadas** entre usuarios
- 🎨 **UI minimalista** tipo Instagram/WhatsApp
- 🔒 **Reglas de seguridad** configuradas
- 📊 **Estado de lectura** (visto/no visto)
- 🔄 **Sincronización instantánea**

## 📁 Estructura del Proyecto

```
features/messages/
├── models/
│   ├── message_model.dart          # Modelo de mensaje
│   └── conversation_model.dart     # Modelo de conversación
├── controllers/
│   ├── messages_controller.dart    # Lista de conversaciones
│   └── chat_controller.dart        # Conversación individual
└── views/
    ├── pages/
    │   ├── messages_page.dart      # Lista de conversaciones
    │   └── chat_page.dart          # Chat individual
    └── widgets/
        └── (widgets futuros)

shared/services/
└── message_service.dart            # Servicio de Realtime Database
```

## 🚀 Instalación y Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar Firebase Realtime Database

#### a) Habilitar Realtime Database en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Build** → **Realtime Database**
4. Haz clic en **Create Database**
5. Selecciona la ubicación (recomendado: us-central1)
6. Inicia en **modo de prueba** (cambiaremos las reglas después)

#### b) Desplegar Reglas de Seguridad

```bash
firebase deploy --only database
```

Las reglas están en `database.rules.json` y aseguran que:
- Solo usuarios autenticados pueden leer/escribir mensajes
- Solo pueden ver conversaciones en las que participan
- Los mensajes deben tener estructura válida
- Solo pueden enviar mensajes desde su propia cuenta

### 3. Verificar Configuración

El servicio ya está registrado en `app_router.dart`:

```dart
// Servicios de la aplicación
Get.put(MessageService(), permanent: true);
```

## 📖 Uso

### Navegar a Mensajes

Desde cualquier parte de la app:

```dart
Get.toNamed(RoutePaths.messages);
```

### Iniciar Chat con Usuario

Desde el perfil de usuario o cualquier lugar:

```dart
Get.to(
  () => ChatPage(
    otherUserId: 'userId',
    otherUsername: 'username',
    otherUserPhotoUrl: 'photoUrl',
    otherUserDisplayName: 'Display Name',
  ),
);
```

### Acceso desde UserProfilePage

Ya está integrado. El botón "Mensaje" abre el chat directamente.

## 🗄️ Estructura de Datos

### Firebase Realtime Database

```
/messages
  /{conversationId}
    /{messageId}
      - id: string
      - conversationId: string
      - senderId: string
      - senderUsername: string
      - senderPhotoUrl: string?
      - receiverId: string
      - text: string
      - timestamp: number
      - isRead: boolean
      - expiresAt: number (timestamp + 7 días)

/conversations
  /{userId}
    /{conversationId}
      - id: string
      - userId: string
      - otherUserId: string
      - otherUserUsername: string
      - otherUserPhotoUrl: string?
      - otherUserDisplayName: string?
      - lastMessage: string
      - lastMessageTimestamp: number
      - lastMessageSenderId: string
      - unreadCount: number
      - expiresAt: number
```

### Modelo de Mensaje (MessageModel)

```dart
final message = MessageModel(
  id: 'msg123',
  conversationId: 'conv123',
  senderId: 'user1',
  senderUsername: 'juan',
  senderPhotoUrl: 'https://...',
  receiverId: 'user2',
  text: 'Hola! ¿Cómo estás?',
  timestamp: DateTime.now().millisecondsSinceEpoch,
  isRead: false,
  expiresAt: DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
);
```

### Modelo de Conversación (ConversationModel)

```dart
final conversation = ConversationModel(
  id: 'conv123',
  userId: 'user1',
  otherUserId: 'user2',
  otherUserUsername: 'maria',
  otherUserPhotoUrl: 'https://...',
  otherUserDisplayName: 'María García',
  lastMessage: 'Nos vemos mañana!',
  lastMessageTimestamp: DateTime.now().millisecondsSinceEpoch,
  lastMessageSenderId: 'user2',
  unreadCount: 3,
  expiresAt: DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
);
```

## 🎯 API del MessageService

### Obtener Conversaciones (Stream)

```dart
final messageService = Get.find<MessageService>();
messageService.getConversationsStream(userId).listen((conversations) {
  print('Conversaciones: ${conversations.length}');
});
```

### Obtener Mensajes de una Conversación (Stream)

```dart
messageService.getMessagesStream(conversationId).listen((messages) {
  print('Mensajes: ${messages.length}');
});
```

### Enviar Mensaje

```dart
await messageService.sendMessage(
  conversationId: conversationId,
  senderId: currentUserId,
  senderUsername: 'juan',
  senderPhotoUrl: 'https://...',
  receiverId: otherUserId,
  receiverUsername: 'maria',
  receiverPhotoUrl: 'https://...',
  receiverDisplayName: 'María García',
  text: 'Hola!',
);
```

### Marcar Mensajes como Leídos

```dart
await messageService.markMessagesAsRead(
  conversationId: conversationId,
  userId: currentUserId,
);
```

### Crear ID de Conversación

```dart
final conversationId = messageService.createConversationId(
  'userId1',
  'userId2',
);
// Siempre devuelve el mismo ID sin importar el orden
```

### Limpiar Mensajes Expirados

```dart
await messageService.cleanExpiredMessages();
// Elimina todos los mensajes cuyo expiresAt < ahora
```

### Obtener Total de No Leídos (Stream)

```dart
messageService.getTotalUnreadCountStream(userId).listen((count) {
  print('Mensajes no leídos: $count');
});
```

## 🎨 UI Personalización

### MessagesPage

Características:
- Lista de conversaciones ordenadas por fecha
- Badge de mensajes no leídos
- Deslizar para eliminar conversaciones
- Pull to refresh
- Indicador de expiración (días restantes)
- Estado vacío personalizado

### ChatPage

Características:
- Burbujas de mensaje estilo WhatsApp
- Indicadores de leído/no leído
- Scroll automático al final
- Separadores de fecha
- Avatar del remitente
- Indicador de expiración en el header
- Campo de texto con botón de envío
- Loading states

## ⚙️ Configuración Avanzada

### Cambiar Tiempo de Expiración

En `message_model.dart`:

```dart
/// Calcular tiempo de expiración (cambiar 7 días)
static int calculateExpiresAt() {
  return DateTime.now().millisecondsSinceEpoch +
      (7 * 24 * 60 * 60 * 1000); // Modificar aquí
}
```

### Programar Limpieza Automática

Puedes usar Firebase Functions para limpiar mensajes expirados:

```javascript
// functions/index.js
exports.cleanExpiredMessages = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = Date.now();
    const messagesRef = admin.database().ref('messages');
    const snapshot = await messagesRef.once('value');
    
    // Limpiar mensajes expirados
    // ...
  });
```

O llamar manualmente desde la app:

```dart
// En initDependencies o al iniciar la app
final messageService = Get.find<MessageService>();
await messageService.cleanExpiredMessages();
```

## 🔒 Seguridad

Las reglas de seguridad aseguran:

1. **Autenticación requerida**: Solo usuarios autenticados pueden acceder
2. **Privacidad**: Solo puedes ver mensajes donde eres participante
3. **Validación de datos**: Los mensajes deben tener estructura correcta
4. **Anti-suplantación**: Solo puedes enviar mensajes desde tu cuenta
5. **Longitud de texto**: Máximo 5000 caracteres por mensaje
6. **Expiración válida**: Los mensajes deben expirar en el futuro

## 📊 Métricas y Analytics

Para rastrear uso de mensajes, puedes agregar analytics:

```dart
// En sendMessage
FirebaseAnalytics.instance.logEvent(
  name: 'message_sent',
  parameters: {
    'conversation_id': conversationId,
    'has_photo': message.senderPhotoUrl != null,
  },
);
```

## 🐛 Troubleshooting

### Los mensajes no se sincronizan

1. Verifica que Realtime Database esté habilitado en Firebase Console
2. Verifica que las reglas estén desplegadas: `firebase deploy --only database`
3. Verifica que el usuario esté autenticado

### Error: Permission Denied

- Las reglas de seguridad están bloqueando el acceso
- Verifica que `auth != null` en las reglas
- Verifica que el usuario esté intentando acceder a sus propios datos

### Los mensajes no se eliminan después de 7 días

- La limpieza debe ser manual o con Cloud Functions
- Llama a `cleanExpiredMessages()` periódicamente
- O implementa Cloud Function programada

## 🚀 Mejoras Futuras

- [ ] Mensajes con imágenes
- [ ] Mensajes de voz
- [ ] Typing indicators (usuario escribiendo...)
- [ ] Mensajes con reacciones
- [ ] Búsqueda de mensajes
- [ ] Exportar conversación
- [ ] Notificaciones push con FCM
- [ ] Múltiples dispositivos (sincronización)
- [ ] Mensajes de sistema (ej: "X empezó a seguirte")
- [ ] Responder a mensajes específicos
- [ ] Mensajes eliminados por ambos lados

## 📝 Licencia

Este módulo es parte de la aplicación Tribbe.

