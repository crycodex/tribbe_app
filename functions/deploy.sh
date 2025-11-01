#!/bin/bash

# 🔥 Script de Deployment para Cloud Functions - Tribbe App

echo "🚀 Iniciando deployment de Cloud Functions..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json. Ejecutar desde el directorio functions/"
    exit 1
fi

# Verificar que Firebase CLI está instalado
if ! command -v firebase &> /dev/null; then
    echo "❌ Error: Firebase CLI no está instalado"
    echo "Instalar con: npm install -g firebase-tools"
    exit 1
fi

# Verificar autenticación
echo "🔐 Verificando autenticación..."
if ! firebase projects:list &> /dev/null; then
    echo "❌ Error: No autenticado en Firebase"
    echo "Ejecutar: firebase login"
    exit 1
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

# Verificar que no hay errores de sintaxis
echo "🔍 Verificando sintaxis..."
node -c index.js

if [ $? -ne 0 ]; then
    echo "❌ Error: Errores de sintaxis en index.js"
    exit 1
fi

# Desplegar funciones
echo "🚀 Desplegando Cloud Functions..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo "✅ Deployment exitoso!"
    echo ""
    echo "📊 Funciones desplegadas:"
    echo "   - updateAllStreaks (Programada - cada día a medianoche)"
    echo "   - updateUserStreak (HTTPS - llamada manual)"
    echo "   - resetAllStreaks (HTTPS - solo testing)"
    echo ""
    echo "🔗 Ver funciones en: https://console.firebase.google.com/project/tribbe-eaf2b/functions"
    echo "📝 Ver logs con: firebase functions:log"
else
    echo "❌ Error en el deployment"
    exit 1
fi
