#!/bin/bash

# 🚀 Script de Prueba Rápida para Linux
# Este script te ayuda a probar Soft Restaurant en Linux

set -e

echo "🍽️  SOFT RESTAURANT - GUÍA DE PRUEBA EN LINUX"
echo "=============================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar sistema
echo "📋 Verificando tu sistema..."
echo ""

# Verificar Flutter
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅ Flutter instalado:${NC}"
    flutter --version | head -1
    FLUTTER_OK=true
else
    echo -e "${RED}❌ Flutter NO instalado${NC}"
    FLUTTER_OK=false
fi

echo ""

# Verificar Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker instalado${NC}"
    DOCKER_OK=true
else
    echo -e "${YELLOW}⚠️  Docker NO instalado${NC}"
    DOCKER_OK=false
fi

echo ""
echo "=============================================="
echo ""

# Mostrar opciones
if [ "$FLUTTER_OK" = true ]; then
    echo -e "${GREEN}OPCIÓN 1: Ejecutar con Flutter (RECOMENDADO)${NC}"
    echo "-------------------------------------------"
    echo ""
    echo "Ejecuta estos comandos:"
    echo ""
    echo "  cd /home/doker/Descargas/Soft-restaurant"
    echo "  flutter pub get"
    echo "  flutter pub run build_runner build --delete-conflicting-outputs"
    echo ""
    echo "Luego elige tu plataforma:"
    echo ""
    echo "  # Para Chrome (web)"
    echo "  flutter run -d chrome"
    echo ""
    echo "  # Para Linux desktop"
    echo "  flutter run -d linux"
    echo ""
    echo "  # Para Android (requiere emulador o dispositivo)"
    echo "  flutter run -d android"
    echo ""
    
elif [ "$DOCKER_OK" = true ]; then
    echo -e "${GREEN}OPCIÓN 2: Ejecutar con Docker${NC}"
    echo "-------------------------------------------"
    echo ""
    echo "  cd /home/doker/Descargas/Soft-restaurant"
    echo "  docker-compose up"
    echo ""
    echo "  Luego abre: http://localhost:8080"
    echo ""
    
else
    echo -e "${YELLOW}NECESITAS INSTALAR FLUTTER O DOCKER${NC}"
    echo "-------------------------------------------"
    echo ""
    echo "OPCIÓN A - Instalar Flutter:"
    echo ""
    echo "  # 1. Descargar Flutter"
    echo "  cd ~"
    echo "  wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz"
    echo ""
    echo "  # 2. Extraer"
    echo "  tar xf flutter_linux_3.27.1-stable.tar.xz"
    echo ""
    echo "  # 3. Agregar al PATH"
    echo "  echo 'export PATH=\"\$HOME/flutter/bin:\$PATH\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo ""
    echo "  # 4. Instalar dependencias"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev"
    echo ""
    echo "  # 5. Verificar"
    echo "  flutter doctor"
    echo ""
    echo "OPCIÓN B - Instalar Docker:"
    echo ""
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y docker.io docker-compose"
    echo "  sudo usermod -aG docker \$USER"
    echo "  newgrp docker"
    echo ""
fi

echo ""
echo "=============================================="
echo ""
echo "📚 RECURSOS ADICIONALES:"
echo ""
echo "  - Documentación completa: README.md"
echo "  - Guía visual: VISUAL_GUIDE.md"
echo "  - Inicio rápido: QUICKSTART.md"
echo ""
echo "=============================================="
echo ""

# Si Flutter está instalado, preguntar si quiere ejecutar ahora
if [ "$FLUTTER_OK" = true ]; then
    read -p "¿Quieres ejecutar la app ahora? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        echo ""
        echo "🚀 Iniciando aplicación..."
        echo ""
        
        # Instalar dependencias
        echo "📦 Instalando dependencias..."
        flutter pub get
        
        echo ""
        echo "🔨 Generando código..."
        flutter pub run build_runner build --delete-conflicting-outputs
        
        echo ""
        echo "🌐 Abriendo en Chrome..."
        echo ""
        echo "IMPORTANTE: Necesitas configurar Firebase primero"
        echo "Presiona Ctrl+C si no lo has hecho"
        sleep 3
        
        flutter run -d chrome
    fi
fi
