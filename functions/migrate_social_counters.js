/**
 * Script de migración para inicializar contadores sociales
 * 
 * Este script actualiza todos los documentos de usuarios que:
 * - No tienen followers_count o following_count
 * - Tienen valores negativos en estos campos
 * 
 * Ejecutar con: node migrate_social_counters.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Necesitas descargar este archivo de Firebase Console

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateSocialCounters() {
  console.log('🚀 Iniciando migración de contadores sociales...\n');
  
  try {
    // Obtener todos los usuarios
    const usersSnapshot = await db.collection('users').get();
    console.log(`📊 Total de usuarios encontrados: ${usersSnapshot.size}\n`);
    
    let updatedCount = 0;
    let batch = db.batch();
    let batchCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userId = userDoc.id;
      
      const updates = {};
      let needsUpdate = false;
      
      // Verificar y corregir followers_count
      if (userData.followers_count === undefined || 
          userData.followers_count === null || 
          userData.followers_count < 0) {
        updates.followers_count = 0;
        needsUpdate = true;
        console.log(`✏️  Usuario ${userId}: Inicializando followers_count a 0`);
      }
      
      // Verificar y corregir following_count
      if (userData.following_count === undefined || 
          userData.following_count === null || 
          userData.following_count < 0) {
        updates.following_count = 0;
        needsUpdate = true;
        console.log(`✏️  Usuario ${userId}: Inicializando following_count a 0`);
      }
      
      // Verificar y corregir friends_count
      if (userData.friends_count === undefined || 
          userData.friends_count === null || 
          userData.friends_count < 0) {
        updates.friends_count = 0;
        needsUpdate = true;
        console.log(`✏️  Usuario ${userId}: Inicializando friends_count a 0`);
      }
      
      // Si necesita actualización, agregar al batch
      if (needsUpdate) {
        batch.update(userDoc.ref, updates);
        updatedCount++;
        batchCount++;
        
        // Firestore permite máximo 500 operaciones por batch
        if (batchCount >= 500) {
          console.log(`\n⏳ Ejecutando batch de ${batchCount} actualizaciones...`);
          await batch.commit();
          console.log('✅ Batch ejecutado exitosamente\n');
          batch = db.batch();
          batchCount = 0;
        }
      }
    }
    
    // Ejecutar el último batch si quedan operaciones
    if (batchCount > 0) {
      console.log(`\n⏳ Ejecutando último batch de ${batchCount} actualizaciones...`);
      await batch.commit();
      console.log('✅ Batch ejecutado exitosamente\n');
    }
    
    console.log(`\n✅ Migración completada exitosamente!`);
    console.log(`📊 Total de usuarios actualizados: ${updatedCount}`);
    console.log(`📊 Total de usuarios sin cambios: ${usersSnapshot.size - updatedCount}\n`);
    
  } catch (error) {
    console.error('❌ Error durante la migración:', error);
    throw error;
  }
}

// Ejecutar la migración
migrateSocialCounters()
  .then(() => {
    console.log('🎉 Migración finalizada');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Error fatal:', error);
    process.exit(1);
  });

