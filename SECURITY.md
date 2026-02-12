# 🔐 SEGURIDAD DE DATOS SENSIBLES - GreenPOS

## Archivos Protegidos

### ❌ NUNCA subir a Git:
- `.env` - Variables de entorno
- `google-services.json` - Configuración Firebase Android
- `GoogleService-Info.plist` - Configuración Firebase iOS  
- `*.keystore`, `*.jks` - Certificados Android
- `key.properties` - Propiedades de firma Android
- `api_keys.dart` - Claves API hardcodeadas
- `secrets.dart` - Secretos de la aplicación

### ✅ SÍ incluir en Git:
- `.env.example` - Plantilla de variables
- `app_config.dart` - Clase de configuración
- Archivos de build (`build/`, `.dart_tool/`)

## Configuración Segura

### 1. Variables de Entorno
```bash
# Crear archivo de configuración local
cp .env.example .env

# Editar con tus valores reales
nano .env
```

### 2. Firebase
```bash
# Colocar configuración en:
android/app/google-services.json  # Android
ios/Runner/GoogleService-Info.plist  # iOS
```

### 3. Certificados Android
```bash
# Generar keystore (solo producción)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Crear key.properties
android/key.properties
```

## Mejores Prácticas

1. **Usar flutter_dotenv** para variables de entorno
2. **Separar configs** por ambiente (dev/prod)
3. **Rotar claves** periódicamente
4. **Verificar .gitignore** antes de cada commit
5. **No hardcodear** secretos en código

## Comando de Verificación
```bash
# Verificar archivos no rastreados
git status --ignored

# Verificar que secretos no estén en historial
git log --all --full-history -- "*.env" "*.keystore"
```