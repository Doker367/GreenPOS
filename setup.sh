#!/bin/bash

# Script de configuración inicial para Soft Restaurant
# Ejecuta este script después de clonar el repositorio

echo "🍽️  Soft Restaurant - Setup Script"
echo "===================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar Flutter
echo "Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado. Por favor instala Flutter primero."
    echo "https://docs.flutter.dev/get-started/install"
    exit 1
fi
print_status "Flutter encontrado: $(flutter --version | head -n 1)"
echo ""

# Verificar versión de Flutter
echo "Verificando versión de Flutter..."
FLUTTER_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+')
REQUIRED_VERSION="3.0.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then 
    print_error "Se requiere Flutter >= $REQUIRED_VERSION"
    print_error "Tu versión: $FLUTTER_VERSION"
    exit 1
fi
print_status "Versión de Flutter compatible"
echo ""

# Limpiar proyecto
echo "Limpiando proyecto anterior..."
flutter clean
print_status "Proyecto limpio"
echo ""

# Instalar dependencias
echo "Instalando dependencias de Flutter..."
flutter pub get
if [ $? -eq 0 ]; then
    print_status "Dependencias instaladas correctamente"
else
    print_error "Error al instalar dependencias"
    exit 1
fi
echo ""

# Verificar Firebase CLI
echo "Verificando Firebase CLI..."
if command -v firebase &> /dev/null; then
    print_status "Firebase CLI encontrado"
    
    # Preguntar si desea configurar Firebase
    read -p "¿Deseas configurar Firebase ahora? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Configurando Firebase..."
        flutterfire configure
        print_status "Firebase configurado"
    else
        print_warning "Recuerda configurar Firebase antes de ejecutar la app"
        echo "Ejecuta: flutterfire configure"
    fi
else
    print_warning "Firebase CLI no encontrado"
    echo "Para instalar Firebase CLI:"
    echo "  npm install -g firebase-tools"
    echo "  dart pub global activate flutterfire_cli"
    echo "Luego ejecuta: flutterfire configure"
fi
echo ""

# Generar código con build_runner
echo "Generando código con build_runner..."
print_warning "Este paso puede tardar varios minutos..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -eq 0 ]; then
    print_status "Código generado correctamente"
else
    print_error "Error al generar código"
    print_warning "Puedes ejecutar manualmente: flutter pub run build_runner build --delete-conflicting-outputs"
fi
echo ""

# Verificar análisis de código
echo "Analizando código..."
flutter analyze --no-fatal-infos
if [ $? -eq 0 ]; then
    print_status "Análisis completado sin errores críticos"
else
    print_warning "Se encontraron algunas advertencias"
fi
echo ""

# Crear archivo de configuración local (opcional)
if [ ! -f ".env" ]; then
    echo "Creando archivo .env de ejemplo..."
    cat > .env << EOF
# Configuración local - NO SUBIR A GIT
API_KEY=tu_api_key_aqui
BASE_URL=https://api.ejemplo.com
DEBUG_MODE=true
EOF
    print_status "Archivo .env creado"
    print_warning "Edita .env con tus credenciales"
fi
echo ""

# Resumen final
echo "================================================"
echo "🎉 Setup completado!"
echo "================================================"
echo ""
echo "Próximos pasos:"
echo ""
echo "1. Configurar Firebase (si no lo hiciste):"
echo "   $ flutterfire configure"
echo ""
echo "2. Ejecutar la aplicación:"
echo "   $ flutter run"
echo ""
echo "3. Para Android:"
echo "   $ flutter run -d <device-id>"
echo ""
echo "4. Para Web:"
echo "   $ flutter run -d chrome"
echo ""
echo "5. Para iOS (macOS únicamente):"
echo "   $ cd ios && pod install && cd .."
echo "   $ flutter run -d <ios-device-id>"
echo ""
echo "📚 Documentación completa en README.md"
echo ""
echo "¿Problemas? Consulta:"
echo "  - README.md"
echo "  - QUICKSTART.md"
echo "  - COMMANDS.md"
echo ""
print_status "¡Feliz desarrollo! 🚀"
