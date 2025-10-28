const functions = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function para actualizar rachas de todos los usuarios
 * Se ejecuta cada día a las 00:00 UTC para verificar y actualizar rachas
 */
exports.updateAllStreaks = functions.scheduler.onSchedule({
  schedule: '0 0 * * *', // Cada día a medianoche UTC
  timeZone: 'UTC',
  memory: '256MiB',
  timeoutSeconds: 540,
}, async (event) => {
    console.log('🔥 Iniciando actualización de rachas...');
    
  try {
    const db = admin.firestore();
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
      console.log('No hay usuarios para procesar');
      return null;
    }
    
    console.log(`📊 Procesando ${usersSnapshot.size} usuarios...`);
    
    let processedCount = 0;
    let updatedCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      try {
        // Obtener la racha del usuario
        const streakRef = db
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .doc('current_streak');
        
        const streakDoc = await streakRef.get();
        
        if (!streakDoc.exists) {
          console.log(`⚠️ Usuario ${userId} no tiene racha, saltando...`);
          continue;
        }
        
        const streakData = streakDoc.data();
        const currentStreak = streakData.current_streak || 0;
        const longestStreak = streakData.longest_streak || 0;
        const weeklyStreak = streakData.weekly_streak || [false, false, false, false, false, false, false];
        
        // Parsear la fecha del último entrenamiento
        let lastWorkoutDate = null;
        if (streakData.last_workout_date) {
          if (typeof streakData.last_workout_date === 'string') {
            lastWorkoutDate = new Date(streakData.last_workout_date);
          } else if (streakData.last_workout_date.toDate) {
            lastWorkoutDate = streakData.last_workout_date.toDate();
          }
        }
        
        if (!lastWorkoutDate) {
          console.log(`⚠️ Usuario ${userId} no tiene fecha de último entrenamiento`);
          continue;
        }
        
        // Calcular días desde el último entrenamiento
        const now = new Date();
        now.setHours(0, 0, 0, 0); // Inicio del día actual
        lastWorkoutDate.setHours(0, 0, 0, 0); // Inicio del día del último entrenamiento
        
        const daysSinceLastWorkout = Math.floor(
          (now - lastWorkoutDate) / (1000 * 60 * 60 * 24)
        );
        
        console.log(`👤 Usuario ${userId}:`);
        console.log(`   - Racha actual: ${currentStreak}`);
        console.log(`   - Último entrenamiento: ${lastWorkoutDate.toISOString()}`);
        console.log(`   - Días desde último entrenamiento: ${daysSinceLastWorkout}`);
        
        let newCurrentStreak = currentStreak;
        let needsUpdate = false;
        
        // Lógica de actualización de racha
        if (daysSinceLastWorkout === 0) {
          // Entrenó hoy: no hacer nada
          console.log(`   ✅ Entrenó hoy, manteniendo racha`);
        } else if (daysSinceLastWorkout === 1) {
          // Entrenó ayer: no hacer nada (ya debería haberse actualizado)
          console.log(`   ✅ Entrenó ayer, racha ya actualizada`);
        } else if (daysSinceLastWorkout >= 2 && daysSinceLastWorkout <= 3) {
          // Perdió 1-2 días: mantener la racha actual
          console.log(`   ⚠️ Perdió ${daysSinceLastWorkout - 1} días, manteniendo racha`);
        } else if (daysSinceLastWorkout > 3) {
          // Perdió más de 3 días: resetear la racha a 0
          newCurrentStreak = 0;
          needsUpdate = true;
          console.log(`   😔 Perdió ${daysSinceLastWorkout - 1} días, reseteando racha: ${currentStreak} → 0`);
        }
        
        // Actualizar racha más larga si es necesario
        const newLongestStreak = newCurrentStreak > longestStreak 
          ? newCurrentStreak 
          : longestStreak;
        
        if (needsUpdate) {
          // Actualizar el documento
          await streakRef.update({
            current_streak: newCurrentStreak,
            longest_streak: newLongestStreak,
            updated_at: new Date().toISOString(),
          });
          
          updatedCount++;
          console.log(`   📝 Racha actualizada: ${currentStreak} → ${newCurrentStreak}`);
        }
        
        processedCount++;
        
      } catch (error) {
        console.error(`❌ Error procesando usuario ${userId}:`, error);
      }
    }
    
    console.log(`📊 Resumen:`);
    console.log(`   - Usuarios procesados: ${processedCount}`);
    console.log(`   - Usuarios actualizados: ${updatedCount}`);
    
    return {
      processed: processedCount,
      updated: updatedCount,
      timestamp: new Date().toISOString(),
    };
    
  } catch (error) {
    console.error('❌ Error en actualización de rachas:', error);
    throw error;
  }
  });

/**
 * Cloud Function para actualizar la racha de un usuario específico
 * Se puede llamar manualmente o desde la app
 */
exports.updateUserStreak = functions.https.onCall({
  memory: '256MiB',
  timeoutSeconds: 60,
}, async (request) => {
  // Verificar autenticación
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  const userId = request.auth.uid;
  const db = admin.firestore();
  
  try {
    console.log(`🔥 Actualizando racha para usuario ${userId}...`);
    
    // Obtener la racha del usuario
    const streakRef = db
      .collection('users')
      .doc(userId)
      .collection('streaks')
      .doc('current_streak');
    
    const streakDoc = await streakRef.get();
    
    if (!streakDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Racha no encontrada');
    }
    
    const streakData = streakDoc.data();
    const currentStreak = streakData.current_streak || 0;
    const longestStreak = streakData.longest_streak || 0;
    
    // Parsear la fecha del último entrenamiento
    let lastWorkoutDate = null;
    if (streakData.last_workout_date) {
      if (typeof streakData.last_workout_date === 'string') {
        lastWorkoutDate = new Date(streakData.last_workout_date);
      } else if (streakData.last_workout_date.toDate) {
        lastWorkoutDate = streakData.last_workout_date.toDate();
      }
    }
    
    if (!lastWorkoutDate) {
      throw new functions.https.HttpsError('invalid-argument', 'No hay fecha de último entrenamiento');
    }
    
    // Calcular días desde el último entrenamiento
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    lastWorkoutDate.setHours(0, 0, 0, 0);
    
    const daysSinceLastWorkout = Math.floor(
      (now - lastWorkoutDate) / (1000 * 60 * 60 * 24)
    );
    
    console.log(`   - Racha actual: ${currentStreak}`);
    console.log(`   - Días desde último entrenamiento: ${daysSinceLastWorkout}`);
    
    let newCurrentStreak = currentStreak;
    let needsUpdate = false;
    
    // Aplicar la misma lógica que en la función principal
    if (daysSinceLastWorkout === 0) {
      // Entrenó hoy
      console.log('   ✅ Entrenó hoy, manteniendo racha');
    } else if (daysSinceLastWorkout === 1) {
      // Entrenó ayer
      console.log('   ✅ Entrenó ayer, racha ya actualizada');
    } else if (daysSinceLastWorkout >= 2 && daysSinceLastWorkout <= 3) {
      // Perdió 1-2 días: mantener
      console.log(`   ⚠️ Perdió ${daysSinceLastWorkout - 1} días, manteniendo racha`);
    } else if (daysSinceLastWorkout > 3) {
      // Perdió más de 3 días: resetear
      newCurrentStreak = 0;
      needsUpdate = true;
      console.log(`   😔 Perdió ${daysSinceLastWorkout - 1} días, reseteando racha`);
    }
    
    const newLongestStreak = newCurrentStreak > longestStreak 
      ? newCurrentStreak 
      : longestStreak;
    
    if (needsUpdate) {
      await streakRef.update({
        current_streak: newCurrentStreak,
        longest_streak: newLongestStreak,
        updated_at: new Date().toISOString(),
      });
      
      console.log(`✅ Racha actualizada: ${currentStreak} → ${newCurrentStreak}`);
      
      return {
        success: true,
        oldStreak: currentStreak,
        newStreak: newCurrentStreak,
        daysSinceLastWorkout,
      };
    }
    
    return {
      success: true,
      message: 'No se requiere actualización',
      currentStreak,
      daysSinceLastWorkout,
    };
    
  } catch (error) {
    console.error(`❌ Error actualizando racha para usuario ${userId}:`, error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Cloud Function para resetear todas las rachas (solo para testing)
 */
exports.resetAllStreaks = functions.https.onCall({
  memory: '256MiB',
  timeoutSeconds: 120,
}, async (request) => {
  // Solo permitir en desarrollo
  if (process.env.NODE_ENV === 'production') {
    throw new functions.https.HttpsError('permission-denied', 'No permitido en producción');
  }
  
  console.log('🔄 Reseteando todas las rachas...');
  
  try {
    const db = admin.firestore();
    const usersSnapshot = await db.collection('users').get();
    
    const batch = db.batch();
    let resetCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const streakRef = db
        .collection('users')
        .doc(userId)
        .collection('streaks')
        .doc('current_streak');
      
      batch.update(streakRef, {
        current_streak: 0,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      resetCount++;
    }
    
    await batch.commit();
    
    console.log(`✅ ${resetCount} rachas reseteadas`);
    
    return {
      success: true,
      resetCount,
    };
    
  } catch (error) {
    console.error('❌ Error reseteando rachas:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Cloud Function para limpiar mensajes expirados (7 días)
 * Se ejecuta cada día a las 02:00 UTC para limpiar mensajes antiguos
 */
exports.cleanExpiredMessages = functions.scheduler.onSchedule({
  schedule: '0 2 * * *', // Cada día a las 2:00 AM UTC
  timeZone: 'UTC',
  memory: '512MiB',
  timeoutSeconds: 540,
}, async (event) => {
  console.log('🧹 Iniciando limpieza de mensajes expirados...');
  
  try {
    const db = admin.database();
    const now = Date.now();
    
    // Limpiar mensajes expirados
    console.log('📨 Limpiando mensajes expirados...');
    const messagesRef = db.ref('messages');
    const messagesSnapshot = await messagesRef.once('value');
    
    if (!messagesSnapshot.exists()) {
      console.log('No hay mensajes para procesar');
      return null;
    }
    
    const messagesData = messagesSnapshot.val();
    let deletedMessagesCount = 0;
    let processedConversationsCount = 0;
    
    // Procesar cada conversación
    for (const [conversationId, conversationMessages] of Object.entries(messagesData)) {
      if (!conversationMessages || typeof conversationMessages !== 'object') {
        continue;
      }
      
      processedConversationsCount++;
      console.log(`📞 Procesando conversación: ${conversationId}`);
      
      const updates = {};
      let conversationHasExpiredMessages = false;
      
      // Verificar cada mensaje en la conversación
      for (const [messageId, messageData] of Object.entries(conversationMessages)) {
        if (!messageData || typeof messageData !== 'object') {
          continue;
        }
        
        const expiresAt = messageData.expiresAt;
        if (expiresAt && expiresAt < now) {
          // Marcar mensaje para eliminación
          updates[`messages/${conversationId}/${messageId}`] = null;
          deletedMessagesCount++;
          conversationHasExpiredMessages = true;
          console.log(`  🗑️ Mensaje expirado eliminado: ${messageId}`);
        }
      }
      
      // Si la conversación tiene mensajes expirados, verificar si quedan mensajes
      if (conversationHasExpiredMessages) {
        const remainingMessages = Object.keys(conversationMessages).filter(
          messageId => !updates[`messages/${conversationId}/${messageId}`]
        );
        
        // Si no quedan mensajes, eliminar la conversación completa
        if (remainingMessages.length === 0) {
          updates[`messages/${conversationId}`] = null;
          console.log(`  🗑️ Conversación vacía eliminada: ${conversationId}`);
        }
      }
      
      // Aplicar actualizaciones si hay cambios
      if (Object.keys(updates).length > 0) {
        await db.ref().update(updates);
        console.log(`  ✅ ${Object.keys(updates).length} cambios aplicados`);
      }
    }
    
    // Limpiar conversaciones vacías
    console.log('💬 Limpiando conversaciones vacías...');
    const conversationsRef = db.ref('conversations');
    const conversationsSnapshot = await conversationsRef.once('value');
    
    if (conversationsSnapshot.exists()) {
      const conversationsData = conversationsSnapshot.val();
      let deletedConversationsCount = 0;
      
      for (const [userId, userConversations] of Object.entries(conversationsData)) {
        if (!userConversations || typeof userConversations !== 'object') {
          continue;
        }
        
        const updates = {};
        
        for (const [conversationId, conversationData] of Object.entries(userConversations)) {
          if (!conversationData || typeof conversationData !== 'object') {
            continue;
          }
          
          const expiresAt = conversationData.expiresAt;
          if (expiresAt && expiresAt < now) {
            // Verificar si la conversación aún existe en messages
            const messageRef = db.ref(`messages/${conversationId}`);
            const messageSnapshot = await messageRef.once('value');
            
            if (!messageSnapshot.exists()) {
              updates[`conversations/${userId}/${conversationId}`] = null;
              deletedConversationsCount++;
              console.log(`  🗑️ Conversación expirada eliminada: ${conversationId} del usuario ${userId}`);
            }
          }
        }
        
        // Aplicar actualizaciones si hay cambios
        if (Object.keys(updates).length > 0) {
          await db.ref().update(updates);
        }
      }
      
      console.log(`📊 Conversaciones eliminadas: ${deletedConversationsCount}`);
    }
    
    console.log(`📊 Resumen de limpieza:`);
    console.log(`   - Conversaciones procesadas: ${processedConversationsCount}`);
    console.log(`   - Mensajes eliminados: ${deletedMessagesCount}`);
    console.log(`   - Timestamp: ${new Date().toISOString()}`);
    
    return {
      processedConversations: processedConversationsCount,
      deletedMessages: deletedMessagesCount,
      timestamp: new Date().toISOString(),
    };
    
  } catch (error) {
    console.error('❌ Error en limpieza de mensajes:', error);
    throw error;
  }
});

/**
 * Cloud Function para limpiar mensajes expirados manualmente
 * Se puede llamar desde la app o manualmente
 */
exports.cleanExpiredMessagesManual = functions.https.onCall({
  memory: '512MiB',
  timeoutSeconds: 120,
}, async (request) => {
  // Verificar autenticación
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  console.log(`🧹 Limpieza manual de mensajes expirados por usuario ${request.auth.uid}...`);
  
  try {
    const db = admin.database();
    const now = Date.now();
    
    // Limpiar mensajes expirados
    const messagesRef = db.ref('messages');
    const messagesSnapshot = await messagesRef.once('value');
    
    if (!messagesSnapshot.exists()) {
      return {
        success: true,
        message: 'No hay mensajes para procesar',
        deletedMessages: 0,
        processedConversations: 0,
      };
    }
    
    const messagesData = messagesSnapshot.val();
    let deletedMessagesCount = 0;
    let processedConversationsCount = 0;
    
    // Procesar cada conversación
    for (const [conversationId, conversationMessages] of Object.entries(messagesData)) {
      if (!conversationMessages || typeof conversationMessages !== 'object') {
        continue;
      }
      
      processedConversationsCount++;
      
      const updates = {};
      let conversationHasExpiredMessages = false;
      
      // Verificar cada mensaje en la conversación
      for (const [messageId, messageData] of Object.entries(conversationMessages)) {
        if (!messageData || typeof messageData !== 'object') {
          continue;
        }
        
        const expiresAt = messageData.expiresAt;
        if (expiresAt && expiresAt < now) {
          // Marcar mensaje para eliminación
          updates[`messages/${conversationId}/${messageId}`] = null;
          deletedMessagesCount++;
          conversationHasExpiredMessages = true;
        }
      }
      
      // Si la conversación tiene mensajes expirados, verificar si quedan mensajes
      if (conversationHasExpiredMessages) {
        const remainingMessages = Object.keys(conversationMessages).filter(
          messageId => !updates[`messages/${conversationId}/${messageId}`]
        );
        
        // Si no quedan mensajes, eliminar la conversación completa
        if (remainingMessages.length === 0) {
          updates[`messages/${conversationId}`] = null;
        }
      }
      
      // Aplicar actualizaciones si hay cambios
      if (Object.keys(updates).length > 0) {
        await db.ref().update(updates);
      }
    }
    
    console.log(`✅ Limpieza manual completada: ${deletedMessagesCount} mensajes eliminados`);
    
    return {
      success: true,
      deletedMessages: deletedMessagesCount,
      processedConversations: processedConversationsCount,
      timestamp: new Date().toISOString(),
    };
    
  } catch (error) {
    console.error(`❌ Error en limpieza manual de mensajes:`, error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
